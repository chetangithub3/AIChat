//
//  CategoryListView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/17/26.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AvatarManager.self) private var avatarManager
    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImageURLString
    @State private var avatars: [AvatarModel] = []
    @State private var showAlert: AnyAppAlert?
    @State private var isLoading = false
    var body: some View {
        List {
            CategoryCellView(
                image: imageName,
                title: category.rawValue.capitalized,
                cornerRadius: 0
            )
            .frame(height: 350)
            .removeListRowFormatting()

            if isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
                    .listRowSeparator(.hidden)
            } else if avatars.isEmpty {
                Text("No avatars found")
                    .listRowSeparator(.hidden)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(avatars) { avatar in
                    CustomListCellView(
                        imageURL: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton {
                        onAvatarPresed(avatar: avatar)
                    }
                }
                .navigationDestinationForCoreModules(path: $path)
            }
        }
        .listStyle(.plain)
        .ignoresSafeArea()
        .screenAppearAnalytic(name: "CategoryListView")
        .task {
            await loadAvatars()
        }
    }
    enum Event: LoggableEvent {
        case avatarPressed(avatar: AvatarModel), loadAvatarsStart, loadAvatarsSuccess, loadAvatarsFail(error: Error)
        var eventName: String {
            switch self {
                case .avatarPressed: return "CategoryListView_Avatar_Pressed"
                case .loadAvatarsStart: return "CategoryListView_LoadAvatars_Start"
                case .loadAvatarsSuccess: return "CategoryListView_LoadAvatars_Success"
                case .loadAvatarsFail: return "CategoryListView_LoadAvatars_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .avatarPressed(avatar: let avatar): return avatar.eventParameters
                case .loadAvatarsFail(error: let error): return error.eventParameters
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .loadAvatarsFail: return .severe
                default: return .analytic
            }
        }
    }
    func onAvatarPresed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    func loadAvatars() async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        isLoading = true
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
            logManager.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
            showAlert = AnyAppAlert(error: error)
            
        }
        isLoading = false
    }
}

#Preview("Has avatars") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService()))
}
#Preview("No avatars") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(avatars: [])))
}
#Preview("Error") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(delay: 4, doesThrow: true)))
}
