//
//  DevSettingsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/1/26.
//

import SwiftUI

struct DevSettingsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    @Binding var showSettings: Bool
    var body: some View {
        NavigationStack {
            List {
                authSection
                userSection
                miscSection
            }
            .navigationTitle("Dev Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                   backbuttonView
                }
            }
        }
    }
    private func onBackButtonPressed() {
        dismiss()
    }
    private var backbuttonView: some View {
        Image(systemName: "xmark")
            .anyButton {
                onBackButtonPressed()
            }
    }
    private var authSection: some View {
        Section {
            let dict = authManager.auth?.eventParameters.asAlphabeticalArray ?? []
            ForEach(dict, id: \.key) { item in
                HStack {
                    Text(item.key)
                    Spacer()
                    if let str = String.convertToString(item.value) {
                        Text(str)
                    }
                }
            }
        } header: {
            Text("Auth Info")
        }
    }
    private var userSection: some View {
        Section {
            let dict =  userManager.currentUser?.eventParameters.asAlphabeticalArray ?? []
            ForEach(dict, id: \.key) { item in
                HStack {
                    Text(item.key)
                    Spacer()
                    if let str = String.convertToString(item.value) {
                        Text(str)
                    }
                }
            }
        } header: {
            Text("User Info")
        }
    }
    private var miscSection: some View {
        Section {
            let dict =  Utilities.eventParameters.asAlphabeticalArray
            ForEach(dict, id: \.key) { item in
                HStack {
                    Text(item.key)
                    Spacer()
                    if let str = String.convertToString(item.value) {
                        Text(str)
                    }
                }
            }
        } header: {
            Text("Utilities")
        }

    }
}

#Preview {
    DevSettingsView(showSettings: .constant(true))
        .previewEnvironment()
}
