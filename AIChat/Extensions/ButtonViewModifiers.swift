//
//  ButtonViewModifiers.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 9/27/25.
//

import SwiftUI
enum ButtonStyleOption {
    case highlight, pressable, plain
}
extension View {
    private func highlightButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(HighlightButtonStyle())
    }

    private func pressableButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PressableButtonStyle())
    }
    private func plainButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PlainButtonStyle())
    }
    @ViewBuilder
    func anyButton(_ option: ButtonStyleOption = .plain, action: @escaping () -> Void) -> some View {
        switch option {
            case .highlight:
                self.highlightButton(action: action)
            case .pressable:
                self.pressableButton(action: action)
            case .plain:
                self.plainButton(action: action)
        }
    }
}

struct HighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.accentColor.opacity(0.4) : Color.accent.opacity(0))
            .animation(.default, value: configuration.isPressed)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1, anchor: .center)
            .animation(.smooth, value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        Text("saloni")
            .mainButtonStyle()
            .anyButton(.plain) {}

        Text("saloni")
            .frame(maxWidth: .infinity)
            .padding()
            .anyButton(.highlight) {}

        Text("saloni")
            .frame(maxWidth: .infinity)
            .padding()
            .mainButtonStyle()
            .anyButton(.pressable) {}
    }
}
