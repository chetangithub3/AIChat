//
//  CategoryCellView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 9/21/25.
//
import SwiftUI

struct CategoryCellView: View {
    var image: String
    var title: String?
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ImageLoaderView(urlString: image)
            if let title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .textSectionBackground()
            }
        }
        .cornerRadius(16)
    }
}

#Preview {
    CategoryCellView(
        image: Constants.randomImageURLString,
        title: CharacterOption.allCases.first?.rawValue.capitalized
    )
    .frame(width: 150, height: 150)
}
