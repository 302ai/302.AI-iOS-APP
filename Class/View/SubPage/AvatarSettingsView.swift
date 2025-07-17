//
//  AvatarSettingsView.swift
//  GPTalks
//
//  Created by Adswave on 2025/6/12.
//

import SwiftUI

struct AvatarSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var config = AppConfiguration.shared
    
    let emojis: [String] = {
        var result = [String]()
        let startValue: UInt32 = 0x1F600  // 😀
        let endValue: UInt32 = 0x1F64F    // 🙏
        
        for value in startValue...endValue {
            if let scalar = Unicode.Scalar(value) {
                result.append(String(scalar))
            }
        }
        return result
    }()
    
    // 定义6列的网格布局
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    
    @State private var selectedEmoji: String? = AppConfiguration.shared.userAvatar
    
    var body: some View {
        VStack {
            if let selectedEmoji = selectedEmoji {
//                Text("已选择: \(selectedEmoji)")
//                    .font(.title3)
//                    .padding()
                
                HStack{
                    Text("已选择:")
                        .font(.title3)
                        .frame(alignment: .trailing)
                        .padding()
                    Text("\(selectedEmoji)")
                        .font(.title)
                        .frame(alignment: .leading)
                        .padding()
                }
                
                
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(emojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 30))
                            .frame(width: 50, height: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .onTapGesture {
                                selectedEmoji = emoji
                                print("点击了: \(emoji)")
                            }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("头像设置", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // 隐藏系统返回按钮
        .navigationBarItems(
            leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    //Text("返回")
                }
                .foregroundStyle(Color(white: 0.3))
            },
            trailing: Button(action: {
                self.saveAvatar()
                
                self.presentationMode.wrappedValue.dismiss()
                
            }) {
                Text("保存")
                    .foregroundColor(Color(white: 0.3))
            }
        )
    }
    
    
    //保存头像
    func saveAvatar(){
        
        if let selectedEmoji2 = selectedEmoji {
            config.userAvatar = selectedEmoji2 + " "
        }
    }
    
}



struct EmojiCell: View {
    let emoji: String
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 30))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .onTapGesture {
                print("Selected emoji: \(emoji)")
            }
    }
}
