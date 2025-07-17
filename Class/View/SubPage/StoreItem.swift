//
//  StoreItem.swift
//  GPTalks
//
//  Created by Adswave on 2025/3/24.
//

import SwiftUI

// 列表项视图
struct StoreItem: View {
    var icon: String
    var title: String
    var description: String
    var rating: Int
    var msg : Int

    var body: some View {
         
            HStack {
                // 图标
                Text(icon)
                    .font(.largeTitle)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)

                // 标题和描述
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        // 评分
                        HStack {
                            Text("\(rating)")
                                .font(.headline)
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        
                        HStack{
                            Text("\(msg)")
                                .font(.headline)
                            Image(systemName: "message")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
            }
            .padding(.vertical, 8)
             
    }
}
#Preview {
    StoreItem(icon: "", title: "", description: "", rating: 0 ,msg: 0 )
}
