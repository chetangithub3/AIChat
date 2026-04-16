//
//  ExploreView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct ExploreView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(PushManager.self) private var pushManager
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var categories = CharacterOption.allCases
    @State private var path: [NavigationPathOption] = []
    @State private var isLoadingFeatured: Bool = false
    @State private var isLoadingPopular: Bool = false
    @State private var showDevSettings: Bool = false
    @State private var showNotificationButton: Bool = true
    @State private var showPushNotificationModal: Bool = false
    var isDevOrMock: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ZStack {
                        if isLoadingFeatured || isLoadingPopular {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                } else {
                    Group {
                        featuredSection
                        categorySection
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
                    if showNotificationButton {
                        notificationButton
                    }
                }
            })
            .sheet(isPresented: $showDevSettings) {
                Text("Dev settings")
            }
            .screenAppearAnalytic(name: "ExploreView")
            .navigationDestinationForCoreModules(path: $path)
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
            .task {
                await shouldShowNotificationButton()
            }
            .onFirstAppear {
                schedulePushNotifications()
            }
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
        }
    }
    private func handleDeepLink(url: URL) {
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
    private func schedulePushNotifications() {
        pushManager.schedulePushNotificationsFortheNextWeek()
    }
    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable Notifications",
            subTitle: "Stay updated with important alerts and reminders.",
            primaryButtonTitle: "Allow",
            primaryButtonAction: {
                pushNotifModalAllowPressed()
            },
            secondaryButtonTitle: "Not Now",
            secondaryButtonAction: {
                pushNotifModalAllowPressed()
            }
        )
    }
    private func shouldShowNotificationButton() async {
         showNotificationButton = await pushManager.canRequestAuthorization()
    }
    private func pushNotifModalAllowPressed() {
        Task {
            await shouldShowNotificationButton()
        }
        showPushNotificationModal = false
    }
    private func pushNotifModalRefusePressed() {
        showPushNotificationModal = false
    }
    private func onNotificationButtonPressed() {
        showPushNotificationModal = true
    }
    private var notificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableText()
            .foregroundStyle(.accent)
            .anyButton {
                onNotificationButtonPressed()
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
                logManager.trackEvent(event: Event.tryAgainPressed)
                Task {
                    await loadFeaturedAvatars()
                }
                Task {
                    await loadPopularAvatars()
                }
            }
        }
    }
    private var devSettingsButton: some View {
        Text("DEV")
            .anyButton {
                showDevSettings = true
            }
    }
    private func loadFeaturedAvatars() async {
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)
        guard featuredAvatars.isEmpty else { return }
        isLoadingFeatured = true
        do {
            self.featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeaturedAvatarsSuccess(avatars: featuredAvatars))
        } catch {
            logManager.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        isLoadingFeatured = false
    }
    private func loadPopularAvatars() async {
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
    private var featuredSection: some View {
        Section {
            CarouselViewBuilder(
                items: featuredAvatars,
                content: { item in
                    HeroCellView(
                        imageStringURL: item.profileImageName,
                        title: item.name,
                        subTitle: item.characterDescription
                    )
                    .padding(.horizontal)
                    .anyButton {
                        onFeaturedAvatarPressed(avatar: item)
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
                    ForEach(categories, id: \.self) { category in
                        if let imageName = featuredAvatars.first(where: {$0.characterOption == category})?.profileImageName {
                            CategoryCellView(image: imageName, title: category.rawValue.capitalized)
                            .frame(width: 150, height: 150)
                            .anyButton {
                                onCategoryItemPressed(category, imageName: imageName)
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
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageURL: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .anyButton(.highlight) {
                    onPopularItemPressed(avatar: avatar)
                }
            }
        } header: {
            Text("Popular")
        }
    }
    private func onCategoryItemPressed(_ category: CharacterOption, imageName: String) {
        logManager.trackEvent(event: Event.categoryItemPressed(category: category))
        path.append(.category(category: category, imageName: imageName))
    }
    private func onPopularItemPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.popularAvatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    private func onFeaturedAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.featuredAvatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
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

#Preview("Happy") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()
}

#Preview("No avatars") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 3)))
        .previewEnvironment()
}

#Preview("Delay") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(delay: 5)))
        .previewEnvironment()
}
