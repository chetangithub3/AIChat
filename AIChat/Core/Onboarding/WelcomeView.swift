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
            ZStack {
                Color.blue.ignoresSafeArea()
                Text("Onboarding view")
            }
        }
    }
}

#Preview {
    WelcomeView()
}
