//
//  SettingsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/8/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.authService) private var authService
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
        }
    }
    func setAnonymousAccountStatus() {
        isAnonymous = authService.getAuthenticatedUser()?.isAnonymous ?? true
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
        Task {
            do {
                try authService.signOut()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    private func dismissScreen() async {
        dismiss()
        root.updateViewState(showOnboarding: true)
    }
    private func onDeleteAccountPressed() {
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
        Task {
            do {
                try await authService.deleteAccount()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    private func onCreateAccountPressed() {
        showCreateAccountView = true
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}

extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical)
            .background(Color(uiColor: .systemBackground))
    }
}
