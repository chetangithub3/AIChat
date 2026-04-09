//
//  FirebaseCrashlyticsService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/6/26.
//

import Foundation
import FirebaseCrashlytics

struct FirebaseCrashlyticsService: LogService {
    private var crashlytics: Crashlytics {
        Crashlytics.crashlytics()
    }
    func identifyUser(userId: String, name: String?, email: String?) {
        Crashlytics.crashlytics().setUserID(userId)
        if let name {
            crashlytics.setCustomValue(name, forKey: "account_name")
        }
        if let email {
            crashlytics.setCustomValue(email, forKey: "account_email")
        }
    }
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        for (key, value) in dict {
            crashlytics.setCustomValue(value, forKey: key)
        }
    }
    func deleteUserProfile() {
        crashlytics.setUserID("New")
    }
    func trackEvent(event: any LoggableEvent) {
        switch event.type {
            case .info, .analytic, .warning:
                break
            case .severe:
                let error = NSError(
                    domain: event.eventName,
                    code: event.eventName.stableHashValue,
                    userInfo: event.parameters
                )
                crashlytics.record(error: error, userInfo: event.parameters)
        }
    }
    func trackScreenEvent(event: any LoggableEvent) {
    }
}
