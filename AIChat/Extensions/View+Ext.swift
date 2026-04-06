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
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55, alignment: .center)
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

    func tappableText(scale: CGFloat = 1.1) -> some View {
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
    }

    func removeListRowFormatting() -> some View {
        self
            .listRowInsets(
                EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
            .listRowBackground(Color.clear)
    }
}

extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var hexInt: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&hexInt)
        let alpha, red, green, blue: UInt64
        switch hexString.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (
                255,
                (hexInt >> 8) * 17,
                (hexInt >> 4 & 0xF) * 17,
                (hexInt & 0xF) * 17
            )
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (
                255,
                hexInt >> 16,
                hexInt >> 8 & 0xFF,
                hexInt & 0xFF
            )
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (
                hexInt >> 24,
                hexInt >> 16 & 0xFF,
                hexInt >> 8 & 0xFF,
                hexInt & 0xFF
            )
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    func toHex(includeAlpha: Bool = false) throws -> String {
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Failed to extract RGB components from Color."))
        }

        let redInt   = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt  = Int(blue * 255)
        let alphaInt = Int(alpha * 255)

        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X", alphaInt, redInt, greenInt, blueInt)
        } else {
            return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
        }
    }
}
