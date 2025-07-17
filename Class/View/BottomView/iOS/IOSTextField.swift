//
//  IOSTextField.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

#if !os(macOS)
import SwiftUI
import PhotosUI
import AlertToast
import PopupView
import Toasts



struct IOSTextField: View {
    @Bindable var session: DialogueSession
    
    @EnvironmentObject var config: AppConfiguration  // 使用 @EnvironmentObject
    @Environment(\.presentToast) var presentToast
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var resetMarker: Int
    @Binding var input: String
    var isReplying: Bool
    @FocusState var focused: Bool
    //var speechText: String
    @Binding var previewOn : Bool
    @State var hasImage = false
    
    @State var isShowMicrophone = false
    var onMicBtnTap: () -> Void
    
    var onAtModelBtnTap: (Bool) -> Void
    var previewBtnTap: (Bool) -> Void
    var clearContextBtnTap: (Bool) -> Void
    
    @Binding var atModelString : String
    
    
    @StateObject private var speechManager = SpeechRecognizerManager()
    
    //艾特 别针 大脑 话筒 可见 上下文  网络
    //var imageArr = ["网络","大脑","话筒","艾特","可见","上下文"]
    var imageArr = ["网络","大脑","话筒","上下文"]
    
    
    var send: () -> Void
    var stop: () -> Void
    
    @State var isShowToast = false
    // 提示文本（可选）
    @State private var hintText: String?

//    @State var isShowAlert = false
//    @State private var alertText = "自定义Api暂不支持"
    
    var body: some View {
          
        ZStack(alignment: .bottomTrailing) {
            
            VStack(spacing: 8) {
                
//                HStack{
//                    Spacer(minLength: 10)
//                    //@模型
//                    AtModelButton(buttonText: $atModelString) {
//                        onAtModelBtnTap(false)
//                         
//                    }
//                    .frame(height:atModelString.isEmpty ? 0 : 20)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    Spacer()
//                }
//                .hidden(atModelString.isEmpty)
                
                // 输入框
                TextField("发送消息", text: $input, axis: .vertical) //"Send a message"
    //                .disableAutocorrection(true)
                    .focused($focused)
                    //.submitLabel(.send)
                    .onSubmit {
                        send()
                    }
                    .multilineTextAlignment(.leading)
                    .lineLimit(1 ... 15)
                    //.padding(6)
                    .padding(.leading, 2)
                    .padding(.trailing, 3) // for avoiding send button
                    .frame(minHeight: imageSize + 7)
                    .background(
                        Color.gray.opacity(0.001)
                    )
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                               
                                //显示清除上下文按钮
                                let btnCount = AppConfiguration.shared.isShowClearContext ? 4 : 3
                                
                                ForEach(0..<btnCount, id:\.self) { index in
                                    
                                    
                                    Button(action: {
                                        if index == 0 {
                                            if config.apiHost.contains("302") {
                                                
                                                config.isWebSearch.toggle()
                                                let toast = ToastValue(
                                                    message: config.isWebSearch  ? "联网搜索已打开" : "联网搜索已关闭"
                                                )
                                                presentToast(toast)
                                            }else{
                                                let toast = ToastValue(
                                                    message: "自定义Api暂不支持"
                                                  )
                                                  presentToast(toast)
                                            }
                                        } else if index == 1 {
                                            if config.apiHost.contains("302")  {
                                                config.isR1Fusion.toggle()
                                                
                                                let toast = ToastValue(
                                                    message: config.isR1Fusion ? "推理模式已打开" : "推理模式已关闭"
                                                )
                                                presentToast(toast)
                                            }else{
                                                let toast = ToastValue(
                                                    message: "自定义Api暂不支持"
                                                  )
                                                  presentToast(toast)
                                            }
                                        }else if index == 2 {
                                            onMicBtnTap()
                                        }else if index == 3 {
                                            
                                            let toast = ToastValue(
                                                message: "上下文已恢复"
                                            )
                                            presentToast(toast)
                                            
                                            clearContextBtnTap(true)
                                            
                                        }else if index == 4 {
                                            //预览 //
//                                            previewOn.toggle()
//                                            previewBtnTap(previewOn)
                                            
                                        }else if index == 5 {
                                            
                                            let toast = ToastValue(
                                                message: "上下文已恢复"
                                            )
                                            presentToast(toast)
                                             
                                            clearContextBtnTap(true)
                                        }else{
                                            hintText = "敬请期待~"
                                        }
                                        
                                        
                                        
                                        // 3秒
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                            isShowToast = false
//                                            hintText = nil
//                                        }
                                    }) {
                                        Image("\(imageArr[index])")
                                                .resizable()
                                                .renderingMode(.template) // 可修改颜色
                                                .frame(width: 24, height: 24)
                                                .padding(.horizontal ,5) // 使按钮实际大小为 44x44
                                                .padding(.vertical,2)
                                                .foregroundColor(
                                                    (index == 0 && config.isWebSearch) || (index == 1 && config.isR1Fusion) ? .blue : Color.init(hex: "707070")
                                                )
                                    }
                                    .disabled(((session.configuration.model.contains("reason") || session.configuration.model.contains("-r1")) && index == 1))

                                }
                            }
                            .padding(0)
                }
                .padding(.horizontal)
                .padding(.bottom, 0)
                .padding(.leading,8)
                .padding(.trailing,20)
                 

            }
            .padding()
            .cornerRadius(10)
            .background(Color.gray.opacity(0.05)) //输入框背景色 改这里  <<<<<<< --------------------------------------------------------
            
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.7), lineWidth: 0.75)
            )
            .padding(6)
            
            .onChange(of: session.inputImages) {
                if !session.inputImages.isEmpty {
                    hasImage = true
                }else{
                    hasImage = false
                }
            }
            
            Group {
                if input.isEmpty && !isReplying && !hasImage {
                    Button {} label: {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize - 15, height: imageSize - 15)
                            .bold()
                            .foregroundStyle(.background)
                            //.opacity(0.5)
                            .padding(10) // 确保圆形有足够空间（可选）
                            .background(Circle().fill(Color.gray.opacity(0.9))) // 可选：添加圆形背景
                            .clipShape(Circle()) // 关键：裁剪为圆形
                            .offset(y:10)
                    }
                    .offset(x: -8, y: 0)
                      
                    
                } else {
                    Group {
                        if isReplying {
                            StopButton(size: imageSize + 5) {
                                stop()
                            }
                        } else {
                            SendButton(size: imageSize + 5) {
                                send()
                            }
                        }
                    }
                    .offset(x: -8, y: 8)//(x: -4, y: -4)
                }
            }
            .offset(x: -20, y: -30)
            //.padding(20) // Increase tappable area 增加可触碰区域
            //.padding(20) // Cancel out visual expansion 取消视觉扩展
            
        }
        .hidden(isShowMicrophone)
        
        
        .onTapGesture {
            focused = true
            
        }
        .toast(isPresenting: $isShowToast){
              
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }

        
        
    }
     
    

    @State private var imageOpacity: Double = 1.0
     
    
    private var imageSize: CGFloat {
        31
    }
}
 
 




#endif
