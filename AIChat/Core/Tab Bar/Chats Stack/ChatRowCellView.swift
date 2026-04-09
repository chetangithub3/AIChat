//
//  ChatRowCellView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/12/25.
//

import SwiftUI

struct ChatRowCellView: View {
    var imageName: String? = Constants.randomImageURLString
    var headline: String? = "Alpha"
    var subheadline: String? = "This is the last message"
    var hasNewChat: Bool = true
    var body: some View {
        HStack(alignment: .center) {
            Group {
                if let imageName {
                    ImageLoaderView(urlString: imageName)
                } else {
                    Rectangle()
                        .foregroundStyle(Color.accent.opacity(0.5))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 8) {
                if let headline {
                    Text(headline)
                        .font(.headline)
                }
                if let subheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)

            if hasNewChat {
                Text("New")
                    .font(Font.caption.italic())
                    .padding(8)
                    .tint(.accentColor)
                    .foregroundStyle(.accent)
            }
        }
    }
}

#Preview {
    List {
        ChatRowCellView()
        ChatRowCellView(imageName: nil, hasNewChat: true)
        ChatRowCellView(hasNewChat: false)
        ChatRowCellView(headline: nil, hasNewChat: false)
        ChatRowCellView(subheadline: nil, hasNewChat: false)
    }
}
