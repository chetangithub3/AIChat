//
//  ProfileView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//
import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @State var showSettingsView: Bool = false
    @State var showCreateAvatarView: Bool = false
    @State var myAvatars: [AvatarModel] = []
    @State var userProfile: UserModel?
    @State var isLoading = true
    @State private var path: [NavigationPathOption] = []
    @State private var showAlert: AnyAppAlert?
    var body: some View {
        NavigationStack(path: $path) {
            List {
                myInfoSection
                    .padding(20)
                myAvatarsSection
            }
                .navigationTitle("Profile")
                .navigationDestinationForCoreModules(path: $path)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        settingsButton
                    }
                }
        }
        .sheet(isPresented: $showSettingsView, content: {
            SettingsView()
        })
        .fullScreenCover(isPresented: $showCreateAvatarView, onDismiss: {
            Task {
                await loadData()
            }
        }, content: {
            CreateAvatarView()
        })
        .task {
            await loadData()
        }
        .showCustomAlert(alert: $showAlert)
    }
    private func loadData() async {
        self.userProfile = userManager.currentUser
        isLoading = true
        do {
            let uid = try authManager.getAuthId()
            myAvatars = try await avatarManager.getAvatarsForAuthor(userId: uid)
        } catch {
        }
        isLoading = false
    }
    @ViewBuilder
    private var myAvatarsSection: some View {
        Section {
            if myAvatars.isEmpty {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                    }
                }
                .padding(.vertical, 50)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
                .removeListRowFormatting()
            } else {
                ForEach(myAvatars, id: \.self) { avatar in
                    CustomListCellView(imageURL: avatar.profileImageName, title: avatar.name)
                        .anyButton(.highlight) {
                            onAvatarPressed(avatar: avatar)
                        }
                }
                .onDelete { index in
                    onDelete(at: index)
                }
            }
        } header: {
            HStack {
                Text("My avatars")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .scaleEffect(1.2)
                    .foregroundStyle(.accent)
                    .anyButton(action: onNewAvatarButtonPressed)
            }
        }
    }
    private var myInfoSection: some View {
        Section {
            Circle()
                .frame(width: 100, height: 100)
                .foregroundStyle(userProfile?.colorCalculated ?? .accent)
                .frame(maxWidth: .infinity)
        }
        .removeListRowFormatting()
    }
    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.title)
            .anyButton(action: onSettingsButtonPressed)
    }
    private func onDelete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let avatar = myAvatars[index]
        myAvatars.remove(at: index)
        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatar.avatarId)
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar", message: "Please try again later")
            }
        }
    }
    private func onSettingsButtonPressed() {
        showSettingsView.toggle()
    }
    private func onNewAvatarButtonPressed() {
        showCreateAvatarView.toggle()
    }
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.id, chat: nil))
    }
}
#Preview {
    ProfileView(userProfile: .mock)
        .previewEnvironment()
}
