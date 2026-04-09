//
//  ProfileView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//
import SwiftUI

struct ProfileView: View {
    @Environment(LogManager.self) private var logManager
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
                await loadAvatars()
            }
        }, content: {
            CreateAvatarView()
        })
        .task {
            await loadAvatars()
        }
        .showCustomAlert(alert: $showAlert)
        .screenAppearAnalytic(name: "ProfileView")
    }
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess(count: Int)
        case loadAvatarsFail(error: Error)

        case settingsPressed
        case newAvatarPressed

        case avatarPressed(avatar: AvatarModel)

        case deleteAvatarStart(avatar: AvatarModel)
        case deleteAvatarSuccess(avatar: AvatarModel)
        case deleteAvatarFail(error: Error)

        var eventName: String {
            switch self {
            case .loadAvatarsStart:        return "ProfileView_LoadAvatars_Start"
            case .loadAvatarsSuccess:      return "ProfileView_LoadAvatars_Success"
            case .loadAvatarsFail:         return "ProfileView_LoadAvatars_Fail"

            case .settingsPressed:         return "ProfileView_Settings_Pressed"
            case .newAvatarPressed:        return "ProfileView_NewAvatar_Pressed"

            case .avatarPressed:           return "ProfileView_Avatar_Pressed"

            case .deleteAvatarStart:       return "ProfileView_DeleteAvatar_Start"
            case .deleteAvatarSuccess:     return "ProfileView_DeleteAvatar_Success"
            case .deleteAvatarFail:        return "ProfileView_DeleteAvatar_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(let count):
                return ["profile_avatar_count": count]

            case .loadAvatarsFail(let error),
                 .deleteAvatarFail(let error):
                return error.eventParameters

            case .avatarPressed(let avatar),
                 .deleteAvatarStart(let avatar),
                 .deleteAvatarSuccess(let avatar):
                return avatar.eventParameters

            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadAvatarsFail, .deleteAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    private func loadAvatars() async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        self.userProfile = userManager.currentUser
        isLoading = true
        do {
            let uid = try authManager.getAuthId()
            myAvatars = try await avatarManager.getAvatarsForAuthor(userId: uid)
            logManager.trackEvent(event: Event.loadAvatarsSuccess(count: myAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
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
        logManager.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))
        myAvatars.remove(at: index)
        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatar.avatarId)
                logManager.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar", message: "Please try again later")
                logManager.trackEvent(event: Event.deleteAvatarFail(error: error))
            }
        }
    }
    private func onSettingsButtonPressed() {
        logManager.trackEvent(event: Event.settingsPressed)
        showSettingsView.toggle()
    }
    private func onNewAvatarButtonPressed() {
        logManager.trackEvent(event: Event.newAvatarPressed)
        showCreateAvatarView.toggle()
    }
    private func onAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.id, chat: nil))
    }
}
#Preview {
    ProfileView(userProfile: .mock)
        .previewEnvironment()
}
