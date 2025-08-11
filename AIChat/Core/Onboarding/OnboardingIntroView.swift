//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/9/25.
//

import SwiftUI

struct OnboardingIntroView: View {
    var body: some View {
        VStack {
            introSection
                .frame(maxHeight: .infinity)
                .padding()
            continueButton
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    private var continueButton: some View {
        NavigationLink {
            OnboardingColorPickerView()
        } label: {
            Text("Continue")
                .mainButtonStyle()
        }
    }
    
    private var introSection: some View {
        Group {
            Text("Make your")
            +
            Text(" avatars ")
                .fontWeight(.bold)
                .foregroundStyle(.accent)
            +
            Text("and chat with them.\n\nHave ")
            +
            Text("real conversations ")
                .fontWeight(.bold)
                .foregroundStyle(.accent)
            +
            Text("with AI generated responses")
        }
        .font(.title2)
    }
}

#Preview {
    OnboardingIntroView()
}
