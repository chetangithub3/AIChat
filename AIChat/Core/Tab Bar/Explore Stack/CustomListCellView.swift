//
//  CustomListCellView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 9/21/25.
//

import SwiftUI

struct CustomListCellView: View {
    var imageURL: String?
    var title: String?
    var subtitle: String?
    var body: some View {
        HStack {
            Group {
                if let imageURL {
                    ImageLoaderView(urlString: imageURL)
                } else {
                    Rectangle()
                        .foregroundStyle(Color.accent.opacity(0.5))
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8)
            if let title = title, let subtitle = subtitle {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    List {
        CustomListCellView(
            imageURL: Constants.randomImageURLString,
            title: AvatarModel.mock.name,
            subtitle: AvatarModel.mock.characterDescription
        )
        CustomListCellView(
            imageURL: nil,
            title: AvatarModel.mock.name,
            subtitle: AvatarModel.mock.characterDescription
        )
    }
}
