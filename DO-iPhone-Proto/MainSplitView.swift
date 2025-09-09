import SwiftUI

// MARK: - Navigation Items
enum NavigationItem: String, CaseIterable {
    case today = "Today"
    case journals = "Journals"
    case prompts = "Prompts"
    case more = "More"
    
    var icon: String {
        switch self {
        case .today:
            return "calendar"
        case .journals:
            return "book"
        case .prompts:
            return "lightbulb"
        case .more:
            return "ellipsis"
        }
    }
    
    var dayOneIcon: DayOneIcon {
        switch self {
        case .today:
            return .calendar
        case .journals:
            return .book
        case .prompts:
            return .prompt
        case .more:
            return .dots_horizontal
        }
    }
}

// MARK: - Main Split View for iPad
struct MainSplitView: View {
    @State private var selectedItem: NavigationItem? = .today
    @State private var selectedJournal: Journal?
    @State private var selectedEntry: EntryView.EntryData?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var showingSettings = false
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            sidebarContent
        } detail: {
            // Detail view based on selection
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Sidebar Content
    @ViewBuilder
    private var sidebarContent: some View {
        List(selection: $selectedItem) {
            // Profile button at the top
            Section {
                Button {
                    showingSettings = true
                } label: {
                    HStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("PM")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Paul Mayne")
                                .font(.headline)
                            Text("View Profile")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }
            
            // Navigation items
            Section {
                ForEach(NavigationItem.allCases, id: \.self) { item in
                    Label {
                        Text(item.rawValue)
                    } icon: {
                        Image(dayOneIcon: item.dayOneIcon)
                            .foregroundColor(.primary)
                    }
                    .tag(item)
                }
            }
            
            // Always show journals list on iPad
            Section("My Journals") {
                // All Entries option
                if Journal.visibleJournals.count > 1 {
                    let allEntriesJournal = Journal(
                        name: "All Entries",
                        color: Color(hex: "333B40"),
                        entryCount: Journal.visibleJournals.reduce(0) { $0 + ($1.entryCount ?? 0) }
                    )
                    
                    Button {
                        selectedJournal = allEntriesJournal
                        // Automatically switch to Journals tab when a journal is selected
                        if selectedItem != .journals {
                            selectedItem = .journals
                        }
                    } label: {
                        HStack {
                            Circle()
                                .fill(allEntriesJournal.color)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text(allEntriesJournal.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                if let count = allEntriesJournal.entryCount {
                                    Text("\(count) entries")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        selectedJournal?.name == allEntriesJournal.name && selectedItem == .journals ?
                        Color.accentColor.opacity(0.1) : Color.clear
                    )
                }
                
                // Individual journals
                ForEach(Journal.visibleJournals) { journal in
                    Button {
                        selectedJournal = journal
                        // Automatically switch to Journals tab when a journal is selected
                        if selectedItem != .journals {
                            selectedItem = .journals
                        }
                    } label: {
                        HStack {
                            Circle()
                                .fill(journal.color)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading) {
                                Text(journal.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                if let count = journal.entryCount {
                                    Text("\(count) entries")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        selectedJournal?.id == journal.id && selectedItem == .journals ?
                        Color.accentColor.opacity(0.1) : Color.clear
                    )
                }
            }
            
            // Search section
            Section {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search", text: $searchQuery)
                        .textFieldStyle(.plain)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .navigationTitle("Day One")
        .listStyle(.sidebar)
    }
    
    // MARK: - Detail Content
    @ViewBuilder
    private var detailContent: some View {
        Group {
            switch selectedItem {
            case .today:
                NavigationStack {
                    TodayView()
                }
            case .journals:
                // Show journal detail split view when a journal is selected
                if selectedJournal != nil {
                    JournalDetailSplitView(
                        selectedJournal: $selectedJournal,
                        selectedEntry: $selectedEntry
                    )
                } else {
                    // Show empty state if no journal is selected yet
                    NavigationStack {
                        ContentUnavailableView(
                            "Select a Journal",
                            systemImage: "book.closed",
                            description: Text("Choose a journal from the sidebar to view entries")
                        )
                    }
                }
            case .prompts:
                NavigationStack {
                    PromptsView()
                }
            case .more:
                NavigationStack {
                    MoreView()
                }
            case .none:
                NavigationStack {
                    ContentUnavailableView(
                        "Select an Item",
                        systemImage: "sidebar.left",
                        description: Text("Choose an item from the sidebar to get started")
                    )
                }
            }
        }
        .id(selectedItem) // Force view refresh on selection change
    }
}

#Preview {
    MainSplitView()
}