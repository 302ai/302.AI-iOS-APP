//
//  ApiListView2.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/10.
//

import SwiftUI
import AlertToast
 


struct ApiItemDetailView2: View {
    
    @EnvironmentObject var dataManager: ApiDataManager
    @EnvironmentObject var config: AppConfiguration
    
    
    //@Environment(\.presentationMode) var presentationMode  // 添加这一行获取presentationMode
    @Environment(\.dismiss) var dismiss
    
    @State private var draftItem: ApiItem  // 改为使用draftItem作为临时编辑副本
    @State private var originalHost = "api.302ai.cn/cn"  //"api.302ai.cn/cn"
    
    
    @State private var isShowingList = false
    @State private var isShowingModelList = false
    
    @State private var selectedOption: String? = "selection2" // 默认选中 selection2
    @State var isShowToast = false
    @State var hintText = ""
    
    init() {
        // 初始化时使用空值，实际值在onAppear中设置
        _draftItem = State(initialValue: ApiItem(name: "", host: "", apiKey: "", model: AI302Model(id: "",is_moderated: true), apiNote: ""))
    }
    
    
    var body: some View {
        
        
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
                    if draftItem.name == "302.AI" {
                        VStack(alignment: .leading){
                            HStack{
                                Text("API Key:")
                                    .foregroundColor(.gray)
                                Spacer()
                                TextField("API Key", text: $draftItem.apiKey)
                                    
                            }
                            .padding(.bottom, 8)
                            
                            HStack{
                                Button {
                                    UIApplication.shared.open(URL(string: "https://dash.302.ai/apis/list")!)
                                } label: {
                                    Text("获取API Key")
                                        .font(.footnote)
                                        .underline() // 添加下划线
                                        .foregroundColor(.blue)
                                        
                                }
                                Spacer()
                                Text("")
                            }
                            .padding([.top,.bottom], 2)
                        }
                        
                    }else{
                        Text("API Key:")
                            .foregroundColor(.gray)
                        
                        Spacer()
                        TextField("API Key", text: $draftItem.apiKey)
                    }
                     
                    
                }
                
                HStack{
                    //TextField("模型", text: $draftItem.model)
                    Text("模型:")
                        .foregroundColor(.gray)
                    Spacer()
                    if draftItem.name == "自定义" {
                        TextField("", text: $draftItem.model.id)
                    }else{
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
                    
                    
                }
                // 修改模型字段为可点击选择
//                HStack {
//                    Text("模型")
//                    Spacer()
//                    Button(action: {
//                        isShowingModelList = true
//                    }) {
//                        HStack {
//                            Text(draftItem.model.isEmpty ? "选择模型" : draftItem.model)
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(.gray)
//                        }
//                        .foregroundColor(draftItem.model.isEmpty ? .gray : .primary)
//                    }
//                }
            }
            
            Section(header: Text("备注")) {
                TextEditor(text: $draftItem.apiNote)
                    .frame(minHeight: 50)
            }
            
            Section(header: Text("一键检测输入的API,域名是否有效")) {
                Button(action: {
                    
                    AppConfiguration.shared.isR1Fusion = false
                    AppConfiguration.shared.isWebSearch = false
                     
                     
                    saveData { success in
                        if success {
                            hintText = "保存成功"
                            isShowToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isShowToast = false
                                dismiss()
                            }
                        }else{
                            hintText = "ApiKey错误,请检查"
                            isShowToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isShowToast = false
                                //dismiss()
                            }
                        }
                    }
                    
                }) {
                    HStack(alignment:.center) {
                        //Spacer()
                        
                        Text("保存")
                            .frame(width: UIScreen.main.bounds.width, height: 44)
                                    //.background(Color.blue)
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                    }
//                    .background(Color.blue)  // 设置背景色为蓝色
//                        .cornerRadius(8)  // 可选：添加圆角
                }
                
                
            }
            
            
            
            
        }
         
        
        .navigationTitle("API详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("保存") {
//                    saveData()
//                }
            }
        }
        .sheet(isPresented: $isShowingModelList) {
            ModelListView(selectedModel: $draftItem.model)
        }
        .sheet(isPresented: $isShowingList) {
            NavigationView {
                ApiItemListView2()
            }
        }
        
        .toast(isPresenting: $isShowToast){
              
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        
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
    
    func saveData(completion: @escaping (Bool) -> Void){
          
        // 确保保存操作正确执行
        print("正在保存项目: \(draftItem)")
        if let selectedId = dataManager.selectedItemId {
             
            if (originalHost != draftItem.host) && draftItem.host.contains("302") {
                config.modifiedHost += 1
            }
            
            if (config.modifiedHost > 1) && draftItem.host.contains("302") {
                if (AppConfiguration.shared.appStoreRegion == "CHN" || AppConfiguration.shared.appStoreRegion == "CN" || AppConfiguration.shared.appStoreRegion == "USA"){
                    draftItem.host = "api.302ai.cn"
                }else{
                    draftItem.host = "api.302.ai"
                }
            }
            
            var updatedItem = draftItem
            updatedItem.id = selectedId
            print("更新前的数据: \(dataManager.apiItems)")
            
            
            
            
            config.OAIkey = updatedItem.apiKey
            config.ai302Model = updatedItem.model.id
            config.apiHost = updatedItem.host
            
            dataManager.updateItem(updatedItem)
            print("更新后的数据: \(dataManager.apiItems)")
        }
        
        NetworkManager.shared.fetchModels { result in
            // 可以在这里处理回调，或者直接依赖 @Published 属性
            switch result {
            case .success(let modelsData):
                //print("获取到的模型数据：\(result)")
                NetworkManager.shared.models = modelsData
                ModelDataManager.shared.saveModels(modelsData)
                completion(true)
            case .failure(let error):
                // 处理错误
                //print("请求失败：\(error.localizedDescription)")
                completion(false)
            }
        }
        
        
        
         
    }
     
}
 

 
struct ApiItemListView2: View {
      
    @EnvironmentObject var dataManager: ApiDataManager
    @Environment(\.presentationMode) var presentationMode
    
     
    var body: some View {
        List {
            ForEach(dataManager.apiItems) { item in
                Button(action: {
                    dataManager.selectItem(item)
                    presentationMode.wrappedValue.dismiss()
                    
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
                    }.contentShape(Rectangle()) // 使整个区域可点击
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
                }
            }
        }
    }
}

 

struct ModelListView: View {
   @Binding var selectedModel: AI302Model
   @Environment(\.presentationMode) var presentationMode
   @State private var searchText = ""
    @State private var isSearching = true
   
   var body: some View {
       //let models = ModelDataManager.shared.loadModels()
        
       var sortedModels: [AI302Model] {
           ModelDataManager.shared.loadModels().sorted { $0.id < $1.id }
       }
       
       
       let filteredModels = sortedModels.filter {
           searchText.isEmpty || $0.id.localizedCaseInsensitiveContains(searchText)
       }
       
       NavigationView {
           VStack(spacing: 0) {
               // 搜索栏
               HStack {
                   Image(systemName: "magnifyingglass")
                       .foregroundColor(.gray)
                   TextField("搜索模型", text: $searchText) { isEditing in
                       //isSearching = isEditing
                       //isSearching = true
                   } onCommit: {
                       isSearching = false
                   }
                   .textFieldStyle(.plain)
                   .autocorrectionDisabled()
                   .textInputAutocapitalization(.never)
                   
                   if !searchText.isEmpty {
                       Button(action: {
                           searchText = ""
                       }) {
                           Image(systemName: "xmark.circle.fill")
                               .foregroundColor(.gray)
                       }
                   }
               }
               .padding(8)
               .background(Color(.systemGray6))
               .cornerRadius(8)
               .padding(.horizontal)
               .padding(.vertical, 8)
               
               // 模型列表
               ScrollViewReader { scrollProxy in
                   List(filteredModels, id: \.self) { model in
                       Button(action: {
                           selectedModel = model
                           presentationMode.wrappedValue.dismiss()
                       }) {
                           HStack {
                               Text(model.id)
                               Spacer()
                               if selectedModel == model {
                                   Image(systemName: "checkmark")
                                       .foregroundColor(.blue)
                               }
                           }
                           .contentShape(Rectangle())
                       }
                       .buttonStyle(PlainButtonStyle())
                       .onAppear {
                           // 滚动时收起键盘
                           if isSearching {
                               UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                               isSearching = false
                           }
                       }
                   }
                   .listStyle(.plain)
                   .gesture(
                       DragGesture().onChanged { _ in
                           // 滚动时收起键盘
                           if isSearching {
                               UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                               isSearching = false
                           }
                       }
                   )
               }
           }
           .navigationTitle("选择模型")
           .navigationBarTitleDisplayMode(.inline)
           .toolbar {
               ToolbarItem(placement: .navigationBarTrailing) {
                   Button("取消") {
                       presentationMode.wrappedValue.dismiss()
                   }
               }
           }
       }
   }
}




struct ModelListView2: View {
    @Binding var selectedModel: AI302Model
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationView {
            List(ModelDataManager.shared.loadModels(), id: \.self) { model in
                Button(action: {
                    selectedModel = model
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(model.id)
                        Spacer()
                        if selectedModel == model {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle()) // 使整个区域可点击
                }
                .buttonStyle(PlainButtonStyle()) // 移除按钮默认样式
            }
            .navigationTitle("选择模型")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
