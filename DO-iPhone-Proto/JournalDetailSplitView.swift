import SwiftUI

// MARK: - Two-Column Journal Detail View for iPad
struct JournalDetailSplitView: View {
    @Binding var selectedJournal: Journal?
    @Binding var selectedEntry: EntryView.EntryData?
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Content - Entry timeline for selected journal
            if let journal = selectedJournal {
                EntryTimelineView(
                    journal: journal,
                    selectedEntry: $selectedEntry
                )
            } else {
                ContentUnavailableView(
                    "Select a Journal",
                    systemImage: "book.closed",
                    description: Text("Choose a journal from the sidebar to view entries")
                )
            }
        } detail: {
            // Detail - Selected entry content
            if let entry = selectedEntry {
                EntryDetailView(
                    entryData: entry,
                    journal: selectedJournal
                )
            } else {
                ContentUnavailableView(
                    "Select an Entry",
                    systemImage: "doc.text",
                    description: Text("Choose an entry to read")
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    JournalDetailSplitView(
        selectedJournal: .constant(Journal(
            name: "Personal Journal",
            color: Color(hex: "44C0FF"),
            entryCount: 42
        )),
        selectedEntry: .constant(nil)
    )
}