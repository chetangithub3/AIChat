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

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ProgressView()
                        .ignoresSafeArea()
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
    private func loadFeaturedAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        do {
            self.featuredAvatars = try await avatarManager.getFeaturedAvatars()
        } catch {
        }
    }
    private func loadPopularAvatars() async {
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
        } catch {
        }
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
        path.append(.chat(avatarId: avatar.avatarId))
    }
    private func onFeaturedAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
}
