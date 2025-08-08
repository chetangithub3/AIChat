//
//  WelcomeView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome")
                    .frame(maxHeight: .infinity)
                    
                NavigationLink {
                    OnboardingCompleteView()
                } label: {
                    Text("Get Started")
                        .mainButtonStyle()
                }
            
            }
        }
    }
}

#Preview {
    WelcomeView()
}
