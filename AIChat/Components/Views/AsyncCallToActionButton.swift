//
//  AsyncCallToActionButtin.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/5/25.
//


struct AsyncCallToActionButtin: View {
    var title: String
    @State var isLoading: Bool = false
    var onbuttonPressed: () -> Void
    var body: some View {
        finishButton
    }
    private var finishButton: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.3)
            } else {
                Text("title")
            }
        }
        .anyButton(.pressable, action: onbuttonPressed)
        .disabled(isLoading)
        .mainButtonStyle()
    }
}