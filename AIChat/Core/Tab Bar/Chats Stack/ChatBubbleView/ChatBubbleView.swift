//
//  ChatBubbleView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/8/25.
//

import SwiftUI

struct ChatBubbleView: View {
    var showImage: Bool = true
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray5)
    var text: String = "This is sample text"
    var imageName: String?
    var offset: CGFloat = 8
    var onImagePressed: (() -> Void)?
    var body: some View {
        HStack(alignment: .bottom) {
            if showImage {
                ZStack {
                    if let imageName = imageName {
                        ImageLoaderView(urlString: imageName)
                            .anyButton {
                                onImagePressed?()
                            }
                    } else {
                        Circle()
                            .fill(.secondary)
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .offset(y: offset)
            }
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .background(backgroundColor)
                .clipShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 20, bottomLeading: 20, bottomTrailing: 20, topTrailing: 20), style: .continuous))
        }
        .padding(.bottom, showImage ? offset : 0)
    }
}

#Preview {
    ScrollView {
        VStack {
            ChatBubbleView()
            ChatBubbleView(text: "Long Text To Test The Truncation...  Long Text To Test The Truncation...Long Text To Test The Truncation...  Long Text To Test The Truncation...Long Text To Test The Truncation...  Long Text To Test The Truncation...")
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                text: "Sample Text With Image"
            )
            ChatBubbleView(
                showImage: false,
                textColor: .white,
                backgroundColor: .accent,
                text: "Long Text To Test The Truncation...  Long Text To Test The Truncation...Long Text To Test The Truncation...  Long Text To Test The Truncation...Long Text To Test The Truncation...  Long Text To Test The Truncation..."
            )
            ChatBubbleView()
        }
    }
}
