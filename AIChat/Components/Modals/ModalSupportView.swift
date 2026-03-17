//
//  ModalSupportView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/16/26.
//

import SwiftUI

struct ModalSupportView<Content: View>: View {
    @Binding var showModal: Bool
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            if showModal {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        showModal = false
                    }
               content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        }
        .zIndex(999)
        .animation(.bouncy, value: showModal)
    }
}
extension View {
    func showModal(showModal: Binding<Bool>, @ViewBuilder content: () -> some View) -> some View {
        self
            .overlay {
                ModalSupportView(showModal: showModal) {
                    content()
                }
            }
    }
}
struct ModalSupportPreView: View {
    @State private var showModal: Bool = false
    var body: some View {
        Button(" Click me") {
            showModal = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .showModal(showModal: $showModal) {
            RoundedRectangle(cornerRadius: 30)
                .padding(40)
                .padding(.vertical, 100)
        }
    }
}
#Preview {
    ModalSupportPreView()
}
