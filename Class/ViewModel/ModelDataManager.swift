//
//  ModelDataManager.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/21.
//

import SwiftUI
import Foundation

class ModelDataManager {
    static let shared = ModelDataManager()
    private let saveModelsKey = "savedAI302Models"
    private let saveModelsKey_moderated = "savedAI302Models_moderated"
    
    // 私有初始化方法防止外部创建实例
    private init() {}
    
    // 保存模型数组
    func saveModels(_ models: [AI302Model]) {
        if let encoded = try? JSONEncoder().encode(models) {
            UserDefaults.standard.set(encoded, forKey: saveModelsKey)
        }
    }
    
    // 保存模型数组
    func saveModelsModerated(_ models: [AI302Model]) {
        if let encoded = try? JSONEncoder().encode(models) {
            UserDefaults.standard.set(encoded, forKey: saveModelsKey_moderated)
        }
    }
    
    // 加载模型数组
    func loadModels() -> [AI302Model] {
        if let data = UserDefaults.standard.data(forKey: saveModelsKey),
           let decoded = try? JSONDecoder().decode([AI302Model].self, from: data) {
            return decoded
        }
        return []
    }
    
    
    
    // 加载模型数组
    func loadModelsModerated() -> [AI302Model] {
        if let data = UserDefaults.standard.data(forKey: saveModelsKey_moderated),
           let decoded = try? JSONDecoder().decode([AI302Model].self, from: data) {
            return decoded
        }
        return []
    }
    
    
    // 添加单个模型
    func addModel(_ model: AI302Model) {
        var currentModels = loadModels()
        currentModels.append(model)
        saveModels(currentModels)
    }
    
    // 删除单个模型
    func removeModel(_ model: AI302Model) {
        var currentModels = loadModels()
        currentModels.removeAll { $0.id == model.id }
        saveModels(currentModels)
    }
    
    // 更新模型
    func updateModel(_ model: AI302Model) {
        var currentModels = loadModels()
        if let index = currentModels.firstIndex(where: { $0.id == model.id }) {
            currentModels[index] = model
            saveModels(currentModels)
        }
    }
}
