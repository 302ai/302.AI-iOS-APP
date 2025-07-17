import SwiftUI
import AlertToast


struct SettingsView: View {
    // 状态管理
    @State private var selectedTheme = "light"
    @State private var selectedLanguage = "简体中文"
    @State private var fontSize: FontSize = .normal
    @State private var showClearButton = true
    @State private var enableLinkExtraction = false
    @State private var enablePreview = false
    
    @State private var selectedStyle = "默认风格"
    @State private var enableMemory = true
    @State private var systemPrompts = true
    @State private var syncPassword = ""
    @State private var showUploadAlert = false
    @State private var showDownloadAlert = false
    
    @State private var enableLivePreview = false
    @State private var useOfficialPrompts = false
    @State private var enableWebSearch = false
    
    @State private var showApiListView = false
    @State private var showHelpModal = false
     
    @ObservedObject var config = AppConfiguration.shared
    
    let languageStyles = ["默认风格", "正式风格", "简洁风格", "解释性风格"]
      
    @EnvironmentObject var store: ApiItemStore
    @EnvironmentObject var dataManager : ApiDataManager
    @EnvironmentObject var fontSettings: FontSettings
    
    
    @State var showPopup = false
    
    @State private var showItemDetailView = false
    @State var isShowToast = false
    @State private var hintText: String?
    
    // 字体大小选项
    enum FontSize: String, CaseIterable {
        case normal = "正常"
        case large = "大"
        case extraLarge = "特大"
    }
    
    var body: some View {
         
        ZStack {
            
            
            NavigationStack {
                List {
                    // 第一组：基本设置
                    
                    Section(header: CustomText("设置")) {
                        
                        NavigationLink(destination: ApiItemDetailView2()) {
                            HStack {
                                CustomText("API列表")
                                Spacer()
                                
                                if let currentItem = dataManager.selectedItem {
                                    CustomText("\(currentItem.name)")
                                        .foregroundColor(.gray)
                                } else {
                                    CustomText("没有可用的API配置")
                                        .foregroundColor(.gray)
                                }
                                
                            }
                        }
                          
                    }
                     
                     
                    // 第二组：外观
                    Section {
                        
                        NavigationLink(destination: AvatarSettingsView()) {
                            HStack {
                                CustomText("头像")
                                Spacer()
                            }
                        }
                         
                        
                        NavigationLink(destination: FontSettingsView().environmentObject(fontSettings) ) {
                            HStack {
                                CustomText("字体大小")
                                Spacer()
                            }
                        }
                        
                        
                    }
                    
                    // 第三组：功能开关
                    Section {
                        Toggle(isOn: $config.isShowClearContext){
                            CustomText("是否显示清除上下文按钮")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                        
                    }
                    
                    
                    // 第一组：基础功能
                    Section {
                        
                        Toggle(isOn: $config.fileParseOn){
                            CustomText("开启链接内容提取")
                        }
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                    } footer: {
                        CustomText("开启后，会自动提取链接里的文本内容")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // 第二组：预览功能
                    Section {
                        Toggle(isOn: $config.previewOn){
                            CustomText("实时预览功能（Beta）")
                        }
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                        
                    } footer: {
                        VStack(alignment: .leading, spacing: 4) {
                            CustomText("类似于Claude官方机器人的Artifacts功能")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                    
                    
                    Section {
                        
                        Toggle(isOn: $config.artifactsPromptsOn){
                            CustomText("使用官方Artifacts提示词")
                        }
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                    } footer: {
                        VStack(alignment: .leading, spacing: 4) {
                            CustomText("如果使用非Claude模型，有可能不生效")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                    
                    
                    // 第三组：搜索功能
                    Section {
                        Toggle(isOn: $config.isWebSearch){
                            CustomText("搜索服务")
                        }
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                    } footer: {
                        CustomText("可为模型增加联网搜索能力")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    
                    // 系统提示词
                    Section {
                        Toggle(isOn: $config.isCustomPromptOn){
                            CustomText("注入系统提示词")
                        }
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                        
                        NavigationLink {
                            CustomPromptView()
                            
                        } label: {
                            HStack {
                                CustomText("系统提示词")
                                Spacer()
                                CustomText("自定义")
                                    .foregroundColor(.gray)
                                
                            }
                        }
                    }
                    
                     
                    
                    // 第7组：关于
                    Section {
                        Button {
                            UIApplication.shared.open(URL(string: "https://302.ai/")!)
                        } label: {
                            HStack{
                                CustomText("302.AI官网")
                                Spacer()
                                Image("applogo")
                                    .resizable()
                                    .frame(width: 30,height:30)
                            }
                        }
 
                        
                        
                    } header: {
                        CustomText("关于")
                            .font(.headline)
                    }
                    
                }
                .navigationTitle("设置")
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(.insetGrouped)
                
                
                
                
            }
//            .onAppear {
//                if let selectedItem = dataManager.selectedItem {
//                    ApiItemDetailView(isItemDetailPresented: $showApiListView)
//                        .environmentObject(dataManager)
//                } else {
//                    CustomText("没有可用的API配置")
//                        .onAppear {
//                            // 确保至少有一个默认项
//                            if dataManager.apiItems.isEmpty {
//                                dataManager.apiItems = ApiItem.presetItems
//                                dataManager.selectedItemId = dataManager.apiItems.first?.id
//                                dataManager.saveData()
//                            }
//                        }
//                }
//            }
            
 
            // 蒙版和View2
//            if showItemDetailView {
//                // 半透明蒙版
//                Color.black.opacity(0.5)
//                    .edgesIgnoringSafeArea(.all)
//                    .onTapGesture {
//                        withAnimation {
//                            //showView2 = false
//                        }
//                    }
//                
//                // View2
//                ApiItemDetailView(isItemDetailPresented: $showItemDetailView)
//                    .frame(width: 400, height: 500)
//                    .background(Color.white)
//                    .cornerRadius(15)
//                    .shadow(radius: 10)
//                    .transition(.scale.combined(with: .opacity))
//                    .zIndex(1)
//            }

        }
        
        .toast(isPresenting: $isShowToast){
              
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        
        if showHelpModal {
            // 半透明蒙版
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        //showView2 = false
                    }
                }
            
            // View2
            HelpView(isPresented: $showHelpModal)
                .transition(.scale.combined(with: .opacity))
        }
        
//        .popup(isPresented: $showPopup) {
//            ApiItemDetailView()
//                .environmentObject(dataManager)
//                .frame(width: UIScreen.main.bounds.width*0.85,height: UIScreen.main.bounds.height*0.6)
//                .cornerRadius(10)
//        }customize: {
//            $0
//                .appearFrom(.centerScale)
//                .closeOnTap(false)
//                .closeOnTapOutside(true)
//                .backgroundColor(.black.opacity(0.7))
//
//        }
                
    }
    
    
    private func uploadChatRecords() {
        print("开始上传聊天记录...")
        
        self.hintText = "上传聊天(敬请期待)"
        
        isShowToast.toggle()
        
        // 3秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isShowToast = false
            hintText = nil
        }
        
        
        // 实际网络请求逻辑
    }
    
    private func downloadChatRecords() {
        //guard !syncPassword.isEmpty else { return }
        print("开始下载聊天记录，密码: \(syncPassword)")
        
        hintText = "下载聊天(敬请期待)"
        
        isShowToast.toggle()
        
        // 3秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isShowToast = false
            hintText = nil
        }
        
        
        // 实际网络请求逻辑
    }
    
    private func saveSettings() {
        // 实际保存逻辑
        print("""
            保存设置：
            - 清除按钮: \(showClearButton)
            - 链接提取: \(enableLinkExtraction)
            - 实时预览: \(enableLivePreview)
            - 官方提示词: \(useOfficialPrompts)
            - 联网搜索: \(enableWebSearch)
            """)
        
        
        hintText = "已保存"
        isShowToast.toggle()
        // 3秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isShowToast = false
            hintText = nil
        }
        
    }
    
    
}


// MARK: - 子视图
struct StyleSelectionView: View {
    @Binding var selectedStyle: String
    let styles = ["默认风格", "专业风格", "轻松风格", "学术风格"]
    
    var body: some View {
        List(styles, id: \.self) { style in
            Button {
                selectedStyle = style
            } label: {
                HStack {
                    CustomText(style)
                    Spacer()
                    if selectedStyle == style {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("语言风格")
    }
}

 
//struct AvatarSettingsView: View {
//    var body: some View {
//        VStack{
//            VStack{}
//                .frame(height:30)
//            CustomText("😀 ")
//                .navigationTitle("头像")
//                .frame(width: 20, height: 20)
//                .padding(10)
//                .overlay( RoundedRectangle(cornerRadius: 6)
//                            .stroke(Color.gray, lineWidth: 0.5))
//            Spacer()
//            VStack{}
//        }
////        CustomText("头像设置页面")
////            .navigationTitle("头像")
//    }
//}

struct SendKeySettingsView: View {
    var body: some View {
        CustomText("发送键设置页面")
            .navigationTitle("发送键")
    }
}

struct PersonalInfoView: View {
    var body: some View {
        Form {
            Section {
                TextField("姓名", text: .constant(""))
                TextField("职业", text: .constant(""))
                TextField("兴趣爱好", text: .constant(""))
            }
            
            Section {
                Toggle("本地存储", isOn: .constant(true))
                Toggle("同步到云端", isOn: .constant(false))
            }
        }
        .navigationTitle("个人信息管理")
    }
}
 



// 预览
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
