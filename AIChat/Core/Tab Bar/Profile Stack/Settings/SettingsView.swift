//
//  SettingsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/8/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var root
    var body: some View {
        NavigationStack {
            List {
                Button {
                    onSignOut()
                } label: {
                    Text("Sign Out")
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func onSignOut() {
        Task {
            dismiss()
            root.updateViewState(showOnboarding: true)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
