import SwiftUI

// MARK: - Journal Selection View Model
@Observable
class JournalSelectionViewModel {
    var selectedJournal: Journal
    
    init() {
        // Default to first visible journal or create a default one
        if let firstJournal = Journal.visibleJournals.first {
            self.selectedJournal = firstJournal
        } else {
            // Fallback journal if none are visible
            self.selectedJournal = Journal(name: "Journal", color: Color(hex: "44C0FF"), entryCount: 0)
        }
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