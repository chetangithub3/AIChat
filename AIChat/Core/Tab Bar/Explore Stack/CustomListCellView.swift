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
            VStack(alignment: .leading) {
                if let title = title {
                    Text(title)
                        .font(.headline)
                }
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
