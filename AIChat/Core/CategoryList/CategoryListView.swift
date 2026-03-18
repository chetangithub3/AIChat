//
//  CategoryListView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/17/26.
//

import SwiftUI

struct CategoryListView: View {

    @Binding var path: [NavigationPathOption]
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
            .frame(height: 350)
            .removeListRowFormatting()
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
        .listStyle(.plain)
        .ignoresSafeArea()
    }
    func onAvatarPresed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview {
    CategoryListView(path: .constant([]))
}
