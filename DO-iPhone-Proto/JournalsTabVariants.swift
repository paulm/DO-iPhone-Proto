import SwiftUI

// MARK: - Multi-Column Journals View
struct JournalsTabMultiColumnView: View {
    @State private var journalViewModel = JournalSelectionViewModel()
    @State private var showingSettings = false
    @State private var selectedJournal: Journal?
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var searchText = ""
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Filtered journals based on search text
    private var filteredJournals: [Journal] {
        if searchText.isEmpty {
            return Journal.visibleJournals
        } else {
            return Journal.visibleJournals.filter { journal in
                journal.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // Multi-column layout for iPad/larger screens
                multiColumnLayout
            } else {
                // Fall back to paged view for compact devices
                JournalsTabPagedView()
            }
        }
    }
    
    @ViewBuilder
    private var multiColumnLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar with journal list
            sidebarContent
                .navigationSplitViewColumnWidth(min: 300, ideal: 350, max: 400)
        } detail: {
            // Detail view with journal content
            if let journal = selectedJournal {
                JournalDetailMultiColumnView(journal: journal)
            } else {
                JournalDetailMultiColumnView(journal: journalViewModel.selectedJournal)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private var sidebarContent: some View {
        List(selection: $selectedJournal) {
            // Search bar is handled by .searchable modifier
            
            // All Entries option (if multiple journals exist)
            if filteredJournals.count > 1 && (searchText.isEmpty || "All Entries".localizedCaseInsensitiveContains(searchText)) {
                let allEntriesJournal = Journal(
                    name: "All Entries",
                    color: Color(hex: "333B40"),
                    entryCount: filteredJournals.reduce(0) { $0 + ($1.entryCount ?? 0) }
                )
                
                NavigationLink(value: allEntriesJournal) {
                    JournalSidebarRow(journal: allEntriesJournal)
                }
            }
            
            // Individual journals
            ForEach(filteredJournals) { journal in
                NavigationLink(value: journal) {
                    JournalSidebarRow(journal: journal)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Journals")
        .searchable(text: $searchText, placement: .sidebar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingSettings = true
                }) {
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: Add new journal action
                }) {
                    Image(systemName: "plus")
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                Button("Edit") {
                    // TODO: Edit journals action
                }
            }
        }
        .onChange(of: selectedJournal) { _, newValue in
            if let journal = newValue {
                journalViewModel.selectJournal(journal)
            }
        }
    }
}

// MARK: - Journal Sidebar Row
struct JournalSidebarRow: View {
    let journal: Journal
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            Circle()
                .fill(journal.color)
                .frame(width: 20, height: 20)
            
            // Journal info
            VStack(alignment: .leading, spacing: 2) {
                Text(journal.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if let count = journal.entryCount {
                    Text("\(count) entries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Multi-Column Journal Detail View
struct JournalDetailMultiColumnView: View {
    let journal: Journal
    @State private var selectedTab = 1
    @State private var showingEntryView = false
    @State private var showingEditView = false
    
    var body: some View {
        ZStack {
            // Background color
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with journal info
                journalHeader
                
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Cover").tag(0)
                    Text("List").tag(1)
                    Text("Calendar").tag(2)
                    Text("Media").tag(3)
                    Text("Map").tag(4)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case 0:
                        CoverTabView()
                    case 1:
                        ListTabView(journal: journal)
                    case 2:
                        CalendarTabView(journal: journal)
                    case 3:
                        MediaTabView()
                    case 4:
                        MapTabView()
                    default:
                        ListTabView(journal: journal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditView = true
                    }) {
                        Label("Edit Journal", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        // TODO: Preview Book action
                    }) {
                        Label("Preview Book", systemImage: "book")
                    }
                    
                    Button(action: {
                        // TODO: Export action
                    }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEntryView) {
            EntryView(journal: journal)
        }
        .sheet(isPresented: $showingEditView) {
            EditJournalMultiColumnView(journal: journal)
        }
        .overlay(alignment: .bottomTrailing) {
            // FAB
            Button(action: {
                showingEntryView = true
            }) {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(journal.color)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
    }
    
    private var journalHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(journal.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                if let count = journal.entryCount {
                    Text("\(count) entries")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Journal color indicator
            Circle()
                .fill(journal.color)
                .frame(width: 40, height: 40)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
    }
}

// MARK: - Edit Journal Multi-Column View
struct EditJournalMultiColumnView: View {
    @Environment(\.dismiss) private var dismiss
    let journal: Journal
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Journal Settings") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(journal.name)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Color")
                        Spacer()
                        Circle()
                            .fill(journal.color)
                            .frame(width: 24, height: 24)
                    }
                }
                
                if !journal.appearance.originalCoverImageData.isEmpty {
                    Section("Appearance") {
                        HStack {
                            Text("Cover Image")
                            Spacer()
                            Text(journal.appearance.originalCoverImageData)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section {
                    Text("Journal editing functionality would be implemented here")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview("Multi-Column") {
    JournalsTabMultiColumnView()
}