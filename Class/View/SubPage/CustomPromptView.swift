//
//  CustomPromptView.swift
//  GPTalks
//
//  Created by Adswave on 2025/6/12.
//

import SwiftUI

struct CustomPromptView: View {
    //@State private var text = "在这里输入多行文本..."
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var config = AppConfiguration.shared
    
    
    var body: some View {
        // 移除外部的 NavigationView，只保留内容
        VStack(spacing: 20) {
            HStack {
                Spacer()
                TextEditor(text: $config.customPromptContent)
                    .frame(height: 200)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.7), lineWidth: 0.75)
                    )
                Spacer()
            }
            
            Spacer()
        }
        .navigationBarTitle("自定义提示词", displayMode: .inline)
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
                self.saveContent()
            }) {
                Text("保存")
                    .foregroundColor(Color(white: 0.3))
            }
        )
    }
    
    private func saveContent() {
        //print("保存内容: \(text)")
        self.presentationMode.wrappedValue.dismiss()
    }
}


#Preview {
    CustomPromptView()
}
