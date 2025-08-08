//
//  ProfileView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//
import SwiftUI

struct ProfileView: View {
    @State var showSettingsView: Bool = false
    var body: some View {
        NavigationStack {
            Text("Profile")
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        settingsButton
                    }
                }
        }
        .sheet(isPresented: $showSettingsView, content: {
            SettingsView()
        })
    }

    private var settingsButton: some View {
        Button(action: onSettingsButtonPressed) {
            Image(systemName: "gear")
                .font(.title)
        }
    }

    private func onSettingsButtonPressed() {
        showSettingsView.toggle()
    }
}
#Preview {
    ProfileView()
}
