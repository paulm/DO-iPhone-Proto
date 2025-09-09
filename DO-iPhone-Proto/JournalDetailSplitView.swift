import SwiftUI

// MARK: - Journal View Mode
enum JournalViewMode: String, CaseIterable {
    case cover = "Cover"
    case list = "List"
    case calendar = "Calendar"
    case media = "Media"
    case map = "Map"
    
    var icon: String {
        switch self {
        case .cover:
            return "photo"
        case .list:
            return "list.bullet"
        case .calendar:
            return "calendar"
        case .media:
            return "photo.on.rectangle.angled"
        case .map:
            return "map"
        }
    }
}

// MARK: - Two-Column Journal Detail View for iPad
struct JournalDetailSplitView: View {
    @Binding var selectedJournal: Journal?
    @Binding var selectedEntry: EntryView.EntryData?
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    @State private var viewMode: JournalViewMode = .list
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Content - Entry timeline for selected journal
            if let journal = selectedJournal {
                VStack(spacing: 0) {
                    // Journal Header with color background
                    JournalHeaderView(journal: journal)
                    
                    // View content based on selected mode - reusing iPhone components
                    Group {
                        switch viewMode {
                        case .cover:
                            // Reuse the iPhone CoverTabView
                            CoverTabView()
                                .background(Color(UIColor.systemBackground))
                        case .list:
                            // Reuse the iPhone ListTabView
                            ListTabView(journal: journal)
                                .background(Color(UIColor.systemBackground))
                        case .calendar:
                            // Use existing CalendarTabView from JournalsView
                            CalendarTabView()
                                .background(Color(UIColor.systemBackground))
                        case .media:
                            // Use existing MediaTabView from JournalsView
                            MediaTabView()
                                .background(Color(UIColor.systemBackground))
                        case .map:
                            // Use existing MapTabView from JournalsView
                            MapTabView()
                                .background(Color(UIColor.systemBackground))
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker("View Mode", selection: $viewMode) {
                            ForEach(JournalViewMode.allCases, id: \.self) { mode in
                                Label(mode.rawValue, systemImage: mode.icon)
                                    .tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 350)
                    }
                }
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

// MARK: - Journal Header View
struct JournalHeaderView: View {
    let journal: Journal
    
    var body: some View {
        VStack(spacing: 0) {
            // Colored header background
            LinearGradient(
                colors: [
                    journal.color.opacity(0.9),
                    journal.color.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            .overlay(
                VStack(spacing: 8) {
                    Text(journal.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("2020 - 2025")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    if let count = journal.entryCount {
                        Text("\(count) entries")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
            )
            
            Divider()
        }
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