import SwiftUI

// MARK: - Three-Column Journals View for iPad
struct JournalsSplitView: View {
    @State private var selectedJournal: Journal?
    @State private var selectedEntry: EntryView.EntryData?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var viewMode: ViewMode = .list
    @State private var showingNewEntry = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar - Journal list
            journalSidebar
        } content: {
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
                    description: Text("Choose a journal to view entries")
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
    
    // MARK: - Journal Sidebar
    @ViewBuilder
    private var journalSidebar: some View {
        List(selection: $selectedJournal) {
            Section("Journals") {
                // All Entries option
                if Journal.visibleJournals.count > 1 {
                    let allEntriesJournal = Journal(
                        name: "All Entries",
                        color: Color(hex: "333B40"),
                        entryCount: Journal.visibleJournals.reduce(0) { $0 + ($1.entryCount ?? 0) }
                    )
                    
                    HStack {
                        Circle()
                            .fill(allEntriesJournal.color)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading) {
                            Text(allEntriesJournal.name)
                                .font(.body)
                            if let count = allEntriesJournal.entryCount {
                                Text("\(count) entries")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tag(allEntriesJournal)
                }
                
                // Individual journals
                ForEach(Journal.visibleJournals) { journal in
                    HStack {
                        Circle()
                            .fill(journal.color)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading) {
                            Text(journal.name)
                                .font(.body)
                            if let count = journal.entryCount {
                                Text("\(count) entries")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tag(journal)
                }
            }
        }
        .navigationTitle("Journals")
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        // TODO: Add new journal
                    } label: {
                        Label("New Journal", systemImage: "plus")
                    }
                    
                    Divider()
                    
                    Picker("View Style", selection: $viewMode) {
                        Label("List", systemImage: "list.bullet")
                            .tag(ViewMode.list)
                        Label("Grid", systemImage: "square.grid.3x3")
                            .tag(ViewMode.grid)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

// MARK: - Entry Timeline View
struct EntryTimelineView: View {
    let journal: Journal?
    @Binding var selectedEntry: EntryView.EntryData?
    @State private var showingNewEntry = false
    
    // Sample entry data (same as in ListTabView)
    private let marchEntries = [
        (day: "WED", date: "12", title: "Had a wonderful lunch with Emily today.",
         preview: "It's refreshing to step away from the daily grind and catch up with old friends. We talked about...",
         time: "6:11 PM CDT", month: 3, year: 2025),
        (day: "TUE", date: "11", title: "Morning run through the park",
         preview: "Felt energized after a good night's sleep. The weather was perfect for running and I...",
         time: "7:45 AM CDT", month: 3, year: 2025),
        (day: "MON", date: "10", title: "Started reading a new book",
         preview: "Picked up 'The Midnight Library' from the bookstore. Already hooked by the first chapter...",
         time: "9:30 PM CDT", month: 3, year: 2025)
    ]
    
    private let februaryEntries = [
        (day: "SUN", date: "23", title: "Family dinner at Mom's house",
         preview: "Great evening with the whole family. Mom made her famous lasagna and we spent hours...",
         time: "8:15 PM CST", month: 2, year: 2025),
        (day: "SAT", date: "15", title: "Weekend project completed",
         preview: "Finally finished organizing the garage. Found so many things I forgot I had...",
         time: "4:20 PM CST", month: 2, year: 2025)
    ]
    
    var body: some View {
        List {
            // March 2025 Section
            Section("March 2025") {
                ForEach(marchEntries, id: \.title) { entry in
                    Button {
                        selectEntry(entry)
                    } label: {
                        EntryRowContent(
                            day: entry.day,
                            date: entry.date,
                            title: entry.title,
                            preview: entry.preview,
                            time: entry.time
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        selectedEntry?.title == entry.title ?
                        Color.accentColor.opacity(0.1) : Color.clear
                    )
                }
            }
            
            // February 2025 Section
            Section("February 2025") {
                ForEach(februaryEntries, id: \.title) { entry in
                    Button {
                        selectEntry(entry)
                    } label: {
                        EntryRowContent(
                            day: entry.day,
                            date: entry.date,
                            title: entry.title,
                            preview: entry.preview,
                            time: entry.time
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        selectedEntry?.title == entry.title ?
                        Color.accentColor.opacity(0.1) : Color.clear
                    )
                }
            }
        }
        .navigationTitle(journal?.name ?? "Entries")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewEntry = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showingNewEntry) {
            EntryView(journal: journal)
        }
    }
    
    private func selectEntry(_ entry: (day: String, date: String, title: String, preview: String, time: String, month: Int, year: Int)) {
        // Create date from components
        var components = DateComponents()
        components.year = entry.year
        components.month = entry.month
        components.day = Int(entry.date)
        let date = Calendar.current.date(from: components) ?? Date()
        
        // Create full content
        let fullContent = generateFullContent(for: entry.title, preview: entry.preview)
        
        selectedEntry = EntryView.EntryData(
            title: entry.title,
            content: fullContent,
            date: date,
            time: entry.time
        )
    }
    
    private func generateFullContent(for title: String, preview: String) -> String {
        if title.contains("lunch with Emily") {
            return """
Had a wonderful lunch with Emily today.

It's refreshing to step away from the daily grind and catch up with old friends. We talked about her new job at the tech startup, my recent travels, and how much has changed since college. Time flies but good friendships remain constant.

We went to that little Italian place downtown that we used to love. The food was just as good as I remembered - I had the seafood linguine and Emily got her usual margherita pizza. We split a tiramisu for dessert, just like old times.

The best part was just being able to talk without any agenda. No work calls, no rushing to the next meeting. Just two friends catching up over good food and wine. We laughed about old memories and made plans to not let so much time pass before our next get-together.

Days like this remind me how important it is to nurture these relationships. Work will always be there, but friends like Emily are rare and precious.
"""
        } else if title.contains("Morning run") {
            return """
Morning run through the park

Felt energized after a good night's sleep. The weather was perfect for running and I managed to do my full 5K route without stopping. The park was peaceful at this early hour, with just a few other runners and dog walkers out.

I love how the morning light filters through the trees along the main path. There's something magical about being out there when the day is just beginning. My pace was steady - not trying to break any records, just enjoying the movement and the fresh air.

Saw the usual group of older folks doing tai chi by the pond. Always makes me smile. There's such a nice community feel to the park in the mornings. Everyone waves or nods as they pass by.

Finished with some stretching by the fountain. Feeling ready to tackle whatever the day brings!
"""
        } else {
            return title + "\n\n" + preview.replacingOccurrences(of: "...", with: ".")
        }
    }
}

// MARK: - Entry Row Content
struct EntryRowContent: View {
    let day: String
    let date: String
    let title: String
    let preview: String
    let time: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 2) {
                Text(day)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(date)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    JournalsSplitView()
}