//
//  CarouselView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 9/13/25.
//

import SwiftUI

struct CarouselViewBuilder<Content: View, T: Hashable>: View {
    var items: [T]
    @ViewBuilder var content: (T) -> Content
    @State var selection: T?
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                      content(item)
                        .id(item)
                        .scrollTransition(.interactive.threshold(.visible(0.95)), axis: .horizontal, transition: { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1 : 0.9, anchor: .center)
                        })
                        .containerRelativeFrame(.horizontal, alignment: .center)
                    }
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $selection)
            .onChange(of: items.count, { _, _ in
                updateSelectionIfNeeded()
            })
            .onAppear {
               updateSelectionIfNeeded()
            }
            HStack {
                ForEach(items, id: \.self) { item in
                    Circle()
                        .fill(item == selection ? Color.accentColor : Color.accentColor.opacity(0.1))
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selection)
        }
    }
    func updateSelectionIfNeeded() {
        if selection == nil || selection == items.last {
            selection = items.first
        }
    }
}

#Preview {
    CarouselViewBuilder(items: AvatarModel.mocks) { item in
        HeroCellView(
            imageStringURL: item.profileImageName,
            title: item.name,
            subTitle: item.characterDescription
        )
    }
}
