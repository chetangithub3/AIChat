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

    var body: some View {
        Rectangle()
            .overlay(content: {
                WebImage(url: URL(string: urlString), options: .highPriority, context: .none, isAnimating: .constant(true))
                .resizable()
                .indicator(.activity)
                .allowsHitTesting(false)
                .aspectRatio(contentMode: resizingMode)
            })
            .clipped()
    }
}

#Preview {
    ImageLoaderView()
        .frame(width: 200, height: 300)
    
}
