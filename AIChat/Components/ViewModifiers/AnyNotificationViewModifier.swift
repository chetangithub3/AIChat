//
//  AnyNotificationViewModifier.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/10/26.
//

import Foundation
import SwiftUI
@MainActor
struct AnyNotificationViewModifier: ViewModifier {
    var notificationName: NSNotification.Name
    var onNotificationReceived: (Notification) -> Void
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: notificationName)) { notification in
                onNotificationReceived(notification)
            }
    }
}

extension View {
    func onNotificationReceived(notificationName: NSNotification.Name, action: @escaping (Notification) -> Void) {
        modifier(AnyNotificationViewModifier(notificationName: notificationName, onNotificationReceived: action))
    }
}
