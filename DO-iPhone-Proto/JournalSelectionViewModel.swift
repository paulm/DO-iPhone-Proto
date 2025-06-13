import SwiftUI

// MARK: - Journal Data Model
struct Journal: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let color: Color
    let entryCount: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static let allJournals = [
        Journal(name: "All Entries", color: .gray, entryCount: 238),
        Journal(name: "Journal", color: Color(hex: "44C0FF"), entryCount: 22),
        Journal(name: "Travel", color: .blue, entryCount: 9),
        Journal(name: "Family Memories", color: .green, entryCount: 4),
        Journal(name: "WCEU", color: Color(red: 0.7, green: 0.8, blue: 0.2), entryCount: 12),
        Journal(name: "Notes", color: .orange, entryCount: 19),
        Journal(name: "Prompts", color: Color(red: 1.0, green: 0.6, blue: 0.2), entryCount: nil)
    ]
}

// MARK: - Journal Selection View Model
@Observable
class JournalSelectionViewModel {
    var selectedJournal: Journal
    
    init() {
        // Default to "Journal" (index 1)
        self.selectedJournal = Journal.allJournals[1]
    }
    
    func selectJournal(_ journal: Journal) {
        selectedJournal = journal
    }
    
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: [selectedJournal.color, selectedJournal.color.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}