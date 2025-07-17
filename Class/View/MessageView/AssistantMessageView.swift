//
//  AssistantMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import SwiftUI
import SwiftMarkdownView
import ActivityIndicatorView
import AlertToast



extension View {
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
}
 

struct AssistantMessageView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(DialogueViewModel.self) private var viewModel
    @State var conversation: Conversation
    var session: DialogueSession
    var isQuick: Bool = false
    
    @State private var showPreviewSheet = false
    @State var isHovered = false
    @State var hoverxyz = false
    
    @State var canSelectText = false
    @State private var showLoadingIndicator: Bool = true
//    @Binding var isPresented: Bool

    @State private var isExpandedReasoning = true
    //var previewBtnTap: (Bool) -> Void
    @State private var showPreview: Bool = false
    //@State private var textHeight:CGFloat = 0.1
    
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    @State private var buttons  = [
        ButtonData(name: "刷新"),
        ButtonData(name: "删除"),
        ButtonData(name: "钉住"),
        ButtonData(name: "复制"),
        ButtonData(name: "播放"),
        ButtonData(name: "可见")
    ]
    
    
    //private let buttonImageNames = ["刷新","删除","钉住","复制","播放"]
    @State private var showButtons = true //展示一排操作按钮
    @State var isShowToast = false
    @State private var hintText: String? 
    
    var body: some View {
        ZStack{
            alternateUI

            #if os(macOS)
            .onHover { isHovered in
                self.isHovered = isHovered
            }
            #else
            .sheet(isPresented: $canSelectText) {
                TextSelectionView(content: conversation.content)
            }
            .contextMenu {
                //长按弹窗
                MessageContextMenu(session: session, conversation: conversation,
                toggleTextSelection: {
                    canSelectText.toggle()
                })
                .labelStyle(.titleAndIcon)
            }
            #endif
        }
        .toast(isPresenting: $isShowToast){
               
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        
        .sheet(isPresented: $showPreview) {
            
            
            PreviewCode(msgContent: conversation.content)
            
        }
    }
    
    
    @ViewBuilder
    var alternateUI: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top, spacing: 10) { //10
                Image("applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .padding(5) //5
                    .foregroundColor(Color("niceColorLighter"))
                    .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
#if !os(macOS)
                    .padding(.top, 3)
#else
                    .offset(y: 1)
#endif
                
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    //加载中
                    if conversation.isReplying {
                        ActivityIndicatorView(isVisible: $showLoadingIndicator, type: .opacityDots(count: 3, inset: 2))
                            .frame(width: 30, height: 5)
                            .offset(y:15)
                            .foregroundStyle(.gray)
//                         ProgressView()
//                             .controlSize(.small)
                    }
                    
                    if let message = ConversationMessage(jsonString: conversation.content) {
                        
                        Spacer(minLength: conversation.atModelName.isEmpty ? 0 : 5)
                        Text("@\(message.atModelName)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .hidden(message.atModelName.isEmpty)
                    }
                    
                    
                    Spacer()
                    Group {
                        if AppConfiguration.shared.isMarkdownEnabled {
                            //MessageMarkdownView(text: conversation.content)
                                if session.isReplying && conversation.contentS.isEmpty && !AppConfiguration.shared.isWebSearch {
                                    
                                    if let message = ConversationMessage(jsonString: conversation.content) {
                                        if AppConfiguration.shared.isR1Fusion {
                                            HStack {
                                                Text("已深度思考(\(message.timeCostString))秒")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                Image(systemName: conversation.expandedReasoning ? "chevron.up" : "chevron.down")
                                                    .foregroundColor(.gray)
                                                Spacer()
                                            }
                                            .hidden(conversation.content.isEmpty)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    isExpandedReasoning.toggle()
                                                    conversation.expandedReasoning.toggle()
                                                    
                                                    let data = Conversation.createConversationData(from: conversation, in: PersistenceController.shared.container.viewContext)
                                                    
                                                    data.sync(with: conversation)
                                                }
                                            }
                                            if isExpandedReasoning {
                                                Text(message.reasoning)
                                                    .cornerRadius(10)
                                                    .font(.footnote)
                                                    .padding(.top, -15)
                                                    .padding(.bottom, 0)
                                                    .padding([.leading, .trailing], -10)
                                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                                                    .frame(minHeight: 40)
                                                    .foregroundStyle(.gray)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.gray.opacity(0.01))
                                                    )
                                                    .transition(.asymmetric(
                                                        insertion: .opacity.combined(with: .move(edge: .leading)),
                                                        removal: .opacity
                                                    ))
                                            }
                                            
                                        }
                                        
                                        SwiftMarkdownView(message.content)
                                            .cornerRadius(10)
                                            //.padding(0)
                                            .padding([.top,.bottom], 15)
                                            .padding([.leading], 13)
                                            .contentShape(RoundedRectangle(cornerRadius: 10))
                                            .frame(minHeight: 40)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.gray.opacity(0.1))
                                            )
                                            .overlay(
                                                conversation.content.isEmpty ? nil : RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray, lineWidth: 0.5)
                                            )
                                            .hidden(message.content.isEmpty)
                                    }
                                    
                                }else{
                                        
                                        // 从JSON字符串解析出消息
                                        if let message = ConversationMessage(jsonString: conversation.content) {
                                            
                                            if !message.reasoning.isEmpty {
                                                HStack {
                                                    Text("已深度思考(\(message.timeCostString))秒")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                    Image(systemName: conversation.expandedReasoning ? "chevron.up" : "chevron.down")
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                }
                                                .hidden(conversation.content.isEmpty)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        isExpandedReasoning.toggle()
                                                        conversation.expandedReasoning.toggle()
                                                        
                                                        let data = Conversation.createConversationData(from: conversation, in: PersistenceController.shared.container.viewContext)
                                                        
                                                        data.sync(with: conversation)
                                                    }
                                                }
                                                if conversation.expandedReasoning {
                                                    Text(message.reasoning)
                                                        .cornerRadius(10)
                                                        .font(.footnote)
                                                        .padding([.top], -15)
                                                        .padding(.bottom, 0)
                                                        .padding([.leading, .trailing], -10)
                                                        .contentShape(RoundedRectangle(cornerRadius: 10))
                                                        .frame(minHeight: 40)
                                                        .foregroundStyle(.gray)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.gray.opacity(0.01))
                                                        )
                                                        .transition(.asymmetric(
                                                            insertion: .opacity.combined(with: .move(edge: .leading)),
                                                            removal: .opacity
                                                        ))
                                                }
                                            }
                                            
                                            VStack{
                                                 
                                                if message.content.count > 20 {
                                                    SwiftMarkdownView(message.content)
                                                        .cornerRadius(10)
                                                        .padding(.top, 15)
                                                        .padding([.leading], 13)
                                                        .padding(.trailing, 8)
                                                        .frame(minWidth:50, minHeight: 40)
                                                        
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.gray.opacity(0.1))
                                                        )
                                                        .overlay(
                                                            conversation.content.isEmpty ? nil : RoundedRectangle(cornerRadius: 10)
                                                                .stroke(Color.gray, lineWidth: 0.5)
                                                        )
                                                        
                                                        .contentShape(RoundedRectangle(cornerRadius: 10))
                                                        .hidden(message.content.isEmpty)
                                                        .onTapGesture {
                                                            withAnimation {
                                                                //showButtons.toggle()
                                                            }
                                                        }
                                                }else{
                                                    HStack {
                                                        Text(message.content)
                                                            .frame(minWidth:100, minHeight: 20)
                                                            .font(.body)
                                                            .cornerRadius(10)
                                                            .padding(8)
                                                        
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .fill(Color.gray.opacity(0.1))
                                                            )
                                                            .overlay(
                                                                conversation.content.isEmpty ? nil : RoundedRectangle(cornerRadius: 10)
                                                                    .stroke(Color.gray, lineWidth: 0.5)
                                                            )
                                                        
                                                            .contentShape(RoundedRectangle(cornerRadius: 10))
                                                            .hidden(message.content.isEmpty)
                                                            .onTapGesture {
                                                                withAnimation {
                                                                    //showButtons.toggle()
                                                                }
                                                            }
                                                        
                                                        Spacer()
                                                    }
                                                }
                                                
                                            }
                                            
                                             
                                            
                                            // VStack2 - 根据状态显示或隐藏
                                            //if showButtons && conversation.arguments.isEmpty{
                                            if  conversation.arguments.isEmpty && !message.content.isEmpty{
                                                let btnCount = AppConfiguration.shared.previewOn ? 6 : 5
                                                
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 10) {
                                                        //ForEach(buttons.indices, id: \.self) { index in
                                                        ForEach(0..<btnCount, id: \.self) { index in
                                                        
                                                            Button(action: {
                                                                print("Button \(index) tapped")
                                                                
                                                                buttonAction(index: index,con: conversation)
                                                                
                                                            }) {
                                                                ZStack {
                                                                    // 按钮背景（46×30，圆角15）
                                                                    RoundedRectangle(cornerRadius: 15)
                                                                        .frame(width: 46, height: 30)
                                                                        .foregroundStyle(.white)
                                                                        .overlay(
                                                                            RoundedRectangle(cornerRadius: 15)
                                                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                                                        )
                                                                    
                                                                    // 图片（缩小显示，宽高20×20）
                                                                    Image(buttons[index].name)
                                                                        .resizable()
                                                                        .renderingMode(.template)
                                                                        .scaledToFit()
                                                                        .foregroundColor(buttonBackgroundColor(for: index))
                                                                        .frame(width: 30, height: 30)
                                                                }
                                                                
                                                            }
                                                        }
                                                    }
                                                    //.padding(.horizontal)  // 左右留白
                                                }
                                                .transition(.opacity)
                                                .padding()
                                                .offset(x:-15)
                                                .frame(height: 46)  // 适当调整高度
                                            }
                                                        
                                            
                                        }else{
                                            VStack{
                                                
                                                if conversation.content.count > 20 {
                                                    SwiftMarkdownView(conversation.content)
                                                        .cornerRadius(10)
                                                        .padding(.top, 15)
                                                        .padding([.leading], 13)
                                                        .padding(.trailing, 8)
                                                        .contentShape(RoundedRectangle(cornerRadius: 10))
                                                        .frame(minHeight: 40)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.gray.opacity(0.1))
                                                        )
                                                        .overlay(
                                                            conversation.content.isEmpty ? nil : RoundedRectangle(cornerRadius: 10)
                                                                .stroke(Color.gray, lineWidth: 0.5)
                                                        )
                                                }else{
                                                    HStack {
                                                        Text(conversation.content)
                                                            .frame(minWidth:100,minHeight:20)
                                                            .cornerRadius(10)
                                                            .padding(8)
                                                            .font(.body)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .fill(Color.gray.opacity(0.1))
                                                            )
                                                            .overlay(
                                                                conversation.content.isEmpty ? nil : RoundedRectangle(cornerRadius: 10)
                                                                    .stroke(Color.gray, lineWidth: 0.5)
                                                            )
                                                        
                                                            .contentShape(RoundedRectangle(cornerRadius: 10))
                                                            .hidden(conversation.content.isEmpty)
                                                            .onTapGesture {
                                                                withAnimation {
                                                                    //showButtons.toggle()
                                                                }
                                                            }
                                                        
                                                        Spacer()
                                                    }
                                                }
                                                
                                            }.hidden(conversation.content.isEmpty)
                                              
                                        }
                                         
                                }
                            
                            
                                //预设提示词
                                if !conversation.arguments.isEmpty {
                                    HStack{
                                        Text(conversation.arguments)
                                            .foregroundStyle(.gray)
                                            .font(.footnote)
                                        Spacer()
                                    }.offset(y:5)
                                }
                               
                        } else {
                            Text(conversation.content)
                                .cornerRadius(10)
                                .overlay(
                                    conversation.content.isEmpty ? nil : RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1)) // 使用填充而不是背景色
                                        .stroke(Color.gray, lineWidth: 0.5)
                                        .padding(-10)
                                )
                        }
                    }
                    .offset(x:-8,y:conversation.arguments.isEmpty ? 10 : 25)
                    .textSelection(.enabled)
                    
                    
                     
                     
                    
                    ForEach(conversation.imagePaths, id: \.self) { imagePath in
                        ImageView2(imageUrlPath: imagePath, imageSize: imageSize, showSaveButton: true)
                    }
                }
                
                
                Spacer()
            }.hidden(conversation.content.isEmpty && !conversation.isReplying)
            .padding()
#if os(macOS)
            HStack {
                Spacer()
                
                messageContextMenu
                    .padding(.leading, 200) // Increase padding to enlarge the invisible hover area
  //                  .background(Color.blue.opacity(0.1)) // Optional: Just to visualize the area during development
                    .contentShape(Rectangle()) // Make the whole padded area hoverable
                    .onHover { isHovered in
                        hoverxyz = isHovered
                    }
                    .animation(.easeInOut(duration: 0.15), value: hoverxyz)
            }
//            .padding(10)
            .padding(.top, -40)
            .padding(.bottom, 3)
            .padding(.horizontal, 18)
#endif
        }
        #if os(macOS)
        .padding(.horizontal, 8)
//        .background(.background.tertiary)
        .background(isQuick ? .regularMaterial :  (colorScheme == .dark ? .ultraThickMaterial : .ultraThinMaterial))
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.4) : .clear)
        #else
        //.background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        //.background(colorScheme == .dark ? Color.gray.opacity(0.12) : Color.gray.opacity(0.05))
        //.background(Color.gray.opacity(0.01))  //背景色
        #endif
        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
        //.border(.quinary, width: 1) //边框
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    
    // 按钮背景色逻辑
       private func buttonBackgroundColor(for index: Int) -> Color {
           let button = buttons[index]
           if button.name == "播放" {
               return speechSynthesizer.isSpeaking ? .blue : .gray
           } else {
               return .gray
           }
       }
    
    
    struct TextWidthPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    
    func buttonAction(index:Int,con:Conversation) {
        
        if index == 0 {
            //重新生成
            Task { @MainActor in
                await session.resend(from: con)
            }
        }
        
        if index == 1 {
            //删除
            session.removeConversation(con)
        }
        
        if index == 2 {
            //钉住
            session.addToTopConversation(con)
        }
        
        if index == 3 {
            //复制
            con.content.copyToPasteboard()
            hintText = "已复制"
            isShowToast.toggle()
            // 3秒
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isShowToast = false
                hintText = nil
            }
        }
        
        if index == 4 {
            //播放内容
            let buttonName = buttons[index].name
            
            if buttonName == "播放" {
                if speechSynthesizer.isSpeaking {
                    speechSynthesizer.stop() // 停止播放
                } else {
                    if let message = ConversationMessage(jsonString: conversation.content) {
                        speechSynthesizer.speak(message.content){
                            // 播放完成后的回调（可选）
                            print("播放完成")
                        }
                    }
                }
            } else {
                print("点击了：\(buttonName)")
            }
        }
        
        if index == 5 {
            //previewBtnTap(true)
            
            showPreview = true
            
        }
        
    }
    
    
    
    /// 从字符串中提取所有被 "+302ai+" 包围的部分
    func extractTexts(from text: String) -> [String] {
        // 1. 用 "+302ai+" 分割字符串
        let components = text.components(separatedBy: "+302ai+")
        // 2. 过滤掉空字符串
        return components.filter { !$0.isEmpty }
    }
    
    
    var messageContextMenu: some View {
        HStack {
            if hoverxyz {
                MessageContextMenu(session: session, conversation: conversation,
                                   toggleTextSelection: { canSelectText.toggle() })
            } else {
                Image(systemName: "ellipsis")
                    .frame(width: 17, height: 17)
            }
        }
        .contextMenuModifier(isHovered: $isHovered)
    }
    
    private var imageSize: CGFloat {
        #if os(macOS)
        300
        #else
        325
        #endif
    }
}
