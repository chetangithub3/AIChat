//
//  SettingsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/8/25.
//

import SwiftUI
import SwiftfulUtilities
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
    @State private var showModal: Bool = false
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
            .showModal(
                showModal: $showModal,
                content: {
                  ratingsModal
            })
            .onAppear(perform: setAnonymousAccountStatus)
            .screenAppearAnalytic(name: "SettingsView")
        }
    }
    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying the app",
            subTitle: "Letting us know will help make the user experience better",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                ratingsYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                ratingsNoPressed()
            }
        )
    }
    private func ratingsYesPressed() {
        logManager.trackEvent(event: Event.ratingsYesPressed)
        showModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }
    private func ratingsNoPressed() {
        logManager.trackEvent(event: Event.ratingsNoPressed)
        showModal = false
    }
private func setAnonymousAccountStatus() {
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
            Text("Rate Us on the Appstore")
                .foregroundStyle(.accent)
            .rowFormatting()
            .anyButton {
                rateUsOnAppstore()
            }
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
                contactUsPressed()
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
    private func rateUsOnAppstore() {
        logManager.trackEvent(event: Event.ratingsPressed)
        showModal = true
    }
    private func contactUsPressed() {
        logManager.trackEvent(event: Event.contactUSPressed)
        let email = "chetan.getsmail@gmail.com"
        let emailString = "mailto:\(email)"
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
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
                try await chatManager.deleteAllChatsForUser(userId: uid)
                try await avatarManager.removeAuthoIdFromAllAvatars(userId: uid)
                try await userManager.deleteCurrentUser()
                try await authManager.deleteAccount()
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

        case createAccountPressed, contactUSPressed, ratingsPressed, ratingsYesPressed, ratingsNoPressed

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
            case .contactUSPressed:             return "SettingsView_ContactUs_Pressed"
            case .ratingsPressed:               return "SettingsView_Ratings_Pressed"
            case .ratingsYesPressed:            return "SettingsView_Ratings_Yes_Pressed"
            case .ratingsNoPressed:             return "SettingsView_Ratings_No_Pressed"
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
