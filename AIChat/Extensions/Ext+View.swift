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
}
