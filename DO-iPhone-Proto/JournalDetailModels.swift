import SwiftUI

// MARK: - Simple Layout Style
enum JournalDetailStyle: String, CaseIterable {
    case colored = "Colored"
    case white = "White"
}

// MARK: - Journal Detail Tab Model
enum JournalDetailTab: String, Identifiable, Hashable, CaseIterable {
    case book
    case timeline
    case calendar
    case media
    case map

    var id: String { rawValue }

    var title: String {
        switch self {
        case .book: return "Book"
        case .timeline: return "Timeline"
        case .calendar: return "Calendar"
        case .media: return "Media"
        case .map: return "Map"
        }
    }

    var dayOneIcon: DayOneIcon {
        switch self {
        case .book: return .book
        case .timeline: return .unordered_list
        case .calendar: return .calendar
        case .media: return .photo_stack
        case .map: return .map_pin
        }
    }

    static let allTabs: [JournalDetailTab] = allCases
}

// MARK: - Journal Detail Pill Picker
struct JournalDetailPillPicker: View {
    let tabs: [JournalDetailTab]
    @Binding var selection: JournalDetailTab
    let selectedColor: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tabs) { tab in
                    Button {
                        withAnimation(.bouncy) {
                            selection = tab
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(dayOneIcon: tab.dayOneIcon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)

                            if selection == tab {
                                Text(tab.title)
                                    .lineLimit(1)
                                    .transition(.opacity.combined(with: .move(edge: .leading)))
                            }
                        }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 7)
                        .contentShape(Capsule())
                    }
                    .foregroundStyle(selection == tab ? .white : .secondary)
                    .background {
                        Capsule()
                            .fill(selection == tab ? selectedColor : Color(uiColor: .secondarySystemFill))
                    }
                    .accessibilityLabel(Text(tab.title))
                    .accessibilityAddTraits(selection == tab ? [.isSelected] : [])
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Journal Detail FAB View
struct JournalDetailFAB: View {
    let journal: Journal
    let onTap: () -> Void
    @State private var showingFAB = false

    var body: some View {
        Button(action: onTap) {
            Text(DayOneIcon.plus.rawValue)
                .dayOneIconFont(size: 24)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
        }
        .background(journal.color)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .offset(y: showingFAB ? 0 : 150) // Slide up/down animation
        .opacity(showingFAB ? 1 : 0)
        .onAppear {
            // Animate FAB in after a short delay with bounce effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.interpolatingSpring(stiffness: 180, damping: 12)) {
                    showingFAB = true
                }
            }
        }
    }
}
