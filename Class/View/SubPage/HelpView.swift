//
//  HelpView.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/23.
//

import SwiftUI

struct HelpView: View {
    
    @Binding var isPresented: Bool
      
    @Environment(\.dismiss) var dismiss
     
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            // 说明部分
            VStack(alignment: .leading, spacing: 8) {
                 
                    VStack(alignment:.center) {
                        HStack(alignment:.center) {
                            Spacer()
                            Text("说明")
                                .font(.title3) 
                            Spacer()
                        }
                            
                        HStack(alignment:.center) {
                            Spacer()
                            Text("聊天机器人详情预览")
                                .foregroundStyle(.gray)
                                .font(.footnote)
                            Spacer()
                        }
                    }
                     
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    VStack{
                        Text("1. 此聊天机器人由302.AI创建，302.AI是一个生成和分享AI的平台，可以一键生成和分享属于自己的AI工具")
                        Text("2. 此聊天机器人默认的模型为 **gpt-4-plus(ChatGPT Plus)**")
                        Text("3. 此聊天机器人的聊天记录均保存在本机，不会被上传，生成此聊天机器人的用户无法看到你的聊天记录")
                        Text("4. 更多信息请访问：302.AI")
                    }
                    .padding(15)
                    
                }
                .font(.body)
                
                
                Divider()
                VStack{}
                    .frame(height: 25)
                
            }
            
            Spacer()
        }
    }
     
}

 
