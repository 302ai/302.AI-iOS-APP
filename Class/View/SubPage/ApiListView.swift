import Foundation
import SwiftUI

struct ApiItem2: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var host: String
    var apiKey: String
    var model: String
    var apiNote: String
      
    var isCurrent: Bool = false
    
    // 可选的模型列表
    static let availableModels = ["gpt-4", "gpt-4o", "gpt-3.5", "gpt-plus"]
    
    // 用于编辑时的临时存储
    var editingName: String {
        get { name }
        set { name = newValue }
    }
    
    var editingHost: String {
        get { host }
        set { host = newValue }
    }
    
    var editingApiKey: String {
        get { apiKey }
        set { apiKey = newValue }
    }
    
     
    var editingModel: String {
        get { model }
        set { model = newValue }
    }
    
    var editingApiNote: String {
        get { apiNote }
        set { apiNote = newValue }
    }
}

class ApiItemStore: ObservableObject {
    @Published var items: [ApiItem2] = []
    @Published var currentItem: ApiItem2?
    
    private let hasSetInitialDataKey = "hasSetInitialData"
    
    init() {
        loadInitialDataIfNeeded()
    }
    
    private func loadInitialDataIfNeeded() {
        let hasSetInitialData = UserDefaults.standard.bool(forKey: hasSetInitialDataKey)
        
        if !hasSetInitialData {
            // 创建4组预设数据
            let presetItems = [
                ApiItem2(name:"302AI",host: "api.302.ai", apiKey: "key1111111111111111",model:"",apiNote: "", isCurrent: true),
                ApiItem2(name:"OpenAI",host: "openai.com", apiKey: "key2222222222222222",model:"",apiNote: ""),
                ApiItem2(name:"11111",host: "api.service3.com", apiKey: "key3333333333333333",model:"",apiNote: ""),
                ApiItem2(name:"22222",host: "api.service4.com", apiKey: "key4444444444444444",model:"",apiNote: "")
            ]
            
            self.items = presetItems
            self.currentItem = presetItems.first
            saveItems()
            
            // 标记已设置初始数据
            UserDefaults.standard.set(true, forKey: hasSetInitialDataKey)
        } else {
            // 正常加载已有数据
            ApiItemStore.load { result in
                switch result {
                case .success(let items):
                    self.items = items
                    self.currentItem = items.first(where: { $0.isCurrent })
                case .failure(let error):
                    print("加载失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveItems() {
        ApiItemStore.save(items: items) { result in
            if case .failure(let error) = result {
                print("保存失败: \(error.localizedDescription)")
            }
        }
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("apiItems.data")
    }
    
    static func load(completion: @escaping (Result<[ApiItem2], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let items = try JSONDecoder().decode([ApiItem2].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(items))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
     
    
    
    static func save(items: [ApiItem2], completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(items)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(items.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}




struct ApiListView: View {
    @EnvironmentObject var store: ApiItemStore
    
    var body: some View {
        NavigationView {
            VStack {
                if let currentItem = store.currentItem {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("当前使用的API配置")
                            .font(.title)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("主机: \(currentItem.host)")
                            Text("API密钥: \(currentItem.apiKey.prefix(4))****") // 部分隐藏敏感信息
                            Text("模型: \(currentItem.model)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                } else {
                    Text("没有可用的API配置")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                NavigationLink(destination: ItemListView()) {
                    Text("管理API配置")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("API配置")
            .onAppear {
                // 加载数据时设置当前item
                if store.currentItem == nil {
                    store.currentItem = store.items.first(where: { $0.isCurrent })
                }
            }
        }
    }
}


struct ItemListView: View {
    @EnvironmentObject var store: ApiItemStore
    @State private var showingAddView = false
    @State private var selectedItem: ApiItem2? = nil
    
    
    var body: some View {
        List {
            ForEach($store.items) { $item in
                ZStack(alignment: .leading) {
                    // 1. 背景层 - 处理整个行的点击
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = item
                        }
                    
                    // 2. 内容层
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.host)
                                .font(.headline)
                            Text("API Key: \(item.apiKey.prefix(4))****")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("模型: \(item.model)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                        }
                        
                        Spacer()
                        
                        if item.isCurrent {
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color(.blue))
                                .frame(width:45,height:45)
                                .contentShape(Rectangle())
                        } else {
                            Button(action: {
                                setCurrentItem(item: item)
                            }) {
                                
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(Color(.gray))
                                  
                            }
                            .frame(width:45,height:45)
                            .contentShape(Rectangle())
                            //.cornerRadius(4)
                            // 阻止事件冒泡
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .background(
                    NavigationLink(
                        destination: EditItemView(item: $item),
                        isActive: Binding(
                            get: { selectedItem?.id == item.id },
                            set: { _ in selectedItem = nil }
                        ),
                        label: { EmptyView() }
                    )
                    .hidden()
                )
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("API配置列表")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddView = true }) {
                    Label("添加", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddView) {
            AddItemView()
        }
    }
    
    
    
    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { store.items[$0] }
        
        // 如果要删除的是当前项目，需要处理
        if itemsToDelete.contains(where: { $0.isCurrent }) {
            store.currentItem = nil
        }
        
        store.items.remove(atOffsets: offsets)
        saveItems()
    }
    
    private func setCurrentItem(item: ApiItem2) {
        // 更新所有项目的isCurrent状态
        for index in store.items.indices {
            store.items[index].isCurrent = (store.items[index].id == item.id)
        }
        
        // 更新当前项目
        store.currentItem = item
        saveItems()
    }
    
    private func saveItems() {
        ApiItemStore.save(items: store.items) { result in
            if case .failure(let error) = result {
                print("保存失败: \(error.localizedDescription)")
            }
        }
    }
}

struct AddItemView: View {
    @EnvironmentObject var store: ApiItemStore
    @Environment(\.dismiss) var dismiss
    
    @State private var host = ""
    @State private var apiKey = ""
    @State private var name = ""
    @State private var apiNote = ""
    @State private var model = ""
    
    
    var body: some View {
        NavigationView {
//            Form {
//                Section(header: Text("API配置")) {
//                    TextField("主机", text: $host)
//                    TextField("API密钥", text: $apiKey)
//                }
//            }
            
            Form {
                Section(header: Text("基本信息")) {
                    HStack {
                        Text("名称:")
                            .foregroundColor(.gray)
                        Spacer()
                        
                        TextField("302.AI", text: $name)
                            .foregroundColor(.blue)
//                        Button(action: {
//                            isShowingList = true
//                        }) {
//                            TextField("api.302.ai", text: $name)
//                                .foregroundColor(.blue)
//                        }
//                        
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
                        
                    }
                    
                    HStack{
                        Text("Host:")
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("api.302.ai", text: $host)
                    }
                    
                    
                    
                    HStack{
                         
                        Text("API Key:")
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("API Key", text: $apiKey)
                    }
                    
                     
                    
                    
                    HStack{
                        //TextField("模型", text: $draftItem.model)
                        Text("模型:")
                            .foregroundColor(.gray)
                        Spacer()
                         
                        TextField("Model", text: $model)
                            .foregroundColor(.blue)
//                        Button(action: {
//                            isShowingList = true
//                        }) {
//                            TextField("Model", text: $model)
//                                .foregroundColor(.blue)
//                        }
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
                        
                    }
                    
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $apiNote)
                        .frame(minHeight: 100)
                }
            }
            
            
            .navigationTitle("添加配置")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let newItem = ApiItem2(name:name,host: host, apiKey: apiKey,model:model,apiNote: apiNote)
                        store.items.append(newItem)
                        ApiItemStore.save(items: store.items) { _ in }
                        dismiss()
                    }
                    .disabled(host.isEmpty || apiKey.isEmpty)
                }
            }
        }
    }
}



struct EditItemView: View {
    @EnvironmentObject var store: ApiItemStore
    @Binding var item: ApiItem2
    @Environment(\.dismiss) var dismiss
    
    @State private var editedName = ""
    @State private var editedApiKey = ""
    @State private var editedHost = ""
    @State private var editedModel = ""
    @State private var editedApiNote = ""
     
    @State private var showingModelSheet = false
    
    
    
    var body: some View {
//        Form {
//            Section(header: Text("API配置")) {
//                TextField("主机", text: $editedHost)
//                TextField("API密钥", text: $editedApiKey)
//            }
//        }
        
        Form{
            Section(header: Text("基本信息")) {
                HStack {
                    Text("名称:")
                        .foregroundColor(.gray)
                    Spacer()
                    
                    TextField("302.AI", text: $editedName)
                        .foregroundColor(.blue)
//                        Button(action: {
//                            isShowingList = true
//                        }) {
//                            TextField("api.302.ai", text: $name)
//                                .foregroundColor(.blue)
//                        }
//
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
                    
                }
                
                HStack{
                    Text("Host:")
                        .foregroundColor(.gray)
                    Spacer()
                    TextField("api.302.ai", text: $editedHost)
                }
                
                
                
                HStack{
                     
                    Text("API Key:")
                        .foregroundColor(.gray)
                    Spacer()
                    TextField("API Key", text: $editedApiKey)
                }
                
                 
                
                
                HStack {
                    Text("模型")
                    Spacer()
                    Text(editedModel)
                        .foregroundColor(.gray)
                    Button(action: {
                        showingModelSheet = true
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showingModelSheet = true
                }
                
            }
            
            Section(header: Text("备注")) {
                TextEditor(text: $editedApiNote)
                    .frame(minHeight: 100)
            }
        }
        
        
        .navigationTitle("编辑配置")
        .sheet(isPresented: $showingModelSheet) {
            ModelSelectionView(selectedModel: $editedModel)
        }
        .onAppear {
            editedHost = item.host
            editedApiKey = item.apiKey
            editedModel = item.model
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    item.host = editedHost
                    item.apiKey = editedApiKey
                    item.model = editedModel
                    
                    // 更新store中的对应item
                    if let index = store.items.firstIndex(where: { $0.id == item.id }) {
                        store.items[index] = item
                        
                        // 如果修改的是当前项目，也需要更新
                        if item.isCurrent {
                            store.currentItem = item
                        }
                    }
                    
                    store.saveItems()
                    dismiss()
                }
            }
        }
    }
}



struct ModelSelectionView: View {
    let models = ApiItem2.availableModels
    @Binding var selectedModel: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(models, id: \.self) { model in
                HStack {
                    Text(model)
                    Spacer()
                    if model == selectedModel {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedModel = model
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("选择模型")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
