//
//  AsyncCallToActionButtin.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/5/25.
//

import SwiftUI

struct AsyncCallToActionButton: View {
    var title: String
    var isLoading: Bool
    var onbuttonPressed: () -> Void
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.3)
            } else {
                Text(title)
            }
        }
        .anyButton(.pressable, action: onbuttonPressed)
        .mainButtonStyle()
        .disabled(isLoading)

    }
}
private struct PreviewView: View {
    @State var isLoading: Bool = false
    var body: some View {
        AsyncCallToActionButton(title: "Finish", isLoading: isLoading) {
            Task {
                isLoading = true
                try await Task.sleep(for: .seconds(2))
                isLoading = false
            }
        }
    }
}
#Preview {
  PreviewView()
}
