//
//  ExploreView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI
@Observable
@MainActor
class ExploreViewModel {
    let authManager: AuthManager
    let pushManager: PushManager
    let avatarManager: AvatarManager
    let logManager: LogManager
    let abTestManager: ABTestManager

    var featuredAvatars: [AvatarModel] = []
    var popularAvatars: [AvatarModel] = []
    var categories = CharacterOption.allCases
    var path: [NavigationPathOption] = []
    var isLoadingFeatured: Bool = false
    var isLoadingPopular: Bool = false
    var showDevSettings: Bool = false
    var showNotificationButton: Bool = true
    var showPushNotificationModal: Bool = false
    var showCreateAccountView: Bool = false
    var showAlert: AnyAppAlert?
    var isAnonymous = true
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)
        self.pushManager = container.resolve(PushManager.self)
        self.avatarManager = container.resolve(AvatarManager.self)
        self.logManager = container.resolve(LogManager.self)
        self.abTestManager = container.resolve(ABTestManager.self)
    }

    func showCreateAcountScreenIfNeeded() {
        guard authManager.auth?.isAnonymous == true
                && abTestManager.activeTests.createAccountTest == true
        else { return }
        showCreateAccountView = true
    }
    func handleDeepLink(url: URL) {
        logManager.trackEvent(event: Event.deepLinkStart(url: url))
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let queryItems = components.queryItems else {
            logManager.trackEvent(event: Event.deeplinkNoQueryItems(url: url))
            return
        }
        for queryItem in queryItems {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(
                rawValue: value
            ), let imageName = popularAvatars.first(
                where: {
                    $0.characterOption == category
                })?.profileImageName {
                path.append(.category(category: category, imageName: imageName))
                logManager.trackEvent(event: Event.deepLinkCategory(category: category))
                return
            }
        }
        logManager.trackEvent(event: Event.deeplinkUnknown(error: URLError(.unknown)))
    }
    func schedulePushNotifications() {
        pushManager.schedulePushNotificationsFortheNextWeek()
    }
    func shouldShowNotificationButton() async {
        showNotificationButton = await pushManager.canRequestAuthorization()
    }
    func pushNotifModalAllowPressed() {
        Task {
            await shouldShowNotificationButton()
        }
        showPushNotificationModal = false
    }
    func pushNotifModalRefusePressed() {
        showPushNotificationModal = false
    }
    func onNotificationButtonPressed() {
        showPushNotificationModal = true
    }
    func onCategoryItemPressed(_ category: CharacterOption, imageName: String) {
        logManager.trackEvent(event: Event.categoryItemPressed(category: category))
        path.append(.category(category: category, imageName: imageName))
    }
    func onPopularItemPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.popularAvatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    func onFeaturedAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.featuredAvatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    func loadFeaturedAvatars() async {
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)
        guard featuredAvatars.isEmpty else { return }
        isLoadingFeatured = true
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeaturedAvatarsSuccess(avatars: featuredAvatars))
        } catch {
            logManager.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        isLoadingFeatured = false
    }
    func loadPopularAvatars() async {
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)
        do {
            isLoadingPopular = true
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(avatars: popularAvatars))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
        isLoadingPopular = false
    }
    enum Event: LoggableEvent {
        case loadFeaturedAvatarsStart, loadFeaturedAvatarsSuccess(avatars: [AvatarModel]), loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart, loadPopularAvatarsSuccess(avatars: [AvatarModel]), loadPopularAvatarsFail(error: Error)
        case categoryItemPressed(category: CharacterOption), popularAvatarPressed(avatar: AvatarModel), featuredAvatarPressed(avatar: AvatarModel)
        case tryAgainPressed
        case deepLinkStart(url: URL)
        case deeplinkNoQueryItems(url: URL)
        case deepLinkCategory(category: CharacterOption)
        case deeplinkUnknown(error: Error)

        var eventName: String {
            switch self {
             case .loadFeaturedAvatarsStart:     return "ExploreView_LoadFeaturedAvatars_Start"
             case .loadFeaturedAvatarsSuccess:   return "ExploreView_LoadFeaturedAvatars_Success"
             case .loadFeaturedAvatarsFail:      return "ExploreView_LoadFeaturedAvatars_Fail"

             case .loadPopularAvatarsStart:      return "ExploreView_LoadPopularAvatars_Start"
             case .loadPopularAvatarsSuccess:    return "ExploreView_LoadPopularAvatars_Success"
             case .loadPopularAvatarsFail:       return "ExploreView_LoadPopularAvatars_Fail"

             case .categoryItemPressed:          return "ExploreView_CategoryItem_Pressed"
             case .popularAvatarPressed:         return "ExploreView_PopularAvatar_Pressed"
             case .featuredAvatarPressed:        return "ExploreView_FeaturedAvatar_Pressed"
             case .tryAgainPressed:              return "ExploreView_TryAgain_Pressed"

             case .deepLinkStart:                return "ExploreView_DeepLink_Start"
             case .deeplinkNoQueryItems:         return "ExploreView_DeepLink_NoQueryItems"
             case .deepLinkCategory:             return "ExploreView_DeepLink_Category"
             case .deeplinkUnknown:              return "ExploreView_DeepLink_Unknown"
             }
        }
        var parameters: [String: Any]? {
            switch self {
                case .loadPopularAvatarsFail(error: let error), .loadFeaturedAvatarsFail(error: let error):
                    return error.eventParameters
                case .featuredAvatarPressed(avatar: let avatar), .popularAvatarPressed(avatar: let avatar):
                    return avatar.eventParameters
                case .loadPopularAvatarsSuccess(avatars: let avatars), .loadFeaturedAvatarsSuccess(avatars: let avatars):
                    var dict: [String: Any] = [:]
                    for avatar in avatars {
                        dict.merge(avatar.eventParameters)
                    }
                    return dict
                case .categoryItemPressed(category: let option):
                    return ["category": option.rawValue]
                case .deepLinkStart(let url),
                     .deeplinkNoQueryItems(let url):
                    return ["url": url.absoluteString]

                case .deepLinkCategory(let category):
                    return ["category": category.rawValue]

                case .deeplinkUnknown(let error):
                    return error.eventParameters
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .loadFeaturedAvatarsFail, .loadPopularAvatarsFail, .deeplinkUnknown: return .severe
                case .deeplinkNoQueryItems: return .warning
                default: return .analytic
            }
        }
    }
}
struct ExploreView: View {
    @State var viewModel: ExploreViewModel

    var isDevOrMock: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if viewModel.featuredAvatars.isEmpty && viewModel.popularAvatars.isEmpty {
                    ZStack {
                        if viewModel.isLoadingFeatured || viewModel.isLoadingPopular {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                } else {
                    Group {
                        if viewModel.abTestManager.activeTests.categoryRowTest == .top {
                            categorySection
                        }
                        featuredSection
                        if viewModel.abTestManager.activeTests.categoryRowTest == .original {
                            categorySection
                        }
                    }
                    .listRowSeparator(.hidden)
                    popularSection
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Explore")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if isDevOrMock {
                        devSettingsButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.showNotificationButton {
                        notificationButton
                    }
                }
            })
            .sheet(isPresented: $viewModel.showDevSettings) {
                DevSettingsView(showSettings: $viewModel.showDevSettings)
            }
            .sheet(isPresented: $viewModel.showCreateAccountView) {
                CreateAccountView()
                    .presentationDetents([.medium])
            }
            .screenAppearAnalytic(name: "ExploreView")
            .navigationDestinationForCoreModules(path: $viewModel.path)
            .task {
                await viewModel.loadFeaturedAvatars()
            }
            .task {
                await viewModel.loadPopularAvatars()
            }
            .task {
                await viewModel.shouldShowNotificationButton()
            }
            .onFirstAppear {
                viewModel.schedulePushNotifications()
                viewModel.showCreateAcountScreenIfNeeded()
            }
            .onOpenURL { url in
                viewModel.handleDeepLink(url: url)
            }
        }
    }

    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable Notifications",
            subTitle: "Stay updated with important alerts and reminders.",
            primaryButtonTitle: "Allow",
            primaryButtonAction: {
                viewModel.pushNotifModalAllowPressed()
            },
            secondaryButtonTitle: "Not Now",
            secondaryButtonAction: {
                viewModel.pushNotifModalAllowPressed()
            }
        )
    }

    private var notificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableText()
            .foregroundStyle(.accent)
            .anyButton {
                viewModel.onNotificationButtonPressed()
            }
    }
    private var loadingIndicator: some View {
        ProgressView()
            .ignoresSafeArea()
            .removeListRowFormatting()
    }
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again") {
                Task {
                    await viewModel.loadFeaturedAvatars()
                }
                Task {
                    await viewModel.loadPopularAvatars()
                }
            }
        }
    }
    private var devSettingsButton: some View {
        Text("DEV")
            .anyButton {
                viewModel.showDevSettings = true
            }
    }

    private var featuredSection: some View {
        Section {
            CarouselViewBuilder(
                items: viewModel.featuredAvatars,
                content: { item in
                    HeroCellView(
                        imageStringURL: item.profileImageName,
                        title: item.name,
                        subTitle: item.characterDescription
                    )
                    .padding(.horizontal)
                    .anyButton {
                        viewModel.onFeaturedAvatarPressed(avatar: item)
                    }
                },
                selection: nil
            )
            .frame(height: Screen.height * 0.3)
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }
    private var categorySection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        if let imageName = viewModel.featuredAvatars.first(where: {$0.characterOption == category})?.profileImageName {
                            CategoryCellView(image: imageName, title: category.rawValue.capitalized)
                            .frame(width: 150, height: 150)
                            .anyButton {
                                viewModel.onCategoryItemPressed(category, imageName: imageName)
                            }
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
    private var popularSection: some View {
        Section {
            ForEach(viewModel.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageURL: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .anyButton(.highlight) {
                    viewModel.onPopularItemPressed(avatar: avatar)
                }
            }
        } header: {
            Text("Popular")
        }
    }
}

#Preview("Has Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, instance: AvatarManager(service: MockAvatarService()))
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()
}

#Preview("No avatars") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, instance: AvatarManager(service: MockAvatarService(avatars: [], delay: 3)))
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 3)))
        .previewEnvironment()
}

#Preview("CreateAccTest") {
    let container = DevPreview.shared.container

    let avatarManager = AvatarManager(
        service: MockAvatarService(avatars: [], delay: 3)
    )
    let authManager = AuthManager(
        service: MockAuthService(user: .mock(isAnonymous: true))
    )
    let abTestManager = ABTestManager(
        service: MockABTestService(createAccountTest: true)
    )

    container.register(AvatarManager.self, instance: avatarManager)
    container.register(AuthManager.self, instance: authManager)
    container.register(ABTestManager.self, instance: abTestManager)

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .environment(avatarManager)
        .environment(authManager)
        .environment(abTestManager)
        .previewEnvironment()
}
#Preview("Delay") {
    let container = DevPreview.shared.container

    let avatarManager = AvatarManager(
        service: MockAvatarService(delay: 5)
    )

    container.register(AvatarManager.self, instance: avatarManager)

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .environment(avatarManager)
        .previewEnvironment()
}

#Preview("CategoryRowTes: Original") {
    let container = DevPreview.shared.container

    let avatarManager = AvatarManager(
        service: MockAvatarService()
    )
    let abTestManager = ABTestManager(
        service: MockABTestService(categoryRowTest: .default)
    )

    container.register(AvatarManager.self, instance: avatarManager)
    container.register(ABTestManager.self, instance: abTestManager)

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .environment(avatarManager)
        .environment(abTestManager)
        .previewEnvironment()
}

#Preview("CategoryRowTes: top") {
    let container = DevPreview.shared.container

    let avatarManager = AvatarManager(
        service: MockAvatarService()
    )
    let abTestManager = ABTestManager(
        service: MockABTestService(categoryRowTest: .top)
    )

    container.register(AvatarManager.self, instance: avatarManager)
    container.register(ABTestManager.self, instance: abTestManager)

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .environment(avatarManager)
        .environment(abTestManager)
        .previewEnvironment()
}

#Preview("CategoryRowTes: hidden") {
    let container = DevPreview.shared.container

    let avatarManager = AvatarManager(
        service: MockAvatarService()
    )
    let abTestManager = ABTestManager(
        service: MockABTestService(categoryRowTest: .hidden)
    )

    container.register(AvatarManager.self, instance: avatarManager)
    container.register(ABTestManager.self, instance: abTestManager)

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .environment(avatarManager)
        .environment(abTestManager)
        .previewEnvironment()
}
