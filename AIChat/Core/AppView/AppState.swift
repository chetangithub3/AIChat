//
//  AppState.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/7/25.
//

import SwiftUI

@Observable
class AppState {
    private(set) var showOnboardingView: Bool {
        didSet {
            UserDefaults.showOnboarding = showOnboardingView
        }
    }
    init(showOnboardingView: Bool = UserDefaults.showOnboarding) {
        self.showOnboardingView = showOnboardingView
    }
    func updateViewState(showOnboarding: Bool) {
        showOnboardingView = showOnboarding
    }
}
