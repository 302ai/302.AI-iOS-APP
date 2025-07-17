//
//  DialogueListItem.swift
//  GPTalks
//
//  Created by Zabir Raihan on 13/11/2023.
//

import SwiftUI

struct DialogueListItem: View {
    @Environment(DialogueViewModel.self) private var viewModel
    
    var session: DialogueSession
    
    @State private var showRenameDialogue = false
    @State private var newName = ""

    var body: some View {
        HStack(spacing: 0) {
            HStack {
                
                VStack(alignment:.leading,spacing:10) {
                    CustomText(session.title)
                        .bold()
                        .font(lastMessageFont)
                        .lineLimit(1)
                       
                    
                    HStack(alignment: .bottom) {
                        CustomText("\(session.conversations.count)" + "条对话") //+ "  " + "\(session.configuration.model)")
                             
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                            .lineLimit(1)
                        Spacer()
                        
                        #if !os(visionOS)
                        
    //                    Text("") //(session.configuration.provider)
    //                        .font(.footnote)
    //                        .foregroundStyle(.secondary)
    //                        .opacity(0.9)
                        
                        
                        CustomText(formatDateToFull(session.date))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .opacity(0.9)
                         
                        #endif
                    }
                }
                
                
                
                
            }
            .padding(.horizontal,10)
            .padding(.vertical,15)
            .background(
                RoundedRectangle(cornerRadius: 10)  // 圆角 10
                    .fill(Color.gray.opacity(0.1))  // 背景色 + 透明度
            )
            
        }//.frame(minHeight:50)
        .padding(.vertical,-5)
        
        
//        .padding(paddingVal)
//        .frame(height: lastMessageMaxHeight)
        .alert("重命名会话", isPresented: $showRenameDialogue) {
            TextField("输入新命名", text: $newName)
                .onAppear {
                    newName = session.title
                }
            Button("重命名") {
                session.rename(newTitle: newName)
            }
            Button("取消", role: .cancel) {
                showRenameDialogue = false
                newName = session.title
            }
        }
        .contextMenu {
            Group {
                if viewModel.selectedDialogues.count < 2 {
                    renameButton
                    
                    //archiveButton //星星 收藏
                }
                
                //deleteButton
                singleDeleteButton
                
                if viewModel.selectedDialogues.count > 1 {
                    Button {
                        viewModel.toggleStarredDialogues()
                    } label: {
                        Label("Star/Unstar", systemImage: "star")
                    }
                }
            }
            .labelStyle(.titleAndIcon)
        }
        .swipeActions(edge: .trailing) {
            singleDeleteButton
        }
        //.swipeActions(edge: .leading) {
            //archiveButton //星星 收藏
        //}
    }
    
    // 将 Date 转换为 "年-月-日 时:分:秒" 格式的字符串
    func formatDateToFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 设置格式为 "年-月-日 时:分:秒"
        return formatter.string(from: date)
    }
    
    var archiveButton: some View {
        Button {
            session.toggleArchive()
        } label: {
            Label(session.isArchive ? "Unstar" : "Star", systemImage: session.isArchive ? "star.slash" : "star")
        }
        .tint(.orange)
    }
    
    var deleteButton: some View {
        if viewModel.selectedDialogues.count > 1 {
            Button {
                viewModel.deleteSelectedDialogues()
            } label: {
                Label("删除", systemImage: "trash")
            }
        } else {
            Button(role: .destructive) {
                viewModel.deleteDialogue(session)
                
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
    
    var singleDeleteButton: some View {
        Button(role: .destructive) {
            
            viewModel.deleteDialogue(session)
            
            if viewModel.allDialogues.count == 0{
                viewModel.selectedDialogue = viewModel.addNewDialogue()
            }else{
                if let session1 =  viewModel.allDialogues.first {
                    
                    viewModel.selectedDialogue = session1
                }
            }
            
            
        } label: {
            Label("删除", systemImage: "trash")
        }
    }
    
    var renameButton: some View {
        Button {
            newName = session.title
            showRenameDialogue.toggle()
        } label: {
            Label("重命名", systemImage: "pencil")
        }
        .tint(.accentColor)
    }
    
    private var paddingVal: CGFloat {
        #if os(macOS)
            7
        #else
            0
        #endif
    }

    private var imgToTextSpace: CGFloat {
        #if os(macOS)
        10
        #else
        13
        #endif
    }

    private var lastMessageMaxHeight: CGFloat {
        #if os(macOS)
        55
        #else
        70
        #endif
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        36
        #else
        50
        #endif
    }

    private var imageRadius: CGFloat {
        #if os(macOS)
        11
        #else
        16
        #endif
    }

    private var titleFont: Font {
        #if os(macOS)
        Font.system(.body)
        #else
        Font.system(.headline)
        #endif
    }

    private var lastMessageFont: Font {
        #if os(macOS)
        Font.system(.body)
        #else
        Font.system(.subheadline)
        #endif
    }

    private var textLineLimit: Int {
        #if os(macOS)
        1
        #else
        2
        #endif
    }
}
