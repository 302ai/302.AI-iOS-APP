//
//  ApiListView2.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/10.
//

import SwiftUI



struct ApiItem: Identifiable, Codable, Equatable {
     
    
    var id = UUID()
    var name: String
    var host: String
    var apiKey: String
    var model: AI302Model
    var apiNote: String
    
    // 示例预设数据
    static var presetItems: [ApiItem] {
        
        //CHN CN
        if AppConfiguration.shared.appStoreRegion == "CHN" || AppConfiguration.shared.appStoreRegion == "CN" || AppConfiguration.shared.appStoreRegion == "USA" {
            [
                ApiItem(name: "302.AI", host: "api.302ai.cn/cn", apiKey: AppConfiguration.shared.OAIkey.isEmpty ? "" : AppConfiguration.shared.OAIkey, model: AI302Model(id: "deepseek-chat",is_moderated: false), apiNote: ""),
                ApiItem(name: "智谱AI", host: "open.bigmodel.cn", apiKey: "", model: AI302Model(id: "glm-g-plus",is_moderated: true), apiNote: ""),
                ApiItem(name: "自定义", host: "xxx.xxxai.com", apiKey: "", model: AI302Model(id:"your-model-id",is_moderated: true), apiNote: "")
            ]
        }else if AppConfiguration.shared.appStoreRegion == "" {
            [
                ApiItem(name: "302.AI", host: "api.302ai.cn/cn", apiKey: "", model: AI302Model(id: "deepseek-chat",is_moderated: false), apiNote: ""),
                ApiItem(name: "智谱AI", host: "open.bigmodel.cn", apiKey: "", model: AI302Model(id: "glm-g-plus",is_moderated: true), apiNote: ""),
                ApiItem(name: "自定义", host: "xxx.xxxai.com", apiKey: "", model: AI302Model(id:"your-model-id",is_moderated: true), apiNote: "")
            ]
        }else {
            [
                ApiItem(name: "302.AI", host: "api.302.ai", apiKey: AppConfiguration.shared.OAIkey.isEmpty ? "" : AppConfiguration.shared.OAIkey, model: AI302Model(id: "gpt-4.1",is_moderated: true), apiNote: ""),
                ApiItem(name: "OpenAI", host: "api.openai.com", apiKey: "", model: AI302Model(id: "gpt-4.1",is_moderated: true), apiNote: ""),
                ApiItem(name: "Anthropic", host: "api.anthropic.com", apiKey: "", model: AI302Model(id:"claude-3-5-sonnet-latest",is_moderated: true), apiNote: ""),
                ApiItem(name: "自定义", host: "xxx.xxxai.com", apiKey: "", model: AI302Model(id:"your-model-id",is_moderated: true), apiNote: "")
            ]
        }
        
        
    }
}




class ApiDataManager: ObservableObject {
    
    static let shared = ApiDataManager()
    
    @Published var apiItems: [ApiItem] = []
    
    @Published var selectedItemId: UUID? {
            didSet {
                // 当 selectedItemId 变化时，自动存储到 UserDefaults
                if let selectedId = selectedItemId {
                    UserDefaults.standard.set(selectedId.uuidString, forKey: "selectedItemId")
                } else {
                    UserDefaults.standard.removeObject(forKey: "selectedItemId")
                }
            }
        }
    
    
    static let availableModels = [ "Doubao-pro-32k", "qwen-vl-max" , "deepseek-chat" ]
    
    var selectedItem: ApiItem? {
        if let selectedItemId = selectedItemId {
            return apiItems.first { $0.id == selectedItemId }
        }
        return nil
    }
    
    init() {
         
        loadData()
    }
    
    private func loadData() {
        // 加载 apiItems
        
        //UserDefaults.standard.removeObject(forKey: "apiItems")
        if let data = UserDefaults.standard.data(forKey: "apiItems"), let decoded = try? JSONDecoder().decode([ApiItem].self, from: data) {
            apiItems = decoded
            
            if !AppConfiguration.shared.appStoreRegion.isEmpty && decoded.count < 3 {
                 
                apiItems = ApiItem.presetItems
                saveData()
            }
        } else {
            apiItems = ApiItem.presetItems
            saveData()
        }
        
        // 恢复 selectedItemId（如果之前存储过）
        if let savedIdString = UserDefaults.standard.string(forKey: "selectedItemId"),
           let savedId = UUID(uuidString: savedIdString),
           apiItems.contains(where: { $0.id == savedId }) {  // 确保该 ID 仍然存在
            selectedItemId = savedId
        } else {
            selectedItemId = apiItems.first?.id  // 如果没有存储或无效，则默认选第一个
        }
    }
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(apiItems) {
            UserDefaults.standard.set(encoded, forKey: "apiItems")
            UserDefaults.standard.synchronize()
            print("数据已保存到UserDefaults")
            } else {
                print("数据编码失败")
            }
    }
    
    
    
    
    func updateItem(_ item: ApiItem) {
        if let index = apiItems.firstIndex(where: { $0.id == item.id }) {
            apiItems[index] = item
            saveData()
        }
    }
    
    func selectItem(_ item: ApiItem) {
        selectedItemId = item.id
    }
}



struct ApiItemDetailView: View {
    
    @Binding var isItemDetailPresented: Bool
    
    @EnvironmentObject var dataManager: ApiDataManager
    
    //@Environment(\.presentationMode) var presentationMode  // 添加这一行获取presentationMode
    @Environment(\.dismiss) var dismiss
    
    @State private var draftItem: ApiItem  // 改为使用draftItem作为临时编辑副本
    
    @State private var isShowingList = false
    @State private var isShowingModelList = false
    
    @State private var selectedOption: String? = "selection2" // 默认选中 selection2
    
    
    
//    init() {
    init(isItemDetailPresented: Binding<Bool>) {
           self._isItemDetailPresented = isItemDetailPresented  // 注意使用下划线访问Binding的投影值
       
        // 初始化时使用空值，实际值在onAppear中设置
        _draftItem = State(initialValue: ApiItem(name: "", host: "", apiKey: "", model: AI302Model(id:"",is_moderated: true), apiNote: ""))
    }
    
    
    var body: some View {
        ZStack {
            VStack{
                HStack{
                    VStack {
                        Text("模型服务设置")
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading) // 左对齐
                            .offset(x:10,y:8)
                        Text("请选择合适的模型")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading) // 左对齐
                            .offset(x:10,y:5)
                        
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isItemDetailPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .offset(x:-10)
                        
                    }

                }
                
                ZStack {
                    Form {
                        Section(header: Text("基本信息")) {
                            HStack {
                                Text("名称:")
                                    .foregroundColor(.gray)
                                Spacer()
                                  
                                Button(action: {
                                    isShowingList = true
                                }) {
                                    Text(draftItem.name)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(8)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                 
                                
                            }
                            
                            
                            HStack{
                                Text("Host:")
                                    .foregroundColor(.gray)
                                Spacer()
                                TextField("api.302.ai", text: $draftItem.host)
                            }
                            
                            
                            
                            HStack{
                                
                                Text("API Key:")
                                    .foregroundColor(.gray)
                                Spacer()
                                TextField("API Key", text: $draftItem.apiKey)
                            }
                            
                            
                            
                            
                            HStack{
                                //TextField("模型", text: $draftItem.model)
                                Text("模型:")
                                    .foregroundColor(.gray)
                                Spacer()
                                
                                Button(action: {
                                    isShowingModelList = true
                                }) {
                                    Text(draftItem.model.id)
                                        .foregroundColor(.blue)
                                }
                                //Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                
                            }
                            
                            
                            // 修改模型字段为可点击选择
//                            HStack {
//                                Text("模型")
//                                Spacer()
//                                Button(action: {
//                                    isShowingModelList = true
//                                }) {
//                                    HStack {
//                                        Text(draftItem.model.isEmpty ? "选择模型" : draftItem.model)
//                                        Image(systemName: "chevron.right")
//                                            .foregroundColor(.gray)
//                                    }
//                                    .foregroundColor(draftItem.model.isEmpty ? .gray : .primary)
//                                }
//                            }
                            
                            
                        }
                        
                        Section(header: Text("备注")) {
                            TextEditor(text: $draftItem.apiNote)
                                .frame(minHeight: 50)
                        }
                        
                        Section(header: Text("一键检测输入的API,域名是否有效")) {
                            Button(action: {
                                print("保存")
                            }) {
                                
                                Text("保存")
                                    .backgroundStyle(.blue)
                                
                            }
                        }
                        
                    }
                    .navigationTitle("API详情")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("保存") {
                                // 确保保存操作正确执行
                                print("正在保存项目: \(draftItem)")
                                if let selectedId = dataManager.selectedItemId {
                                    var updatedItem = draftItem
                                    updatedItem.id = selectedId
                                    print("更新前的数据: \(dataManager.apiItems)")
                                    dataManager.updateItem(updatedItem)
                                    print("更新后的数据: \(dataManager.apiItems)")
                                }
                                dismiss()
                                //presentationMode.wrappedValue.dismiss()  // 保存后返回上一页
                                
                            }
                        }
                    }
                    .sheet(isPresented: $isShowingModelList) {
                        ModelListView(selectedModel: $draftItem.model)
                    }
                    
    //                .sheet(isPresented: $isShowingList) {
    //                    NavigationView {
    //                        ApiItemListView()
    //                    }
    //                }
                    .onAppear {
                        // 每次视图出现时，从dataManager加载当前选中的item
                        if let currentItem = dataManager.selectedItem {
                            draftItem = currentItem
                        }
                    }
                    .onChange(of: dataManager.selectedItem) { newItem in
                        // 当selectedItem变化时更新draftItem
                        if let newItem = newItem {
                            draftItem = newItem
                        }
                    }
                    
                }
                
            }.background(.background)

            
            // 蒙版和View2
            if isShowingList {
                // 半透明蒙版
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            //isShowingList = false  //点击蒙版消失
                        }
                    }
                
                // View2
                ApiItemListView(isShowingList: $isShowingList)
                    .frame(width: 300, height: 400)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
                 
    }
     
}
 

 
struct ApiItemListView: View {
    
    @Binding var isShowingList: Bool
     
    @EnvironmentObject var dataManager: ApiDataManager
    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.dismiss) var dismiss
    
    
    init(isShowingList: Binding<Bool>) {
        self._isShowingList = isShowingList
    }
    
    var body: some View {
        List {
            ForEach(dataManager.apiItems) { item in
                Button(action: {
                    dataManager.selectItem(item)
                    presentationMode.wrappedValue.dismiss()
                    
                    isShowingList = false
                    
//                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .offset(x:10,y:0)
                            Text(item.host)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .offset(x:10,y:0)
                        }
                        
                        Spacer()
                         
                        // 添加选中标记
                        if dataManager.selectedItemId == item.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle()) // 确保整个区域可点击
                }
                .foregroundColor(.primary) // 确保文字颜色不受按钮影响
                .buttonStyle(.plain) // 防止 List 的点击冲突
                .contentShape(Rectangle()) // 确保整个区域可点击
            }
        }
        .navigationTitle("选择API")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    presentationMode.wrappedValue.dismiss()
//                    dismiss()
                }
            }
        }
    }
}

 
