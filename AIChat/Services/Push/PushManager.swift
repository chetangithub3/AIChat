//
//  PushManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/9/26.
//

import Foundation
import SwiftfulUtilities

@MainActor
@Observable
class PushManager {
    private let logManager: LogManager?
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }
    func schedulePushNotificationsFortheNextWeek() {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
                try await scheduleNotification(title: "hey You, ready to chat", subtitle: "open AIChat to begin", triggerDate: Date().addingTimeInterval(26000 * 1))
                try await scheduleNotification(title: "hey You, ready to chat", subtitle: "open AIChat to begin", triggerDate: Date().addingTimeInterval(26000 * 3))
                try await scheduleNotification(title: "hey You, ready to chat", subtitle: "open AIChat to begin", triggerDate: Date().addingTimeInterval(26000 * 5))
                try await scheduleNotification(title: "hey stranger , we miss you", subtitle: "Dont forget about us", triggerDate: Date().addingTimeInterval(26000 * 7))
                logManager?.trackEvent(event: Event.weekScheduleSuccess)
            } catch {
                logManager?.trackEvent(event: Event.weekScheduleFail(error: error))
            }
        }
    }
    private func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title, body: subtitle)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
    func requestAuthorization() async throws -> Bool {
        let isAuthorized = try await LocalNotifications.requestAuthorization()
        logManager?.addUserProperties(dict: [
            "push_is_authorized": isAuthorized
        ], isHighPriority: true)
        return isAuthorized
    }
    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
    enum Event: LoggableEvent {
        case weekScheduleSuccess
        case weekScheduleFail(error: Error)

        var eventName: String {
            switch self {
                case .weekScheduleSuccess: return "PushMgr_WeekSchedule_Success"
                case .weekScheduleFail: return "PushMgr_WeekSchedule_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .weekScheduleFail(error: let error):
                    return error.eventParameters
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .weekScheduleFail: return .severe
                default: return .analytic
            }
        }
    }
}
