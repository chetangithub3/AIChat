//
//  OnboardingCompleteView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct OnboardingCompleteView: View {
    @Environment(AppState.self) private var root
    var body: some View {
        NavigationStack {
            VStack {
                Text("Onboarding complete")
                    .frame(maxHeight: .infinity)
                    
                Button(action: onFinishPressed) {
                    Text("Finish")
                        .mainButtonStyle()
                }
            }
        }
    }
    
    func onFinishPressed() {
        root.updateViewState(showOnboarding: false)
    }
}

#Preview {
    OnboardingCompleteView()
        .environment(AppState())
}
