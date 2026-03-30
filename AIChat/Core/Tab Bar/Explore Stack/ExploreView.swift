//
//  ExploreView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct ExploreView: View {
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var categories = CharacterOption.allCases
    @State private var path: [NavigationPathOption] = []
    @Environment(AvatarManager.self) private var avatarManager
    @State private var isLoadingFeatured: Bool = false
    @State private var isLoadingPopular: Bool = false

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
            .navigationDestinationForCoreModules(path: $path)
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
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
                    await loadFeaturedAvatars()
                }
                Task {
                    await loadPopularAvatars()
                }
            }
        }
    }
    private func loadFeaturedAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        isLoadingFeatured = true
        do {
            self.featuredAvatars = try await avatarManager.getFeaturedAvatars()
        } catch {
        }
        isLoadingFeatured = false
    }
    private func loadPopularAvatars() async {
        do {
            isLoadingPopular = true
            popularAvatars = try await avatarManager.getPopularAvatars()
        } catch {
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
        path.append(.category(category: category, imageName: imageName))
    }
    private func onPopularItemPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    private func onFeaturedAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
}

#Preview("Happy") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
}

#Preview("No avatars") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 3)))
}

#Preview("Delay") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(delay: 5)))
}
