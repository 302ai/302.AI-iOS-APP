//
//  UserMessageView2.swift
//  GPTalks
//
//  Created by Adswave on 2025/6/16.
//

import SwiftUI
import SwiftMarkdownView
import AlertToast


extension String {
    /// 检测字符串中是否包含 URL
    var containsURL: Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return false
        }
        let matches = detector.matches(in: self, range: NSRange(location: 0, length: self.utf16.count))
        return !matches.isEmpty
    }

    /// 提取字符串中的所有 URL 和对应文本
    func extractURLs() -> [(text: String, url: String)] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return []
        }
        let matches = detector.matches(in: self, range: NSRange(location: 0, length: self.utf16.count))
        return matches.compactMap { match in
            guard let range = Range(match.range, in: self) else { return nil }
            let urlText = String(self[range])
            return (text: urlText, url: urlText)
        }
    }
}

struct SmartText: View {
    let content: String
    var linkColor: Color = .blue
    var underlineLinks: Bool = true

    var body: some View {
        if let attributedText = createAttributedText() {
            CustomText(attributedText)
        } else {
            CustomText(content)
        }
    }

    private func createAttributedText() -> AttributedString? {
        guard content.containsURL else { return nil }
        var attributedString = AttributedString(content)
        let urlTuples = content.extractURLs()

        for tuple in urlTuples {
            if let range = attributedString.range(of: tuple.text) {
                attributedString[range].link = URL(string: tuple.url)
                attributedString[range].foregroundColor = linkColor
                if underlineLinks {
                    attributedString[range].underlineStyle = .single
                }
            }
        }
        return attributedString
    }
}

struct UserMessageView2: View {
    @Environment(DialogueViewModel.self) private var viewModel
    
    @State private var isExpanded = false
    
    var conversation: Conversation
    var session: DialogueSession

    @State var isEditing: Bool = false
    @State var editingMessage: String = ""
    
    @State private var isHovered = false
    @State var hoverxyz = false
    
    @State var canSelectText = false

    var scrollToMessageTop: () -> Void?
    
    
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    @State private var buttons  = [
        ButtonData(name: "刷新"),
        ButtonData(name: "删除"),
        //ButtonData(name: "钉住"),
        ButtonData(name: "复制"),
        ButtonData(name: "播放")
    ]
    @State private var showButtons = true //展示一排操作按钮
    @State var isShowToast = false
    @State private var hintText: String?
    
    var showButtonsTop: Int {
        if !conversation.content.isEmpty && !conversation.imagePaths.isEmpty {
                return 5
            } else if !conversation.content.isEmpty && conversation.imagePaths.isEmpty {
                return 0
            } else if conversation.content.isEmpty && !conversation.imagePaths.isEmpty {
                return -35
            } else {
                return 0
            }
        }
    
    var body: some View {
        
        
        ZStack{
            
            alternateUI
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
                .sheet(isPresented: $isEditing) {
                    EditingView(editingMessage: $editingMessage, isEditing: $isEditing, session: session, conversation: conversation)
                }
#if !os(macOS)
                .sheet(isPresented: $canSelectText) {
                    TextSelectionView(content: conversation.content)
                }
                .contextMenu {
                    //长按弹窗
                    MessageContextMenu(session: session, conversation: conversation, isExpanded: isExpanded,
                                       editHandler: {
                        session.setupEditing(conversation: conversation)
                    }, toggleTextSelection: {
                        canSelectText.toggle()
                    }, toggleExpanded: {
                        isExpanded.toggle()
                    })
                    .labelStyle(.titleAndIcon)
                }
#else
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        if (session.conversations.filter { $0.role == .user }.last)?.id == conversation.id {
                            editBtn
                        }
                    }
                }
#endif
        }
        .toast(isPresenting: $isShowToast){
               
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        
        
        
    }
    
    var alternateUI: some View {
        VStack(alignment: .trailing) {
            
            HStack(alignment: .top, spacing: 10) {
                Spacer()
                 
                
                
                //头像
                Text(AppConfiguration.shared.userAvatar)
                    .frame(width: 22, height: 20)
                    .padding(3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
#if !os(macOS)
                    .padding(.top, 3)
                    .offset(x:5)
#else
//                    .offset(x:5,y:0)
                    //.padding(.bottom, 3)
#endif
                 
            }
            .padding()
            
            
            
            VStack(alignment: .trailing, spacing: 6) {
                     
#if os(macOS)
                Text(isExpanded || conversation.content.count <= 300 ? conversation.content : String(conversation.content.prefix(300)) + "\n...")
                    .textSelection(.enabled)
#else
                Group {
                    if !conversation.arguments.isEmpty {
                        //MessageMarkdownView(text: conversation.content)
                         
                        VStack(alignment: .trailing){
                            VStack(alignment: .trailing){
                                SwiftMarkdownView(conversation.content)
                                    .markdownFontSize(UserDefaults.standard.object(forKey: "fontSize") as? CGFloat ?? 16)
                                    .cornerRadius(10)
                                    .padding(10)
                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                                
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                    .overlay(
                                        conversation.content.isEmpty ? nil : RoundedRectangle(cornerRadius: 10)
                                        //.fill(Color.gray.opacity(0.1)) // 使用填充而不是背景色
                                            .stroke(Color.gray, lineWidth: 0.5)
                                        //.padding(-10)
                                    )
                            }//.offset(y: -5)
                            
                            CustomText(conversation.arguments)
                                .foregroundStyle(.gray)
                                .font(.footnote)
                            
                        }
                        .offset(y:-10)
                         
                        
                    } else {
                        CustomText(conversation.content)
                            .textSelection(.enabled)
                            .cornerRadius(10)
                            .padding(10)
                            .hidden(conversation.content.isEmpty)
                            .background(
                                    conversation.content.isEmpty ? nil :
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                )
//                            .overlay(
//                                conversation.content.isEmpty ? nil :
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.gray.opacity(0.1)) // 使用填充而不是背景色
//                                    .stroke(Color.gray, lineWidth: 0.5)
//                                    .padding(-10) // 调整边框与文字的距离
//                            )
                        
                            .offset(x:-5)
                            .onTapGesture {
                                withAnimation {
                                     
                                }
                            }
                        
                    }
                }
                .padding([.leading,.trailing],15)
                .offset(y:-5)
                 

                 
#endif
                ForEach(conversation.imagePaths, id: \.self) { imagePath in
                    ImageView2(imageUrlPath: imagePath, imageSize: imageSize)
                }
                .offset(x:-8,y:conversation.content.isEmpty ? -30 : 10)
                
                // VStack2 - 根据状态显示或隐藏
                if showButtons && conversation.arguments.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                 
                                ForEach(buttons.indices, id: \.self) { index in
                                    Button(action: {
                                        print("Button \(index) tapped")
                                        
                                        buttonAction(index: index,con: conversation)
                                        
                                    }) {
                                        ZStack {
                                            // 按钮背景（46×30，圆角15）
                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 32, height: 32)
                                                .foregroundStyle(.background)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                                )
                                            
                                            // 图片（缩小显示，宽高20×20）
                                            Image(buttons[index].name)
                                                .resizable()
                                                .renderingMode(.template)
                                                .scaledToFit()
                                                .foregroundColor(buttonBackgroundColor(for: index))
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                    }.frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                            }
                            .padding(.leading,UIScreen.main.bounds.width*0.4)//往右偏
                        
 
                    }
                    .transition(.opacity)
                    .frame(height: 46)  // 调整高度
                    .padding(.leading,30)
                    .padding(.trailing,-20)
                    .offset(y:CGFloat(showButtonsTop))
                }
                 
            }
            
            
            
#if os(macOS)
            HStack {
                Spacer()
                
                messageContextMenu
                    .padding(.leading, 200) // Increase padding to enlarge the invisible hover area
                    .contentShape(Rectangle()) // Make the whole padded area hoverable
                    .onHover { isHovered in
                        hoverxyz = isHovered
                    }
                    .animation(.easeInOut(duration: 0.15), value: hoverxyz)
            }
            .padding(.top, -40)
            .padding(.bottom, 3)
            .padding(.horizontal, 18)
#endif
        }

        #if os(macOS)
        .padding(.horizontal, 8)
        #endif
        .frame(maxWidth: .infinity, alignment: .topLeading) // Align content to the top left
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        .background(session.conversations.firstIndex(where: { $0.id == conversation.id }) == session.editingIndex ? Color("niceColor").opacity(0.3) : .clear)
        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
        
        
        
        
    }
    
    var messageContextMenu: some View {
        HStack {
            if hoverxyz {
                MessageContextMenu(session: session, conversation: conversation, isExpanded: isExpanded,
                editHandler: {
                    session.setupEditing(conversation: conversation)
                }, toggleTextSelection: {
                    withAnimation {
                        canSelectText.toggle()
                    }
                }, toggleExpanded: {
                    isExpanded.toggle()
                    withAnimation {
                        scrollToMessageTop()
                    }
                })
            } else {
                Image(systemName: "ellipsis")
                    .frame(width: 17, height: 17)
            }

        }
        .contextMenuModifier(isHovered: $isHovered)
    }
    
    var editBtn: some View {
        Button("") {
            session.setupEditing(conversation: conversation)
        }
        .frame(width: 0, height: 0)
        .hidden()
        .keyboardShortcut("e", modifiers: .command)
        .padding(4)
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        300
        #else
        UIScreen.main.bounds.width/3.5  //325
        #endif
    }
      
    
    // 按钮背景色逻辑
       private func buttonBackgroundColor(for index: Int) -> Color {
           let button = buttons[index]
           if button.name == "播放" {
               return speechSynthesizer.isSpeaking ? .blue : .gray
           } else {
               return .gray
           }
       }
    
    
    func buttonAction(index:Int,con:Conversation) {
        
        if index == 0 {
            //重新生成
            Task { @MainActor in
                await session.resend(from: con)
            }
        }
        
        if index == 1 {
            //删除
            session.removeConversation(con)
        }
        
        if index == 2 {
            //钉住
            //session.addToTopConversation(con)
            
        }
        
        if index == 2 {
            //复制
            con.content.copyToPasteboard()
            hintText = "已复制"
            isShowToast.toggle()
            // 3秒
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isShowToast = false
                hintText = nil
            }
        }
        
        if index == 3 {
            //播放内容
            let buttonName = buttons[index].name
            
            if buttonName == "播放" {
                if speechSynthesizer.isSpeaking {
                    speechSynthesizer.stop() // 停止播放
                } else {
                    speechSynthesizer.speak(con.content){
                        // 播放完成后的回调（可选）
                        print("播放完成")
                    }
                }
            } else {
                print("点击了：\(buttonName)")
            }
        }
    }
    
    
}
