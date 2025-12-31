import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static func gradientForString(_ text: String) -> LinearGradient {
        let colors: [Color] = [
            Color(hex: "FF6B6B"), Color(hex: "4ECDC4"), Color(hex: "45B7D1"),
            Color(hex: "FFA07A"), Color(hex: "98D8C8"), Color(hex: "F7DC6F"),
            Color(hex: "BB8FCE"), Color(hex: "85C1E2"), Color(hex: "F8B88B"),
            Color(hex: "52B788")
        ]

        let charValue = text.unicodeScalars.first?.value ?? 0
        let colorIndex = Int(charValue) % colors.count
        let color = colors[colorIndex]

        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}