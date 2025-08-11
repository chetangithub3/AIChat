//
//  HeroCellView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/12/25.
//

import SwiftUI

struct HeroCellView: View {
    var imageStringURL: String? = Constants.randomImageURLString
    var title: String? = "This is the title"
    var subTitle: String? = "This is the subtitle which goes here"
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageStringURL = imageStringURL {
                ImageLoaderView(urlString: imageStringURL)
            }
            textSection
        }
        .cornerRadius(16)
    }
    
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            if let subTitle = subTitle {
                Text(subTitle)
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background {
            LinearGradient(
                colors: [
                    .black.opacity(0.01),
                    .black.opacity(0.3),
                    .black.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

#Preview {
    HeroCellView()
        .frame(width: 300, height: 200)
       
}
