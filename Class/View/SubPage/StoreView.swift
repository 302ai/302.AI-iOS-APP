//
//  StoreView.swift
//  GPTalks
//
//  Created by Adswave on 2025/3/24.
//

import SwiftUI

struct StoreView: View {
    // 半屏页面内容
    @Environment(\.dismiss) private var dismiss // 获取 dismiss 环境变量
    
    @State private var isFirstSearch: Bool = true
    @State private var searchText: String = "" // 搜索输入框的内容
    @State private var titleItems: [String] = ["学术论文1", "学术论文2", "学术论文3", "学术论文4", "学术论文5", "学术论文6"] // 初始数据
    
    // 示例数据
    @State private var listItems: [StoreModel] = [
        StoreModel(id: "111", icon: "ZGB", title: "RechtGPT", description: "Schweizerrecht einfach gemacht.", rating: 4, msg: 8),
        StoreModel(id: "222", icon: "Big Boss Rap", title: "Generator", description: "Interactive rap song creator based on user'...", rating: 5, msg: 8),
        StoreModel(id: "333", icon: "ZGB", title: "RechtGPT", description: "Schweizerrecht einfach gemacht.", rating: 4, msg: 8),
        StoreModel(id: "444", icon: "Big Boss Rap", title: "Generator", description: "Interactive rap song creator based on user'...", rating: 5, msg: 8)]
    
    
    var body: some View {
        VStack {
            
            VStack(alignment: .leading) { // 设置 VStack 的对齐方式为 .leading
                        Text("应用商店")
                            .font(.title)
                            .padding(.leading) // 添加左侧内边距
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // 确保 VStack 本身也居左
                    .padding() // 添加外部内边距
                
            HStack {
                       // 搜索输入框
                       TextField("请输入搜索内容", text: $searchText)
                           .padding(10)
                           .background(Color(.systemGray6))
                           .cornerRadius(10)
                           .overlay(
                               RoundedRectangle(cornerRadius: 10)
                                   .stroke(Color.gray, lineWidth: 1)
                           )

                       // 搜索按钮
                       Button(action: {
                           performSearch()
                           
                           if !searchText.isEmpty {
                               
                               if isFirstSearch {
                                   isFirstSearch = false
                                   titleItems.insert(searchText, at: 0) // 将输入内容添加到数组中
                               }else{
                                   if titleItems.first == searchText {
                                       return
                                   }
                                   
                                   titleItems.removeFirst()
                                   titleItems.insert(searchText, at: 0) // 将输入内容添加到数组中
                               }
                               
                               //searchText = ""
                           }else{
                               titleItems.removeFirst()
                           }

                           
                       }) {
                           Image(systemName: "magnifyingglass") // 使用系统图标
                               .padding(10)
                               .background(Color.blue)
                               .foregroundColor(.white)
                               .cornerRadius(10)
                       }
                   }
                   .padding(.horizontal)

            
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(titleItems.indices, id: \.self) { index in
                                Button(action: {
                                    print("\(titleItems[index]) 被点击")
                                })  {
                                    Text("\(titleItems[index])")
                                        .font(.system(size: 18, weight: .bold))
                                        .frame(width: 100, height: 36)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(18)
                                }
                            }
                        }
                        .padding(0)
            }
            .padding(.horizontal)
            .padding(.bottom, 0)
            .padding(.leading,20)
            .padding(.trailing,20)
            
            
            Spacer()

            List {
                // 使用 ForEach 遍历数组
                ForEach(listItems) { item in
                    StoreItem(icon: item.icon, title: item.title, description: item.description, rating: item.rating,msg: item.msg)
                }
            }
            .listStyle(PlainListStyle()) // 使用 PlainListStyle 去除默认的列表样式
        }
        .padding()
    }
    
    
    
    // 搜索操作
    private func performSearch() {
        print("搜索内容: \(searchText)")
    }
    
}

#Preview {
    StoreView()
}
