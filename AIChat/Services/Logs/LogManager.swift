//
//  LogManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/3/26.
//

import Foundation

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any])
    func deleteUserProfile()
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
}

struct ConsoleLogService: LogService {
    func identifyUser(userId: String, name: String?, email: String?) {
        let str = """
            Identify User
            userId: \(userId)
            name: \(name ?? "unknown")
            email: \(email ?? "unknown")
            """
        print(str)
    }
    func addUserProperties(dict: [String: Any]) {
        var string = """
            Log User Properties
            """
        let sorted = dict.keys.sorted()
        for key in sorted {
            if let value = dict[key] {
                string += "\n (key: \(key), value: \(value))"
            }
        }
        print(string)
    }
    func deleteUserProfile() {
        let string = """
            Delete User Profile
            """
        print(string)
    }
    func trackEvent(event: any LoggableEvent) {
        var string = """
            \(event.eventName)
            """
        if let params = event.parameters, !params.isEmpty {
            let sorted = params.keys.sorted()
            for key in sorted {
                if let value = params[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        print(string)
    }
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}

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
    func addUserProperties(dict: [String: Any]) {
        for service in services {
            service.addUserProperties(dict: dict)
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
    func trackScreenEvent(event: any LoggableEvent) {
        for service in services {
            service.trackScreenEvent(event: event)
        }
    }
}
