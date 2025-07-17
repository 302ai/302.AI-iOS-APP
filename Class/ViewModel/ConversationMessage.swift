//
//  ConversationMessage.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/28.
//
import SwiftUI
import Foundation


struct ConversationMessage: Codable {
    var content: String
    var reasoning: String
    var receivedTime: TimeInterval
    var startTime: Date
    var atModelName: String
    
    
    // 显式声明成员式初始化方法
    init(content: String, reasoning: String, receivedTime: TimeInterval, startTime: Date,atModelName:String) {
        self.content = content
        self.reasoning = reasoning
        self.receivedTime = receivedTime
        self.startTime = startTime
        self.atModelName = atModelName
    }
    
    // 计算属性，获取耗时字符串
    var timeCostString: String {
        let cost = receivedTime
        return String(format: "%.2f", cost) //return String(format: "%.2fs", cost)
    }
    
    // 合并内容的方法
    func combinedText() -> String {
        return "Reasoning (\(timeCostString)):\n\(reasoning)\n\nContent:\n\(content)"
    }
    
    // 从JSON字符串初始化
    init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(ConversationMessage.self, from: data) else {
            return nil
        }
        self = decoded
    }
    
    // 转换为JSON字符串
    func toJsonString() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
