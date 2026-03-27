//
//  Screen.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 9/13/25.
//

import SwiftUI
import UIKit

@MainActor
enum Screen {
    static var width: CGFloat {
        UIApplication.shared
            .connectedScenes
            .compactMap {($0 as? UIWindowScene)?.screen}
            .first?.bounds.size.width ?? .zero
    }

    static var height: CGFloat {
        UIApplication.shared
            .connectedScenes
            .compactMap {($0 as? UIWindowScene)?.screen}
            .first?.bounds.size.height ?? .zero
    }
}
