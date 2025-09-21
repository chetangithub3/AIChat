//
//  ExploreView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI
struct ExploreView: View {
    var body: some View {
        NavigationStack {
            CarouselView(items: AvatarModel.mocks)
            .frame(maxHeight: Screen.height * 0.3)
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
}
