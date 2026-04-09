//
//  LogManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/3/26.
//

import Foundation

@MainActor
@Observable
class LogManager {
    private var services: [LogService]

    init(services: [LogService] = []) {
        self.services = services
    }
    func identifyUser(userId: String, name: String?, email: String?) {
        for service in services {
            service.identifyUser(userId: userId, name: name, email: email)
        }
    }
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        for service in services {
            service.addUserProperties(dict: dict, isHighPriority: isHighPriority)
        }
    }
    func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
        }
    }
    func trackEvent(event: any LoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }
    func trackEvent(event: AnyLoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }
    func trackScreenEvent(event: any LoggableEvent) {
        for service in services {
            service.trackScreenEvent(event: event)
        }
    }
}
