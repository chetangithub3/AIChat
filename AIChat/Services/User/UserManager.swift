//
//  UserManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/21/26.
//

import SwiftUI

@MainActor
@Observable
class UserManager {

    private(set) var currentUser: UserModel?
    private let remote: RemoteUserService
    private let local: LocalUserPersistence
    private let logManager: LogManager?
    init(services: UserServices, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.logManager = logManager
        self.currentUser = local.getCurrentUser()
    }
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        logManager?.trackEvent(event: Event.logInStart(user: user))
        try await remote.saveUser(user: user)
        logManager?.trackEvent(event: Event.logInSuccess(user: user))
        addCurentUserListerner(userId: user.userId)
    }
    private func addCurentUserListerner(userId: String) {
        logManager?.trackEvent(event: Event.remoteListenerStart)
        Task {
            do {
                for try await value in remote.streamUser(userId: userId) {
                    self.currentUser = value
                    self.saveCurrentUserLocally()
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                }
            } catch {
                logManager?.trackEvent(event: Event.remoteListenerFail(error: error))
            }
        }
    }
    private func saveCurrentUserLocally() {
        logManager?.trackEvent(event: Event.saveLocalStart(user: currentUser))
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                logManager?.trackEvent(event: Event.saveLocalSuccess(user: currentUser))
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFail(error: error))
            }
        }
    }
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }
    func signOut() {
        logManager?.trackEvent(event: Event.signOut)
        currentUser = nil
    }
    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        let uid = try currentUserId()
        do {
            try await remote.deleteUser(userId: uid)
            logManager?.trackEvent(event: Event.deleteAccountSuccess)
        } catch {
            logManager?.trackEvent(event: Event.deleteAccountFail(error: error))
        }
        signOut()
    }

    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    enum UserManagerError: LocalizedError {
        case noUserId
    }
    enum Event: LoggableEvent {
        case logInStart(user: UserModel)
        case logInSuccess(user: UserModel)

        case remoteListenerStart
        case remoteListenerSuccess(user: UserModel)
        case remoteListenerFail(error: Error)

        case saveLocalStart(user: UserModel?)
        case saveLocalSuccess(user: UserModel?)
        case saveLocalFail(error: Error)

        case signOut

        case deleteAccountStart
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        var eventName: String {
            switch self {
               case .logInStart:             return "UserManager_LogIn_Start"
               case .logInSuccess:           return "UserManager_LogIn_Success"

               case .remoteListenerStart:    return "UserManager_RemoteListener_Start"
               case .remoteListenerSuccess:  return "UserManager_RemoteListener_Success"
               case .remoteListenerFail:     return "UserManager_RemoteListener_Fail"

               case .saveLocalStart:         return "UserManager_SaveLocal_Start"
               case .saveLocalSuccess:       return "UserManager_SaveLocal_Success"
               case .saveLocalFail:          return "UserManager_SaveLocal_Fail"

               case .signOut:                return "UserManager_SignOut"

               case .deleteAccountStart:     return "UserManager_DeleteAccount_Start"
               case .deleteAccountSuccess:   return "UserManager_DeleteAccount_Success"
               case .deleteAccountFail:      return "UserManager_DeleteAccount_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .logInStart(let user),
                 .logInSuccess(let user),
                 .remoteListenerSuccess(let user):
                return user.eventParameters

            case .saveLocalStart(let user),
                 .saveLocalSuccess(let user):
                return user?.eventParameters

            case .remoteListenerFail(let error),
                 .saveLocalFail(let error),
                 .deleteAccountFail(error: let error):
                return error.eventParameters

            default:
                return nil
            }
        }
        var type: LogType {
            switch self {
                case .remoteListenerFail, .saveLocalFail: return .severe
                default: return .analytic
            }
        }
    }
}
