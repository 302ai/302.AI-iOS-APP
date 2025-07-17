//
//  ContextResetDivider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/12/2023.
//

import SwiftUI

struct ContextResetDivider: View {
    var session: DialogueSession

    var body: some View {
        VStack {
            
            Divider()
                .padding(6)
            HStack {
                Text("上下文已清除")
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        session.removeResetContextMarker()
                    }

//                Button(role: .destructive) {
//                    session.removeResetContextMarker()
//                } label: {
//                    Image(systemName: "delete.backward")
//                        .foregroundColor(.secondary)
//                }
//                .buttonStyle(.plain)
            }

            Divider()
                .padding(6)
            #if os(visionOS)
                .opacity(0.1)
            #endif
        }
    }

    var line: some View {
        Divider()
            .background(Color.gray)
    }
}
