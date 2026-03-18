//
//  ProfileModalView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/13/26.
//

import SwiftUI

struct ProfileModalView: View {
    var imageName: String? = Constants.randomImageURLString
    var title: String? = "Alpha"
    var subTitle: String? = "Alien"
    var headline: String? = "An alien in the park."
    var onClosePressed: () -> Void = { }
    var body: some View {
        VStack(alignment: .leading) {
            if let imageName {
                ImageLoaderView(urlString: imageName, forceDrawringGroup: true)
            }
            VStack(alignment: .leading, spacing: 12) {
                if let title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                }
                if let subTitle {
                    Text(subTitle)
                        .font(.headline)
                        .fontWeight(.light)
                }
                if let headline {
                    Text(headline)
                        .font(.subheadline)
                        .fontWeight(.ultraLight)
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 24))
        .overlay(alignment: .topTrailing) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundStyle(.black)
                .padding(8)
                .anyButton {
                    onClosePressed()
                }
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 200)
    }
}

#Preview("Modal w/ Image") {
    ZStack {
        Color.black.opacity(0.6).ignoresSafeArea()
        ProfileModalView()
    }
}
#Preview("Modal w/o Image") {
    ZStack {
        Color.black.opacity(0.6).ignoresSafeArea()
        ProfileModalView(imageName: nil)
    }
}
