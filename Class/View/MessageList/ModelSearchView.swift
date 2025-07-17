//
//  ModelSearchView.swift
//  GPTalks
//
//  Created by Adswave on 2025/3/25.
//

import SwiftUI
 

struct SearchView: View {
    // 数据模型
    struct Category: Identifiable {
        let id = UUID()
        let name: String
        let items: [String]
    }
    
    // 示例数据
    @State private var allCategories: [Category] = [
        Category(name: "水果", items: ["苹果", "橘子", "香蕉"]),
        Category(name: "蔬菜", items: ["白菜", "萝卜", "西兰花"]),
        Category(name: "电子产品", items: ["iPhone", "iPad", "MacBook"])
    ]
    
    @State private var searchText = ""
    @State private var isSearchActive = false
    
    // 过滤后的分类数据
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return allCategories
        } else {
            return allCategories.compactMap { category in
                let filteredItems = category.items.filter {
                    $0.localizedCaseInsensitiveContains(searchText) ||
                    category.name.localizedCaseInsensitiveContains(searchText)
                }
                return filteredItems.isEmpty ? nil : Category(
                    name: category.name,
                    items: filteredItems
                )
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            // 主列表
            List {
                ForEach(filteredCategories) { category in
                    Section(header: Text(category.name)) {
                        ForEach(category.items, id: \.self) { item in
                            Text(item)
                        }
                    }
                }
            }
            .navigationTitle("商品分类")
            .toolbar {
                // 导航栏搜索框
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("搜索商品", text: $searchText)
                            .onTapGesture { isSearchActive = true }
                            .submitLabel(.search)
                            .onSubmit { isSearchActive = false }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            // 二级搜索菜单
            .overlay(alignment: .top) {
                if isSearchActive {
                    VStack(spacing: 0) {
                        // 搜索建议
                        List {
                            Section("常用搜索") {
                                Button("苹果") { searchText = "苹果" }
                                Button("白菜") { searchText = "白菜" }
                            }
                            
                            // 实时搜索结果
                            ForEach(filteredCategories.prefix(2)) { category in
                                Section(category.name) {
                                    ForEach(category.items.prefix(3), id: \.self) { item in
                                        Button(item) {
                                            searchText = item
                                            isSearchActive = false
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .frame(height: 300)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.top, 10)
                    .transition(.move(edge: .top))
                    .zIndex(1)
                }
            }
            // 点击空白处收起菜单
            .onTapGesture {
                if isSearchActive {
                    isSearchActive = false
                }
            }
        }
    }
}
