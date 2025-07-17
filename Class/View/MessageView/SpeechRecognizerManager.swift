//
//  SpeechRecognizerManager.swift
//  GPTalks
//
//  Created by Adswave on 2025/5/9.
//

import Foundation
import Speech

class SpeechRecognizerManager: ObservableObject {
    @Published var recognizedText = "点击开始讲话"
    @Published var isRecording = false
    
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer?
    
    init(locale: Locale = Locale(identifier: "zh-CN")) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        requestAuthorization()
    }
    
    func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
        isRecording.toggle()
    }
    
    func startRecording() {
        recognizedText = "正在聆听..."
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            recognizedText = "语音识别不可用"
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                recognizedText = "无法创建识别请求"
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                }
                
                if let error = error {
                    //self.recognizedText = "识别错误" //"识别错误: \(error.localizedDescription)"
                    self.stopRecording()
                }
            }
        } catch {
            recognizedText = "录音启动失败" //"录音启动失败: \(error.localizedDescription)"
            stopRecording()
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        if recognizedText == "正在聆听..." {
            recognizedText = ""
        }
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch authStatus {
                case .authorized:
                    break
                case .denied:
                    self.recognizedText = "用户拒绝语音识别权限"
                case .restricted:
                    self.recognizedText = "设备限制语音识别"
                case .notDetermined:
                    self.recognizedText = "语音识别权限未确定"
                @unknown default:
                    self.recognizedText = "未知权限状态"
                }
            }
        }
    }
}
