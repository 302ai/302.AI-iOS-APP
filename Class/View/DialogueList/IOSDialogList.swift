//
//  IOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if !os(macOS)
import SwiftUI
import OpenAI
import SwiftUIIntrospect

struct IOSDialogList: View {
     
    
    @Bindable var viewModel: DialogueViewModel
    @State var imageSession: ImageSession = .init()
    @State var navigateToImages = false

    @State private var showSettingView = false //设置
    @State private var showStoreSheet = false // 应用商店
    @State private var showTipsSheet = false // 提示词
    
    @State private var models = [AI302Model]()
    @State private var hasLoadedModels = false
    
    @ObservedObject var config = AppConfiguration.shared
    @State var showAlert = false
    @State private var showHelpModal = false
      
    @State private var lastContentOffset: CGFloat = 0
    @State private var isSearchBarVisible = false
    @State private var lastTriggerTime: Date? // 记录上次触发时间
    @State private var debounceTask: DispatchWorkItem? // 防抖任务
    
    var body: some View {
        ZStack{
            VStack {
                
                HStack{
                    VStack(alignment:.leading) {
                        Text("302.AI") // 主标题
                            .font(.title3)
                            .offset(x:0 ,y: -2)
                        Text("一键生成属于自己的AI机器人") // 副标题
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .offset(x:0 ,y: -2)
                        
                    }
                    .padding()
                    .offset(y:10)
                    
                    Spacer()
                    
                    VStack{
                        Button {
                            //viewModel.addDialogue()
                            UIApplication.shared.open(URL(string: "https://302.ai/")!)
                             
                        } label: {
                            Image("applogo")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        .offset(x:0,y: -1)
                        .keyboardShortcut("n", modifiers: .command)
                    }
                    .padding()
                    .offset(y:-5)
                    
                }
                 
                
                
                HStack (spacing: 10) {
                    Button(action: {
                        if config.OAIkey.isEmpty {
                            showAlert.toggle()
                            return
                        }
                        showTipsSheet.toggle()  //提示词
                        
                    }) {
                        HStack {
                            Image("bear")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 20, height: 20)
                                .clipped()
                            
                            Text("提示词")
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,9)
                        .cornerRadius(10)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.background)
                                .shadow(radius: 1.5) // 阴影效果
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        print("应用商店 按钮 被点击")
                        if config.OAIkey.isEmpty {
                            showAlert.toggle()
                            return
                        }
                        showStoreSheet.toggle() // 点击按钮时切换状态
                    }) {
                        
                        HStack {
                            Image("shop")
                                .aspectRatio(contentMode: .fill) // 填充整个frame
                                .frame(width: 20, height: 20)
                                .clipped()
                            
                            Text("应用商店")
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,9)
                        .cornerRadius(10)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.background)
                                .shadow(radius: 1.5) // 阴影效果
                        )
                         
                    }
                }
                .padding(.horizontal,20)
                .padding(.top,5)
                
                .sheet(isPresented: $showStoreSheet) {
                    
                    StoreView2(viewModel:viewModel)
                        .presentationDragIndicator(.visible) // 显示拖拽指示器
                }
                
                .sheet(isPresented: $showTipsSheet) {
                    PromptsListView(viewModel:viewModel) // 半屏页面内容
                        .presentationDetents([.large]) // 设置半屏高度
                        .presentationDragIndicator(.visible) // 显示拖拽指示器
                }
             
                
                VStack {
                    // 1. 添加搜索文本框
                    if isSearchBarVisible {
                        TextField("搜索聊天", text: $viewModel.searchText)
                            .padding()
                            .font(.subheadline)
                            .frame(height:38)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    

                    list
                        .fullScreenCover(isPresented: $navigateToImages, onDismiss: {navigateToImages = false}) {
                            NavigationStack {
                                ImageCreator(imageSession: imageSession)
                            }
                        }
                        .animation(.default, value: viewModel.selectedState)
                        .animation(.default, value: viewModel.searchText)
                     
                        .scrollDismissesKeyboard(.immediately)//收起键盘
                        //.searchable(text: $viewModel.searchText, prompt: "搜索聊天" )
                    
    #if os(iOS)
                    
                    //.navigationTitle(viewModel.selectedState.rawValue)
                        .navigationTitle("")
                         
    #endif
                        .sheet(isPresented: $showSettingView) {
                            SettingsView()
                        }
                    
                    /*
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                
                                VStack(alignment:.leading) {
                                    Text("302.AI") // 主标题
                                        .font(.title3)
                                        .offset(x:0 ,y: -2)
                                    Text("一键生成属于自己的AI机器人") // 副标题
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .offset(x:0 ,y: -2)
                                }
                                
                            }
                            
                            ToolbarItem(placement: .automatic) {
                                Button {
                                    //viewModel.addDialogue()
                                    UIApplication.shared.open(URL(string: "https://302.ai/")!)
                                     
                                } label: {
                                    Image("applogo")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                                .offset(x:0,y: -1)
                                .keyboardShortcut("n", modifiers: .command)
                            }
                        }*/
                     
                            
                    
                    HStack {
                        HStack(spacing:20) {
                        
                            Button(action: {
                                print("设置按钮  被点击")
                                
                                showSettingView.toggle() // 点击按钮时切换状态
                            }) {
                                Image("setting")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                            }
                            //.padding(.horizontal,15)
                            .frame(width: 35, height: 35)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.background)
                                    .shadow(radius: 1.5) // 阴影效果
                            )
                            
                            
                            Button(action: {
                                print("帮助按钮  被点击")
                                showHelpModal.toggle()
                            }) {
                                Image("问号")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            //.padding(.horizontal,10)
                            .frame(width: 35, height: 35)
                            .background( RoundedRectangle(cornerRadius: 6)
                                    .fill(.background)
                                    .shadow(radius: 1.5) // 阴影效果
                            )
                            
                        }
                        .padding(.horizontal,20)
                        .sheet(isPresented: $showSettingView) {
                            SettingsView() // SettingView
                                .presentationDetents([.medium, .large]) // 设置半屏高度
                                .presentationDragIndicator(.visible) // 显示拖拽指示器
                        }
                        .sheet(isPresented: $showStoreSheet) {
                            StoreView() // StoreView
                                .presentationDetents([.medium, .large]) // 设置半屏高度
                                .presentationDragIndicator(.visible) // 显示拖拽指示器
                        }
                        
                        
                        
                        
                        Spacer()
                        
                        Button(action: {
                            if config.OAIkey.isEmpty {
                                showAlert.toggle()
                                return
                            }
                            
                            viewModel.addDialogue()
                        }) {
                            
                            HStack {
                                Image("加号")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                
                                Text("新的聊天")
                                    .foregroundColor(.primary)
                                    .font(.subheadline)
                            }
                            
                            .frame(width: 130, height: 34)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.background)
                                    .shadow(radius: 1.5) // 阴影效果
                            )
                            
                        }
                        
                    }
                    .padding(.horizontal,20)
                    .padding(.vertical,10)
                     
                }
                
                
            }
            .alert("请输入 302AI API Key", isPresented: $showAlert) {
                TextField("API Key", text: $config.OAIkey)
                Button("确定") {}
                Button("获取API Key") {
                    UIApplication.shared.open(URL(string: "https://302.ai/")!)
                }
                Button("取消", role: .cancel) {}
            }
            .background(Color.gray.opacity(0.01))
             
             
            .onAppear {
                if !hasLoadedModels {
//                    Task {
//                        await loadModelsData()
//                        
//                    }
                }
            }
             
            if showHelpModal {
                // 1. 半透明蒙版（可点击消失）
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showHelpModal = false
                    }
                    .zIndex(0)
                
                // 2. 弹窗内容（ViewB）
                HelpView(isPresented:$showHelpModal)
                    .transition(.scale) // 缩放动画
            }
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
                        self.models = models
                        ModelDataManager.shared.saveModels(models)
                        hasLoadedModels = true
                    }
                    
                case .failure(let error):
                    // 处理错误
                    print("请求失败：\(error.localizedDescription)")
                }
        }
    }
    
    struct CustomNavBarView: View {
        var body: some View {
            NavigationStack {
                ScrollView {
                    Text("内容区域")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // 左侧图片
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image("applogo") // 替换为你的图片名
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30) // 控制图片高度
                    }
                    
                    // 右侧按钮
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { print("按钮点击") }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                // 修改导航栏高度（通过透明背景+覆盖实现）
                .toolbarBackground(
                    Color.clear,
                    for: .navigationBar
                )
                .background(
                    GeometryReader { geo in
                        Color.blue.opacity(0.3) // 自定义背景色
                            .frame(height: geo.safeAreaInsets.top + 80) // 80是自定义高度
                            .edgesIgnoringSafeArea(.top)
                    }
                )
            }
        }
    }
    
    
     
    
    @ViewBuilder
    private var list: some View {
            if viewModel.shouldShowPlaceholder {
                //PlaceHolderView(imageName: "message.fill", title: viewModel.placeHolderText)
            } else {
                    List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                        DialogueListItem(session: session)
                            .listRowSeparator(.hidden) // 隐藏分割线
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(
                                            key: ScrollOffsetKey.self,
                                            value: geometry.frame(in: .named("List")).minY
                                        )
                                }
                            )
                    }
                    //.listStyle(.plain)
                    .coordinateSpace(name: "List")
                    .listStyle(.plain)
                    .onPreferenceChange(ScrollOffsetKey.self) { offset in
                        handleScrollOffsetChange(offset)
                        
//                        // 取消之前的防抖任务（避免堆积）
//                        debounceTask?.cancel()
//                        // 创建新的防抖任务（延迟 0.2 秒执行）
//                        let task = DispatchWorkItem {
//                            handleScrollOffsetChange(offset)
//                        }
//                        debounceTask = task
//                        // 0.2 秒后执行（防抖）
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: task)
                    }
                    .introspect(.list, on: .iOS(.v16, .v17)) { tableView in
                        tableView.bounces = false // 禁用回弹
                    }
            }
        
    }
    
    
    
    /// 处理滚动偏移变化（带冷却时间）
    private func handleScrollOffsetChange(_ offset: CGFloat) {
        let now = Date()

        // 如果上次触发时间在 5 秒内，则忽略
//        if let lastTime = lastTriggerTime, now.timeIntervalSince(lastTime) < 3 {
//            return
//        }

        let scrollDelta = offset - lastContentOffset
        lastContentOffset = offset

        let isBouncing = offset < 0 // 过滤回弹
        guard !isBouncing else { return }

        //let threshold: CGFloat = 10
        let isScrollingUp = scrollDelta > 50//threshold
        let isScrollingDown = scrollDelta < -50//threshold

        withAnimation(.smooth) {
             
            if isScrollingUp {
                isSearchBarVisible = false
            } else if isScrollingDown  {
                isSearchBarVisible = true
            }
             
            //print("offset: \(String(format: "%.2f", offset))")
            
            
        }

        lastTriggerTime = now // 记录本次触发时间
    }
}
    



 


// 自定义 PreferenceKey 用于获取滚动偏移量
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}




#endif
