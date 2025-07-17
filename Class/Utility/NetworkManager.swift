//
//  NetworkManager.swift
//  GPTalks
//
//  Created by Adswave on 2025/3/31.
//

import SwiftUI


struct ModelResponse: Codable {
    
    let data : [AI302Model]?
}

struct APIResponse: Codable {
    let code: Int
    let msg: String
    let data: ResponseData
    
    struct ResponseData: Codable {
        let error: String
        let stdout: String
    }
}



class NetworkManager: ObservableObject {
    
    static let shared = NetworkManager()
    
    @Published var models: [AI302Model] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 定义回调类型（成功返回 [AI302Model]，失败返回 Error）
    typealias FetchModelsCompletion = (Result<[AI302Model], Error>) -> Void
    
    func fetchModels(completion: FetchModelsCompletion? = nil)  {
        isLoading = true
        errorMessage = nil

        let item = ApiDataManager().selectedItem
        var host : String = item?.host ?? ""
        //let apiKey = AppConfiguration.shared.OAIkey
          
        if !host.contains("https://"){
            host = "https://" + host + "/v1/models"
        }else{
            host = host + "/v1/models"
        }
        
        guard var urlComponents = URLComponents(string: host) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        // 添加查询参数
        urlComponents.queryItems = [
            URLQueryItem(name: "llm", value: "1"),
            URLQueryItem(name: "chat", value: "1")
        ]

        guard let url = urlComponents.url else {
            errorMessage = "Invalid URL components"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let apiKey = "Bearer " + AppConfiguration.shared.OAIkey
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // 这里直接使用 DispatchQueue.main.async 的闭包语法
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion?(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self?.errorMessage = "Invalid response"
                completion?(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            if let data = data {
                do {
                     
                    let model = try JSONDecoder().decode(ModelResponse.self, from: data)
                    self?.models = model.data!
                    print("\n \(host) ----->>>>>>>  model:\(model)")
                    completion?(.success(self!.models))
                    
                } catch {
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }else{
                completion?(.failure(error!))
            }

        }
        
        task.resume()
    }
    
    
    func executeCodeAndReturnString(language: String, code: String, completion: @escaping  (String) -> Void) {
        // 1. 准备URL
        guard let url = URL(string: "https://api.302.ai/302/run/code") else {
            completion("错误：无效的URL")
            return
        }
        
        // 2. 准备请求体
        let requestBody: [String: Any] = [
            "language": language,
            "code": code
        ]
        
        // 3. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let apiKey = "Bearer " + AppConfiguration.shared.OAIkey
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        
        // 4. 编码JSON body
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion("错误：请求体编码失败")
            return
        }
        request.httpBody = httpBody
        
        // 5. 发送请求
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 处理网络错误
            if let error = error {
                completion("网络错误：\(error.localizedDescription)")
                return
            }
            
            // 确保有数据返回
            guard let data = data else {
                completion("错误：没有收到数据")
                return
            }
            
            // 尝试将数据直接转为字符串
            if let rawString = String(data: data, encoding: .utf8) {
                completion(rawString)
                return
            }
            
            // 如果无法转为字符串，返回原始数据描述
            completion("收到无法解码的数据：\(data.description)")
        }.resume()
    }
    
    func executeCode(language: String, code: String, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        // 1. 准备URL
        guard let url = URL(string: "https://api.302.ai/302/run/code") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // 2. 准备请求体
        let requestBody: [String: Any] = [
            "language": language,
            "code": code
        ]
        
        // 3. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer sk-JlPHNbbOjqQNxZHWSY0s60p2GP9IZ3VmgooOYMcnLVA3glQt", forHTTPHeaderField: "Authorization")
        
        // 4. 编码JSON body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // 5. 发送请求
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 错误处理
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 数据验证
            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            // 解码响应
            do {
                let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func sendChat(completion: FetchModelsCompletion? = nil)  {
        isLoading = true
        errorMessage = nil

        guard var urlComponents = URLComponents(string: "https://api.302.ai/v1/models") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        // 添加查询参数
        urlComponents.queryItems = [
            URLQueryItem(name: "llm", value: "1")
        ]

        guard let url = urlComponents.url else {
            errorMessage = "Invalid URL components"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let apiKey = "Bearer " + AppConfiguration.shared.OAIkey
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // 这里直接使用 DispatchQueue.main.async 的闭包语法
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion?(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self?.errorMessage = "Invalid response"
                completion?(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            if let data = data {
                do {
                     
                    let model = try JSONDecoder().decode(ModelResponse.self, from: data)
                    self?.models = model.data!
                    //print("https://api.302.ai/v1/models model:\(model)")
                    completion?(.success(self!.models))
                    
                } catch {
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }else{
                completion?(.failure(error!))
            }

        }
        
        task.resume()
    }
    
    
}
