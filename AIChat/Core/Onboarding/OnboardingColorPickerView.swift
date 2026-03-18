//
//  OnboardingColorPickerView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/9/25.
//

import SwiftUI

struct OnboardingColorPickerView: View {
    @State var selectedColor: Color?
    private let avatarColors: [Color] = [
           .red, .orange, .yellow, .green, .mint,
           .black, .indigo, .purple, .pink, .gray
       ]
    private let columns = Array(
            repeating: GridItem(.flexible(minimum: 50), spacing: 16, alignment: .center),
            count: 3
        )

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: columns,
                spacing: 24,
                pinnedViews: .sectionHeaders
            ) {
                Section {
                    ForEach(avatarColors, id: \.self) { color in
                        ColorCirle(color: color, isSelected: selectedColor == color) {
                            if selectedColor == color {
                               selectedColor = nil
                            } else {
                                selectedColor = color
                            }
                        }
                    }
                } header: {
                  scrollViewHeader
                }
            }
            .padding()
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            if let color = selectedColor {
                footerButton(color: color)
            }
        }
        .transition(AnyTransition.move(edge: .bottom))
    }

    private func footerButton(color: Color) -> some View {
        NavigationLink {
            OnboardingCompleteView(selectedColor: color)
        } label: {
            Text("Continue")
                .mainButtonStyle()
        }
        .background(Color(.systemBackground))
    }

    private var scrollViewHeader: some View {
        Text("Select a profile color")
            .font(.headline)
    }

    private struct ColorCirle: View {
        let color: Color
        let isSelected: Bool
        let onTap: () -> Void
        var body: some View {
            Circle()
                .fill(color)
                .padding(isSelected ? 16 : 0)
                .background(Circle().fill(Color.accentColor))
                .onTapGesture(perform: onTap)
                .animation(.bouncy, value: isSelected)
        }
    }
}

#Preview {
    OnboardingColorPickerView()
}
