//
//  NavigationPathOption.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/17/26.
//

import SwiftUI

enum NavigationPathOption: Hashable {
    case chat(avatarId: String)
    case category(category: CharacterOption, imageName: String)
}

extension View {
    func navigationDestinationForCoreModules(path: Binding<[NavigationPathOption]>) -> some View {
        self
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                    case .chat(avatarId: let avatarId):
                        ChatView(avatarId: avatarId)
                    case .category(category: let category, let imageName):
                        CategoryListView(path: path, category: category, imageName: imageName)
                }
            }
    }
}
