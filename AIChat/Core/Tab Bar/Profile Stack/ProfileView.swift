//
//  ProfileView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//
import SwiftUI

@Observable
@MainActor
class ProfileViewModel {
    let authManager: AuthManager
    let userManager: UserManager
    let avatarManager: AvatarManager
    let logManager: LogManager

    private(set) var myAvatars: [AvatarModel] = []
    private(set) var userProfile: UserModel?
    private(set) var isLoading = true

    var showSettingsView: Bool = false
    var showCreateAvatarView: Bool = false
    var path: [NavigationPathOption] = []
    var showAlert: AnyAppAlert?

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)
        self.userManager = container.resolve(UserManager.self)
        self.avatarManager = container.resolve(AvatarManager.self)
        self.logManager = container.resolve(LogManager.self)
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
    func loadAvatars() async {
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
    func onAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.id, chat: nil))
    }
    func onDelete(at offsets: IndexSet) {
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
    func onSettingsButtonPressed() {
        logManager.trackEvent(event: Event.settingsPressed)
        showSettingsView.toggle()
    }
    func onNewAvatarButtonPressed() {
        logManager.trackEvent(event: Event.newAvatarPressed)
        showCreateAvatarView.toggle()
    }
}

struct ProfileView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProfileViewModel
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                myInfoSection
                    .padding(20)
                myAvatarsSection
            }
                .navigationTitle("Profile")
                .navigationDestinationForCoreModules(path: $viewModel.path)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        settingsButton
                    }
                }
        }
        .sheet(isPresented: $viewModel.showSettingsView, content: {
            SettingsView()
        })
        .fullScreenCover(
            isPresented: $viewModel.showCreateAvatarView,
            onDismiss: {
                Task {
                    await viewModel.loadAvatars()
                }
            },
            content: {
                CreateAvatarView(
                    viewModel: CreateAvatarViewModel(container: container)
                )
        })
        .task {
            await viewModel.loadAvatars()
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .screenAppearAnalytic(name: "ProfileView")
    }

    @ViewBuilder
    private var myAvatarsSection: some View {
        Section {
            if viewModel.myAvatars.isEmpty {
                Group {
                    if viewModel.isLoading {
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
                ForEach(viewModel.myAvatars, id: \.self) { avatar in
                    CustomListCellView(imageURL: avatar.profileImageName, title: avatar.name)
                        .anyButton(.highlight) {
                            viewModel.onAvatarPressed(avatar: avatar)
                        }
                }
                .onDelete { index in
                    viewModel.onDelete(at: index)
                }
            }
        } header: {
            HStack {
                Text("My avatars")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .scaleEffect(1.2)
                    .foregroundStyle(.accent)
                    .anyButton(action: viewModel.onNewAvatarButtonPressed)
            }
        }
    }
    private var myInfoSection: some View {
        Section {
            Circle()
                .frame(width: 100, height: 100)
                .foregroundStyle(viewModel.userProfile?.colorCalculated ?? .accent)
                .frame(maxWidth: .infinity)
        }
        .removeListRowFormatting()
    }
    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.title)
            .anyButton(action: viewModel.onSettingsButtonPressed)
    }
}
#Preview {
    ProfileView(
        viewModel: ProfileViewModel(
            container: DevPreview.shared.container
        )
    )
}
