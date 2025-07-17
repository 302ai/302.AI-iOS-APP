//
//  TipWordView.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/15.
//

import SwiftUI

struct Prompt: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

struct PromptCategory: Decodable {
    let cn: [[String]]
}

class PromptDataService {
    static func loadPrompts() -> [Prompt] {
        guard let url = Bundle.main.url(forResource: "prompts", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        
        do {
            let category = try JSONDecoder().decode(PromptCategory.self, from: data)
            return category.cn.compactMap { item in
                guard item.count == 2 else { return nil }
                return Prompt(title: item[0], content: item[1])
            }
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}



// 更新后的数据模型（增加image字段）
struct ExpertCard: Identifiable {
    let id = UUID()
    let image: String  // 系统图标名称
    let title: String
    let subtitle: String
    let description: String
    let iconBgColor: Color // 新增图标背景色字段
}




struct TipsTypeModel: Identifiable {
    let id = UUID()
    let name: String
    let typeId: Int
    let type: String
    var isSelected: Bool = false //  选中状态
    
    // 可选：自定义初始化方法
    init(name: String, typeId: Int, type: String = "default") {
        self.name = name
        self.typeId = typeId
        self.type = type
    }
}


struct TipsWordView: View {
    @State private var isShowingTipsType = false
    @State private var selectedItem: TipsTypeModel? = nil
        
    
    
        // 示例数据
    @State private var items = [
        TipsTypeModel(name: "全部", typeId: 0),
        TipsTypeModel(name: "我的", typeId: 1),
        TipsTypeModel(name: "职业", typeId: 2),
        TipsTypeModel(name: "商业", typeId: 3),
        TipsTypeModel(name: "工具", typeId: 4),
        TipsTypeModel(name: "语言", typeId: 5),
        TipsTypeModel(name: "办公", typeId: 6),
        TipsTypeModel(name: "通用", typeId: 7),
        TipsTypeModel(name: "写作", typeId: 8),
        TipsTypeModel(name: "精选", typeId: 9),
        TipsTypeModel(name: "编程", typeId: 10),
        TipsTypeModel(name: "情感", typeId: 11),
        TipsTypeModel(name: "教育", typeId: 12),
        TipsTypeModel(name: "创意", typeId: 13),
        TipsTypeModel(name: "学术", typeId: 14),
        TipsTypeModel(name: "设计", typeId: 15),
        TipsTypeModel(name: "艺术", typeId: 16),
        TipsTypeModel(name: "娱乐", typeId: 17),
        TipsTypeModel(name: "生活", typeId: 18),
        TipsTypeModel(name: "医疗", typeId: 19),
        TipsTypeModel(name: "游戏", typeId: 20),
        TipsTypeModel(name: "翻译", typeId: 21),
        TipsTypeModel(name: "音乐", typeId: 22),
        TipsTypeModel(name: "点评", typeId: 23),
        TipsTypeModel(name: "文案", typeId: 24),
        TipsTypeModel(name: "百科", typeId: 25),
        TipsTypeModel(name: "健康", typeId: 26),
        TipsTypeModel(name: "营销", typeId: 27),
        TipsTypeModel(name: "科学", typeId: 28),
        TipsTypeModel(name: "分析", typeId: 29),
        TipsTypeModel(name: "法律", typeId: 30),
        TipsTypeModel(name: "咨询", typeId: 31),
        TipsTypeModel(name: "金融", typeId: 32),
        TipsTypeModel(name: "旅游", typeId: 33),
        TipsTypeModel(name: "管理", typeId: 34),
        TipsTypeModel(name: "其他", typeId: 35),
        TipsTypeModel(name: "创造", typeId: 36),
        TipsTypeModel(name: "心理", typeId: 37)
        
    ]
        
    // 更新数组数据源（添加image字段）
    let prompts: [Prompt] = PromptDataService.loadPrompts()
         
    
     
    
        var body: some View {
            ZStack{
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("提示词")
                        .foregroundStyle(.primary)
                        .font(.headline)
                    
                    Button {
                        // 更新所有项的选中状态
                        items = items.map { item in
                            var modifiedItem = item
                            modifiedItem.isSelected = (selectedItem?.id == item.id)
                            return modifiedItem
                        }
                        isShowingTipsType = true
                        
                    } label: {
                        HStack{
                            Image(systemName: "list.triangle")
                            
                            if let selectedItem = selectedItem {
                                Text("\(selectedItem.name)")
                            }else{
                                Text("全部")
                            }
                            
                        }
                        
                    }
                    
                    VStack {
                        List(prompts) { prompt in
//                            CardView(card: prompt)
//                                .listRowInsets(EdgeInsets())
//                                .listRowSeparator(.hidden)
//                                .padding(.horizontal)
//                                .padding(.vertical, 8)
                        }
                    }
                    
                    
                }.padding()

                
                // View2 弹出层
                if isShowingTipsType {
                    
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isShowingTipsType = false
                            }
                        }
                    
                    TipsTypeView(
                        items: $items,
                        isPresented: $isShowingTipsType,
                        onSelectItem: { item in
                            selectedItem = item
                            isShowingTipsType = false
                        }
                    )
                    .transition(.move(edge: .leading))
                    .zIndex(1)
                }
            }
            .animation(.easeInOut, value: isShowingTipsType)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // 整体左上对齐
                //.padding() // 添加内边距
            
                                
                
            
        }
    
    
   
    
}
 



