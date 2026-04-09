//
//  AppView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI
import SwiftfulUtilities
struct AppView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @State var appState: AppState = AppState()
    var body: some View {
        AppViewBuilder(
            showOnboardingView: appState.showOnboardingView,
            onboardingView: {
                WelcomeView()
            },
            tabbarView: {
                TabbarView()
            }
        )
        .environment(appState)
        .task {
            try? await Task.sleep(for: .seconds(3))
            await checkUserStatus()
        }
        .task {
            await showATTPromptIfNeeded()
        }
        .onChange(of: appState.showOnboardingView) { _, showOnboardingView in
            if showOnboardingView {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    private func checkUserStatus() async {
        if let user = authManager.auth {
            logManager.trackEvent(event: Event.existingAuthStart)
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                await checkUserStatus()
            }
        } else {
            do {
                logManager.trackEvent(event: Event.anonAuthStart)
                let result = try await authManager.signInAnonymously()
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(event: Event.anonAuthSuccess)
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
    private func showATTPromptIfNeeded() async {
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: Event.attStatus(dict: status.eventParameters))
    }
    enum Event: LoggableEvent {
        var eventName: String {
            switch self {
                case .existingAuthStart: return "AppView_ExistingAuth"
                case .existingAuthFail: return "AppView_ExistingAuth_Fail"
                case .anonAuthStart: return "AppView_AnonAuth_Start"
                case .anonAuthSuccess: return "AppView_AnonAuth_Success"
                case .anonAuthFail: return "AppView_AnonAuth_Fail"
                case .attStatus: return "AppView_ATTStatus"
                            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                    return error.eventParameters
                case .attStatus(dict: let dict):
                    return dict
                default:
                    return nil
            }
        }
        var type: LogType {
            switch self {
                case .anonAuthFail, .existingAuthFail: return .severe
                default: return .analytic
            }
        }
        case existingAuthStart, existingAuthFail(error: Error)
        case anonAuthStart, anonAuthSuccess, anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])

    }
}

#Preview("Tabbar View") {
   AppView(appState: AppState(showOnboardingView: false))
        .environment(AuthManager(service: MockAuthService(user: .mock)))
        .environment(UserManager(services: MockUserServices(user: .mock)))
}

#Preview("Onboarding View") {
    AppView(appState: AppState(showOnboardingView: true))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
}
