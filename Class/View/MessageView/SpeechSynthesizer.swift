//
//  SpeechSynthesizer.swift
//  GPTalks
//
//  Created by Adswave on 2025/5/7.
//

import SwiftUI
import AVFoundation
 

// 按钮数据模型
struct ButtonData {
    let name: String
}

 

class SpeechSynthesizer: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    var onFinishSpeaking: (() -> Void)?
    
    // 是否正在播放
    @Published var isSpeaking = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ text: String, language: String = "zh-CN", onFinish: (() -> Void)? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        self.onFinishSpeaking = onFinish
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        onFinishSpeaking?() // 手动触发完成回调
    }
     
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("开始播放")
        isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("播放完成")
        isSpeaking = false
        onFinishSpeaking?()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("已暂停")
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("继续播放")
        isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("播放取消")
        isSpeaking = false
    }
}
