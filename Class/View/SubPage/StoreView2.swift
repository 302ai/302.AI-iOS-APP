//
//  StoreView2.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/22.
//

import SwiftUI
import WebKit
import AlertToast


struct PostMessageModel: Codable {
    let description: String?
    let detail: String?
    let display_name: String?
    let display_url: String?
    let id: Int
    let num_str: String?
    let review_stats_count: Int
    let review_stats_total: Int
    let short_url: String?
    let uuid: String? //
}


struct WebView: UIViewRepresentable {
    let url: URL
    var onMessageReceived: ((Any) -> Void)? // 接收任意类型的数据（String/Dictionary等）
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // 1. 注入 JavaScript 来监听 window.postMessage
        let script = """
        window.addEventListener('message', function(event) {
            // 只处理特定来源的消息（可选）
            if (event.data && event.data.from === "auth") {
                window.webkit.messageHandlers.jsHandler.postMessage(event.data);
            }
        });
        """
        let userScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentStart, // 在页面加载前注入
            forMainFrameOnly: false // 适用于所有 iframe
        )
        
        // 2. 添加脚本和消息处理器
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.userContentController.add(
            context.coordinator,
            name: "jsHandler"
        )
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "jsHandler" {
                parent.onMessageReceived?(message.body) // 传递原始数据
            }
        }
    }
}


struct StoreView2: View {
    @State private var receivedMessage: String = ""
    
    @Bindable var viewModel: DialogueViewModel
    @Environment(\.dismiss) var dismiss
    @State var isShowToast = false
    
    var body: some View {
        VStack {
            WebView(
                url: URL(string: "https://gpts.302.ai/zh?simple_version=1")!,
                onMessageReceived: { message in
                    if let dict = message as? [String: Any], let from = dict["from"] as? String, from == "auth", let data = dict["data"] as?  [String: Any] {
                        
                        //if let dataDic = data as? [String: Any] {
                            let display_name = data["display_name"] as? String ?? "新的聊天"
                            let display_url = data["display_url"] as? String ?? ""
                            let uuid = data["uuid"] as? String ?? ""
                            let description = data["description"] as? String ?? "你好"
                            
                            //let message = parseResponseData(from: data as? String ?? "")
                             /**
                              display_name：
                              论文写手
                              description：
                              专业的论文撰写专家，专门负责根据提供的论文选题撰写完整的学术论文。
                              */
                        
                        
//                        isShowToast = true
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            
//                            isShowToast = false
//                        }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
//                            dismiss()
//                        }
                        
                        
                        //应用商店  敬请期待
                        dismiss()
                        viewModel.addDialogue(conversations: [Conversation(role: .assistant, content: description,avatar:display_url ,arguments: "预设提示词",atModelName: "",contentS: description)],title: display_name,model_topic:uuid)
                        
                        
                        
                    }
                }
            )
//            .toast(isPresenting: $isShowToast){
//                  
//                AlertToast(displayMode: .alert, type: .regular, title: "敬请期待")
//                 
//            }
            
        }
    }
    
    
    
    func parseResponseData(from jsonString: String) -> PostMessageModel? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert string to data")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let responseData = try decoder.decode(PostMessageModel.self, from: jsonData)
            return responseData
        } catch {
            print("JSON decoding error:", error)
            return nil
        }
    }
}


