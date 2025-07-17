//
//  MDWebView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/7/11.
//

import SwiftUI
import WebKit


struct MathWebView: UIViewRepresentable {
    let markdownString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        // 加载本地 HTML 模板
        if let htmlURL = Bundle.main.url(forResource: "md_index", withExtension: "html") {
            webView.load(URLRequest(url: htmlURL))
        } else {
            // 如果没有本地 HTML 文件，使用内置模板
            let htmlTemplate = """
            <!DOCTYPE html>
            <html lang="zh-CN">
                <head>
                    <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>支持高级 LaTeX 的 Markdown 渲染</title>
                            <!-- 引入 Marked.js -->
                            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
                            <!-- 引入 MathJax 配置 -->
                            <script>
                                window.MathJax = {
                                    tex: {
                                        inlineMath: [['\\(', '\\)']],    // 行内公式分隔符
                                        displayMath: [['\\[', '\\]']],   // 块级公式分隔符
                                        processEscapes: true,               // 支持反斜杠转义
                                        packages: {
                                            '[+]': ['base', 'ams', 'amssymb', 'boldsymbol', 'physics', 'mhchem', 'newcommand']
                                        }
                                    },
                                    startup: {
                                        typeset: false                       // 禁止自动初始化，手动控制渲染
                                    },
                                    loader: {
                                        load: ['[tex]/mhchem', '[tex]/physics']
                                    }
                                };
                            </script>
                            <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
                            <style>
                                .MathJax {
                                    font-size: 1.3em !important;
                                }
                                /* 表格样式 */
                                table {
                                    width: 100%;
                                    border-collapse: collapse;
                                    margin: 10px 0;
                                }
                                th, td {
                                    border: 1px solid #ddd;
                                    padding: 8px;
                                    text-align: left;
                                }
                                th {
                                    background-color: #f2f2f2;
                                }
                            </style>
                        </head>
                <body>
                    <div id="rendered-content"></div>
                    
                    <script>
                        
                        // 配置 Marked.js，启用表格支持
                        marked.setOptions({
                            breaks: true,
                            tables: true,
                            gfm: true,
                            headerIds: true,
                            smartLists: true,
                            smartypants: true,
                            xhtml: true,
                            mangle: false, // 禁用邮箱混淆
                            sanitize: false
                        });
                        
                        var text = ""
                        // 渲染函数
                        function renderMarkdown(markdownText) {
                            markdownText += "\n"
                            text += markdownText
                            document.getElementById('rendered-content').innerHTML = marked.parse(text);;
                            // 确保 MathJax 重新渲染
                            MathJax.typesetPromise().catch(err => console.log(err));
                        }
                        window.renderMarkdown = renderMarkdown; // 暴露给 客户端 调用
                    </script>
                    
                </body>
            </html>
            """
            webView.loadHTMLString(htmlTemplate, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 分割字符串并逐行渲染
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let array = markdownString.components(separatedBy: "\n")
            for item in array {
                let escapedMarkdown = escape(markdown: item.trimmingCharacters(in: .whitespaces))
                let script = "renderMarkdown('\(escapedMarkdown)');"
                uiView.evaluateJavaScript(script)
            }
        }
    }
    
    private func escape(markdown: String) -> String {
        
        return markdown
            .replacingOccurrences(of: "\\", with: "\\\\\\\\")  // 转义反斜杠
            .replacingOccurrences(of: "'", with: "\\'")    // 转义单引号
            .replacingOccurrences(of: "\n", with: "\\n")   // 转义换行符
            .replacingOccurrences(of: "\r", with: "\\r")   // 转义回车符
    }
}
