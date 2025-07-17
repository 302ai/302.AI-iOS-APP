//
//  MessageContextMenu2.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/02/2024.
//

import SwiftUI

struct MessageContextMenu: View {
    @Environment(DialogueViewModel.self) private var viewModel
    var session: DialogueSession
    var conversation: Conversation
    var isExpanded: Bool = false
    
    var editHandler: () -> Void = {}
    var toggleTextSelection: () -> Void = {}
    var toggleExpanded: () -> Void = {}
    
    @State private var itemSize = CGSize.zero
    
    
    var body: some View {
        HStack(spacing: 10) {
            Group {
                Section {
                    if conversation.role == .user {
                        #if os(macOS)
                        if conversation.content.count > 300 {
                            expandButton
                        }
                        #endif
                        
//                        Button {
//                            editHandler()
//                        } label: {
//                            Label("Edit", systemImage: "applepencil.tip")
//                        }
                    }
                    
                    Button {
                        if !conversation.arguments.isEmpty {
                            conversation.content.copyToPasteboard()
                        } else {
                            conversation.content.copyToPasteboard()
                        }
                        
//                        if conversation.imagePaths.count > 0 {
//                            
//                        }
                        
                        
                    } label: {
                        Label("复制", systemImage: "paperclip")
                    }
                    
                    #if !os(macOS)
                    Button {
                        toggleTextSelection()
                    } label: {
                        Label("选择", systemImage: "text.viewfinder")
                    }
                    #endif
                }
                
//                Section {
//                    Button {
//                        session.setResetContextMarker(conversation: conversation)
//                    } label: {
//                        Label("Reset Context", systemImage: "eraser")
//                    }
//                    
//                    Button {
//                        let forkedConvos = session.forkSession(conversation: conversation)
//                        viewModel.addDialogue(conversations: forkedConvos)
//                    } label: {
//                        Label("Fork Session", systemImage: "arrow.branch")
//                    }
//                }
                
                Section {
                    
                    Button(role: .destructive) {
                        session.removeConversation(conversation)
                    } label: {
                        Label("删除", systemImage: "minus.diamond")
                    }
                    .tint(.red)
                    
                }
            }
            .buttonStyle(.plain)
            .imageScale(.medium)
        }
    }
    
    var expandButton: some View {
        Button {
            toggleExpanded()
        } label: {
            Label("Expand", systemImage: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
        }
    }
}
