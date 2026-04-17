//
//  ImageLoaderView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/8/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageLoaderView: View {
    var urlString: String = Constants.randomImageURLString
    var resizingMode: ContentMode = .fill
    var forceDrawringGroup: Bool = false
    var body: some View {
        Rectangle()
            .opacity(0.001)
            .overlay(content: {
                WebImage(url: URL(string: urlString),
                         options: .highPriority,
                         context: .none,
                         isAnimating: .constant(true))
                .resizable()
                .indicator(.activity)
                .allowsHitTesting(false)
                .aspectRatio(contentMode: resizingMode)
            })
            .clipped()
            .ifSatisfiesCondition(forceDrawringGroup) { content in
                content
                    .drawingGroup()
            }
    }
}

#Preview {
    ImageLoaderView()
        .frame(width: 200, height: 300)
}
