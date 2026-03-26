//
//  OnboardingCompleteView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct OnboardingCompleteView: View {
    var selectedColor: Color
    @Environment(UserManager.self) private var userManager
    @Environment(AppState.self) private var root
    @State var isUpdatingProfileSetup: Bool = false
    var body: some View {
        VStack {
            titleAndDescription
                .padding(24)
                .frame(maxHeight: .infinity)
            finishButton
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
    private var titleAndDescription: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Setup Complete!")
                .font(.largeTitle)
                .foregroundStyle(selectedColor)
                .fontWeight(.semibold)
            Text("We've setup your profile and we are ready to start chatting!")
                .font(.title)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
    }
    private var finishButton: some View {
        ZStack {
            if isUpdatingProfileSetup {
                ProgressView()
                    .scaleEffect(1.3)
            } else {
                Text("Finish")
            }
        }
        .anyButton(.pressable, action: onFinishPressed)
        .disabled(isUpdatingProfileSetup)
        .mainButtonStyle()
    }
    private func onFinishPressed() {
        Task {
            isUpdatingProfileSetup = true
            let hexColor = try selectedColor.toHex()
            try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: hexColor)
            root.updateViewState(showOnboarding: false)
            isUpdatingProfileSetup = false
        }
    }
}

#Preview {
    OnboardingCompleteView(selectedColor: .orange)
        .environment(UserManager(service: MockUserService()))
        .environment(AppState())
}
