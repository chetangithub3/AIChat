//
//  AppView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

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
            await checkUserStatus()
        }
        .onChange(of: appState.showOnboardingView) { _, showOnboardingView in
            if showOnboardingView {
                Task {
                    await checkUserStatus()
                }
            }
        }
        .onAppear {
            logManager.identifyUser(userId: "userManager.currentUser?.userId", name: "wsdewfqf", email: "efqf")
            logManager.trackEvent(event: TestEvent.alpha)
            logManager.trackEvent(event: TestEvent.beta)
            logManager.trackEvent(event: TestEvent.gamma)
            logManager.trackEvent(event: TestEvent.delta)
        }
    }
    private func checkUserStatus() async {
        if let user = authManager.auth {
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}
enum TestEvent: LoggableEvent {
    var eventName: String {
        switch self {
            case .alpha:
                return "alpha"
            case .beta:
                return "beta"
            case .gamma:
                return "gamma"
            case .delta:
                return "delta"
        }
    }
    var parameters: [String: Any]? {
        switch self {
            case .alpha, .beta:
                return [
                    "aaa": 123,
                    "bbb": true
                ]
            default:
                return nil
        }
    }
    var type: LogType {
        switch self {
            case .alpha:
                return .info
            case .beta:
                return .analytic
            case .gamma:
                return .warning
            case .delta:
                return .severe
        }
    }
    case alpha, beta, gamma, delta
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
