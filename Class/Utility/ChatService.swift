//
//  ChatService.swift
//  GPTalks
//
//  Created by Adswave on 2025/6/13.
//

import SwiftUI
 
// 请求体模型
struct ChatRequest: Codable {
    let model: String
    let messages: [Message]
    let stream: Bool
    
    struct Message: Codable {
        let role: String
        let content: String
    }
}

// 响应体模型
struct ChatCompletionChunk: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let citations : [String]?
    
    struct Choice: Codable {
        let index: Int
        let delta: Delta
        let finishReason: String?
         
        
        struct Delta: Codable {
            let role: String?
            internal let _reasoning: String?
            internal let _reasoningContent: String?
 
            public var reasoning: String? {
                _reasoning ?? _reasoningContent
            }
            let content: String?
            
            enum CodingKeys: String, CodingKey {
                case role, content
                case _reasoning = "reasoning"
                case _reasoningContent = "reasoning_content"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case index,delta
            case finishReason = "finish_reason"
        }
    }
}
 



// 网络服务类
class ChatService {
    
    static let shared = ChatService()
    private let url = URL(string: "https://api.302.ai/v1/chat/completions")!
    private let apiKey = "sk-JlPHNbbOjqQNxZHWSY0s60p2GP9IZ3VmgooOYMcnLVA3glQt"
    
    func streamMessage(message: String,
                      onChunkReceived: @escaping (ChatCompletionChunk) -> Void,
                      onCompletion: @escaping (Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatRequest(
            model: "gpt-4o",
            messages: [ChatRequest.Message(role: "user", content: message)],
            stream: true
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            onCompletion(error)
            return
        }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                onCompletion(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                onCompletion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                return
            }
            
            guard let data = data else {
                onCompletion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // 处理流式响应
            if let responseString = String(data: data, encoding: .utf8) {
                let lines = responseString.components(separatedBy: .newlines)
                for line in lines {
                    guard line.hasPrefix("data: "),
                          let jsonData = line.dropFirst(6).data(using: .utf8) else {
                        continue
                    }
                    
                    do {
                        let chunk = try JSONDecoder().decode(ChatCompletionChunk.self, from: jsonData)
                        DispatchQueue.main.async {
                            onChunkReceived(chunk)
                        }
                    } catch {
                        print("Error decoding chunk: \(error)")
                    }
                }
                print("responseString:----->>>>>  \(responseString)")
            }
            

            
            onCompletion(nil)
        }
        task.resume()
    }
}

 
    
