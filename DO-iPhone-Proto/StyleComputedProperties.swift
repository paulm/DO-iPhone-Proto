import SwiftUI

// MARK: - Style Computed Properties Protocol
protocol StyleComputedProperties {
    var color: Color { get }
    var selectedStyle: JournalDetailStyle { get }
}

extension StyleComputedProperties {
    var headerBackgroundColor: Color {
        selectedStyle == .white ? .white : color
    }

    var headerTextColor: Color {
        selectedStyle == .white ? color : .white
    }

    var toolbarColorScheme: ColorScheme? {
        selectedStyle == .white ? nil : .dark
    }

    var selectedPillColor: Color {
        selectedStyle == .white ? color : Color(hex: "333B40")
    }
}
