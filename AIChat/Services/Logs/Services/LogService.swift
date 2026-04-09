//
//  LogService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/4/26.
//

import SwiftUI
protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
