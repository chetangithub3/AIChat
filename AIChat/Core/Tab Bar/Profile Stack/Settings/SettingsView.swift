//
//  SettingsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/8/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LogManager.self) private var logManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AppState.self) private var root
    @State private var isPremium = false
    @State private var isAnonymous = true
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchasesSection
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView) {
                setAnonymousAccountStatus()
            } content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            }
            .showCustomAlert(alert: $showAlert)
            .onAppear(perform: setAnonymousAccountStatus)
            .screenAppearAnalytic(name: "SettingsView")
        }
    }
    func setAnonymousAccountStatus() {
        isAnonymous = authManager.auth?.isAnonymous ?? true
    }
    private var accountSection: some View {
        Section {
            if isAnonymous {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
            } else {
                Text("Sign Out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onSignOut()
                    }
            }
            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    onDeleteAccountPressed()
                }
        } header: {
            Text("Account")
                .padding(.horizontal)
        }
        .removeListRowFormatting()
    }
    private var purchasesSection: some View {
        Section {
            HStack {
                Text("Account status ")
                Spacer()
                if isPremium {
                    Text("Premium")
                } else {
                    Text("Free")
                }
            }
            .foregroundStyle(.accent)
            .rowFormatting()
            .anyButton(.highlight) {
                    //
            }
        } header: {
            Text("Purchases")
                .padding(.horizontal)
        }
        .removeListRowFormatting()
    }
    private var applicationSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            HStack {
                Text("Build number")
                Spacer()
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            Text("Contact Us")
                .foregroundStyle(.accent)
            .rowFormatting()
            .anyButton {
                //
            }
        } header: {
            Text("Application")
                .padding(.horizontal)
        } footer: {
            Text("Created by Chetan Dhowlaghar")
                .padding(.horizontal)
        }
        .removeListRowFormatting()
    }

    private func onSignOut() {
        logManager.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                logManager.trackEvent(event: Event.signOutSuccess)
                await dismissScreen()
            } catch {
                logManager.trackEvent(event: Event.signOutFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    private func dismissScreen() async {
        dismiss()
        root.updateViewState(showOnboarding: true)
    }
    private func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.deleteAccountStart)
        showAlert = AnyAppAlert(
            title: "Delete Account?",
            message: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    private func onDeleteAccountConfirmed() {
        logManager.trackEvent(event: Event.deleteAccountStartConfirm)
        Task {
            do {
                let uid = try authManager.getAuthId()
                async let deleteAuth: () = authManager.deleteAccount()
                async let deleteUser: () = userManager.deleteCurrentUser()
                async let deleteAvatars: () = avatarManager.removeAuthoIdFromAllAvatars(userId: uid)
                async let deleteChats: () = chatManager.deleteAllChatsForUser(userId: uid)
                let (_, _, _, _) = await (try deleteAuth, try deleteUser, try deleteAvatars, try deleteChats)
                logManager.trackEvent(event: Event.deleteAccountSuccess)
                logManager.deleteUserProfile()
                await dismissScreen()
            } catch {
                logManager.trackEvent(event: Event.deleteAccountFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    private func onCreateAccountPressed() {
        logManager.trackEvent(event: Event.createAccountPressed)
        showCreateAccountView = true
    }
    enum Event: LoggableEvent {
        case signOutStart, signOutSuccess, signOutFail(error: Error)

        case deleteAccountStart, deleteAccountStartConfirm, deleteAccountSuccess, deleteAccountFail(error: Error)

        case createAccountPressed

        var eventName: String {
            switch self {
            case .signOutStart:                 return "SettingsView_SignOut_Start"
            case .signOutSuccess:               return "SettingsView_SignOut_Success"
            case .signOutFail:                  return "SettingsView_SignOut_Fail"
            case .deleteAccountStart:           return "SettingsView_DeleteAccount_Start"
            case .deleteAccountStartConfirm:    return "SettingsView_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess:         return "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail:            return "SettingsView_DeleteAccount_Fail"
            case .createAccountPressed:         return "SettingsView_CreateAccount_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(let error),
                 .deleteAccountFail(let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical)
            .background(Color(uiColor: .systemBackground))
    }
}

#Preview("Not Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
#Preview("No auth") {
    SettingsView()
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .previewEnvironment()
}
