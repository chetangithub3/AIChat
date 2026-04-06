//
//  MixPanleService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/6/26.
//

import Foundation
import Mixpanel
struct MixPanelService: LogService {
    private var instance: MixpanelInstance {
        Mixpanel.mainInstance()
    }
    init(token: String, loggingEnabled: Bool = false) {
        Mixpanel.initialize(token: token, trackAutomaticEvents: true)
        instance.loggingEnabled = loggingEnabled
    }
    func identifyUser(userId: String, name: String?, email: String?) {
        instance.identify(distinctId: userId)
        if let name {
            instance.people.set(property: "name", to: name)
        }
        if let email {
            instance.people.set(property: "email", to: email)
        }
    }
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        var userProperties: [String: MixpanelType] = [:]
        for (key, value) in dict {
            let newKey = key.clipped(maxCharacters: 255)
            if let value = value as? MixpanelType {
                userProperties[newKey] = value
            }
        }
        instance.people.set(properties: userProperties)
    }
    func deleteUserProfile() {
        instance.people.deleteUser()
    }
    func trackEvent(event: any LoggableEvent) {
        var eventProperties: [String: MixpanelType] = [:]
        if let parameters = event.parameters {
            for (key, value) in parameters {
                let newKey = key.clipped(maxCharacters: 255)
                if let value = value as? MixpanelType {
                    eventProperties[newKey] = value
                }
            }
        }
        instance.track(event: event.eventName, properties: eventProperties.isEmpty ? nil : eventProperties)
    }
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
