//
//  CodeBlockView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/7/4.
//
 
import SwiftUI
import MarkdownUI
import Splash

struct CodeBlockView: View {
    let configuration: CodeBlockConfiguration
        let theme: Splash.Theme
        let fontSize: CGFloat
        
        @State private var isCopied = false // 新增状态变量
        
        var body: some View {
            VStack(spacing: 0) {
                headerView
                Divider()
                codeContentView
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .markdownMargin(top: .zero, bottom: .em(0.8))
        }
        
        private var headerView: some View {
            HStack {
                Text(configuration.language ?? "plain text")
                    .font(.system(size: fontSize * 1.05, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(theme.plainTextColor))
                
                Spacer()
                
                // 修改后的图标部分
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .foregroundColor(isCopied ? .green : Color(theme.plainTextColor))
                    .onTapGesture {
                        copyToClipboard(configuration.content)
                        withAnimation {
                            isCopied = true
                        }
                        // 10秒后恢复原状
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            withAnimation {
                                isCopied = false
                            }
                        }
                    }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(theme.backgroundColor))
        }
    
    private var codeContentView: some View {
        ScrollView(.horizontal) {
            configuration.label
                .relativeLineSpacing(.em(0.25))
                .markdownTextStyle {
                    FontFamilyVariant(.monospaced)
                    FontSize(.em(0.95))
                }
                .padding()
        }
        .background(.black)
    }
    
    private func copyToClipboard(_ string: String) {
        #if os(macOS)
        if let pasteboard = NSPasteboard.general {
            pasteboard.clearContents()
            pasteboard.setString(string, forType: .string)
        }
        #elseif os(iOS)
        UIPasteboard.general.string = string
        #endif
    }
}



extension View {
    func codeBlockStyle(theme: Splash.Theme, fontSize: CGFloat) -> some View {
        self.markdownBlockStyle(\.codeBlock) { configuration in
            CodeBlockView(
                configuration: configuration,
                theme: theme,
                fontSize: fontSize
            )
        }
    }
}
