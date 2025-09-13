//
//  ExploreView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI
struct ExploreView: View {
    let avatar = AvatarModel.mock
    var body: some View {
        NavigationStack {
            HeroCellView(
                imageStringURL: avatar.profileImageName,
                title: avatar.name,
                subTitle: avatar.characterDescription
            )
            .frame(maxHeight: Screen.height * 0.5)
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
}
