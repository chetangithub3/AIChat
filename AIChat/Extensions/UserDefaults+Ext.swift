//
//  Keys.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/7/25.
//

import SwiftUI

extension UserDefaults {

    private struct Keys {
        static let showOnboarding: String = "showOnboarding"
    }

    static var showOnboarding: Bool {
        get {
            guard let _ = standard.object(forKey: Keys.showOnboarding) else {
                return true
            }
            return standard.bool(forKey: Keys.showOnboarding)
        }
        set {
            standard.set(newValue, forKey: Keys.showOnboarding)
        }
    }
}
