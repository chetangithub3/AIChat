//
//  CategoryListView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/17/26.
//

import SwiftUI

struct CategoryListView: View {
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImageURLString
    @State private var avatars: [AvatarModel] = AvatarModel.mocks
    var body: some View {
        List {
            CategoryCellView(
                image: imageName,
                title: category.rawValue.capitalized,
                cornerRadius: 0
            )
            .frame(width: .infinity, height: 350)
            .removeListRowFormatting()
            ForEach(avatars) { avatar in
                CustomListCellView(
                    imageURL: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
            }

        }
        .listStyle(.plain)
        .ignoresSafeArea()
    }
}

#Preview {
    CategoryListView()
}
