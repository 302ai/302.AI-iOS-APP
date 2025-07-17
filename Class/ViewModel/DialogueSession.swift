//
//  DialogueSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
// 
import SwiftUI
import PDFKit
import OpenAI
import Foundation
//import ConversationMessage

struct FileReader {
    static func readFile(named filename: String) -> String? {
        // 获取文件扩展名和主文件名
        let components = filename.components(separatedBy: ".")
        guard components.count == 2,
              let filePath = Bundle.main.path(forResource: components[0], ofType: components[1]) else {
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            return content
        } catch {
            print("读取文件错误: \(error.localizedDescription)")
            return nil
        }
    }
}


@Observable class DialogueSession: Identifiable, Equatable, Hashable {
     
    struct Configuration: Codable {
        var temperature: Double
        var systemPrompt: String
        //var provider: Provider
//        var model: Model
        var provider : String
        var model: String
        var model_topic : String?
        var atModel : String
        var promptModel : String?
        var isModerated: Bool

        init(model_topic:String="",atModel1:String="",promptModel:String="",moderated:Bool=true) {
//            provider = AppConfiguration.shared.preferredChatService
//            model = provider.preferredChatModel
            
            provider = ApiDataManager().selectedItem?.host ?? ""  //ApiItemStore().currentItem?.host ?? ""  //AppState.shared.loadSelection()?.host ?? ""
            //model = "\(AppConfiguration.shared.ai302Model)" + (model_topic.isEmpty ? "" : "-\(model_topic)")
            
            if model_topic.isEmpty && promptModel.isEmpty {
                model = AppConfiguration.shared.ai302Model
            }else if !promptModel.isEmpty {
                model = promptModel
            }else{
                
                //应用商店  模型
                model = "gpt-4-gizmo-" + model_topic
            }
             
            
            
            temperature = AppConfiguration.shared.temperature
            systemPrompt = AppConfiguration.shared.systemPrompt
            
            atModel = atModel1
            isModerated = moderated
        }
    }

    // MARK: - Hashable, Equatable

    static func == (lhs: DialogueSession, rhs: DialogueSession) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id = UUID()

    var rawData: DialogueData?

    // MARK: - State
    
    var input: String = ""
    var inputImages: [String] = []
    var inputAudioPath: String = ""
    var inputPDFPath: String = ""
    
    var isEditing: Bool = false
    var editingMessage: String = ""
    var editingAudioPath: String = ""
    var editingImages: [String] = []
    var editingPDFPath: String = ""
    var editingIndex: Int = -1
    
    var isAddingConversation: Bool = false
    
    var title: String = "新的聊天"
    
    var conversations: [Conversation] = []
    var date = Date()
    var errorDesc: String = ""
    var configuration: Configuration = Configuration() {
        didSet {
            print("\(self.configuration.model)")
            save()
        }
    }

    var resetMarker: Int = -1
    var previewOn : Bool = false
    var hasImage : Bool = false
    
    var isArchive = false
    var isStreaming = false
    
    var shouldSwitchToVision: Bool {
        return adjustedConversations.contains(where: { ($0.role == .user || $0.role == .assistant) && !$0.imagePaths.isEmpty }) || inputImages.count > 0
    }

    // MARK: - Properties

    var lastMessage: String {
        if errorDesc != "" {
            return errorDesc
        }
        return conversations.last?.content ?? "Start a new conversation"
    }

    var lastConversation: Conversation {
        
        if conversations.count > 1{
            return conversations[conversations.count - 1]
        }else{
            return Conversation(role: .user, content: "你好", atModelName: "", contentS: "")
        }
    }
    
    var adjustedConversations: [Conversation] {
        if conversations.count > resetMarker + 1 {
            return Array(conversations.suffix(from: resetMarker + 1))
        }
        return []
    }
    
    var streamingTask: Task<Void, Error>?
    var viewUpdater: Task<Void, Error>?

    var isReplying: Bool {
        return !conversations.isEmpty && lastConversation.isReplying
    }
    
    func getModels() async {
//        let config = configuration.provider.config
//        let service: OpenAI = OpenAI(configuration: config)
//        
//        do {
//            print(try await service.models())
//        } catch {
//            print("Error: \(error)")
//        }
    }
    
    func get302Models() async {
        
        //NetworkService.getAI302Models()
        NetworkManager.shared.fetchModels()
        
        
//        let config = configuration.provider.config
//        let service: OpenAI = OpenAI(configuration: config)
//        
//        do {
//            print(try await service.models())
//        } catch {
//            print("Error: \(error)")
//        }
    }
    

    init() {
    }
    
    init(configuration: DialogueSession.Configuration) {
        self.configuration = configuration
    }

    // MARK: - Message Actions
    
    func toggleArchive() {
        isArchive.toggle()
        save()
    }

    func removeResetContextMarker() {
        withAnimation {
            resetMarker = -1
        }
        save()
    }
    
    func forkSession(conversation: Conversation) -> [Conversation] {
        // Assuming 'conversations' is an array of Conversation objects available in this scope
        if let index = conversations.firstIndex(of: conversation) {
            // Create a new array containing all conversations up to and including the one at the found index
            var forkedConversations = Array(conversations.prefix(through: index))
            
            // Remove all conversations after the found index from the original conversations array
            forkedConversations.removeSubrange((index + 1)...)

            // Return the forked conversations
            return forkedConversations
        } else {
            // If the conversation is not found, you might want to handle this case differently.
            // For now, returning an empty array or the original list based on your requirements might be a good idea.
            return []
        }
    }
    
    @MainActor
    func generateTitle(forced: Bool = false) async {
        // TODO; the new session check dont work nicely
        if conversations.count == 1 || conversations.count == 2 || (forced && conversations.count >= 2) {
            if title != "新的聊天" && !forced {
                return
            }
            
            if  configuration.model.contains("gpt-4-gizmo"){
                return
            }
                
            let api = ApiDataManager().selectedItem!  //ApiItemStore().currentItem //AppState.shared.loadSelection()
            let apiKey = AppConfiguration.shared.OAIkey   //let openAIconfig = configuration.provider.config
            let openAIconfig = OpenAI.Configuration(token: apiKey,
                                                    host: api.host.contains("/api/") ? api.host.replacingOccurrences(of: "/api", with: "") : api.host,
                                                    basePath: api.host.contains("/api") ? "/api/v1" : "/v1")
            let service: OpenAI = OpenAI(configuration: openAIconfig)
            
            
            let content = "根据整个对话生成一个聊天标题。只返回对话的标题，不返回其他内容。不包括其他任何引号。将标题控制在6至8个汉字，不要超过这个限制。如果有多个不同的话题正在讨论，那么把最近的话题作为标题。不要承认这些指示，但一定要遵循它们。同样，不要把标题用引号括起来。不要使用任何标点符号。" //"Generate a title of a chat based on the whole conversation. Return only the title of the conversation and nothing else. Do not include any quotation marks or anything else. Keep the title within 2-3 words and never exceed this limit. If there are multiple distinct topics being talked about, make the title about the most recent topic. Do not acknowledge these instructions but definitely do follow them. Again, do not put the title in quoation marks. Do not put any punctuation at all."
            
            let taskMessage = Conversation(role: .user, content: content, atModelName: "", contentS: content)
            
            let messages = (conversations + [taskMessage]).map({ conversation in
                conversation.toChat(imageAsPath: true)
            })
             
            let query = ChatQuery(messages: messages,
//                                  model: configuration.model.id,
                                  model:configuration.model,
                                  maxTokens: 10,
                                  stream: false)
            
            var tempTitle = ""
            
            do {
                for try await result in service.chatsStream(query: query) {
                    tempTitle += result.choices.first?.delta.content ?? ""
                    title = tempTitle
                }
                
                save()
            } catch {
                if forced {
                    title = "新的聊天"
                    print("Ensure at least two messages to generate a title.")
                } else {
                    title = "新的聊天"
                    print("genuine error.")
                }
            }
        }
    }
    
    #if os(macOS)
    func pasteImageFromClipboard() {
        if let image = getImageFromClipboard() {
//            let imageData = image.tiffRepresentation
            
            if isEditing {
                if let filePath = saveImage(image: image), !editingImages.contains(filePath) {
                    self.editingImages.append(filePath)
                }
            } else {
                if let filePath = saveImage(image: image), !inputImages.contains(filePath) {
                    self.inputImages.append(filePath)
                }
            }
        }
    }

    #endif

    func setResetContextMarker(conversation: Conversation) {
        if let index = conversations.firstIndex(of: conversation) {
            // animation only if the one being reset is not the last one
            if index != conversations.count - 1 {
                withAnimation {
                    resetMarker = index
                }
            } else {
                resetMarker = index
            }
        }

        save()
    }

    func resetContext() {
        if conversations.isEmpty {
            return
        }
            if resetMarker == conversations.count - 1 {
                withAnimation {
                    removeResetContextMarker()
                }
            } else {
                resetMarker = conversations.count - 1
            }

        save()
    }

    @MainActor
    func stopStreaming() {
        if let lastConcersationContent = conversations.last?.content, lastConcersationContent.isEmpty {
            removeConversation(at: conversations.count - 1)
        }
        streamingTask?.cancel()
        streamingTask = nil
        
        if let _ = conversations.last {
            conversations[conversations.count - 1].isReplying = false
        }
    }
    
    @MainActor
    func sendAppropriate() async {
        if isEditing {
            if editingMessage.isEmpty {
                return
            }
            await edit()
        } else {
            if input.isEmpty && inputImages.isEmpty {
                return
            }
            await send()
        }
    }

    @MainActor
    func send() async {
        let text = input
        input = ""
        await send(text: text)
    }

    func rename(newTitle: String) {
        title = newTitle
        save()
    }
    
    @MainActor
    func retry() async {
        if lastConversation.contentS.isEmpty {
            removeConversations(from: conversations.count - 1)
        }
        
        await send(text: lastConversation.content, isRetry: true)
    }

    @MainActor
    func regenerateLastMessage() async {
        if conversations.isEmpty {
            return
        }

        if conversations[conversations.count - 1].role != .user {
            removeConversations(from: conversations.count - 1)
        }
        await send(text: lastConversation.content, isRegen: true)
    }

    @MainActor
    func regenerate(from conversation: Conversation) async {
        if let index = conversations.firstIndex(of: conversation) {
            if index <= resetMarker {
                removeResetContextMarker()
            }
            
            if conversations[index].role == .assistant {
                removeConversations(from: index)
                await send(text: lastConversation.content, isRegen: true)
            } else {
                await edit(conversation: conversation, editedContent: conversation.content)
            }
        }
    }
    
    
    @MainActor
    func resend(from conversation: Conversation) async {
        if let index = conversations.firstIndex(of: conversation) {
            if index <= resetMarker {
                removeResetContextMarker()
            }
            
            if conversations[index].role == .assistant {
                 
                if conversations.count > 1 && index != 0 {
                    
                    
                    
                    let content = conversations[index-1].content
                    self.inputImages = conversations[index-1].imagePaths
                    
                    removeTwoConversations(from: index, role: .assistant)
                    
                    await send(text: content, isRegen: false, isRetry: false)
                }
            } else {
                removeTwoConversations(from: index, role: .user)
                
                self.inputImages = conversation.imagePaths
                await send(text: conversation.content, isRegen: false, isRetry: false)
            }
        }
    }
    
    
    
    @MainActor
    func edit() async {
        if editingIndex <= resetMarker {
            removeResetContextMarker()
        }

        removeConversations(from: editingIndex)
        let text = self.editingMessage
    
        await send(text: text, isEdit: true)
    }
    
    func setupEditing(conversation: Conversation) {
        withAnimation {
            isEditing = true
            editingIndex = conversations.firstIndex { $0.id == conversation.id }!
            editingMessage = conversation.content
            editingAudioPath = conversation.audioPath
            editingPDFPath = conversation.pdfPath
            for imagePath in conversation.imagePaths {
                editingImages.append(imagePath)
            }
        }
    }
    
    func resetIsEditing() {
        withAnimation {
            isEditing = false
            editingIndex = -1
            editingMessage = ""
            editingImages = []
            editingAudioPath = ""
            editingPDFPath = ""
        }
    }

    @MainActor
    func edit(conversation: Conversation, editedContent: String) async {
        if let index = conversations.firstIndex(of: conversation) {
            if index <= resetMarker {
                removeResetContextMarker()
            }

            for imagePath in conversation.imagePaths {
                inputImages.append(imagePath)
            }
            
            if !conversation.audioPath.isEmpty {
                inputAudioPath = conversation.audioPath
            }
            
            if !conversation.pdfPath.isEmpty {
                inputPDFPath = conversation.pdfPath
            }
            
            removeConversations(from: index)
            await send(text: editedContent)
        }
    }
    
    @MainActor
    private func send(text: String, isRegen: Bool = false, isRetry: Bool = false, isEdit: Bool = false) async {
        streamingTask?.cancel()
        
        if isEdit {
            inputImages = editingImages
            inputAudioPath = editingAudioPath
            inputPDFPath = editingPDFPath
        }
        
        resetErrorDesc()

        if !isRegen && !isRetry {
            let imagePaths = Array(inputImages)
       
            appendConversation(Conversation(role: .user, content: text, imagePaths: imagePaths, audioPath: inputAudioPath, pdfPath: inputPDFPath, atModelName: self.configuration.atModel, contentS: text))
        }
        
        if isEdit {
            resetIsEditing()
        }
        
        streamingTask = Task(priority: .userInitiated) {
            try await processRequest()
        }
        
        do {
            inputImages = []
            inputAudioPath = ""
            inputPDFPath = ""
            
            #if os(macOS)
            try await streamingTask?.value
            #else
            let application = UIApplication.shared
            let taskId = application.beginBackgroundTask {
                // Handle expiration of background task here
            }
            
            try await streamingTask?.value
            
            application.endBackgroundTask(taskId)
            #endif
            
        } catch {
            if let lastConversation = conversations.last, lastConversation.role == .assistant, lastConversation.content == "" {
                removeConversation(at: conversations.count - 1)
            }
            
            conversations[conversations.count - 1].isReplying = false
            setErrorDesc(errorDesc: error.localizedDescription)
        }


        save()
    }
    
    @MainActor
    func createChatQuery() -> ChatQuery {
        var mutableConversations = adjustedConversations
        if mutableConversations.last?.role == .assistant {
            mutableConversations = mutableConversations.dropLast()
        }
        
        var finalMessages = mutableConversations.map({ conversation in
            return conversation.toChat()
        })

        
        let finalSysPrompt = {
            self.configuration.systemPrompt
        }
        
        var systemPrompt = Conversation(role: .system, content: finalSysPrompt(),atModelName: "", contentS: finalSysPrompt())
        let artifactsPrompt = {
            String().fetchArtifactsPrompt()
        }
        
        //artifacts 提示词
        if AppConfiguration.shared.artifactsPromptsOn {
            
            //let originalString = "You are ChatGPT, a large language model trained by OpenAI. Current model: gpt-4.0. Current time: Tue Jun 17 2025 17:19:02 GMT+0800 (China Standard Time). Latex inline: (\\x^2\\) Latex block: $$e=mc^2$$"
            var processedString = ""
            // 1. 替换模型版本
            var tempString = artifactsPrompt().replacingOccurrences(of: "gpt-4.1", with: "\(configuration.model)")
            
            // 2. 替换时间部分
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM dd yyyy HH:mm:ss 'GMT+0800 (China Standard Time)'"
            let currentTime = dateFormatter.string(from: Date())
            
            if let timeRange = tempString.range(of: "Current time: ") {
                let prefix = String(tempString[..<timeRange.upperBound])
                if let suffixRange = tempString.range(of: "GMT+0800 (China Standard Time)") {
                    let suffix = String(tempString[suffixRange.upperBound...])
                    tempString = prefix + currentTime + suffix
                }
            }
            
            processedString = tempString
            
            systemPrompt = Conversation(role: .system, content:processedString , atModelName: "", contentS: processedString)
        }
        
        
        if !systemPrompt.content.isEmpty {
            finalMessages.insert(systemPrompt.toChat(), at: 0)
        }
        
//        var tools_web_search : ChatQuery.ChatCompletionToolParam?
//        if AppConfiguration.shared.isWebSearch {
//            tools_web_search = [{"type": "web_search_preview"}]
//        }
        
        var model = configuration.model
        if AppConfiguration.shared.isR1Fusion && AppConfiguration.shared.isWebSearch {
            
            model = configuration.model //+ "-r1-fusion" + "-web-search"
        }
        
        if !AppConfiguration.shared.isR1Fusion && AppConfiguration.shared.isWebSearch {
            
            model = configuration.model //+ "-web-search"
            
        }
        if AppConfiguration.shared.isR1Fusion && !AppConfiguration.shared.isWebSearch {
            
            model = configuration.model //+ "-r1-fusion"//"-deep-search"//"-r1-fusion"
            
        }
         
        
//        if self.conversations.count >= 2 {
//            let lastConvstion = self.conversations[conversations.count-2]
//            if !lastConvstion.imagePaths.isEmpty {
//                model = configuration.model + "-ocr"
//            }
//        }
        let api = ApiDataManager().selectedItem!
        if !configuration.isModerated && api.host.contains("302") {
            if self.conversations.count >= 2 {
                let lastConvstion = self.conversations[conversations.count-2]
                if !lastConvstion.imagePaths.isEmpty {
                    model = configuration.model + "-ocr"
                }
            }
            
            //model = configuration.model + "-ocr"
        }
        
        if AppConfiguration.shared.fileParseOn && api.host.contains("302") {
            model = configuration.model + "-file-parse"
        }
        
        
        let isWebSearch = AppConfiguration.shared.isWebSearch ? true : nil //联网搜索
        let isR1Fusion = AppConfiguration.shared.isR1Fusion ? true : nil //推理模式
        
        //print("发送数据:  --> message:\(finalMessages.last),model_id:\(model)")
        
        let chatQuery = ChatQuery(messages: finalMessages,
                                 model: model,
                                 webSearch: isWebSearch, //联网搜索
                                 r1Fusion: isR1Fusion, //推理模式
                                 maxTokens: 4000,
                                 temperature: configuration.temperature,
                                  stream:false)
        print("chatQuery:\(chatQuery)")
        return chatQuery
            
        
    }
    
    //MARK: - 发送请求 ------------------------
    @MainActor
    func processRequest() async throws {
        let lastConversationData = appendConversation(Conversation(role: .assistant, content: "", atModelName: self.configuration.atModel, isReplying: true, contentS: ""))
        
        let api = ApiDataManager().selectedItem!
        let apiKey = AppConfiguration.shared.OAIkey
        
        var host = api.host
        var path = "/v1"

        if host.contains("/api"){
            host = host.replacingOccurrences(of: "/api", with: "")
            path = "/api/v1"
        }
        
        if host.contains("302") {
            host = "api.302.ai"
        }
        
        
        //openrouter.ai/api --- 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 --- meta-llama/llama-4-maverick:free
//        let openaiConfig = OpenAI.Configuration(token: apiKey,
//                                                host: api.host.contains("/api") ? api.host.replacingOccurrences(of: "/api", with: "") : api.host,
//                                                basePath: api.host.contains("/api") ? "/api/v1" : "/v1")
        let openaiConfig = OpenAI.Configuration(token: apiKey,
                                                host: host,
                                                basePath: path)
        
        
        let service = OpenAI(configuration: openaiConfig) //configuration.provider.config
        
        let query = createChatQuery()
        
        Task {
            await generateTitle(forced: true)
        }
        
        let uiUpdateInterval = TimeInterval(0.15)
        var lastUIUpdateTime = Date()
        
        
        var streamReasoning = ""
        var streamContent = ""
        let startTime = Date() // 记录开始时间
        var reasoning2 = ""
        var streamText2 = ""
        
        for try await result in service.chatsStream(query: query) {
        
            // 获取当前时间
            let currentTime = Date()
            
            // 推理模式 -r1-fusion
            if AppConfiguration.shared.isR1Fusion || configuration.model.contains("deepseek-reasoner") || configuration.model.contains("think") || configuration.model.contains("MiniMax") || configuration.model.contains("DeepSeek-R1"){
                if let reasoning = result.choices.first?.delta.reasoning, !reasoning.isEmpty {
                    streamReasoning += reasoning
                    reasoning2 += reasoning
                }
            }
            
            if let content = result.choices.first?.delta.content, !content.isEmpty {
                 
                if (configuration.model.contains("reason") || configuration.model.contains("-r1")) && configuration.model != "deepseek-reasoner"  && !configuration.model.contains("MiniMax") {
                    
                    streamReasoning += content
                    streamReasoning = streamReasoning.replacingOccurrences(of: "<think>", with: "思考中...")
                    
                    if streamReasoning.contains("</think>") {
                        if !extractThinkContent(from: streamReasoning).isEmpty {
                            reasoning2 = streamReasoning
                            
                            if !content.contains("</think>") {
                                
                                streamContent += content
                                streamText2 = streamContent
                            }
                        }else{
                            streamContent += content
                            streamText2 = streamContent
                        }
                    }else{
                    }
                }else{
                    streamContent += content
                    streamText2 += content
                }
                
                
            }
            
            print("思考中:streamReasoning:\(streamReasoning)")
            
            print("请求结果processRequest streamContent:\(streamContent)")
            
            // 计算耗时
            let timeCost = currentTime.timeIntervalSince(startTime)
            
            
            //深度搜索  -deep-search
            if AppConfiguration.shared.isDeepSearch {
                streamContent = streamText2.replacingOccurrences(of: "<think>", with: "思考中...")
            }
            
            
            // 创建消息对象
            let message = ConversationMessage (
                content: streamContent,
                reasoning: streamReasoning,
                receivedTime: timeCost,
                startTime: startTime,
                atModelName: self.configuration.atModel.isEmpty ? "" : self.configuration.model
            )
            
            // 定期更新UI
            if currentTime.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                
                if streamReasoning.isEmpty {
                    conversations[conversations.count - 1].content = streamContent
                    lastConversationData.sync(with: conversations[conversations.count - 1])
                    lastUIUpdateTime = currentTime
                }else{
                    if let jsonString = message.toJsonString() {
                        conversations[conversations.count - 1].content = jsonString  //reasoning + content
                        conversations[conversations.count - 1].reasoning = reasoning2     //reasoning
                        conversations[conversations.count - 1].contentS = streamText2  //content
                        conversations[conversations.count - 1].atModelName = self.configuration.atModel.isEmpty ? "" : self.configuration.model
                         
                        lastConversationData.sync(with: conversations[conversations.count - 1])
                        lastUIUpdateTime = currentTime
                    }
                }
                
               
            }
            
            
            if result.choices.first?.finishReason == .stop {
                
                date = Date()
                
                if streamReasoning.contains("思考中...") {
                    streamReasoning = streamReasoning.replacingOccurrences(of: "思考中...", with: " ")
                    streamText2 = streamReasoning
                }
                
                if streamReasoning.contains("</think>\n") {
                    streamReasoning = streamReasoning.extractBeforeThinkTag(streamReasoning)
                    streamText2 = streamReasoning
                }
                
                if streamContent.contains("</think>") {
                    streamContent = streamContent.replacingOccurrences(of: "</think>\n", with: "")
                    streamText2 = streamContent
                }
                 
                if streamContent.starts(with:"\n\n") {
                    streamContent = String(streamContent.dropFirst(2))
                    streamText2 = streamContent
                }
                 
                if AppConfiguration.shared.isDeepSearch {
                    streamContent = streamContent.removingThinkTags()
                }
                
                //联网搜索
                if AppConfiguration.shared.isWebSearch {
                    // 网址添加编号, 拼接换行符
                    let numberedString = result.citations?.enumerated().map { (index, item) in
                        "\(index + 1). \(item)"  // 编号从 1 开始
                    }.joined(separator: "\n")
                    streamContent += "\n" + (numberedString ?? "")
                }
            }
            
        }
        
        // 最终更新耗时
        let finalTimeCost = Date().timeIntervalSince(startTime)
        let finalMessage = ConversationMessage(
            content: streamContent,
            reasoning: streamReasoning,
            receivedTime: finalTimeCost,
            startTime: startTime,
            atModelName: self.configuration.atModel.isEmpty ? "" : self.configuration.model
        )
         
        
        if streamReasoning.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                
                self.conversations[self.conversations.count - 1].content = streamContent
                lastConversationData.sync(with: self.conversations[self.conversations.count - 1])
                self.conversations[self.conversations.count - 1].isReplying = false
            }
        }else{
            if let jsonString = finalMessage.toJsonString() {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    
                    self.conversations[self.conversations.count - 1].content = jsonString
                    //reasoning
                    self.conversations[self.conversations.count - 1].reasoning = reasoning2.trimmingCharacters(in: .whitespacesAndNewlines)
                    //content
                    self.conversations[self.conversations.count - 1].contentS = streamText2.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    self.conversations[self.conversations.count - 1].atModelName = self.configuration.atModel.isEmpty ? "" : self.configuration.model
                    
                    lastConversationData.sync(with: self.conversations[self.conversations.count - 1])
                    self.conversations[self.conversations.count - 1].isReplying = false
                }
            }
        }
        
        
        /**
         for try await result in service.chatsStream(query: query) {
             
             if AppConfiguration.shared.isR1Fusion {
                  streamText = result.choices.first?.delta.reasoning ?? ""
             }
             streamText += result.choices.first?.delta.content ?? ""
              
             if AppConfiguration.shared.isDeepSearch {
                 streamText = streamText.replacingOccurrences(of: "<think>", with: "思考中...")
             }
             
             let currentTime = Date()
             if currentTime.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                  
                 conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                 lastConversationData.sync(with: conversations[conversations.count - 1])
                 lastUIUpdateTime = currentTime
             }
             
             if result.choices.first?.finishReason == .stop {
                  
                 if AppConfiguration.shared.isDeepSearch {
                     streamText = streamText.removingThinkTags()
                 }
                   
                 if AppConfiguration.shared.isWebSearch {
                     // 添加编号并用换行符拼接
                     let numberedString = result.citations?.enumerated().map { (index, item) in
                         "\(index + 1). \(item)"  // 编号从 1 开始
                     }.joined(separator: "\n")
                     
                     //streamText += result.citations?.joined(separator: "\n") ?? ""
                     streamText += "\n" + (numberedString ?? "")

                 }
             }
             
         }
         */
 
       
//        if !streamText.isEmpty {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.conversations[self.conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
//                self.conversations[self.conversations.count - 1].reasoning = reasoning2.trimmingCharacters(in: .whitespacesAndNewlines)
//                lastConversationData.sync(with: self.conversations[self.conversations.count - 1])
//                self.conversations[self.conversations.count - 1].isReplying = false
//            }
//        }
    }
    
    
    @MainActor
    func processRequest2() async throws {
        let lastConversationData = appendConversation(Conversation(role: .assistant, content: "", atModelName: self.configuration.atModel, isReplying: true, contentS: ""))
        
        let api = ApiDataManager().selectedItem
        let apiKey = AppConfiguration.shared.OAIkey
        
        let openaiConfig = OpenAI.Configuration(token: apiKey, host: api?.host ?? "")
        let service = OpenAI(configuration: openaiConfig) //configuration.provider.config
        
        //let query = createChatQuery()
        
        Task {
            await generateTitle(forced: false)
        }
        
        let uiUpdateInterval = TimeInterval(0.12)
        var lastUIUpdateTime = Date()
        
        
        var streamReasoning = ""
        var streamContent = ""
        let startTime = Date() // 记录开始时间
        var reasoning2 = ""
        var streamText2 = ""
         
        
        ChatService.shared.streamMessage(message: "你好") { result in
             
            // 获取当前时间
            let currentTime = Date()
            // 推理模式 -r1-fusion
            if AppConfiguration.shared.isR1Fusion {
                if let reasoning = result.choices.first?.delta.reasoning, !reasoning.isEmpty {
                    streamReasoning += reasoning
                    reasoning2 += reasoning
                }
            }
            
            if let content = result.choices.first?.delta.content, !content.isEmpty {
                streamContent += content
                streamText2 += content
            }
            
            print("请求结果processRequest streamContent:\(streamContent)")
            
            // 计算耗时
            let timeCost = currentTime.timeIntervalSince(startTime)
            
            
            //深度搜索  -deep-search
            if AppConfiguration.shared.isDeepSearch {
                streamContent = streamText2.replacingOccurrences(of: "<think>", with: "思考中...")
            }
            
            
            // 创建消息对象
            let message = ConversationMessage (
                content: streamContent,
                reasoning: streamReasoning,
                receivedTime: timeCost,
                startTime: startTime,
                atModelName: self.configuration.atModel.isEmpty ? "" : self.configuration.model
            )
            
            // 定期更新UI
            if currentTime.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                if let jsonString = message.toJsonString() {
                    self.conversations[self.conversations.count - 1].content = jsonString  //reasoning + content
                    self.conversations[self.conversations.count - 1].reasoning = reasoning2     //reasoning
                    self.conversations[self.conversations.count - 1].contentS = streamText2  //content
                    self.conversations[self.conversations.count - 1].atModelName = self.configuration.atModel.isEmpty ? "" : self.configuration.model
                    
                    
                    lastConversationData.sync(with: self.conversations[self.conversations.count - 1])
                    lastUIUpdateTime = currentTime
                }
            }
            
            
            if result.choices.first?.finishReason == "stop" {
                if AppConfiguration.shared.isDeepSearch {
                    streamContent = streamContent.removingThinkTags()
                }
                
                //联网搜索
                if AppConfiguration.shared.isWebSearch {
                    // 网址添加编号, 拼接换行符
                    let numberedString = result.citations?.enumerated().map { (index, item) in
                        "\(index + 1). \(item)"  // 编号从 1 开始
                    }.joined(separator: "\n")
                    streamContent += "\n" + (numberedString ?? "")
                }
            }
            
            
        } onCompletion: { error in
            
        }
 

        // 最终更新耗时
        let finalTimeCost = Date().timeIntervalSince(startTime)
        let finalMessage = ConversationMessage(
            content: streamContent,
            reasoning: streamReasoning,
            receivedTime: finalTimeCost,
            startTime: startTime,
            atModelName: self.configuration.atModel.isEmpty ? "" : self.configuration.model
        )
        
         
        
        if let jsonString = finalMessage.toJsonString() {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                 
                self.conversations[self.conversations.count - 1].content = jsonString
                //reasoning
                self.conversations[self.conversations.count - 1].reasoning = reasoning2.trimmingCharacters(in: .whitespacesAndNewlines)
                //content
                self.conversations[self.conversations.count - 1].contentS = streamText2.trimmingCharacters(in: .whitespacesAndNewlines)
                
                self.conversations[self.conversations.count - 1].atModelName = self.configuration.atModel.isEmpty ? "" : self.configuration.model
                
                lastConversationData.sync(with: self.conversations[self.conversations.count - 1])
                self.conversations[self.conversations.count - 1].isReplying = false
            }
        }
        
        
    }
    
    // 提取思考内容函数（带参数）
        func extractThinkContent(from input: String) -> String {
            /**let pattern = "<think>\n(.*?)</think>\n"
             guard let regex = try? NSRegularExpression(pattern: pattern) else { return "" }
             
             let matches = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))
             
             guard let match = matches.first,
                   let range = Range(match.range(at: 1), in: input) else {
                 return ""
             }
             
             return String(input[range]).trimmingCharacters(in: .whitespacesAndNewlines)*/
            
            guard let start = input.range(of: "思考中..."),
                          let end = input.range(of: "</think>") else {
                        return ""
                    }
                    
                    let thinkRange = start.upperBound..<end.lowerBound
                    return String(input[thinkRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // 提取消息内容函数（带参数）
        func extractMessageContent(from input: String) -> String {
            /**let pattern = "</think>(.*?)$"
             guard let regex = try? NSRegularExpression(pattern: pattern) else { return "" }
             
             let matches = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))
             
             guard let match = matches.first,
                   let range = Range(match.range(at: 1), in: input) else {
                 return ""
             }
             
             return String(input[range]).trimmingCharacters(in: .whitespacesAndNewlines)*/
            guard let endThink = input.range(of: "</think>\n") else {
                return ""
            }
            
            let messageRange = endThink.upperBound..<input.endIndex
            return String(input[messageRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    
    
    
    
    
    // 计算推理模式-响应时间
    func calculateAverageResponseTime() -> String {
        let validConversations = conversations.compactMap { ConversationMessage(jsonString: $0.content) }
        guard !validConversations.isEmpty else { return "N/A" }
        
        let totalTime = validConversations.reduce(0) { $0 + $1.receivedTime }
        let average = totalTime / Double(validConversations.count)
        return String(format: "%.2fs", average)
    }
    
}
 
extension String {
     
    func removingContentBetweenTags(_ openingTag: String, _ closingTag: String) -> String {
        let pattern = "\(openingTag)[\\s\\S]*?\(closingTag)"
        return self.replacingOccurrences(of: pattern,
                                       with: "",
                                       options: .regularExpression)
    }
    
    // 专门处理 <think> 标签的便捷方法
    func removingThinkTags() -> String {
        //return self.removingContentBetweenTags("<think>", "</think>")
        return self.removingContentBetweenTags("思考中...", "</think>")
    }
    
    
    // 提取 </think> 之前的内容
    func extractBeforeThinkTag(_ string: String) -> String {
        // 找到 </think> 的位置
        if let range = string.range(of: "</think>") {
            // 返回 </think> 之前的部分
            return String(string[..<range.lowerBound])
        }
        // 如果没有找到 </think>，返回原字符串
        return string
    }
    
    
    func fetchArtifactsPrompt() -> String {
           
        if let content = FileReader.readFile(named: "artifacts_prompts.txt") {
            return content
        } else {
            return  "你是一个乐于助人的助手"
        }
    }
    
}


extension DialogueSession {
    convenience init?(rawData: DialogueData) {
        self.init()
        guard let id = rawData.id,
              let date = rawData.date,
              let title = rawData.title,
              let errorDesc = rawData.errorDesc,
              let configurationData = rawData.configuration,
              let conversations = rawData.conversations as? Set<ConversationData> else {
            return nil
        }
        let resetMarker = rawData.resetMarker
        let isArchive = rawData.isArchive
        let previewOn = rawData.previewOn

        self.rawData = rawData
        self.id = id
        self.date = date
        self.title = title
        self.previewOn = previewOn
        self.errorDesc = errorDesc
        self.isArchive = isArchive
        self.resetMarker = Int(resetMarker)
        
        if let configuration = try? JSONDecoder().decode(Configuration.self, from: configurationData) {
            self.configuration = configuration
        }

        self.conversations = conversations.compactMap { data in
            if let id = data.id,
               let content = data.content,
               let role = data.role,
               let date = data.date,
               let avatar = data.avatar,
               let contentS = data.contentS,
               let atModelName = data.atModelName,
               let audioPath = data.audioPath,
               let pdfPath = data.pdfPath,
               let toolRawValue = data.toolRawValue,
               let arguments = data.arguments,
               let imagePaths = data.imagePaths {
                let imagePaths = imagePaths.split(separator: "|||").map(String.init) // Convert back to an array of strings
                let conversation = Conversation(
                  id: id,
                  date: date,
                  role: ConversationRole(rawValue: role) ?? .assistant,
                  content: content,
                  avatar: avatar,
                  imagePaths: imagePaths,
                  audioPath: audioPath,
                  pdfPath: pdfPath,
                  toolRawValue: toolRawValue,
                  arguments: arguments,
                  atModelName: atModelName,
                  contentS: contentS
                )
                return conversation
            } else {
                return nil
            }
        }

        self.conversations.sort {
            $0.date < $1.date
        }
    }

    @discardableResult
    func appendConversation(_ conversation: Conversation) -> ConversationData {
        if conversations.isEmpty {
            removeResetContextMarker()
        }

//        withAnimation {
            conversations.append(conversation)
//        }
        isAddingConversation.toggle()
        
        let data = Conversation.createConversationData(from: conversation, in: PersistenceController.shared.container.viewContext)
        
        rawData?.conversations?.adding(data)
        
        data.dialogue = rawData

        do {
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }

        return data
    }

    @discardableResult
    func addToTopConversation(_ conversation: Conversation) -> ConversationData {
        if conversations.isEmpty {
            removeResetContextMarker()
        }

        
        let con = Conversation(role: conversation.role, content: conversation.content, atModelName: "", contentS: conversation.contentS)
        con.id = UUID()
        let argumentCount = -864000 + TimeInterval(conversations.filter { !$0.arguments.isEmpty }.count)
        con.date = self.conversations.first!.date.addingTimeInterval(argumentCount)
        
        con.arguments = "预设提示词 "
        
        conversations.insert(con, at: 0) //临时数据
         
        let data = Conversation.createConversationData(from: conversation, in: PersistenceController.shared.container.viewContext)
        
        data.id = UUID()
        data.atModelName = ""
        data.date = data.date!.addingTimeInterval(argumentCount)
        data.arguments = "预设提示词 "
        
        let set1 : NSSet = [data]
        
        if let set2 = rawData?.conversations as? Set<ConversationData> {
    
            // 合并
            let combinedSet = set1.addingObjects(from: set2) as NSSet //持久数据
            rawData?.conversations? = combinedSet
        }
        
        
        
        data.dialogue = rawData

        do {
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }

        return data
    }
    
    
//    func addToTopConversation(_ conversation: Conversation) {
//        guard let context = rawData?.managedObjectContext else {
//            print("Error: No managed object context available")
//            return
//        }
//        
//        do {
//            let newConversationData = ConversationData(context: context)
//            newConversationData.id = conversation.id
//            newConversationData.role = conversation.role.rawValue
//            newConversationData.content = conversation.content
//            newConversationData.arguments = "预设提示词"
//            newConversationData.atModelName = ""
//            newConversationData.contentS = conversation.contentS
//            //newConversationData.dialogue = conversation.dialogue
//            // 设置其他属性...
//            
//            if var conversationsSet = rawData?.conversations as? Set<ConversationData> {
//                conversationsSet.insert(newConversationData)
//                rawData?.conversations = conversationsSet as NSSet
//            } else {
//                rawData?.conversations = [newConversationData] as NSSet
//            }
//            
//            // 3. 显式保存到持久化存储（关键步骤）
//            try context.save()
//            
//            // 4. 更新内存数组（插入到首位）
//            conversations.insert(conversation, at: 0)
//            
//        } catch {
//            print("Failed to add conversation: \(error.localizedDescription)")
//            // 可选：回滚更改（如果保存失败）
//            context.rollback()
//        }
//    }
    
    
    func removeConversation(at index: Int) {
        if self.isReplying {
            return
        }
        
        let conversation = conversations[index]
        
        if conversations.count <= 2 {
            let _ = conversations.remove(at: index)
        } else {
            withAnimation {
                let _ = conversations.remove(at: index)
            }
        }

        if resetMarker == index {
            if conversations.count > 1 {
                resetMarker = index - 1
            } else {
                resetMarker = -1
            }
        }

        do {
            if var conversationsSet = rawData?.conversations as? Set<ConversationData>,
               let conversationData = conversationsSet.first(where: {
                   $0.id == conversation.id || ($0.date == conversation.date && $0.content == conversation.content)
               }) {
                
                // 从 Set 中删除匹配的元素
                conversationsSet.remove(conversationData)
                    
                // 更新 rawData.conversations
                rawData?.conversations = conversationsSet as NSSet
                
                //PersistenceController.shared.container.viewContext.delete(conversationData)
            }
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }

//    @MainActor
    func removeConversation(_ conversation: Conversation) {
        guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else {
            return
        }

        withAnimation {
            removeConversation(at: index)
        }

        if conversations.isEmpty {
            resetErrorDesc()
        }
    }

    func removeConversations(from index: Int) {
        guard index < conversations.count else {
            print("Index out of range")
            return
        }

        let conversationsToRemove = Array(conversations[index...])
        let idsToRemove = conversationsToRemove.map { $0.id }

        do {
            if let conversationsSet = rawData?.conversations as? Set<ConversationData> {
                let conversationsDataToRemove = conversationsSet.filter { idsToRemove.contains($0.id!) }
                for conversationData in conversationsDataToRemove {
                    PersistenceController.shared.container.viewContext.delete(conversationData)
                }
            }
            try PersistenceController.shared.save()
            conversations.removeSubrange(index...)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    
    func removeTwoConversations(from index: Int,role:ConversationRole) {
        guard index < conversations.count else {
            print("Index out of range")
            return
        }
 
        var conversationsToRemove = [Conversation]()
        
        if role == .assistant {
            conversationsToRemove = conversations.filter { conversation in
                conversation.id == conversations[index].id || conversation.id == conversations[index-1].id
            }
        }else{
            conversationsToRemove = conversations.filter { conversation in
                if index + 1 < conversations.count {
                        return conversation.id == conversations[index].id || conversation.id == conversations[index+1].id
                    } else {
                        return conversation.id == conversations[index].id
                    }
            }
        }
        let idsToRemove = conversationsToRemove.map { $0.id }
        do {
            if let conversationsSet = rawData?.conversations as? Set<ConversationData> {
                let conversationsDataToRemove = conversationsSet.filter { idsToRemove.contains($0.id!) }
                for conversationData in conversationsDataToRemove {
                    PersistenceController.shared.container.viewContext.delete(conversationData)
                }
            }
            try PersistenceController.shared.save()
            // 4. 从内存数组删除（正确方式）
            conversations.removeAll { idsToRemove.contains($0.id) }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    func removeAllConversations() {
        removeResetContextMarker()
        resetErrorDesc()
        
        withAnimation {
            conversations.removeAll()
        }

        do {
            let viewContext = PersistenceController.shared.container.viewContext
            if let conversations = rawData?.conversations as? Set<ConversationData> {
                conversations.forEach(viewContext.delete)
            }
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func setErrorDesc(errorDesc: String) {
        self.errorDesc = errorDesc
        save()
    }

    func resetErrorDesc() {
        errorDesc = ""
        save()
    }

    func save() {
        do {
            rawData?.date = date
            rawData?.title = title
            rawData?.errorDesc = errorDesc
            rawData?.isArchive = isArchive
            rawData?.previewOn = previewOn
            rawData?.resetMarker = Int16(resetMarker)
            
        
            rawData?.configuration = try JSONEncoder().encode(configuration)

            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}





#if os(macOS)
extension DialogueSession {
    public func exportToMd() -> String? {
        let markdownContent = generateMarkdown(for: conversations)

        let uniqueTimestamp = Int(Date().timeIntervalSince1970)
        // Specify the file path
        let filePath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads/\(title)_\(uniqueTimestamp).md")

        // Write the content to the file
        do {
            try markdownContent.write(to: filePath, atomically: true, encoding: .utf8)
            return filePath.lastPathComponent
        } catch {
            return nil
        }

    }
    
    // Function to generate Markdown content
    private func generateMarkdown(for conversations: [Conversation]) -> String {
        var markdown = "# Conversations\n\n"
        
        for conversation in conversations {
            markdown += "### \(conversation.role.rawValue.capitalized)\n"
            markdown += "\(conversation.content)\n\n"
        }
        
        return markdown
    }

}
#endif
