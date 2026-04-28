//
//  CategoryListView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/17/26.
//

import SwiftUI

@Observable
@MainActor
class CategoryListViewModel {
    private let avatarManager: AvatarManager
    private let logManager: LogManager

    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading = false

    var showAlert: AnyAppAlert?

    init(container: DependencyContainer) {
        self.avatarManager = container.resolve(AvatarManager.self)
        self.logManager = container.resolve(LogManager.self)
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

    func loadAvatars(category: CharacterOption) async {
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
struct CategoryListView: View {
    @State var viewModel: CategoryListViewModel

    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImageURLString

    var body: some View {
        List {
            CategoryCellView(
                image: imageName,
                title: category.rawValue.capitalized,
                cornerRadius: 0
            )
            .frame(height: 350)
            .removeListRowFormatting()

            if viewModel.isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
                    .listRowSeparator(.hidden)
            } else if viewModel.avatars.isEmpty {
                Text("No avatars found")
                    .listRowSeparator(.hidden)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.avatars) { avatar in
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
        .showCustomAlert(alert: $viewModel.showAlert)
        .task {
            await viewModel.loadAvatars(category: category)
        }
    }
    func onAvatarPresed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
}

#Preview("Has avatars") {
    let container = DevPreview.shared.container

    let avatarManager = AvatarManager(
        service: MockAvatarService()
    )

    container.register(AvatarManager.self, instance: avatarManager)

    return CategoryListView(
        viewModel: CategoryListViewModel(container: container), path: .constant([])
    )
    .environment(avatarManager)
    .previewEnvironment()
}

#Preview("No avatars") {
    let container = DevPreview.shared.container

    let avatarManager = AvatarManager(
        service: MockAvatarService(avatars: [])
    )

    container.register(AvatarManager.self, instance: avatarManager)

    return CategoryListView(
        viewModel: CategoryListViewModel(container: container), path: .constant([])
    )
    .environment(avatarManager)
    .previewEnvironment()
}

#Preview("Error") {
    let container = DevPreview.shared.container

    let avatarManager = AvatarManager(
        service: MockAvatarService(delay: 4, doesThrow: true)
    )

    container.register(AvatarManager.self, instance: avatarManager)

    return CategoryListView(
        viewModel: CategoryListViewModel(container: container), path: .constant([])
    )
    .environment(avatarManager)
    .previewEnvironment()
}
