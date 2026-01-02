import SwiftUI

// MARK: - Style Computed Properties Protocol
protocol StyleComputedProperties {
    var color: Color { get }
    var selectedStyle: JournalDetailStyle { get }
}

extension StyleComputedProperties {
    var headerBackgroundColor: Color {
        selectedStyle == .colored ? color : .white
    }

    var headerTextColor: Color {
        selectedStyle == .colored ? .white : color
    }

    var toolbarColorScheme: ColorScheme? {
        selectedStyle == .colored ? .dark : nil
    }

    var selectedPillColor: Color {
        selectedStyle == .colored ? Color(hex: "333B40") : color
    }
}
