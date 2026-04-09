//
//  CustomModalView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/9/26.
//

import SwiftUI

struct CustomModalView: View {
    var title: String = "Are you enjoying the app?"
    var subTitle: String? = "This is a subtitle"
    var primaryButtonTitle: String = "Yes"
    var primaryButtonAction: (() -> Void) = { }
    var secondaryButtonTitle: String? = "No"
    var secondaryButtonAction: (() -> Void) = { }
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                if let subTitle {
                    Text(subTitle)
                        .fontWeight(.light)
                }
            }
            VStack(spacing: 0) {
                Text(primaryButtonTitle)
                    .modalPrimaryButtonStyle()
                    .anyButton(.pressable) {
                        primaryButtonAction()
                    }
                if let secondaryButtonTitle {
                    Text(secondaryButtonTitle)
                        .modalSecondaryButtonStyle()
                        .anyButton(.pressable) {
                            secondaryButtonAction()
                        }
                }
            }
        }
        .padding()
        .background(.white)
        .clipShape(.rect(cornerSize: CGSize(width: 12, height: 12)))
        .padding(.horizontal, 24)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CustomModalView()
            .previewEnvironment()
    }
}
