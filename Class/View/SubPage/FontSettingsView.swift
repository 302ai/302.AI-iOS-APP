//
//  FontSettingsView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/6/30.
//

import SwiftUI
import SwiftMarkdownView
import MarkdownUI
import Splash

  
struct FontSettingsView: View {
    
    @EnvironmentObject var fontSettings: FontSettings
    @Environment(\.colorScheme) private var colorScheme
    
        var body: some View {
            VStack(spacing: 20) {
                // 使用自定义 Text 显示示例文本
                CustomText("示例文本:\n\n企业级AI应用平台,让AI为每个需求找到答案\n\n持续接入最新的AI模型,文字/图片/声音/视频/RAG，应有尽有\n\n ")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                
//                SwiftMarkdownView("# Markdown 标题\n这是Markdown内容")
//                               .markdownFontSize(5)
                
//                SwiftMarkdownView("# Markdown 标题\n这是Markdown内容")
//                    .markdownFontSize(fontSettings.fontSize)
//                    .markdownTextStyle {
//                        FontSize(fontSettings.fontSize)
//                    }
                let text = "```swift \n let scores = [\"Alice\": 85, \"Bob\": 92, \"Charlie\": 78]\n for (name, score) in scores {\n print(\"\\(name)'s score is \\(score)\")\n }\n ```"
                 
                Markdown(text)
                    .markdownTextStyle {
                        FontSize(fontSettings.fontSize)
                    }
                    .codeBlockStyle(
                        theme: .adaptiveTheme(for: colorScheme, fontSize: fontSettings.fontSize),
                        fontSize: fontSettings.fontSize
                    )
                    .markdownCodeSyntaxHighlighter(.splash(theme: .adaptiveTheme(for: colorScheme, fontSize: fontSettings.fontSize)))
                
                
                
//                SwiftMarkdownView(text)
//                    .markdownFontSize(fontSettings.fontSize)
                
                
                Spacer()
                
                // 字体大小 Slider
                VStack(alignment: .leading) {
                    HStack{
                        Text("字体大小: \(Int(fontSettings.fontSize))")
                            .font(.headline)
                        Text("如未生效,建议重启App")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                            
                    }
                    
                    
                    Slider(
                        value: $fontSettings.fontSize,
                        in: 12...25,
                        step: 1
                    ) {
                        Text("字体大小")
                    } minimumValueLabel: {
                        Text("12")
                    } maximumValueLabel: {
                        Text("25")
                    }
                }
                
                VStack{}.frame(height: 20)
                 
                
            }
            .padding()
            .navigationTitle("字体设置")  // 添加导航标题
            .navigationBarTitleDisplayMode(.inline)  // 设置标题显示模式
        }
    
      
}
   



