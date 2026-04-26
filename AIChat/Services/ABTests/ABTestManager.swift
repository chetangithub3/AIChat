//
//  ABTestManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/16/26.
//
import SwiftUI

@MainActor
@Observable
class ABTestManager {

    private let service: ABTestService
    var activeTests: ActiveABTests
    private let logManager: LogManager?

    init(service: ABTestService, logManager: LogManager? = nil) {
        self.service = service
        self.activeTests = service.activeTests
        self.logManager = logManager
        configure()
    }
    private func configure() {
        Task {
            do {
                activeTests = try await service.fetchUpdatedConfig()
                logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
                logManager?.trackEvent(event: Event.fetchRemoteConfigSuccess)
            } catch {
                logManager?.trackEvent(event: Event.fetchRemoteConfigFail(error: error))
            }
        }
    }
    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
    enum Event: LoggableEvent {
        case fetchRemoteConfigSuccess
        case fetchRemoteConfigFail(error: Error)
        var eventName: String {
            switch self {
                case .fetchRemoteConfigSuccess: return "ABTestManager_FetchRemoteConfig_Success"
                case .fetchRemoteConfigFail: return "ABTestManager_FetchRemoteConfig_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .fetchRemoteConfigFail(error: let error): return error.eventParameters
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .fetchRemoteConfigFail: return .severe
                default: return .analytic
            }
        }
    }
}
