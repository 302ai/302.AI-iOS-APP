//
//  ChatGPTApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import Toasts

@main
struct Chat302AI: App {
    @State private var viewModel = DialogueViewModel(context: PersistenceController.shared.container.viewContext)
    
    @StateObject private var store = ApiItemStore()
    
    @StateObject private var dataManager = ApiDataManager()
    
    @StateObject private var fontSettings = FontSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fontSettings)
                .environmentObject(dataManager)
                .environmentObject(store)
                .environmentObject(AppConfiguration.shared)
                .environment(viewModel)
                .installToast(position: .bottom)
                .onAppear {
                    
                }
            
            
        }
        //.environment(viewModel)
        //.environmentObject(AppState.shared)
        
        .commands {
            CommandGroup(after: .sidebar) {
                Section {
                    Button("Toggle Markdown") {
                        AppConfiguration.shared.isMarkdownEnabled.toggle()
                    }
                }
                
                Section {
                    Button(viewModel.isExpanded ? "Collapse Chat List" : "Expand Chat List") {
                        withAnimation {
                            viewModel.isExpanded.toggle()
                        }
                    }
                    
                    Button("Image Generations") {
                        viewModel.toggleImageAndChat()
                    }
                    .keyboardShortcut("i", modifiers: [.command, .shift])
                }
            }
        }
        #if os(macOS)
        Settings {
            MacOSSettingsView()
        }
        #endif
    }
}
