//
//  OnboardingCompleteView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct OnboardingCompleteView: View {
    var selectedColor: Color
    @Environment(AppState.self) private var root
    @State var isUpdatingProfileColor: Bool = false
    
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
        Button(action: onFinishPressed) {
            ZStack {
                if isUpdatingProfileColor {
                    ProgressView()
                        .scaleEffect(1.3)
                } else {
                    Text("Finish")
                }
            }
            .mainButtonStyle()
        }
        .disabled(isUpdatingProfileColor)
    }
    private func onFinishPressed() {
        Task {
            isUpdatingProfileColor = true
                // update backend
            try await Task.sleep(nanoseconds: 100_000_000)
            root.updateViewState(showOnboarding: false)
            isUpdatingProfileColor = false
        }
    }
}

#Preview {
    OnboardingCompleteView(selectedColor: .orange)
        .environment(AppState())
}
