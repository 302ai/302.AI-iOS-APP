//
//  TipsTypeView.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/15.
//

import SwiftUI

struct TipsTypeView: View {
    
    @Binding var items: [TipsTypeModel] // 改为 Binding 类型
    @Binding var isPresented: Bool
    var onSelectItem: (TipsTypeModel) -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            
            GeometryReader { geometry in
                List {
                    ForEach($items) { $item in
                        Button {
                            onSelectItem(item)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .foregroundColor(item.isSelected ? .purple : .primary) // 紫色字体
                                    Text("Type: \(item.type)")
                                        .font(.caption)
                                }
                                Spacer()
                                if item.isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.purple)
                                }
                            }
                            .padding(10)
                            .background(
                                item.isSelected ? Color.purple.opacity(0.1) : Color.clear // 浅紫色背景
                            )
                            .cornerRadius(8)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(width: geometry.size.width * 0.7) // 内容视图 (3/4 屏幕宽度)
                .background(Color.white)
            }
        }
    }
}

 
