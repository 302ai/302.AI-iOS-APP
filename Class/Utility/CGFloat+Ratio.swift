//
//  CGFloat+Ratio.swift
//  Chat302AI
//
//  Created by Adswave on 2025/7/8.
//

import Foundation


extension CGFloat {
    /// 根据屏幕宽度比例调整尺寸（基准宽度：iPhone 15 = 390pt）
    /// - Parameters:
    ///   - value: 设计稿尺寸（基于 iPhone 15 的尺寸）
    /// - Returns: 按当前设备屏幕宽度比例缩放后的值
    ///
//    static func adaptive(_ value: Int) -> CGFloat {
//        let baseScreenWidth: CGFloat = 390.0 // iPhone 15 的逻辑屏幕宽度（pt）
//        let currentScreenWidth = UIScreen.main.bounds.width
//        let scaleFactor = currentScreenWidth / baseScreenWidth
//        return CGFloat(value) * scaleFactor
//    }
//    
//    /// 更通用的方法，允许自定义基准宽度
//    /// - Parameters:
//    ///   - value: 原始尺寸
//    ///   - baseWidth: 基准屏幕宽度（默认 iPhone 15 的 390pt）
//    /// - Returns: 按比例缩放后的值
    
//    static func adaptive(_ value: Int, baseWidth: CGFloat = 390.0) -> CGFloat {
//        let currentScreenWidth = UIScreen.main.bounds.width
//        let scaleFactor = currentScreenWidth / baseWidth
//        return CGFloat(value) * scaleFactor
//    }
}
