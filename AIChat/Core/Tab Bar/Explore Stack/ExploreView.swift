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
                featuredSection
                categorySection
                popularSection
            }
            .listStyle(.grouped)
            .navigationTitle("Explore")
        }
    }
    private var featuredSection: some View {
        Section {
            CarouselView(items: AvatarModel.mocks)
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
                        CategoryCellView(image: Constants.randomImageURLString, title: category.rawValue.capitalized)
                        .frame(width: 150, height: 150)
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
            }
        } header: {
            Text("Popular")
        }
    }
}

#Preview {
    ExploreView()
}
