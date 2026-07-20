//
//  Theme.swift
//  ThermalForge
//
//  DESIGN.md design tokens — colors, fonts, radii, spacing.
//

import AppKit
import SwiftUI

enum TFTheme {

    // MARK: - Colors (DESIGN.md)

    enum Colors {
        static let canvas = Color(red: 0xfd / 255, green: 0xfc / 255, blue: 0xfc / 255)
        static let ink = Color(red: 0x20 / 255, green: 0x1d / 255, blue: 0x1d / 255)
        static let inkDeep = Color(red: 0x0f / 255, green: 0x00 / 255, blue: 0x00 / 255)
        static let charcoal = Color(red: 0x30 / 255, green: 0x2c / 255, blue: 0x2c / 255)
        static let body = Color(red: 0x42 / 255, green: 0x42 / 255, blue: 0x45 / 255)
        static let mute = Color(red: 0x64 / 255, green: 0x62 / 255, blue: 0x62 / 255)
        static let ash = Color(red: 0x9a / 255, green: 0x98 / 255, blue: 0x98 / 255)
        static let surfaceSoft = Color(red: 0xf8 / 255, green: 0xf7 / 255, blue: 0xf7 / 255)
        static let surfaceCard = Color(red: 0xf1 / 255, green: 0xee / 255, blue: 0xee / 255)
        static let hairline = Color(red: 15 / 255, green: 0, blue: 0, opacity: 0.12)
        static let hairlineStrong = Color(red: 0x64 / 255, green: 0x62 / 255, blue: 0x62 / 255)
        static let accent = Color(red: 0, green: 0x7a / 255, blue: 1.0)
    }

    // MARK: - Radius

    static let radius: CGFloat = 4

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    // MARK: - Font (Berkeley Mono → system monospaced fallback)

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if NSFont(name: "Berkeley Mono", size: size) != nil {
            return .custom("Berkeley Mono", size: size)
        }
        return .system(size: size, weight: weight, design: .monospaced)
    }
}
