//
//  OnboardingCompleteView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct OnboardingCompleteView: View {
    @Environment(LogManager.self) private var logManager
    var selectedColor: Color
    @Environment(UserManager.self) private var userManager
    @Environment(AppState.self) private var root
    @State var isUpdatingProfileSetup: Bool = false
    @State private var showAlert: AnyAppAlert?
    var body: some View {
        VStack {
            titleAndDescription
                .padding(24)
                .frame(maxHeight: .infinity)
            finishButton
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .showCustomAlert(alert: $showAlert)
        .screenAppearAnalytic(name: "OnboardingCompleteView")
    }
    private var titleAndDescription: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Setup Complete!")
                .font(.largeTitle)
                .foregroundStyle(selectedColor)
                .fontWeight(.semibold)
            Text("We've setup your profile and we are ready to start chatting!")
                .font(.title)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
    }
    private var finishButton: some View {
        ZStack {
            if isUpdatingProfileSetup {
                ProgressView()
                    .scaleEffect(1.3)
            } else {
                Text("Finish")
            }
        }
        .anyButton(.pressable, action: onFinishPressed)
        .disabled(isUpdatingProfileSetup)
        .mainButtonStyle()
    }
    private func onFinishPressed() {
        logManager.trackEvent(event: Event.markOBCompleteForCurrentUserStart)
        Task {
            isUpdatingProfileSetup = true
            do {
                let hexColor = try selectedColor.toHex()
                try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: hexColor)
                root.updateViewState(showOnboarding: false)
                logManager.trackEvent(event: Event.markOBCompleteForCurrentUserSuccess(hexColor: hexColor))
            } catch {
                logManager.trackEvent(event: Event.markOBCompleteForCurrentUserFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
            isUpdatingProfileSetup = false
        }
    }
    enum Event: LoggableEvent {
        case markOBCompleteForCurrentUserStart, markOBCompleteForCurrentUserSuccess(hexColor: String), markOBCompleteForCurrentUserFail(error: Error)
        var eventName: String {
            switch self {
                case .markOBCompleteForCurrentUserStart: return "OnboardingComplteView_MarkComplete_Start"
                case .markOBCompleteForCurrentUserSuccess: return "OnboardingComplteView_MarkComplete_Success"
                case .markOBCompleteForCurrentUserFail: return "OnboardingComplteView_MarkComplete_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .markOBCompleteForCurrentUserSuccess(hexColor: let hexColor):
                    return ["hex_color": hexColor]
                case .markOBCompleteForCurrentUserFail(error: let error):
                    return error.eventParameters
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .markOBCompleteForCurrentUserFail: return .severe
                default: return .analytic
            }
        }
    }
}

#Preview {
    OnboardingCompleteView(selectedColor: .orange)
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
}
