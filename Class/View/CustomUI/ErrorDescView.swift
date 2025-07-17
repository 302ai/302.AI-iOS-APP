//
//  ErrorDescView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/12/2023.
//

import SwiftUI

struct ErrorDescView: View {
    var session: DialogueSession
    @State private var isPresented = false
    
    var errorString : String  {
        
        if session.errorDesc.contains("OpenAIError") {
            return "Change the model and Try again"
        }else{
            return session.errorDesc
        }
         
        //return "更换模型再试试?"
    }
    
    
    var body: some View {
        if session.errorDesc != "" && !session.conversations.isEmpty && !session.configuration.model.contains("MiniMax") {
            
            if AppConfiguration.shared.OAIkey.isEmpty {
                VStack(spacing: 15) {
                    HStack {
                        //Text(session.errorDesc)
                        Text("未设置Api Key")
                            .textSelection(.enabled)
                            .foregroundStyle(.red)
                        
                        Button(role: .destructive) {
                            withAnimation {
                                session.resetErrorDesc()
                            }
                        } label: {
//                            Image(systemName: "doc.badge.gearshape.fill")
//                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    //Button("Retry") {
                    Button("去设置") {
                        isPresented.toggle()
                    }
                    .keyboardShortcut("r", modifiers: .command)
                    .clipShape(.capsule(style: .circular))
                }
                .padding()
                .sheet(isPresented: $isPresented) {
                    ApiItemDetailView2()
                }

            }
            else{
                VStack(spacing: 15) {
                    HStack {
                        CustomText("error:\(errorString)")
                        //Text("Network error, please retry.")
//                            .textSelection(.enabled)
//                            .foregroundStyle(.red)
                            .cornerRadius(10)
                            .font(.body)
                            .padding(10)
                            .contentShape(RoundedRectangle(cornerRadius: 10))
                            .frame(minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                            )
                            .overlay(
                                //conversation.content.isEmpty ? nil : RoundedRectangle(cornerRadius: 10)
                                RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5)
                            )
                        
                        
                        Button(role: .destructive) {
                            withAnimation {
                                session.resetErrorDesc()
                            }
                        } label: {
//                            Image(systemName: "delete.backward")
//                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    //Button("Retry") {
                    Button {
                        Task { @MainActor in
                            await session.retry()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise.circle")
                            .frame(width: 44,height: 44)
                    }
                    .keyboardShortcut("r", modifiers: .command)
                    .clipShape(.capsule(style: .circular))
                }
                .padding()
            }
            
            
            
            
        } else {
            EmptyView()
        }
    }
    
}
