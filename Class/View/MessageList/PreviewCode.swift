//
//  PreviewCode.swift
//  GPTalks
//
//  Created by Adswave on 2025/5/23.
//

import SwiftUI
import WebKit
import SwiftMarkdownView

enum CodeType: String, CaseIterable {
    case html = "HTML"
    case svg = "SVG"
    case javascript = "JavaScript"
    case python = "Python"
    case unknown = "Unknown"
    
    var icon: String {
        switch self {
        case .html: return "chevron.left.slash.chevron.right"
        case .svg: return "square.fill.on.square.fill"
        case .javascript: return "curlybraces"
        case .python: return "p.square.fill"
        case .unknown: return "questionmark.square.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .html: return .orange
        case .svg: return .blue
        case .javascript: return .yellow
        case .python: return .green
        case .unknown: return .gray
        }
    }
}


struct PreviewCode: View {
    var msgContent: String
    @State private var showPreview = true
    
    var svgCode: String = ""
    
    
    enum Tab: String, CaseIterable {
            case preview = "预览"
            case code = "代码"
        }
    @State private var selectedTab: Tab = .preview
    @State var runCodeResponse: String = "正在执行代码"
    @EnvironmentObject var fontSettings: FontSettings
    
    var body: some View {
        
        
        VStack {
            Spacer(minLength: 20)
            
            HStack{
                
                SegmentedControl(
                    items: Tab.allCases,
                    selectedItem: $selectedTab,
                    titleProvider: { $0.rawValue }
                )
                .frame(width: 150)
                .padding()
                
                Spacer()
            }
            
            ZStack {
                
                if selectedTab == .preview {
                    if let msg = ConversationMessage(jsonString: msgContent) {
                            let codeType =  detectCodeType(msg.content)
                        if codeType == .svg || codeType == .html{
                            SVGWebView(inputText: msg.content)
                                .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                                .cornerRadius(10)  // 先设置圆角
                                .overlay(          // 再用 overlay 添加带圆角的边框
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                        }else{
                            VStack{
                                HStack{
                                    Spacer()
                                    Image("applogo")
                                        .resizable()
                                        .frame(width: 40,height:40)
                                    Text("302.AI")
                                        .font(.title)
                                    Spacer()
                                }
                                
                                Text("实时预览功能(Beta)")
                                    .font(.body)
                                    .foregroundStyle(.gray)
                            }
                            .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                            .padding(8)
                            .cornerRadius(10)  // 先设置圆角
                            .overlay(          // 再用 overlay 添加带圆角的边框
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 0.5)
                            )
                        }
                        
                    }else if !msgContent.isEmpty {
                        let codeType =  detectCodeType(msgContent)
                        if codeType == .svg || codeType == .html{
                            SVGWebView(inputText: msgContent)
                                .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                                .cornerRadius(10)  // 先设置圆角
                                .overlay(          // 再用 overlay 添加带圆角的边框
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                        }else{
                            VStack{
                                HStack{
                                    Spacer()
                                    Image("applogo")
                                        .resizable()
                                        .frame(width: 40,height:40)
                                    Text("302.AI")
                                        .font(.title)
                                    Spacer()
                                }
                                
                                Text("实时预览功能(Beta)")
                                    .font(.body)
                                    .foregroundStyle(.gray)
                            }
                            .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                            .padding(8)
                            .cornerRadius(10)  // 先设置圆角
                            .overlay(          // 再用 overlay 添加带圆角的边框
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 0.5)
                            )
                        }
                        
                    }else{
                        VStack{
                            HStack{
                                Spacer()
                                Image("applogo")
                                    .resizable()
                                    .frame(width: 40,height:40)
                                Text("302.AI")
                                    .font(.title)
                                Spacer()
                            }
                            
                            Text("实时预览功能(Beta)")
                                .font(.body)
                                .foregroundStyle(.gray)
                        }
                        .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                        .padding(8)
                        .cornerRadius(10)  // 先设置圆角
                        .overlay(          // 再用 overlay 添加带圆角的边框
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    }
                }else{
                    
                    ScrollView {
                        if let msg = ConversationMessage(jsonString: msgContent) {
                            let codeType =  detectCodeType(msg.content)
                            switch codeType {
                            case .svg:
                                let codeContent = extractSVG(from: msg.content)
                                SwiftMarkdownView("```xml\n" + "\(codeContent)" + "```")
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                                    .cornerRadius(10)  // 先设置圆角
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            case .html:
                                let codeContent = extractHTMLFromMarkdown(msg.content)
                                let content2 = "```java\n" + "\(codeContent ?? "")"
                                SwiftMarkdownView(content2)
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .cornerRadius(10)  // 先设置圆角
                                    .padding(5)
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            case .javascript:
                                let codeContent = extractJavascript(msg.content)
                                let content2 = "```java\n" + "\(codeContent ?? "")"
                                SwiftMarkdownView(content2)
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .frame(minHeight: 200)
                                    .cornerRadius(10)  // 先设置圆角
                                    .padding(5)
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            case .python:
                                let codeContent = extractPython(msg.content)
                                
                                let content2 = "```java\n" + "\(codeContent ?? "")"
                                SwiftMarkdownView(content2)
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(minHeight: 200)
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .cornerRadius(10)  // 先设置圆角
                                    .padding(5)
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            default:
                                SwiftMarkdownView("```java\n" + "\(msg.content)")
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(minHeight: 200)
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .cornerRadius(10)  // 先设置圆角
                                    .padding(5)
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            }
                        }else if (!msgContent.isEmpty) {
                            let codeType =  detectCodeType(msgContent)
                            switch codeType {
                            case .svg:
                                let codeContent = extractSVG(from: msgContent)
                                SwiftMarkdownView("```xml\n" + "\(codeContent)" + "```")
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .cornerRadius(10)  // 先设置圆角
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            case .html:
                                let codeContent = extractHTMLFromMarkdown(msgContent)
                                let content2 = "```java\n" + "\(codeContent ?? "")"
                                SwiftMarkdownView(content2)
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .cornerRadius(10)  // 先设置圆角
                                    .padding(5)
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            case .javascript:
                                let codeContent = extractJavascript(msgContent)
                                let content2 = "```java\n" + "\(codeContent ?? "")"
                                SwiftMarkdownView(content2)
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .frame(minHeight: 200)
                                    .cornerRadius(10)  // 先设置圆角
                                    .padding(5)
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            case .python:
                                let codeContent = extractPython(msgContent)
                                
                                let content2 = "```java\n" + "\(codeContent ?? "")"
                                SwiftMarkdownView(content2)
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(minHeight: 200)
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .cornerRadius(10)  // 先设置圆角
                                    .padding(5)
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            default:
                                
//                                SwiftMarkdownView("```java\n" + "\(msgContent)")
//                                    .markdownFontSize(fontSettings.fontSize)
//                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                    .frame(minHeight: 200)
//                                    .frame(width:UIScreen.main.bounds.width-40)
//                                    .cornerRadius(10)  // 先设置圆角
//                                    .padding(5)
//                                    .overlay(          // 再用 overlay 添加带圆角的边框
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.gray, lineWidth: 0.5)
//                                    )
                                VStack{
                                    HStack{
                                        Spacer()
                                        Image("applogo")
                                            .resizable()
                                            .frame(width: 40,height:40)
                                        Text("302.AI")
                                            .font(.title)
                                        Spacer()
                                    }
                                    
                                    Text("实时预览功能(Beta)")
                                        .font(.body)
                                        .foregroundStyle(.gray)
                                }
                                .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                                .padding(8)
                                .cornerRadius(10)  // 先设置圆角
                                .overlay(          // 再用 overlay 添加带圆角的边框
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )

                                
                            }
                        }else{
                            
//                            let htmlContent = "```xml\n" + msgContent + "```"
//                            SwiftMarkdownView(htmlContent)
//                                .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
//                                .cornerRadius(10)  // 先设置圆角
//                                .overlay(          // 再用 overlay 添加带圆角的边框
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(Color.gray, lineWidth: 0.5)
//                                )
                            
                            
                            VStack{
                                
                                Text(msgContent)
                                Spacer()
                            }.frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                                .padding(8)
                                .cornerRadius(10)  // 先设置圆角
                                .overlay(          // 再用 overlay 添加带圆角的边框
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                        }

                        
                        
                    }
                                        
                }
                
            }.background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.01))
            )
            
            
            Spacer()
        }
        .task {
            if let msg = ConversationMessage(jsonString: msgContent){
                let codeType = detectCodeType(msg.content)
                if codeType == .python {
                    
                    let code = extractPython(msg.content)
                    NetworkManager.shared.executeCode(language: "python3", code: code ?? "") { result in
                        switch result {
                        case .success(let response):
                            if response.code == 0 {
                                runCodeResponse = response.data.stdout
                            } else {
                                runCodeResponse = response.msg
                            }
                        case .failure(let error):
                            runCodeResponse = error.localizedDescription
                        }
                        
                    }
                }
                if  codeType == .javascript{
                    let code = extractJavascript(msg.content)
                    NetworkManager.shared.executeCode(language: "nodejs", code: code ?? "") { result in
                        //runCodeResponse = response
                        
                        switch result {
                        case .success(let response):
                            if response.code == 0 {
                                runCodeResponse = response.data.stdout
                            } else {
                                runCodeResponse = response.msg
                            }
                        case .failure(let error):
                            runCodeResponse = error.localizedDescription
                        }
                    }
                }
            }
        }
        .onAppear {
            UIPasteboard.general.string = ""
            UIPasteboard.general.items = []
        }
    }
     
    
    func extractJavascript(_ markdown: String) -> String? {
        // 查找 ```html 和 ``` 之间的内容
        if let startRange = markdown.range(of: "```javascript\n"),
           let endRange = markdown.range(of: "\n```", range: startRange.upperBound..<markdown.endIndex) {
            let htmlContent = String(markdown[startRange.upperBound..<endRange.lowerBound])
            return htmlContent
        }
        return nil
    }
    
    func extractPython(_ markdown: String) -> String? {
        
            // 定义匹配 Python 代码块的正则表达式
            let pattern = "```python\\n([\\s\\S]*?)\\n```"
            
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                return nil
            }
            
            // 查找第一个匹配项
            if let match = regex.firstMatch(in: markdown, range: NSRange(markdown.startIndex..., in: markdown)) {
                // 提取匹配到的代码范围
                let matchRange = match.range(at: 1)
                if let swiftRange = Range(matchRange, in: markdown) {
                    // 返回提取的代码字符串，并去除首尾空白
                    return String(markdown[swiftRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            return nil
        
        // 查找 ```html 和 ``` 之间的内容
//        if let startRange = markdown.range(of: "```python\n"),
//           let endRange = markdown.range(of: "\n```", range: startRange.upperBound..<markdown.endIndex) {
//            let htmlContent = String(markdown[startRange.upperBound..<endRange.lowerBound])
//            return htmlContent
//        }
//        return nil
    }
    
    
    func extractSVG(from text: String) -> String {
        
        // 正则表达式匹配 SVG 标签及其内容
               let pattern = "<svg[^>]*>(.|\\n)*?</svg>"
               
               do {
                   let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                   let range = NSRange(location: 0, length: text.utf16.count)
                   
                   if let match = regex.firstMatch(in: text, options: [], range: range) {
                       let matchedRange = match.range
                       if let swiftRange = Range(matchedRange, in: text) {
                           return String(text[swiftRange])
                       }
                   }
               } catch {
                   print("正则表达式错误: \(error.localizedDescription)")
                   return error.localizedDescription
               }
        return ""
    }
    
    
    private func processMarkdownContent(_ text: String) -> String {
           // 1. 替换HTML特殊字符
           var processed = text
               .replacingOccurrences(of: "<", with: "&lt;")
               .replacingOccurrences(of: ">", with: "&gt;")
           
           // 2. 确保代码块有正确换行
           processed = processed.replacingOccurrences(of: "```html", with: "\n```html\n")
           
           return processed
       }

    func extractSvgCode(from text: String) -> String {
        // 正则表达式匹配 SVG 标签及其内容
               let pattern = "```xml[^>]*>(.|\\n)*?```"
               
               do {
                   let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                   let range = NSRange(location: 0, length: text.utf16.count)
                   
                   if let match = regex.firstMatch(in: text, options: [], range: range) {
                       let matchedRange = match.range
                       if let swiftRange = Range(matchedRange, in: text) {
                           return String(text[swiftRange])
                       }
                   }
               } catch {
                   print("正则表达式错误: \(error.localizedDescription)")
                   return ""
               }
        return ""
    }
    
    func extractHTMLFromMarkdown(_ markdown: String) -> String? {
        // 查找 ```html 和 ``` 之间的内容
        if let startRange = markdown.range(of: "```html\n"),
           let endRange = markdown.range(of: "\n```", range: startRange.upperBound..<markdown.endIndex) {
            let htmlContent = String(markdown[startRange.upperBound..<endRange.lowerBound])
            return htmlContent
        }
        return nil
    }
     
     
}


struct SegmentedControl<Element: Hashable>: View {
    let items: [Element]
    @Binding var selectedItem: Element
    let titleProvider: (Element) -> String
    
    // 自定义样式
    var activeColor: Color = .purple
    var inactiveColor: Color = .gray
    var backgroundColor: Color = .clear
    var cornerRadius: CGFloat = 8
    var padding: CGFloat = 4
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedItem = item
                    }
                }) {
                    Text(titleProvider(item))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedItem == item ? .white : inactiveColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .background(
                    selectedItem == item ? activeColor : backgroundColor
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(inactiveColor, lineWidth: 1)
                )
        )
        .cornerRadius(cornerRadius)
        .padding(padding)
    }
}

 
struct MyWebView: UIViewRepresentable {
    let htmlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

struct SVGWebView: View {
    let inputText: String
    @State private var svgData: String?
    @State private var htmlData: String?
    @State private var jsData: String?
    @State private var pythonData: String?
    
    
    @State private var codeType : CodeType?
    
    var body: some View {
        
        Group {
            
            if  (svgData != nil) {
                MyWebView(htmlString: createHTMLPage(svgContent: svgData ?? ""))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if (htmlData != nil){
                MyWebView(htmlString:  htmlData ?? "")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("没有可预览的数据")
                    .foregroundColor(.gray)
            }
             
        }
        .onAppear {
            if let msg = ConversationMessage(jsonString: inputText) {
                 
                
                print("msg!.content: \(msg.content)")
                let result = detectCodeType(msg.content)
                // 使用 switch 处理检测结果
                switch result {
                case .html:
                    codeType = .html
                    htmlData = extractHTMLFromMarkdown(inputText)
                case .svg:
                    
                    codeType = .svg
                    extractSVG(from: msg.content)
                    
                case .javascript:
                    codeType = .javascript
                     
                    jsData = extractSingleJavaScriptCode(from: inputText)
                    
                case .python:
                    codeType = .python
                case .unknown:
                    codeType = .unknown
                }
                        
            }else{
                
                let result = detectCodeType(inputText)
                // 使用 switch 处理检测结果
                switch result {
                case .html:
                    codeType = .html
                    htmlData = extractHTMLFromMarkdown( inputText)
                case .svg:
                    
                    codeType = .svg
                    extractSVG(from: inputText)
                    
                case .javascript:
                    codeType = .javascript
                    
                    jsData = extractSingleJavaScriptCode(from: inputText)
                    
                case .python:
                    codeType = .python
                case .unknown:
                    codeType = .unknown
                }
                
                
            }
        }
    }
    
    func extractSingleJavaScriptCode(from text: String) -> String? {
        let pattern = "```javascript\\n([\\s\\S]*?)\\n```"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        
        // 修正后的正确写法
        if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            let matchRange = match.range(at: 1)
            if let swiftRange = Range(matchRange, in: text) {
                return String(text[swiftRange])
            }
        }
        
        return nil
    }
    
    func extractHTMLFromMarkdown(_ markdown: String) -> String? {
        // 查找 ```html 和 ``` 之间的内容
        if let startRange = markdown.range(of: "```html\n"),
           let endRange = markdown.range(of: "\n```", range: startRange.upperBound..<markdown.endIndex) {
            let htmlContent = String(markdown[startRange.upperBound..<endRange.lowerBound])
            return htmlContent
        }
        return nil
    }
    
    
    func extractSVG(from text: String) {
        // 正则表达式匹配 SVG 标签及其内容
               let pattern = "<svg[^>]*>(.|\\n)*?</svg>"
               
               do {
                   let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                   let range = NSRange(location: 0, length: text.utf16.count)
                   
                   if let match = regex.firstMatch(in: text, options: [], range: range) {
                       let matchedRange = match.range
                       if let swiftRange = Range(matchedRange, in: text) {
                           svgData = String(text[swiftRange])
                       }
                   }
               } catch {
                   print("正则表达式错误: \(error.localizedDescription)")
               }
    }
    
    private func createHTMLPage(svgContent: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; }
                svg { max-width: 100%; height: auto; }
            </style>
        </head>
        <body>
            \(svgContent)
        </body>
        </html>
        """
    }
}




func detectCodeType(_ code: String) -> CodeType {
    let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
    
    
    // HTML 检测
    let htmlPattern = "```html"//"<[a-z][\\s\\S]*?>"
    if code.contains(htmlPattern){//trimmedCode.range(of: htmlPattern, options: .regularExpression) != nil {
        return .html
    }
    
    // SVG 检测（优先于 HTML 检测）
    let svgPatterns = [
        "<svg[\\s\\S]*?>[\\s\\S]*<\\/svg>"
//        "<svg[\\s\\S]*?\\/>",
//        "viewBox=\"[^\"]*\"",
//        "d=\"[^\"]*\"",  // 路径数据
//        "<path\\s",
//        "<circle\\s",
//        "<rect\\s",
//        "<polygon\\s"
    ]
    if svgPatterns.contains(where: { trimmedCode.range(of: $0, options: .regularExpression) != nil }) {
        return .svg
    }
    
    
    
    // JavaScript 检测
    let jsPatterns = [
        "```javascript",
        "function\\s+[a-zA-Z_$][0-9a-zA-Z_$]*\\s*\\([^)]*\\)\\s*\\{[^}]*\\}",
        "const\\s+|let\\s+|var\\s+",
        "=>\\s*\\{",
        "console\\.log\\("
    ]
    if jsPatterns.contains(where: { trimmedCode.range(of: $0, options: .regularExpression) != nil }) {
        return .javascript
    }
    
    
    let pythonPatterns = "```python"
    if trimmedCode.contains(pythonPatterns) {
        return .python
    }
    
    // Python 检测
//    let pythonPatterns = [
//        "^\\s*def\\s+[a-zA-Z_][a-zA-Z0-9_]*\\s*\\([^)]*\\):",
//        "^\\s*class\\s+[a-zA-Z_][a-zA-Z0-9_]*\\s*:",
//        "^\\s*import\\s+|^\\s*from\\s+",
//        "^\\s*print\\s*\\(",
//        "^\\s*if\\s+.+:",
//        "^\\s*for\\s+.+\\s+in\\s+.+:"
//    ]
//    if pythonPatterns.contains(where: { trimmedCode.range(of: $0, options: .regularExpression) != nil }) {
//        return .python
//    }
    
    return .unknown
}

//func isHtml(code:String) -> String{
//    // 检测常规 HTML 标签
//        let tagPattern = "<[a-z][\\s\\S]*?>"
//        
//        // 检测 Markdown 代码块中的 HTML
//        let markdownHtmlPattern = "```html\\n[\\s\\S]*?```"
//        
//        // 检测 DOCTYPE 声明
//        //let doctypePattern = "<!DOCTYPE html>"
//        
//        // 检测完整的 HTML 结构
//        let fullHtmlPattern = "<html[\\s\\S]*?>[\\s\\S]*<\\/html>"
//        
//        return code.range(of: tagPattern, options: .regularExpression) != nil || code.range(of: markdownHtmlPattern, options: .regularExpression) != nil || code.range(of: doctypePattern, options: .regularExpression) != nil || code.range(of: fullHtmlPattern, options: .regularExpression) != nil
//}
 
