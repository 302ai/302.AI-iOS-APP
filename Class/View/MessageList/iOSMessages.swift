//
//  iOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if !os(macOS)
import SwiftUI
import UniformTypeIdentifiers
import AlertToast
import UIKit
import StoreKit

// 提取消息内容为独立视图
struct MessageContentView: View {
    @Bindable var session: DialogueSession
     
    var body: some View {
        ForEach(session.conversations) { conversation in
            
            ConversationView(session: session, conversation: conversation)  
        }
    }
}



struct iOSMessages: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @Environment(DialogueViewModel.self) private var viewModel
    @EnvironmentObject var config: AppConfiguration
    
    
    @State private var lastBackgroundDate: Date?
    @State private var needsRefresh = false
    @State private var scrollToSelected = false  // 状态控制滚动
    
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
        AI302Model(id: "GPT-4o",is_moderated: true),
        AI302Model(id: "gpt4o_mini",is_moderated: true)
    ]
    
    @State private var ai302Models_moderate : [AI302Model] = [
        AI302Model(id: "GPT-4o",is_moderated: true)
    ]
    
    
    @State private var hasLoadedModels = false
    
    @State private var showDialogList = true //会话列表
    @State private var showSettingView = false //设置
    @State private var showStoreSheet = false // 应用商店
    @State private var showTipsSheet = false // 提示词
    
    private var loadModelsTimer: Timer?
    
    @State private var isShowingSideMenu = false
    @State private var dragOffset: CGFloat = 0
    //@State private var menuItems = ["首页", "个人资料", "消息中心", "设置", "帮助", "关于我们", "退出登录", "订单管理", "收藏夹", "历史记录"]
    private let sideMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    private let edgeSwipeWidth: CGFloat = 30
    private let triggerThreshold: CGFloat = 0.125 // 20%宽度触发完全显示
    
    
    
    var currentSession2: DialogueSession  {
        if let selected = viewModel.selectedDialogue {
            return selected
        } else {
            if let session1 = viewModel.allDialogues.first {
                return session1
            }else{
                viewModel.addDialogue()
                
                let session1 = viewModel.allDialogues.first!
                return session1
            }
        }
    }
    
    
    var body: some View {
          
        @Bindable var currentSession = currentSession2
        
        var sortedModels: [AI302Model] {
            ai302Models.sorted { $0.id < $1.id }
        }
        
         
        ZStack(alignment: .leading){
            VStack{
                
                // 过滤后的数据
                var filteredModels: [AI302Model] {
                    
                    guard !searchText.isEmpty else { return sortedModels }
                    
                    
                    return sortedModels.filter { model in
                        model.id.localizedCaseInsensitiveContains(searchText)
                    }
                }
                
                
                HStack{
                    //MARK: -  导航栏左侧按钮
                    Button {
                        //withAnimation {}
                        self.showDialogList = true
                        self.isShowingSideMenu = true
                        
                        dragOffset = sideMenuWidth
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
                                CustomText("[应用]\(currentSession.title)")
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
                                        Spacer(minLength: min(100,1700/CGFloat(currentSession.configuration.model.count)/1.1))
                                        HStack{
                                            CustomText(truncateMiddle(currentSession.configuration.model, maxLength: 22))
                                                .onTapGesture {
                                                    isEditing = true
                                                    isFocused = true
                                                    self.ai302Models = NetworkManager.shared.models
                                                    
                                                    print("navigation:左宽度:\(1700/CGFloat(currentSession.configuration.model.count))--右宽度:\(100/CGFloat(currentSession.configuration.model.count))")
                                                }
                                                .lineLimit(1)
                                            Image(systemName: "chevron.down")
                                                .foregroundStyle(.black)
                                        }
                                        .offset(x:CGFloat(currentSession.configuration.model.count > 12 ? 0 : 25))
                                        .transition(.scale.combined(with: .opacity))
                                         
                                        Spacer(minLength: min(100,300/CGFloat(currentSession.configuration.model.count)))
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
//                                HStack{
                                HStack{ 
                                    Spacer(minLength: min(100,1700/CGFloat(currentSession.configuration.model.count)/1.1))
                                    HStack{
                                        CustomText(truncateMiddle(currentSession.configuration.model, maxLength: 22))
                                            .onTapGesture {
                                                isEditing = true
                                                isFocused = true
                                                self.ai302Models = NetworkManager.shared.models
                                                
                                                print("navigation:左宽度:\(1700/CGFloat(currentSession.configuration.model.count))--右宽度:\(100/CGFloat(currentSession.configuration.model.count))")
                                            }
                                            .lineLimit(1)
                                        Image(systemName: "chevron.down")
                                            .foregroundStyle(.black)
                                    }
                                    .offset(x:CGFloat(currentSession.configuration.model.count > 12 ? 0 : 25))
                                    .transition(.scale.combined(with: .opacity))
                                     
                                    Spacer(minLength: min(100,300/CGFloat(currentSession.configuration.model.count)))
                                }
//                                    VStack{}
//                                        .frame(width: 80)
//                                    Spacer(minLength: 20)
//                                    HStack{
//                                        
//                                        CustomText(truncateMiddle(currentSession.configuration.model, maxLength: 26))
//                                            .onTapGesture {
//                                                isEditing = true
//                                                isFocused = true
//                                                self.ai302Models = NetworkManager.shared.models
//                                            }
//                                        Image(systemName: "chevron.down")
//                                            .foregroundStyle(.black)
//                                    }
//                                    .transition(.scale.combined(with: .opacity))
//                                    
//                                    Spacer()
//                                    VStack{}
//                                        .frame(width: 20)
//                                }
                                
                            }
                        }
                        
                    }
                    
                    //MARK: - 右侧  设置
                    HStack{
                        Button(action: {
                            print("设置被点击")
                            showSettingView.toggle()
                        }) {
                            //Image(systemName: "arrowshape.turn.up.right") // 分享
                            Image("setting") // 设置
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                        .frame(width: 44, height: 44)
                    }
                    .frame(minWidth: UIScreen.main.bounds.width/5)
                    .offset(x:0)
                    
                }
                //.background(Color.red)
                .frame(minHeight: 44)
                
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
                            .onChange(of: scenePhase) { newPhase in
                                handleScenePhaseChange(newPhase)
                            }
                            
                            .onChange(of: config.previewOn) { _ in
                                refreshData()
                            }
                            
                            .onChange(of: isEditing) { _ in
                                selectedModelString = currentSession.configuration.model
                            }
                            
                            .onChange(of: needsRefresh) { _ in
                                if needsRefresh {
                                    refreshData()
                                    needsRefresh = false
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
                            //if isTextFieldFocused {
                            //}
                            scrollToBottom(proxy: proxy, delay: 0.35)
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
                            // 当 selectedDialogue 变化时重置滚动位置等状态
    //                        if newValue != nil {
    //                            shouldStopScroll = false
    //                        }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                scrollToBottom(proxy: proxy)
                            }
                        }
                        .onChange(of: currentSession.configuration.model) { oldValue, newValue in
                            
                             
                        }
                        
                        
                        .alert("重命名会话", isPresented: $showRenameDialogue) {
                            TextField("Enter new name", text: $newName)
                            Button("重命名", action: {
                                currentSession.rename(newTitle: newName)
                            })
                            Button("取消", role: .cancel, action: {})
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
                    }.scrollIndicators(.never)
                     
                    
                }
                //.offset(y:40)
                
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
//                .safeAreaInset(edge: .top) {
//                    if !viewModel.searchText.isEmpty {
//                        HStack {
//                            CustomText("Searched:")
//                                .bold()
//                                .font(.callout)
//                            CustomText(viewModel.searchText)
//                                .font(.callout)
//                            
//                            Spacer()
//                            
//                            Button {
//                                withAnimation {
//                                    viewModel.searchText = ""
//                                }
//                            } label: {
//                                CustomText("Clear")
//                            }
//                        }
//                        .padding(10)
//                        //.background(.blue)
//                    }
//                }
                //MARK: -  ----------输入框-------------
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
                //.safeAreaPadding(.bottom,60)
                //.edgesIgnoringSafeArea(.top)
                //.offset(y:-60)
                
                
                .animation(.spring(), value: isEditing)
                .padding(.horizontal, 10)
                .padding(.vertical, 0)
                //.background(Color(.blue)) //页面背景色
                .cornerRadius(10)
                
                
                
                // 搜索弹出框
                .overlay(alignment: .top) {
                    
                    // View2 弹出层
                    Group{
                        
                        
                        if isEditing {
//                            VStack(spacing: 0) {
//                                // 搜索结果列表
//                                List {
//                                    ForEach(filteredModels) { model in
//                                        ZStack(alignment: .leading) {
//                                            Color.clear
//                                                .contentShape(Rectangle())
//                                            
//                                            Button(action: {
//                                                
//                                                if !currentSession.configuration.atModel.isEmpty && !hasAtModel {
//                                                    currentSession.configuration.atModel = model.id
//                                                    selectedModelString = currentSession.configuration.atModel
//                                                    
//                                                    endEditing()
//                                                }else if hasAtModel {
//                                                    currentSession.configuration.atModel = currentSession.configuration.atModel.isEmpty ? currentSession.configuration.model : currentSession.configuration.atModel
//                                                    
//                                                    selectedModelString = currentSession.configuration.atModel
//                                                    
//                                                    currentSession.configuration.model = model.id
//                                                    atModelString = model.id
//                                                    hasAtModel = false
//                                                    
//                                                    endEditing()
//                                                }else{
//                                                    DispatchQueue.main.async {
//                                                        selectedModelString = "\(model.id)"
//                                                        currentSession.configuration.isModerated = model.is_moderated
//                                                        currentSession.configuration.model = model.id
//                                                        
//                                                        endEditing()
//                                                    }
//                                                }
//                                                
//                                            }) {
//                                                HStack {
//                                                    
//                                                    CustomText("\(model.id)").frame(width: 300, height: 40, alignment: .leading)
//                                                    Spacer()
//                                                    if selectedModelString == model.id {
//                                                        Image(systemName: "checkmark")
//                                                            .foregroundColor(.blue)
//                                                    }
//                                                }
//                                                .contentShape(Rectangle())
//                                            }
//                                            .padding(.horizontal)
//                                            .foregroundColor(.primary)
//                                            
//                                        }
//                                        .buttonStyle(PlainButtonStyle())
//                                            
//                                    }
//                                    
//                                    if filteredModels.isEmpty && !searchText.isEmpty {
//                                        CustomText("未找到\"\(searchText)\"的结果")
//                                            .foregroundColor(.gray)
//                                            .frame(maxWidth: .infinity, alignment: .center)
//                                            .listRowBackground(Color.clear)
//                                    }
//                                }
//                                .buttonStyle(PlainButtonStyle())
//                                .listStyle(.plain)
//                                .frame(height: min(400, CGFloat(filteredModels.count * 80)))
//                            }
                            
                            VStack(spacing: 0) {
                                ScrollViewReader { proxy in
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
                                                            currentSession.configuration.isModerated = model.is_moderated
                                                            currentSession.configuration.model = model.id
                                                            
                                                            endEditing()
                                                        }
                                                    }
                                                    scrollToSelected = true  // 标记需要滚动
                                                }) {
                                                    HStack {
                                                        CustomText("\(model.id)").frame(width: 300, height: 40, alignment: .leading)
                                                        Spacer()
                                                        if selectedModelString == model.id {
                                                            Image(systemName: "checkmark")
                                                                .foregroundColor(.blue)
                                                        }
                                                    }
                                                    .contentShape(Rectangle())
                                                }
                                                .padding(.horizontal)
                                                .foregroundColor(.primary)
                                                
                                            }
                                            .id(model.id)  // 为每个项目设置唯一标识
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .onChange(of: selectedModelString) { newValue in
                                        if scrollToSelected {
                                            withAnimation {
                                                proxy.scrollTo(newValue, anchor: .center)
                                            }
                                            scrollToSelected = false
                                        }
                                    }
                                    .onAppear {
                                        // 初次显示时自动滚动到选中项
                                        withAnimation {
                                            proxy.scrollTo(selectedModelString, anchor: .center)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .listStyle(.plain)
                                    .frame(height: min(400, CGFloat(filteredModels.count * 80)))
                                }
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
                 
                 
                
            }.zIndex(0)
             
//            if showDialogList {
//                Color.black.opacity(0.2)
//                    .edgesIgnoringSafeArea(.all)
//                    .onTapGesture {
//                        //withAnimation {
//                        //}
//                        showDialogList = false
//                    }
//                
//                LeadingView(viewModel:viewModel, isPresented: $showDialogList,presentViewTypeTap: { type in
//                    if type == PresentViewType.prompt {
//                        showTipsSheet = true
//                    }else{
//                        showStoreSheet = true
//                    }
//                })
//                .frame(height: UIScreen.main.bounds.height*1.01)
//                .transition(.move(edge: .leading))
//                .zIndex(0)
//            }
            
              
            
            //MARK: - 侧边栏 半透明背景
            if isShowingSideMenu {
                Color.black.opacity(0.4)
                //Color(hex: 0x000000, alpha: 0.3)
                    .zIndex(1)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        closeMenu()
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                handleDragGesture(gesture)
                            }
                            .onEnded { gesture in
                                handleDragEnded(gesture)
                            }
                    )
            }
            
            //侧边菜单
            //SideMenuView()
            //MARK: - 侧边栏 ----  LeadingView  -----
            LeadingView(viewModel:viewModel, isPresented: $isShowingSideMenu, offsetX: $dragOffset , presentViewTypeTap: { type in
                if type == PresentViewType.prompt {
                    showTipsSheet = true
                }else{
                    showStoreSheet = true
                }
            })
            .zIndex(2)
            .frame(width: sideMenuWidth)
            .offset(x: isShowingSideMenu ? min(0, dragOffset) : -sideMenuWidth + dragOffset)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.5), value: isShowingSideMenu)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.5), value: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        handleDragGesture(gesture)
                    }
                    .onEnded { gesture in
                        handleDragEnded(gesture)
                    }
            )
             
        }
        //.safeAreaPadding(.top,80)
        .onReceive(NotificationCenter.default.publisher(
            for: Notification.Name(FontSettings.kFontSettingsSetFontSize))
        ) { _ in
            refreshData()
        }
        
        .onAppear {
            if !hasLoadedModels {
                Task {
                    await loadModelsData()
                }
                 
            }
            
        }
        
        .onAppear {
            Task {
                let region = await checkAppStoreRegion()
                print("国家/地区:\(region)")
                
               
                 
            }
        }
         
//        .onAppear {
//            Task {
//                let region = await fetchAppStoreRegion()
//                print("国家/地区:\(region)")
//            }
//        }
        
        .animation(.smooth, value: isShowingSideMenu)
        
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if isShowingSideMenu && gesture.translation.width < 0 {
                        dragOffset = max(gesture.translation.width, -sideMenuWidth)
                    }
                }
                .onEnded { gesture in
                    if isShowingSideMenu {
                        handleDragEnded(gesture)
                    }
                }
        )
    }
     
    
    @MainActor
    func checkAppStoreRegion() async -> String? {
        do {
            let storefront = try await Storefront.current
            
            //CHN CN
            let region = storefront?.countryCode
            config.appStoreRegion =  region ?? "Unknown"
            
            return region
        } catch {
            print("Error getting storefront: \(error)")
            return nil
        }
    }
    
//    @MainActor
//    func fetchAppStoreRegion() async -> String? {
//        //let region = Locale.current.region?.identifier
//        //return region
//        
//        if #available(iOS 13.0, *) {
//               let queue = SKPaymentQueue.default()
//               if let storefront = queue.storefront {
//                   let countryCode = storefront.countryCode // 如 "GBR"
//                   return countryCode
//                   print("App Store Country Code: \(countryCode)")
//               } else {
//                   return "未知"
//                   print("Failed to retrieve storefront info")
//               }
//           }
//        
//        
//    }
    
    
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
            switch newPhase {
            case .background:
                // 记录进入后台的时间
                lastBackgroundDate = Date()
            case .active:
                // 检查是否在后台停留超过5分钟
                if let lastDate = lastBackgroundDate, Date().timeIntervalSince(lastDate) >= 300 {  //300
                    needsRefresh = true
                }
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        //MARK: - ------------- 刷新数据 -------------
        private func refreshData() {
            // session.loadConversations()
            print("Refreshing data after 5 minutes in background\n")
            
            print("已刷新")
//            if viewModel.allDialogues.count > 1 {
//                viewModel.selectedDialogue = viewModel.allDialogues.last
//            }
            if currentSession2.conversations.count > 1 {
                let cons = currentSession2.conversations
                currentSession2.conversations.removeAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    currentSession2.conversations = cons
                }
            }
                
            
            
            //currentSession2.conversations = Array(currentSession2.conversations)
             
        }
    
    
    //MARK: - 侧滑手势处理 -----------------------------------
    private func handleDragGesture(_ gesture: DragGesture.Value) {
        if isShowingSideMenu {
            // 菜单已显示时，处理右滑关闭
            let translation = gesture.translation.width
            if translation < 0 {
                dragOffset = translation
            } else {
                // 允许少量向右拖动（弹性效果）
                dragOffset = translation / 3
            }
        } else {
            // 菜单未显示时，处理左滑打开
            if gesture.startLocation.x < edgeSwipeWidth && gesture.translation.width > 0 {
                dragOffset = min(gesture.translation.width, sideMenuWidth)
            }
        }
    }
    
    private func handleDragEnded(_ gesture: DragGesture.Value) {
        let translation = gesture.translation.width
        let velocity = gesture.velocity.width
        
        if isShowingSideMenu {
            // 关闭菜单的逻辑
            if velocity < -800 || translation < -sideMenuWidth / 3 {
                closeMenu()
            } else {
                // 回弹到打开状态
                withAnimation(.interactiveSpring()) {
                    dragOffset = 0
                }
            }
        } else {
            // 打开菜单的逻辑
            if velocity > 500 || translation > sideMenuWidth * triggerThreshold {
                openMenu()
            } else {
                withAnimation(.interactiveSpring()) {
                    dragOffset = 0
                }
            }
        }
    }
    
    private func toggleMenu() {
        withAnimation(.interactiveSpring()) {
            isShowingSideMenu.toggle()
            dragOffset = 0
        }
    }
    
    private func openMenu() {
        withAnimation(.interactiveSpring()) {
            isShowingSideMenu = true
            dragOffset = 0
        }
    }
    
    private func closeMenu() {
        withAnimation(.interactiveSpring()) {
            isShowingSideMenu = false
            dragOffset = 0
        }
    }
    
    
    
    //MARK: - 请求模型数据 ------------------------------
    func loadModelsData() async {
        
        if config.appStoreRegion.isEmpty {
            return
        }
        
        NetworkManager.shared.fetchModels() { result in
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
                CustomText(item)
            }
            .navigationTitle(title)
        }
    }
    
    
    private var navTitle: some View {
        
        HStack{
            CustomText("123")
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

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

#endif
