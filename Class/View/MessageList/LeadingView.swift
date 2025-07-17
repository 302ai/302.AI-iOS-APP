//
//  LeadingView.swift
//  GPTalks
//
//  Created by Adswave on 2025/5/29.
//

import SwiftUI
 
  

#if !os(macOS)
import SwiftUI
import OpenAI
import SwiftUIIntrospect

enum PresentViewType: String {
    case prompt = "Prompt"  //提示词
    case store = "Store"  //应用商店
}


struct LeadingView: View {
     
    
    @Bindable var viewModel: DialogueViewModel
    @State var imageSession: ImageSession = .init()
    @State var navigateToImages = false
    @Binding var isPresented: Bool
    @Binding var offsetX: CGFloat
    
    var presentViewTypeTap: (PresentViewType) -> Void
    
    @State private var showSettingView = false //设置
    @State private var showStoreSheet = false // 应用商店
    @State private var showTipsSheet = false // 提示词
    
    @State private var models = [AI302Model]()
    @State private var hasLoadedModels = false
    
    @ObservedObject var config = AppConfiguration.shared
    @State var showAlert = false
    @State private var showHelpModal = false
      
    @State private var lastContentOffset: CGFloat = 0
    @State private var isSearchBarVisible = true
    @State private var lastTriggerTime: Date? // 记录上次触发时间
    @State private var debounceTask: DispatchWorkItem? // 防抖任务
    
    
    
    var body: some View {
        HStack{
            VStack(alignment:.leading) {
                
                Spacer(minLength: 50)
                
                
                HStack{
                    Button {
                        hiddenView()
                        offsetX = 0
                        
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(Color(white: 0.3))
                    }
                    .offset(x:20)
                    
                    Spacer()
                    
                    CustomText("会话历史")
                    
                    Spacer()
                     
                    Button {
                        hiddenView()
                        offsetX = 0
                        offsetX = 0
                        viewModel.addDialogue()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color(white: 0.3))
                    }
                    .offset(x:-20)

                }
                //.offset(y:-20)
                
                Divider()
                
//                // 1. 添加搜索文本框
                if isSearchBarVisible {
                    TextField("搜索聊天", text: $viewModel.searchText)
                        .padding()
                        .font(.subheadline)
                        .frame(height:38)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                
                
                HStack (spacing: 10) {
                    Button(action: {
                        
                        if !config.apiHost.contains("302"){
                            return
                        }
                        
                        if config.OAIkey.isEmpty {
                            showAlert.toggle()
                            return
                        }
//                        showTipsSheet.toggle()  //提示词
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            hiddenView()
                        offsetX = 0
                        }
                        presentViewTypeTap(.prompt)
                        
                    }) {
                        HStack {
                            Image("bear")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 22, height: 22)
                                .clipped()
                            
                            CustomText("提示词")
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
                        
                        if !config.apiHost.contains("302"){
                            return
                        }
                        
                        if config.OAIkey.isEmpty {
                            showAlert.toggle()
                            return
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPresented = false
                        offsetX = 0
                        }
                        presentViewTypeTap(.store)
                    }) {
                        
                        HStack {
                            Image("shop")
                                .aspectRatio(contentMode: .fill) // 填充整个frame
                                .frame(width: 20, height: 20)
                                .clipped()
                            
                            CustomText("应用商店")
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
             

                
                

                list
                    .fullScreenCover(isPresented: $navigateToImages, onDismiss: {navigateToImages = false}) {
                        NavigationStack {
                            ImageCreator(imageSession: imageSession)
                        }
                    }
                    .animation(.default, value: viewModel.selectedState)
                    .animation(.default, value: viewModel.searchText)
                 
                    .scrollDismissesKeyboard(.immediately)//收起键盘
                
//                Button(action: {
//                    if config.OAIkey.isEmpty {
//                        showAlert.toggle()
//                        return
//                    }
//                    viewModel.addDialogue()
//                }) {
//                    
//                    HStack {
//                        Image("加号")
//                            .resizable()
//                            .frame(width: 22, height: 22)
//                        
//                        Text("新的聊天")
//                            .foregroundColor(.primary)
//                            .font(.subheadline)
//                    }
//                    
//                    .frame(width: UIScreen.main.bounds.width*0.85-60, height: 34)
//                    .background(
//                        RoundedRectangle(cornerRadius: 6)
//                            .fill(.background)
//                            .shadow(radius: 1.5) // 阴影效果
//                    ) 
//                }
                
                
                Spacer(minLength: 60)
                
#if os(iOS)
                
                //.navigationTitle(viewModel.selectedState.rawValue)
                    .navigationTitle("")
#endif
            }
            .offset(y:20)
            
            .sheet(isPresented: $showAlert) {
                ApiItemDetailView2()
            }
            
            
//            .alert("请输入 302AI API Key", isPresented: $showAlert) {
//                TextField("API Key", text: $config.OAIkey)
//                Button("确定") {}
//                
//                Button("获取API Key") {
//                    UIApplication.shared.open(URL(string: "https://302.ai/")!)
//                }
//                Button("取消", role: .cancel) {}
//            }
            .background(.background)
              
            .onAppear {
                if !hasLoadedModels {
//                    Task {
//                        await loadModelsData()
//
//                    }
                }
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .edgesIgnoringSafeArea(.all)
    }
        
    
    func hiddenView(){
         
        isPresented = false
        viewModel.searchText = ""
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
     
    
    @ViewBuilder
    private var list: some View {
            if viewModel.shouldShowPlaceholder {
                //PlaceHolderView(imageName: "message.fill", title: viewModel.placeHolderText)
                VStack {
                    //Spacer(minLength: UIScreen.main.bounds.height/1.5)
                    Spacer()
                    Text("")
                    Spacer()
                }
            } else {
                
                List(viewModel.currentDialogues) { session in
                    //DialogueListItem(session: session)
                    
                    Button(action: {
                            viewModel.selectedDialogue = session
                            isPresented = false
                        offsetX = 0
                            // 其他点击处理逻辑
                        }) {
                            DialogueListItem(session: session)
                        }
                        .buttonStyle(PlainButtonStyle()) // 保持列表项外观
                    
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
                
//                    List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
//                        DialogueListItem(session: session)
//                            .listRowSeparator(.hidden) // 隐藏分割线
//                            .background(
//                                GeometryReader { geometry in
//                                    Color.clear
//                                        .preference(
//                                            key: ScrollOffsetKey.self,
//                                            value: geometry.frame(in: .named("List")).minY
//                                        )
//                                }
//                            )
//                    }
                    .coordinateSpace(name: "List")
                    .listStyle(.plain)
                    .onPreferenceChange(ScrollOffsetKey.self) { offset in
                        handleScrollOffsetChange(offset)
                         
                    }
                    .introspect(.list, on: .iOS(.v16, .v17)) { tableView in
                        tableView.bounces = false // 禁用回弹
                    }
            }
        
    }
    
    
    
    /// 处理滚动偏移变化（带冷却时间）
    private func handleScrollOffsetChange(_ offset: CGFloat) {
        let now = Date()
  
        let scrollDelta = offset - lastContentOffset
        lastContentOffset = offset

        let isBouncing = offset < 0 // 过滤回弹
        guard !isBouncing else { return }
        
        let isScrollingUp = scrollDelta > 50//threshold
        let isScrollingDown = scrollDelta < -50//threshold

        withAnimation(.smooth) {
             
            if isScrollingUp {
                isSearchBarVisible = false
            } else if isScrollingDown  {
                isSearchBarVisible = true
            }
              
            
        }

        lastTriggerTime = now // 记录本次触发时间
    }
}

#endif
