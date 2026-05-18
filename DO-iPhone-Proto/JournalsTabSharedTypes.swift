import SwiftUI

// MARK: - Constants

/// Size for toggle disclosure icons (arrow-right-circle)
let toggleIconSize: CGFloat = 24

// MARK: - View Mode Enum

enum ViewMode: Int, CaseIterable {
    case list = 0
    case grid = 1
}

// MARK: - Journals Population Enum

enum JournalsPopulation: String, CaseIterable {
    case newUser = "New User"
    case threeJournals = "3 Journals"
    case lots = "Lots"
    case oneHundredOne = "101 Journals"
}

// MARK: - Journals Tab Paged Variant

struct JournalEntry: Identifiable {
    let id: String
    let title: String
    let preview: String
    let date: String
    let time: String
    let journalName: String
    let journalColor: Color
}

// MARK: - Preference Keys for Journal Row Tracking

struct JournalRowPreferenceData: Equatable {
    let id: String
    let frame: CGRect
    let color: Color
}

struct JournalRowPreferenceKey: PreferenceKey {
    static var defaultValue: [JournalRowPreferenceData] = []
    
    static func reduce(value: inout [JournalRowPreferenceData], nextValue: () -> [JournalRowPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Journals Tab Paged Variant


enum JournalSectionType: String, CaseIterable, Hashable {
    case recentJournals
    case recentEntries
    case journals
    case newJournalButtons

    var displayName: String {
        switch self {
        case .recentJournals: return "Recent Journals"
        case .recentEntries: return "Recent Entries"
        case .journals: return "Journals"
        case .newJournalButtons: return "New Journal Button Row"
        }
    }

    var icon: String {
        switch self {
        case .recentJournals: return "clock"
        case .recentEntries: return "doc.text"
        case .journals: return "book"
        case .newJournalButtons: return "plus.circle"
        }
    }
}

// MARK: - Journals Reorder View Data Models

