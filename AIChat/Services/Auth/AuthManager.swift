//
//  AuthManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/20/26.
//

import SwiftUI
@MainActor
@Observable
class AuthManager {

    private(set) var auth: UserAuthInfo?
    private let service: AuthService
    private var listener: (any NSObjectProtocol)?
    private let logManager: LogManager?

    init(service: AuthService, logManager: LogManager? = nil) {
        self.service = service
        self.auth = service.getAuthenticatedUser()
        self.logManager = logManager
        self.addAuthListener()
    }

    private func addAuthListener() {
        logManager?.trackEvent(event: Event.authListenerStart)
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.auth = value
                logManager?.trackEvent(event: Event.authListenerSuccess(user: value))
                if let value {
                    logManager?.identifyUser(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    logManager?.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
                }
            }
        }
    }
    func getAuthId() throws -> String {
        guard let uid = auth?.uid else {
            throw AuthError.notSignedIn
        }
        return uid
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signInAnonymously()
    }
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signInApple()
    }
    func signOut() throws {
        logManager?.trackEvent(event: Event.signOutStart)
        try service.signOut()
        logManager?.trackEvent(event: Event.signOutSuccess)
        auth = nil
    }
    func deleteAccount() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        try await service.deleteAccount()
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
        auth = nil
    }
    enum AuthError: LocalizedError {
        case notSignedIn
    }
    enum Event: LoggableEvent {
        case authListenerStart
        case authListenerSuccess(user: UserAuthInfo?)

        case signOutStart
        case signOutSuccess

        case deleteAccountStart
        case deleteAccountSuccess

        var eventName: String {
            switch self {
            case .authListenerStart:     return "AuthManager_AuthListener_Start"
            case .authListenerSuccess:   return "AuthManager_AuthListener_Success"

            case .signOutStart:          return "AuthManager_SignOut_Start"
            case .signOutSuccess:        return "AuthManager_SignOut_Success"

            case .deleteAccountStart:    return "AuthManager_DeleteAccount_Start"
            case .deleteAccountSuccess:  return "AuthManager_DeleteAccount_Success"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .authListenerSuccess(let user):
                return user?.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
