import SwiftUI

enum TodayViewStyle: String, CaseIterable {
    case standard = "Standard"
}

// MARK: - Supporting Views

struct MomentOption: View {
    let icon: DayOneIcon
    let count: Int
    let title: String
    let position: MomentPosition
    let onTap: () -> Void

    enum MomentPosition {
        case left, center, right

        var cornerRadii: RectangleCornerRadii {
            switch self {
            case .left:
                return RectangleCornerRadii(topLeading: 26, bottomLeading: 26, bottomTrailing: 8, topTrailing: 8)
            case .center:
                return RectangleCornerRadii(topLeading: 8, bottomLeading: 8, bottomTrailing: 8, topTrailing: 8)
            case .right:
                return RectangleCornerRadii(topLeading: 8, bottomLeading: 8, bottomTrailing: 26, topTrailing: 26)
            }
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(dayOneIcon: icon)
                    .font(.system(size: 28)) // ~70% of largeTitle size
                    .foregroundStyle(.primary)

                Text("\(count) \(title)")
                    .font(.footnote)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(.systemGray6))
            .clipShape(UnevenRoundedRectangle(cornerRadii: position.cornerRadii))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
