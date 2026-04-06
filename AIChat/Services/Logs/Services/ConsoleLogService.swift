//
//  ConsoleLogService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/4/26.
//

import SwiftUI
import OSLog

actor LogSystem {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConsoleLogger")
    func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
    nonisolated func log(level: LogType, message: String) {
        Task {
            await log(level: level.toOSLogType, message: message)
        }
    }
}

enum LogType {
    case info, analytic, warning, severe
    var toOSLogType: OSLogType {
        switch self {
            case .info:
                return .info
            case .analytic:
                return .default
            case .warning:
                return .error
            case .severe:
                return .fault
        }
    }
    var emoji: String {
        switch self {
            case .info:
                return "ℹ️"
            case .analytic:
                return "📊"
            case .warning:
                return "⚠️"
            case .severe:
                return "🚨"
        }
    }
}
struct ConsoleLogService: LogService {
    let logger = LogSystem()
    let doPrintParameters: Bool
    init(doPrintParameters: Bool = true) {
        self.doPrintParameters = doPrintParameters
    }
    func identifyUser(userId: String, name: String?, email: String?) {
        let str = """
            Identify User
            userId: \(userId)
            name: \(name ?? "unknown")
            email: \(email ?? "unknown")
            """
        logger.log(level: LogType.info, message: str)
    }
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        var string = """
            Log User Properties (Is High Priority: \(isHighPriority.description))
            """
        if doPrintParameters {
            let sorted = dict.keys.sorted()
            for key in sorted {
                if let value = dict[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        logger.log(level: LogType.info, message: string)
    }
    func deleteUserProfile() {
        let string = """
            Delete User Profile
            """
        logger.log(level: LogType.info, message: string)
    }
    func trackEvent(event: LoggableEvent) {
        var string = """
            \(event.type.emoji) \(event.eventName)
            """
        if doPrintParameters, let params = event.parameters, !params.isEmpty {
            let sorted = params.keys.sorted()
            for key in sorted {
                if let value = params[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        logger.log(level: event.type, message: string)
    }
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
