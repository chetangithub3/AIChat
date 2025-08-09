//
//  Ext+View.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

extension View {
    
    func mainButtonStyle() -> some View {
        self
            .font(.headline)
            .tint(.white)
            .frame(maxWidth: .infinity, maxHeight: 55, alignment: .center)
            .background(.accent)
            .clipShape(.buttonBorder)
            .padding()
    }

    func tappableTextWithAction(_ action: @escaping () -> Void, scale: CGFloat = 1) -> some View {
        self
            .background(
                GeometryReader { geo in
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: geo.size.width * scale,
                               height: geo.size.height * scale)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            )
            .onTapGesture(perform: action)
    }
}
