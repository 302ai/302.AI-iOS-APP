//
//  ImportPreviewers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI

struct CustomImportedImagesView: View {
    @Bindable var session: DialogueSession
    
    private var currentImages: Binding<[String]> {
        session.isEditing ? $session.editingImages : $session.inputImages
    }
    
    var body: some View {
        
//        ForEach(currentImages.wrappedValue, id: \.self) { image in
//            ImagePreviewer(imageURL: URL(string: image)!) {
//                self.currentImages.wrappedValue.removeAll(where: { $0 == image })
//            }
//        }
        
        ScrollView(.horizontal, showsIndicators: false) {
                   HStack(spacing: 10) {
                       ForEach(currentImages.wrappedValue, id: \.self) { image in
                           ImagePreviewer(imageURL: URL(string: image)!) {
                               self.currentImages.wrappedValue.removeAll(where: { $0 == image })
                           }
                       }
                   }
                   .padding(.horizontal, 15)  // 添加一些边距
               }
    }
}

#if os(macOS)
struct CustomTextEditorView: View {
    @Bindable var session: DialogueSession
    
    private var currentMessage: Binding<String> {
        session.isEditing ? $session.editingMessage : $session.input
    }
    
    private var containsPdfOrAudio: Bool {
        return !session.inputPDFPath.isEmpty || !session.inputAudioPath.isEmpty || !session.editingPDFPath.isEmpty || !session.editingPDFPath.isEmpty
    }
    
    private var containsImage: Bool {
        return !session.inputImages.isEmpty || !session.editingImages.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if containsImage {
                ScrollView(.horizontal) {
                    HStack {
                        CustomImportedImagesView(session: session)
                    }
                    .padding(10)
                }
            }

            MacTextEditor(input: currentMessage)
        }
        .roundedRectangleOverlay()
    }
}
#else
struct CustomTextEditorView: View {
    @Bindable var session: DialogueSession
    @FocusState var focused: Bool
    //@Binding var previewOn : Bool 
    //@Binding var hasImage : Bool
    
    var extraAction: (() -> Void)
    
    var onCustomMicBtnTap: () -> Void
    
    var onAtModelBtnTap: (Bool) -> Void
    var previewBtnTap: (Bool) -> Void
    var clearContextBtnTap: (Bool) -> Void
    
    @Binding var atModelString : String 
    
    var currentMessage: Binding<String> {
          
        session.isEditing ? $session.editingMessage : $session.input
    }
    
    var body: some View {
            
        
        IOSTextField(session:session, resetMarker:$session.resetMarker, input: currentMessage, isReplying:  session.isReplying, focused: _focused, previewOn: $session.previewOn, onMicBtnTap: {
            onCustomMicBtnTap()
        }, onAtModelBtnTap: { isAtModel in
            onAtModelBtnTap(isAtModel)
        }, previewBtnTap: { preview in
            //预览
            previewBtnTap(preview)
            
        }, clearContextBtnTap: { clearContext in
            //clear context
            clearContextBtnTap(clearContext)
        }, atModelString: $atModelString ) {  // send:() -> Void
            focused = false
            
            //发送 send
            Task { @MainActor in
                extraAction()
                await session.sendAppropriate()
            }
        }stop: {
            session.stopStreaming()
        }
         
 
 
    }
}
#endif

struct CustomCrossButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.background)
                .background(.primary, in: Circle())
        }
        .padding(7)
        .buttonStyle(.plain)
    }
}
