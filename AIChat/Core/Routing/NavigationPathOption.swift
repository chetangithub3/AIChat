//
//  NavigationPathOption.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/17/26.
//

import SwiftUI

enum NavigationPathOption: Hashable {
    case chat(avatarId: String, chat: ChatModel?)
    case category(category: CharacterOption, imageName: String)
}
struct NavigationDestinationForCoreModuleViewModifier: ViewModifier {
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[NavigationPathOption]>

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                    case .chat(avatarId: let avatarId, chat: let chat):
                        ChatView(avatarId: avatarId, chat: chat)
                    case .category(category: let category, let imageName):
                        CategoryListView(viewModel: CategoryListViewModel(container: container), path: path, category: category, imageName: imageName)
                }
            }
    }
}
extension View {
    func navigationDestinationForCoreModules(path: Binding<[NavigationPathOption]>) -> some View {
        modifier(NavigationDestinationForCoreModuleViewModifier(path: path))

    }
}
