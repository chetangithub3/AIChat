//
//  OnboardingColorPickerView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/9/25.
//

import SwiftUI

struct OnboardingColorPickerView: View {
    @State var selectedColor: Color? = nil
    let avatarColors: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .mint,
        .black,
        .indigo,
        .purple,
        .pink,
        .gray
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(
                        .flexible(
                            minimum: 50
                        ),
                        spacing: 16,
                        alignment: .center
                    ),
                    count: 3
                ),
                alignment: .center,
                spacing: 24,
                pinnedViews: .sectionHeaders
            ) {
                Section {
                    ForEach(
                        avatarColors,
                        id: \.self
                    ) { color in
                        colorComponent(color: color)
                    }
                } header: {
                  scrollViewHeader
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            if selectedColor != nil {
                footerButton
            }
        }
        .background(.white)
        .transition(AnyTransition.move(edge: .bottom))
    }

    private var footerButton: some View {
        Button {
            
        } label: {
            Text("Continue")
                .mainButtonStyle()
        }
    }

    private var scrollViewHeader: some View {
        Text("Select a profile color")
            .font(.headline)
    }

    private func colorComponent(color: Color) -> some View {
        ZStack {
            Circle().fill(Color.accentColor)
            Circle()
                .fill(
                    color
                )
                .onTapGesture {
               
                        selectedColor = color
                }
                .padding(selectedColor == color ? 16 : 0)
                .animation(.bouncy, value: selectedColor)
        }
    }
}

#Preview {
    OnboardingColorPickerView()
}
