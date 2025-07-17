//
//  IOSInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

#if !os(macOS)
import SwiftUI
import PhotosUI
import ActivityIndicatorView
import Toasts


struct AtModelButton: View {
    
    @Binding var buttonText : String
    var action: () -> Void
     
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                CustomText("@\(buttonText)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("x")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                //Capsule()
                    //.fill(Color(.blue).opacity(0.3))
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.blue.opacity(0.1))
                    
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.cyan, lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .hidden(buttonText.isEmpty)
    }
}


struct IOSInputView: View {
    @Bindable var session: DialogueSession
    @Environment(\.presentToast) var presentToast
    @FocusState var focused: Bool
    //@Binding var previewOn : Bool
    @State private var importingImage = false
    @State private var importingAudio = false
    @State private var showMore = false
    @State private var isHiddenInput = false
    @State private var isSpeaking = false
    
    @State private var isKeyboardIconHidden = false
    @State private var isPressBtnOut = false
    //@State private var hasImage = false
    
    @State var selectedItems: [PhotosPickerItem] = []
    
    @StateObject private var speechManager = SpeechRecognizerManager()
    
    var onAtModelBtnTap: (Bool) -> Void
    var previewBtnTap: (Bool) -> Void
    var clearContextBtnTap: (Bool) -> Void
    
    //@State var hasAtModel = false
    @Binding var atModelString : String
    
    
    @State var pressHoldIsPressing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading ) {
            CustomImportedImagesView(session: session)
//            CustomPDFViewer(session: session)

            
//            ActivityIndicatorView(isVisible: $isKeyboardIconHidden, type: .equalizer(count: 30))
//                .frame(width: UIScreen.main.bounds.width-100, height: 15)
//                .offset(x:50,y:10)
//                .foregroundStyle(isPressBtnOut ? .red : .blue)
            
            HStack(alignment: .top, spacing: 12) {
                if session.isEditing {
                    stopEditing
                }
                 
                //选取照片
//                moreOptions
                
//                if showMore {
//                    addImage
//                    CustomPDFPickerView(session: session, showMore: $showMore, imageSize: imageSize, padding: 10)
//                    resetContext
//                }
                 
                 
                 
                
                    ZStack(alignment: .bottomLeading) {
                        CustomTextEditorView(session: session, focused: _focused, extraAction: {
                            //CustomTextEditorView extraAction block
                            
                            selectedItems = []
                        }, onCustomMicBtnTap: {
                            print("CustomTextEditorView onMicBtnTap")
                            
                            isHiddenInput = true
                        }, onAtModelBtnTap: { isAtModel in
                            //hasAtModel = isAtModel
                            onAtModelBtnTap(isAtModel)
                        }, previewBtnTap: { preview in
                            //预览
                            previewBtnTap(preview)
                            
                        }, clearContextBtnTap: { clearContext in
                            // clear Context
                            clearContextBtnTap(clearContext)
                        }, atModelString: $atModelString)
                        .hidden(isHiddenInput)
                        
                          
                        
                        //选取照片
                        moreOptions.offset(x: 25, y: -33)
                            .hidden(isHiddenInput)
                         
                        if isHiddenInput {
                             
                            
                            VStack {
                                //语音输入
                                HStack(alignment:.center) {
                                     
                                    Spacer(minLength:20)
                                      
                                    ZStack{
                                        PressHoldButton { isPressing in
                                            isKeyboardIconHidden = isPressing
                                            
                                            if !isPressing{
                                                speechManager.stopRecording()
                                                pressHoldIsPressing = false
                                                Task {
                                                    session.input = speechManager.recognizedText
                                                    await session.sendAppropriate()
                                                }
                                            }else{
                                                speechManager.startRecording()
                                                pressHoldIsPressing = true
                                            }
                                        }onPressOutChanged: { isOut in
                                            isPressBtnOut = isOut
                                        }
                                        .offset(y:-10)
                                        
                                          
                                        Button {
                                            isHiddenInput = false
                                            isSpeaking = false
                                            
                                        } label: {
                                            Image("键盘")
                                                .resizable()  // 允许调整
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                        }
                                        .offset(x:UIScreen.main.bounds.width/2.5, y:isKeyboardIconHidden ? 30 : 0)
                                        .hidden(pressHoldIsPressing)
                                        
                                    }
                                    
                                    
                                    
                                    Spacer(minLength:25)
                                }
                                .cornerRadius(10)
                                .frame(width:UIScreen.main.bounds.width-30, height:isKeyboardIconHidden ? 125 : 60)
                                .background(Color.gray.opacity(0.05)) //输入框背景色 改这里  <<<<<<< --------------------------------------------------------
                                
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.7), lineWidth: 0.75)
                                )
                                .padding()

                            }
                            
                        }
                        
                    }
                 
                  
                
            }
               
           
            
            HStack {
                Spacer()
                Text("AI可能会犯错误，请考虑核实重要信息。")
                    .font(.system(size: FontSettings().fontSize-4))
                    .foregroundStyle(Color.gray.opacity(0.5))
                    .frame(width: 300,height: 18,alignment: .center)
                    .offset(y:-3)
                    .frame(alignment: .center)
                Spacer()
            }
             
        }
//        .background(.blue)
        .onChange(of: session.input) {
            if session.input.count > 3 {
                showMore = false
            }
        }
        .animation(.default, value: session.inputImages)
        .animation(.default, value: showMore)
        .buttonStyle(.plain)
//        .padding(.horizontal)
//        .padding(.vertical, verticalPadding + 2)
    }
    
 
    var resetContext: some View {
        Button {
            showMore = false
            session.resetContext()
        } label: {
            Image(systemName: "eraser")
                .resizable()
                .inputImageStyle(padding: 10, imageSize: imageSize)
        }
        .padding(.top, -1)
    }
    
    var stopEditing: some View {
        Button {
            session.resetIsEditing()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 10, imageSize: imageSize, color: .red)
                .rotationEffect(.degrees(45))
        }
    }
    
    var addImage: some View {
        Button {
            importingImage = true
            showMore = false
        } label: {
            Image(systemName: "photo")
                .resizable()
                .inputImageStyle(padding: 11, imageSize: imageSize)
     
        }
    }
    
    @State private var imageOpacity: Double = 1.0
    
    @State private var imagePath: String?  // 存储的图片路径
    @State private var selectedImage: UIImage?  // 存储用户选择的图片
    @State private var showImagePicker = false
    @State private var showSourceSelection = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var moreOptions: some View {
        //Image(systemName: "plus")
        Image("曲别针")
            .resizable()
            .renderingMode(.template) // 可修改颜色
            //.inputImageStyle(padding: 0, imageSize: 28,color: Color.white )
            .frame(width:25,height:25)
            .padding(-10)
            
            .foregroundColor(
                Color.init(hex: "707070")
            )
            .opacity(imageOpacity)
            .gesture(
                TapGesture()
                    .onEnded {
                        imageOpacity = 0.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            imageOpacity = 1.0
                        }
                        //importingImage = true
                        
                        if session.inputImages.count < 5{
                            showSourceSelection = true
                        }else{
                            let toast = ToastValue(message: "最多发送5张图片")
                            presentToast(toast)
                        }
                    }
                    .simultaneously(with: LongPressGesture(minimumDuration: 0.3)
                        .onChanged { _ in
                            imageOpacity = 0.5
                        }
                        .onEnded { _ in
                            imageOpacity = 1.0
                            session.resetContext()
                        }
                    )
            )
        
        
            .confirmationDialog("选择图片来源", isPresented: $showSourceSelection) {
                Button("相机") {
                    sourceType = .camera
                    showImagePicker = true
                }
                
                Button("相册") {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }
                
                Button("取消", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(imagePath: $imagePath, selectedImage: $selectedImage, sourceType: sourceType)
            }
        .photosPicker(
            isPresented: $importingImage,
            selection: $selectedItems,
            maxSelectionCount: 5, 
            matching: .images,
            photoLibrary: .shared()
        )
        
        .onChange(of: imagePath) {
            
            if let image = imagePath {
                
                session.inputImages.append(image)
            }
        }
        
        .onChange(of: selectedItems) {
            Task {
                for newItem in selectedItems {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            if let filePath = saveImage(image: image) {
                                if session.isEditing {
                                    session.editingImages.append(filePath)
                                } else {
                                    session.inputImages.append(filePath)
                                    print("Image saved to \(filePath)")
                                }
                                //hasImage = true
                            }
                        }
                    }
                }
                selectedItems = [] // Reset selection
            }
        }
    }

    private var verticalPadding: CGFloat {
        return 7
    }

    private var imageSize: CGFloat {
        37
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imagePath: String?
    @Binding var selectedImage: UIImage?  // 用于存储选择的图片
    @Environment(\.presentationMode) private var presentationMode
    
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator  // 设置代理
        picker.sourceType = sourceType
        picker.allowsEditing = false  // 是否允许编辑
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    // 创建 Coordinator 处理回调
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    var imageFile = ""
    // Coordinator 类，处理 UIImagePickerController 的代理方法
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // 用户选择了图片
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image  // 存储选择的图片
                
                
                if let filePath = saveImage(image: image) {
                     parent.imagePath = filePath
                }
                
            }
            parent.presentationMode.wrappedValue.dismiss()  // 关闭 ImagePicker
        }
        
        // 用户取消选择
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()  // 关闭 ImagePicker
        }
    }
}


class PressBtnManager : ObservableObject {
    @Published var isRecording = false
    
}


struct PressHoldButton: View {
    @State var isPressing = false
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var isCancelled = false
    @State private var fingerPosition: CGPoint? = nil
    //@StateObject private var pressBtnManager = PressBtnManager()
    
    var onPressStateChanged: ((Bool) -> Void)?
    var onPressOutChanged: ((Bool) -> Void)?
    var onAtModelBtnTap: ((Bool) -> Void)?
    
    var frameWidth = UIScreen.main.bounds.width/1.6
    
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // 计算手指是否在按钮范围内
    private var isFingerInside: Bool {
        guard let position = fingerPosition else { return false }
        return position.y >= 0 && position.y <= 60
    }
    
    // 按钮背景色
    private var buttonColor: Color {
        if !isPressing {
            return .clear
        } else if !isFingerInside {
            return .red.opacity(0.7)
        } else {
            return .blue.opacity(0.7)
        }
    }
    
    // 按钮文字
    private var buttonText: String {
        if !isPressing {
            
            return "按住说话"
        } else if !isFingerInside {
            
            return ""//"松开取消"
        } else {
            
            return ""//"松开结束"
        }
    }
    
    
    // 按钮提示
    private var buttonText2: String {
        if !isPressing {
            return "         " //◉
        } else if !isFingerInside {
            return "松开取消"
        } else {
            return "松开发送,上滑取消"
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            
            VStack{
                
            }.frame(height: 10)
            ActivityIndicatorView(isVisible: $isPressing, type: .equalizer(count: 20))
                .frame(width: frameWidth, height: 15)
                //.offset(y:-12)
                .foregroundStyle(isFingerInside ? .blue : .red)
            
            
            CustomText(buttonText2)
                .font(.body)
                .frame(width: frameWidth, height: isPressing ? 22 : 0)

             
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(buttonColor)
                    .frame(width: frameWidth,height:45)
                    .animation(.easeInOut(duration: 0.2), value: isFingerInside)
                
                CustomText(buttonText)
                    .foregroundColor(.primary)
                    .font(.headline)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        fingerPosition = value.location
                        
                        if !isPressing && isFingerInside {
                            startPress()
                        }
                         
                        if isPressing && !isFingerInside {
                            // 手指离开按钮范围，准备取消
                            cancelTiming()
                        }else{
                            onPressOutChanged?(false)
                        }
                    }
                    .onEnded { value in
                        if isPressing {
                            if isFingerInside {
                                // 在按钮范围内正常松开结束
                                endTiming()
                            } else {
                                // 在按钮范围外松开，确认取消
                                confirmCancel()
                            }
                        }
                        fingerPosition = nil
                    }
            )
        }
        .padding()
        .onReceive(timer) { _ in
            if isPressing && isFingerInside, let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    
    private func startPress() {
           startTime = Date()
           isPressing = true
           isCancelled = false
           onPressStateChanged?(true) // 按压开始回调
       }
       
    
    private func cancelTiming() {
        // 手指离开时停止计时，但不重置数据
        
        onPressOutChanged?(true)
        isCancelled = true
    }
    
    private func confirmCancel() {
        isPressing = false
        isCancelled = true
        elapsedTime = 0
        startTime = nil
        
        onPressStateChanged?(false)
    }
    
    private func endTiming() {
        isPressing = false
        isCancelled = false
        
        onPressStateChanged?(false)
        print("计时结果: \(elapsedTime)秒")
    }
}


#endif
