//
//  MyMessages.swift
//  GPTalks
//
//  Created by Adswave on 2025/6/16.
//
 
#if !os(macOS)
import SwiftUI
import UniformTypeIdentifiers
import AlertToast
import UIKit


struct MyMessages: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @Environment(DialogueViewModel.self) private var viewModel

    //@Bindable var session: DialogueSession

    @State private var shouldStopScroll: Bool = false
    @State private var showScrollButton: Bool = false

    @State private var showSysPromptSheet: Bool = false

    @State private var showRenameDialogue = false
    @State private var newName = ""

    @FocusState var isTextFieldFocused: Bool
     
     
    @State private var searchText = "" //搜索文本
    @State private var selectedModelString = ""  //selected model
    @State private var isSearchActive = false
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    @State private var showPreviewSheet = false
    
    @State var hasAtModel = false
    //@State var selectModelString = ""
    @State var atModelString = ""  //艾特模型
    @State var atModelNil = ""  //未艾特模型
    
    @State private var isShowToast = false
     
    @State private var ai302Models : [AI302Model] = [
        AI302Model(id: "GPT-4o" ,is_moderated: true),
        AI302Model(id: "gpt4o_mini" ,is_moderated: true)
    ]
    
    @State private var hasLoadedModels = false
    
    @State private var showDialogList = false //会话列表
    @State private var showSettingView = false //设置
    @State private var showStoreSheet = false // 应用商店
    @State private var showTipsSheet = false // 提示词
    
    private var loadModelsTimer: Timer?
    
    @State private var offsetX: CGFloat = 0
    @State private var menuWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    @State private var isMenuVisible = false
    
    
    
      
    var currentSession2: DialogueSession  {
        if let selected = viewModel.selectedDialogue {
            return selected
        } else {
            if let session1 = viewModel.allDialogues.first {
                return session1
            }else{
                viewModel.addDialogue()
                return viewModel.allDialogues.first!
            }
        }
    }
    
    
    var body: some View {
          
        @Bindable var currentSession = currentSession2
        
        var sortedModels: [AI302Model] {
            ai302Models.sorted { $0.id < $1.id }
        }
        
         
        ZStack{
            VStack{
                
                // 过滤后的数据
                var filteredModels: [AI302Model] {
                    
                    guard !searchText.isEmpty else { return ai302Models }
                    
                    return ai302Models.filter { model in
                        model.id.localizedCaseInsensitiveContains(searchText)
                    }
                }
                
                HStack{
                    // 导航栏左侧按钮
                    Button {
                        //withAnimation {}
                        self.showDialogList = true
                    } label: {
                        HStack{
                            Image(systemName: "list.triangle")
                                .foregroundStyle(Color(white: 0.3))
                        }
                    }
                    .frame(width: 40, height: 40)
                    .offset(x:15)
                    
                    Spacer( )
                    
                    HStack(alignment:.center){
                        
                        // 动态切换按钮和输入框
                        if let conversation = currentSession.conversations.first {
                            if (conversation.arguments == "预设提示词" && conversation.role == .assistant && !AppConfiguration.shared.isCustomPromptOn) {
                                 Spacer()
                                 Text("[应用]\(currentSession.title)")
                                 Spacer()
                             }else {
                                if isEditing {
                                    
                                    HStack {
                                         
                                        TextField("搜索...", text: $searchText)
                                            .focused($isFocused)
                                            .frame(width: 180)
                                            .textFieldStyle(.roundedBorder)
                                            .submitLabel(.search)
                                            .onSubmit {
                                                endEditing()
                                            }
                                        
                                        Button(action: endEditing) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                } else {
                                    HStack{
                                        VStack{}
                                            .frame(width: currentSession.configuration.model.count > 15 ? 30 : 50)
                                        Spacer(minLength: currentSession.configuration.model.count > 10 ? 0 : 20)
                                        HStack{
                                            
                                            Text(truncateMiddle(currentSession.configuration.model, maxLength: 15))
                                                .lineLimit(1)
                                                .onTapGesture {
                                                    isEditing = true
                                                    isFocused = true
                                                }
                                            Image(systemName: "chevron.down")
                                                .foregroundStyle(.black)
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                        
                                        Spacer()
                                    }
                                    
                                }
                            }
                        }else{
                            if isEditing {
                                
                                HStack {
                                     
                                    TextField("搜索...", text: $searchText)
                                        .focused($isFocused)
                                        .frame(width: 180)
                                        .textFieldStyle(.roundedBorder)
                                        .submitLabel(.search)
                                        .onSubmit {
                                            endEditing()
                                        }
                                    
                                    Button(action: endEditing) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                     
                                }
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                
                                
                                HStack{
                                    VStack{}
                                        .frame(width: 80)
                                    Spacer(minLength: 20)
                                    HStack{
                                        
                                        Text(truncateMiddle(currentSession.configuration.model, maxLength: 15))
                                            .lineLimit(1)
                                            .onTapGesture {
                                                isEditing = true
                                                isFocused = true
                                            }
                                        Image(systemName: "chevron.down")
                                            .foregroundStyle(.black)
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                    
                                    Spacer()
                                    VStack{}
                                        .frame(width: 20)
                                }
                                 
                            }
                        }
                         
                    }
                     
                    
                    //右侧
                    HStack{
                        Button(action: {
                            print("设置被点击")
                            showSettingView.toggle()
                        }) {
                            Image("setting") // 设置
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                        .frame(width: 44, height: 44)
                    }
                    .frame(minWidth: UIScreen.main.bounds.width/5)
                    .offset(x:0)
                    
                }
                
                ZStack{
                    ScrollViewReader { proxy in
                        ZStack(alignment: .bottomTrailing) {
                            ScrollView {
                                
                                VStack(spacing: 0) {
                                    MessageContentView(session: currentSession)
                                }
                                .padding(.bottom, 8)
                                
                                ErrorDescView(session: currentSession)
                                    .offset(x:0,y:-35)
                                
                                ScrollSpacer
                                
                                GeometryReader { geometry in
                                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                                }
                            }
                            
                            
                            
                            scrollBtn(proxy: proxy)
                            
                            
                        }
                        
                        
    #if !os(visionOS)
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            let bottomReached = value > UIScreen.main.bounds.height
                            shouldStopScroll = bottomReached
                            showScrollButton = bottomReached
                        }
                        .scrollDismissesKeyboard(.immediately)
    #endif
                        .listStyle(.plain)
                        .onAppear {
                            
                            self.ai302Models = NetworkManager.shared.models
                            
                            scrollToBottom(proxy: proxy, delay: 0.3)
                            
                            if currentSession.conversations.count > 8 {
                                scrollToBottom(proxy: proxy, delay: 0.8)
                            }
                            
                            selectedModelString =  currentSession.configuration.atModel.isEmpty ? currentSession.configuration.model : currentSession.configuration.atModel
                            
                        }
                        
                        .onTapGesture {
                            isTextFieldFocused = false
                        }
                        .onChange(of: isTextFieldFocused) {
                            if isTextFieldFocused {
                                scrollToBottom(proxy: proxy)
                            }
                        }
                        .onChange(of: currentSession.input) {
                            scrollToBottom(proxy: proxy)
                        }
                        .onChange(of: currentSession.resetMarker) {
                            if currentSession.resetMarker == currentSession.conversations.count - 1 {
                                scrollToBottom(proxy: proxy)
                            }
                        }
                        .onChange(of: currentSession.errorDesc) {
                            scrollToBottom(proxy: proxy)
                        }
                        .onChange(of: currentSession.conversations.last?.content) {
                            if !shouldStopScroll {
                                scrollToBottom(proxy: proxy, animated: true)
                            }
                        }
                        .onChange(of: currentSession.conversations.count) {
                            shouldStopScroll = false
                        }
                        .onChange(of: currentSession.inputImages) {
                            if !currentSession.inputImages.isEmpty {
                                scrollToBottom(proxy: proxy, animated: true)
                            }
                        }
                        .onChange(of: currentSession.isAddingConversation) {
                            scrollToBottom(proxy: proxy)
                        }
                        
                        .onChange(of: viewModel.selectedDialogue) { oldValue, newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                scrollToBottom(proxy: proxy)
                            }
                        }
                        .onChange(of: currentSession.configuration.model) { oldValue, newValue in
                             
                        }
                        
                        
                        .alert("Rename Session", isPresented: $showRenameDialogue) {
                            TextField("Enter new name", text: $newName)
                            Button("Rename", action: {
                                currentSession.rename(newTitle: newName)
                            })
                            Button("Cancel", role: .cancel, action: {})
                        }
                        .sheet(isPresented: $showSysPromptSheet) {
                            sysPromptSheet
                        }
                        .sheet(isPresented: $showPreviewSheet) {
                            
                            if let msgContent = currentSession.conversations.last?.content {
                                
                                if let paste = UIPasteboard.general.string , paste.count > 100 , paste.contains("</svg>") {
                                    PreviewCode(msgContent: paste)
                                        .presentationDetents([.large])
                                        .presentationDragIndicator(.visible)
                                }else{
                                    PreviewCode(msgContent: msgContent)
                                        .presentationDetents([.large])
                                        .presentationDragIndicator(.visible)
                                }
                            }
                            
                        }
                    }
                    
                }
                 
                
                .sheet(isPresented: $showStoreSheet) {
                    
                    StoreView2(viewModel:viewModel)
                        .presentationDragIndicator(.visible) // 显示拖拽指示器
                }
                
                .sheet(isPresented: $showTipsSheet) {
                    PromptsListView(viewModel:viewModel) // 半屏页面内容
                        .presentationDetents([.large]) // 设置半屏高度
                        .presentationDragIndicator(.visible) // 显示拖拽指示器
                }
                .sheet(isPresented: $showSettingView) {
                    SettingsView()
                }
                .safeAreaInset(edge: .top) {
                    if !viewModel.searchText.isEmpty {
                        HStack {
                            Text("Searched:")
                                .bold()
                                .font(.callout)
                            Text(viewModel.searchText)
                                .font(.callout)
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    viewModel.searchText = ""
                                }
                            } label: {
                                Text("Clear")
                            }
                        }
                        .padding(10)
                        //.background(.blue)
                    }
                }
                
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    IOSInputView(session: currentSession, focused: _isTextFieldFocused , onAtModelBtnTap: { isAtModel in
                        
                        hasAtModel = isAtModel
                        isEditing = isAtModel
                        
                        if isAtModel {
                            
                        }else{
                            currentSession.configuration.model = selectedModelString
                            currentSession.configuration.atModel = ""
                        }
                    }, previewBtnTap: { preview in
                        //预览
                        currentSession.previewOn = preview
                        currentSession.save()
                    }, clearContextBtnTap: { clearContext in
                        //clear context
                        if clearContext {
                            //清除上下文
                            
                            if currentSession.resetMarker == -1 {
                                currentSession.resetContext()
                            }else{
                                //恢复上下文
                                currentSession.removeResetContextMarker()
                            }
                        }else{
                            //恢复上下文
                            currentSession.removeResetContextMarker()
                        }
                        
                    },atModelString: currentSession.configuration.atModel.isEmpty ? $atModelNil :  $currentSession.configuration.model)
                    .background(.background)
                    
                    
                }
                .offset(x:0,y:10)
                
                .animation(.spring(), value: isEditing)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .cornerRadius(10)
                
                
                
                // 搜索弹出框
                .overlay(alignment: .top) {
                    
                    // View2 弹出层
                    Group{
                        
                        
                        if isEditing {
                            VStack(spacing: 0) {
                                // 搜索结果列表
                                List {
                                    ForEach(filteredModels) { model in
                                        ZStack(alignment: .leading) {
                                            Color.clear
                                                .contentShape(Rectangle())
                                            
                                            Button(action: {
                                                
                                                if !currentSession.configuration.atModel.isEmpty && !hasAtModel {
                                                    currentSession.configuration.atModel = model.id
                                                    selectedModelString = currentSession.configuration.atModel
                                                    
                                                    endEditing()
                                                }else if hasAtModel {
                                                    currentSession.configuration.atModel = currentSession.configuration.atModel.isEmpty ? currentSession.configuration.model : currentSession.configuration.atModel
                                                    
                                                    selectedModelString = currentSession.configuration.atModel
                                                    
                                                    currentSession.configuration.model = model.id
                                                    atModelString = model.id
                                                    hasAtModel = false
                                                    
                                                    endEditing()
                                                }else{
                                                    DispatchQueue.main.async {
                                                        selectedModelString = "\(model.id)"
                                                        currentSession.configuration.model = model.id
                                                        
                                                        endEditing()
                                                    }
                                                }
                                                
                                            }) {
                                                HStack {
                                                    
                                                    Text("\(model.id)").frame(width: 200, height: 40, alignment: .leading)
                                                    Spacer()
                                                    if searchText.isEmpty {
                                                        Text("\(model.id)") .font(.caption) .foregroundColor(.gray)
                                                    }
                                                }
                                                .contentShape(Rectangle())
                                            }
                                            .padding(.horizontal)
                                            .foregroundColor(.primary)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                    }
                                    
                                    if filteredModels.isEmpty && !searchText.isEmpty {
                                        Text("未找到\"\(searchText)\"的结果")
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .listRowBackground(Color.clear)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listStyle(.plain)
                                .frame(height: min(400, CGFloat(filteredModels.count * 80)))
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .padding(.top, 10)
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                        }
                    }
                }
                 
                
            }
             
            
            
            // 侧边菜单
            if showDialogList {
                
                Color.black.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        //withAnimation {
                        //}
                        showDialogList = false
                    }
                
                LeadingView(viewModel:viewModel, isPresented: $showDialogList, offsetX: $offsetX, presentViewTypeTap: { type in
                    if type == PresentViewType.prompt {
                        showTipsSheet = true
                    }else{
                        showStoreSheet = true
                    }
                })
                .frame(height: UIScreen.main.bounds.height*1.01)
                .transition(.move(edge: .leading))
                .zIndex(0)
            }
            
            
            // 半透明背景
            if isMenuVisible {
                Color.red.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        closeMenu()
                    }
            }
             
            // 侧边菜单
            SideMenuView()
                .frame(width: menuWidth)
                .offset(x: offsetX - menuWidth)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            handleDragChange(gesture)
                        }
                        .onEnded { gesture in
                            handleDragEnd(gesture)
                        }
                )
            
        }
        .onAppear {
            if !hasLoadedModels {
                Task {
                    await loadModelsData()
                }
            }
        }
        .animation(.snappy, value: showDialogList)
        
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    guard gesture.startLocation.x < 20 else { return }
                    handleDragChange(gesture)
                }
                .onEnded { gesture in
                    guard gesture.startLocation.x < 20 else { return }
                    handleDragEnd(gesture )
                }
        )
        
        
    }
    
    
    
    private func handleDragChange(_ gesture: DragGesture.Value) {
            let translationX = gesture.translation.width
            // 限制最大拖动距离
            let newOffset = min(max(translationX, 0), menuWidth)
            offsetX = newOffset
            isMenuVisible = true
        }
        
        private func handleDragEnd(_ gesture: DragGesture.Value) {
            let velocityX = gesture.predictedEndLocation.x - gesture.location.x
            let threshold: CGFloat = menuWidth / 2
            
            // 根据拖动距离和速度决定是否打开菜单
            if offsetX > threshold || velocityX > 800 {
                openMenu()
            } else {
                closeMenu()
            }
        }
        
        private func openMenu() {
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                offsetX = menuWidth
                isMenuVisible = true
            }
        }
        
        private func closeMenu() {
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                offsetX = 0
                isMenuVisible = false
            }
        }
    
    
    func loadModelsData() async {
        
        NetworkManager.shared.fetchModels { result in
            // 可以在这里处理回调，或者直接依赖 @Published 属性
            switch result {
            case .success(let models):
                //print("获取到的模型数据：\(models)")
                
                DispatchQueue.main.async {
                    // 例如更新某个 @State 变量
                    
                    
                    
                    self.ai302Models = models
                     
                    ModelDataManager.shared.saveModels(models)
                    hasLoadedModels = true
                }
                
            case .failure(let error):
                // 处理错误
                print("请求失败：\(error.localizedDescription)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    Task {
                        await loadModelsData()
                    }
                }
                
            }
        }
    }
    
    func truncateMiddle(_ text: String, maxLength: Int) -> String {
        guard text.count > maxLength else { return text }
        
        let prefix = text.prefix(maxLength / 2)
        let suffix = text.suffix(maxLength / 2)
        return "\(prefix)...\(suffix)"
    }
    
  
    func loadData() async {
        self.ai302Models = NetworkManager.shared.models
    }
    
    
    
    private func startEditing() {
        isEditing = true
        isFocused = true
    }
    
    private func endEditing() {
        isEditing = false
        isFocused = false
        searchText = "" // 清空搜索词（可选）
    }
    
    struct SubMenuView: View {
        let title: String
        let items: [String]
        
        var body: some View {
            List(items, id: \.self) { item in
                Text(item)
            }
            .navigationTitle(title)
        }
    }
    
    
    private var navTitle: some View {
        
        HStack{
            Text("123")
        }
        
                
         
    }
    
    private var ScrollSpacer: some View {
        Spacer()
            .id("bottomID")
            .onAppear {
                showScrollButton = false
            }
            .onDisappear {
                showScrollButton = true
            }
    }

    private func scrollBtn(proxy: ScrollViewProxy) -> some View {
        Button {
            scrollToBottom(proxy: proxy)
        } label: {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(.foreground.secondary, .ultraThickMaterial)
                .padding(.bottom, 15)
                .padding(.trailing, 15)
        }
        .opacity(showScrollButton ? 1 : 0)
    }

    private var sysPromptSheet: some View {
        NavigationView {
            Form {
                //TextField("System Prompt", text: $currentSession.configuration.systemPrompt, axis: .vertical)
                //.lineLimit(4, reservesSpace: true)
            }
            .navigationTitle("System Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    showSysPromptSheet = false
                }
            }
        }
    }
}
 


struct SideMenuView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.blue
            
            VStack(alignment: .leading, spacing: 20) {
                Text("菜单选项")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "house")
                        Text("首页")
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "gear")
                        Text("设置")
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}



#endif
