//
//  ExploreView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct ExploreView: View {
    @State private var featuredAvatars = AvatarModel.mocks
    @State private var categories = CharacterOption.allCases
    var body: some View {
        NavigationStack {
            List {
                Group {
                    featuredSection
                    categorySection
                }
                .listRowSeparator(.hidden)
                popularSection
            }
            .listStyle(.grouped)
            .navigationTitle("Explore")
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
                },
                selection: nil
            )
            .frame(height: Screen.height * 0.3)
            .anyButton(action: onFeaturedItemPressed)
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
                        CategoryCellView(image: Constants.randomImageURLString, title: category.rawValue.capitalized)
                        .frame(width: 150, height: 150)
                        .anyButton(action: onCategoryItemPressed)
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
            ForEach(featuredAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageURL: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .anyButton(.highlight, action: onPopularItemPressed)
            }
        } header: {
            Text("Popular")
        }
    }
    // todo
    private func onFeaturedItemPressed() {
        print("hello f")
    }
    private func onCategoryItemPressed() {
        print("hello c")
    }
    private func onPopularItemPressed() {
        print("hello")
    }
}

#Preview {
    ExploreView()
}
