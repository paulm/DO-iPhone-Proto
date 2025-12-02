import SwiftUI
import UIKit
import TipKit

// MARK: - View Mode Enum

enum ViewMode: Int, CaseIterable {
    case compact = 0
    case list = 1
    case grid = 2
}

// MARK: - Journals Population Enum

enum JournalsPopulation: String, CaseIterable {
    case newUser = "New User"
    case threeJournals = "3 Journals"
    case lots = "Lots"
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

struct JournalsTabPagedView: View {
    @Environment(JournalSelectionViewModel.self) private var journalViewModel
    @State private var showingSettings = false
    @State private var viewMode: ViewMode = .list // Default to Icons view
    @State private var selectedJournal: Journal?
    @State private var selectedFolder: JournalFolder?
    @State private var showingNewEntry = false
    @State private var shouldShowAudioAfterEntry = false
    @State private var showRecentJournals = true
    @State private var showRecentEntries = false
    @State private var recentJournalsExpanded = true
    @State private var recentEntriesExpanded = true
    @State private var isEditMode = false
    @State private var journalItems: [Journal.MixedJournalItem] = Journal.mixedJournalItems
    @State private var useSeparatedCollections = false
    @State private var journalsPopulation: JournalsPopulation = .lots
    @State private var showAddJournalTips = false
    @State private var addNotesJournalTip = AddNotesJournalTip()
    @State private var addWorkJournalTip = AddWorkJournalTip()
    @State private var addTravelJournalTip = AddTravelJournalTip()
    @State private var manuallyAddedJournalNames: Set<String> = []
    @State private var dismissedJournalTips: Set<String> = [] // Track dismissed tips by journal name

    // Folder expansion state - expand all by default
    @State private var expandedFolders: Set<String> = Set(Journal.folders.map { $0.id })

    // Sheet regular position from top (in points)
    let sheetRegularPosition: CGFloat = 250

    // Get visible journals and folders based on population setting
    private var filteredJournals: [Journal] {
        let allJournals = Journal.sampleJournals
        var baseJournals: [Journal]

        switch journalsPopulation {
        case .newUser:
            // Return only the first journal ("Journal")
            baseJournals = Array(allJournals.prefix(1))
        case .threeJournals:
            // Return Journal, Notes, Daily (first 3 journals)
            baseJournals = Array(allJournals.prefix(3))
        case .lots:
            // Return all journals
            baseJournals = allJournals
        }

        // Add manually added journals that aren't already in the base list
        let baseJournalNames = Set(baseJournals.map { $0.name })
        let manuallyAddedJournals = allJournals.filter { journal in
            manuallyAddedJournalNames.contains(journal.name) && !baseJournalNames.contains(journal.name)
        }

        return baseJournals + manuallyAddedJournals
    }

    private var filteredFolders: [JournalFolder] {
        switch journalsPopulation {
        case .newUser, .threeJournals:
            // No folders for simplified modes
            return []
        case .lots:
            // Return all folders
            return Journal.folders
        }
    }

    private var filteredMixedJournalItems: [Journal.MixedJournalItem] {
        // For newUser and threeJournals modes, only show standalone journals (no folders)
        switch journalsPopulation {
        case .newUser, .threeJournals:
            // Create mixed items from filtered journals only
            return filteredJournals.map { Journal.MixedJournalItem(journal: $0) }
        case .lots:
            // Return all mixed items (journals and folders)
            return Journal.mixedJournalItems
        }
    }

    // Should show All Entries only when there are 2 or more journals
    private var shouldShowAllEntries: Bool {
        return filteredJournals.count > 1
    }

    // Check if specific journals exist in filtered journals
    private var hasNotesJournal: Bool {
        return filteredJournals.contains(where: { $0.name == "Notes" })
    }

    private var hasWorkJournal: Bool {
        return filteredJournals.contains(where: { $0.name == "Work Notes" })
    }

    private var hasTravelJournal: Bool {
        return filteredJournals.contains(where: { $0.name == "Travel" })
    }

    // Determine which tip to show based on progression
    // Order: Notes -> Work -> Travel
    private enum CurrentJournalTip {
        case notes
        case work
        case travel
        case none
    }

    private var currentJournalTip: CurrentJournalTip {
        // Check Notes first
        if !hasNotesJournal && !dismissedJournalTips.contains("Notes") {
            return .notes
        }
        // Then Work
        if !hasWorkJournal && !dismissedJournalTips.contains("Work Notes") {
            return .work
        }
        // Then Travel
        if !hasTravelJournal && !dismissedJournalTips.contains("Travel") {
            return .travel
        }
        return .none
    }

    // Colors for each journal tip
    private var currentTipColor: Color {
        switch currentJournalTip {
        case .notes:
            return Color(hex: "FFC107") // Honey
        case .work:
            return Color(hex: "2DCC71") // Green
        case .travel:
            return Color(hex: "16D6D9") // Aqua
        case .none:
            return .blue
        }
    }

    private var folders: [JournalFolder] {
        return filteredFolders
    }

    private var unfolderedJournals: [Journal] {
        return Journal.unfolderedJournals
    }

    // Method to add a journal by name
    private func addJournal(named name: String) {
        // Add to manually added journals
        manuallyAddedJournalNames.insert(name)

        // Select the journal
        if let journal = Journal.sampleJournals.first(where: { $0.name == name }) {
            journalViewModel.selectJournal(journal)
        }
    }

    // Method to dismiss a journal tip
    private func dismissJournalTip(named name: String) {
        dismissedJournalTips.insert(name)
    }

    var body: some View {
        navigationContent
        .sheet(isPresented: $showingNewEntry) {
            EntryView(
                journal: journalViewModel.selectedJournal,
                shouldShowAudioOnAppear: shouldShowAudioAfterEntry,
                startInEditMode: true
            )
            .onDisappear {
                shouldShowAudioAfterEntry = false
            }
        }
    }
    
    // MARK: - Navigation Content
    private var navigationContent: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Journal content based on view mode
                    journalListContent
                        .padding(.top, 12)
                }
            }
            .navigationTitle("Journals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            isEditMode.toggle()
                        }) {
                            Label(isEditMode ? "Done" : "Edit", systemImage: isEditMode ? "checkmark" : "pencil")
                        }
                        
                        Button(action: {
                            // TODO: Select multiple journals action
                        }) {
                            Label("Select", systemImage: "checkmark.circle")
                        }
                        
                        Button(action: {
                            // TODO: Add new journal action
                        }) {
                            Label("New Journal", systemImage: "plus")
                        }
                        
                        Divider()

                        Picker("View Style", selection: $viewMode) {
                            Label("List", systemImage: "list.bullet")
                                .tag(ViewMode.compact)
                            Label("Icons", systemImage: "square.grid.3x3")
                                .tag(ViewMode.list)
                            Label("Books", systemImage: "books.vertical")
                                .tag(ViewMode.grid)
                        }

                        Divider()

                        Toggle(isOn: $showRecentJournals) {
                            Label("Show Recent Journals", systemImage: "clock")
                        }

                        Toggle(isOn: $showRecentEntries) {
                            Label("Show Recent Entries", systemImage: "doc.text")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    
                    Menu {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Label("Settings", systemImage: "gearshape")
                        }

                        Divider()

                        Section("Journal Manager Options") {
                            Toggle(isOn: $useSeparatedCollections) {
                                Label("Separated Collections", systemImage: "folder.badge.gearshape")
                            }

                            Toggle(isOn: $showAddJournalTips) {
                                Label("Show Add Journal Tips", systemImage: "lightbulb")
                            }
                        }

                        Section("Journals Population") {
                            Picker("Population", selection: $journalsPopulation) {
                                ForEach(JournalsPopulation.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .pickerStyle(.inline)
                        }
                    } label: {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("PM")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .navigationDestination(item: $selectedJournal) { journal in
                JournalDetailPagedView(journal: journal, journalViewModel: journalViewModel, sheetRegularPosition: sheetRegularPosition)
            }
            .navigationDestination(item: $selectedFolder) { folder in
                FolderDetailView(folder: folder, sheetRegularPosition: sheetRegularPosition)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Journal List Content
    @ViewBuilder
    private var journalListContent: some View {
        switch viewMode {
        case .compact:
            listModeView
        case .list:
            iconsModeView
        case .grid:
            gridJournalList
        }
    }
    
    private var listModeView: some View {
        LazyVStack(spacing: 4) {
            // Recent Journals horizontal scroll section
            if showRecentJournals {
                VStack(alignment: .leading, spacing: 12) {
                    // Toggleable header with disclosure arrow
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            recentJournalsExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Recent Journals")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(recentJournalsExpanded ? 90 : 0))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    if recentJournalsExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recentJournals) { journal in
                                    RecentJournalBookView(
                                        journal: journal,
                                        isSelected: false,
                                        onSelect: {
                                            journalViewModel.selectJournal(journal)
                                            selectedJournal = journal
                                        },
                                        onNewEntry: {
                                            journalViewModel.selectJournal(journal)
                                            showingNewEntry = true
                                        }
                                    )
                                    .frame(width: 70)
                                }
                            }
                            .padding(.leading, 0)
                        }
                    }
                }
                .padding(.bottom, 16)
            }

            // Recent Entries horizontal scroll section
            if showRecentEntries {
                VStack(alignment: .leading, spacing: 12) {
                    // Toggleable header with disclosure arrow
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            recentEntriesExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Recent Entries")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(recentEntriesExpanded ? 90 : 0))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    if recentEntriesExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recentEntries) { entry in
                                    RecentEntryCard(entry: entry)
                                        .frame(width: 108)
                                }
                            }
                            .padding(.trailing)
                        }
                    }
                }
                .padding(.bottom, 16)
            }

            // All Entries navigation row (only show if more than one journal)
            if let allEntries = Journal.allEntriesJournal, Journal.visibleJournals.count > 1 {
                Button(action: {
                    journalViewModel.selectJournal(allEntries)
                    selectedJournal = allEntries
                }) {
                    HStack {
                        Text("All Entries")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 16)
            }

            // Journals section header
            Text("Journals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            if useSeparatedCollections {
                // Show only journals (no folders mixed in)
                ForEach(filteredMixedJournalItems) { item in
                    if let journal = item.journal {
                        CompactJournalRow(
                            journal: journal,
                            isSelected: journal.id == journalViewModel.selectedJournal.id,
                            onSelect: {
                                journalViewModel.selectJournal(journal)
                                selectedJournal = journal
                            }
                        )
                    }
                }

                // Collections section header (only show if there are folders)
                if !filteredFolders.isEmpty {
                    Text("Collections")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                }

                // Show folders separately
                ForEach(folders) { folder in
                    CompactFolderRow(
                        folder: folder,
                        isExpanded: expandedFolders.contains(folder.id),
                        onToggle: {
                            if expandedFolders.contains(folder.id) {
                                expandedFolders.remove(folder.id)
                            } else {
                                expandedFolders.insert(folder.id)
                            }
                        },
                        onSelectFolder: {
                            selectedFolder = folder
                        }
                    )

                    // Show journals inside expanded folder
                    if expandedFolders.contains(folder.id) {
                        ForEach(folder.journals) { journal in
                            CompactJournalRow(
                                journal: journal,
                                isSelected: journal.id == journalViewModel.selectedJournal.id,
                                onSelect: {
                                    journalViewModel.selectJournal(journal)
                                    selectedJournal = journal
                                }
                            )
                            .padding(.leading, 20) // Indent journals inside folders
                        }
                    }
                }
            } else {
                // Mixed folders and journals (original behavior)
                ForEach(filteredMixedJournalItems) { item in
                    if item.isFolder, let folder = item.folder {
                        CompactFolderRow(
                            folder: folder,
                            isExpanded: expandedFolders.contains(folder.id),
                            onToggle: {
                                if expandedFolders.contains(folder.id) {
                                    expandedFolders.remove(folder.id)
                                } else {
                                    expandedFolders.insert(folder.id)
                                }
                            },
                            onSelectFolder: {
                                selectedFolder = folder
                            }
                        )

                        // Show journals inside expanded folder
                        if expandedFolders.contains(folder.id) {
                            ForEach(folder.journals) { journal in
                                CompactJournalRow(
                                    journal: journal,
                                    isSelected: journal.id == journalViewModel.selectedJournal.id,
                                    onSelect: {
                                        journalViewModel.selectJournal(journal)
                                        selectedJournal = journal
                                    }
                                )
                                .padding(.leading, 20) // Indent journals inside folders
                            }
                        }
                    } else if let journal = item.journal {
                        CompactJournalRow(
                            journal: journal,
                            isSelected: journal.id == journalViewModel.selectedJournal.id,
                            onSelect: {
                                journalViewModel.selectJournal(journal)
                                selectedJournal = journal
                            }
                        )
                    }
                }
            }

            // New Collection and New Journal buttons
            HStack(spacing: 12) {
                // New Collection button
                Button(action: {
                    // TODO: Add new collection action
                }) {
                    HStack(spacing: 8) {
                        Text(dayOneIcon: .folder_add)
                            .font(.dayOneIcons(size: 18))
                        Text("New Collection")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // New Journal button
                Button(action: {
                    // TODO: Add new journal action
                }) {
                    HStack(spacing: 8) {
                        Text(dayOneIcon: .plus_circle)
                            .font(.dayOneIcons(size: 18))
                        Text("New Journal")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.top, 16)

            // Trash row (Icons mode - simple style)
            Button(action: {
                // TODO: Show trash
            }) {
                HStack(spacing: 12) {
                    // Trash icon (instead of colored circle)
                    Text(dayOneIcon: .trash)
                        .font(.dayOneIcons(size: 12))
                        .foregroundStyle(.secondary)

                    // Trash label
                    Text("Trash")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(.primary)

                    Spacer()

                    // Entry count (just the number)
                    Text("12")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 0)
            }
            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                Button(action: {
                    // TODO: Empty trash action
                }) {
                    Label("Empty Trash", systemImage: "trash")
                }
            }
            .padding(.top, 16)

            // TipKit tip for adding journals (progression: Notes -> Work -> Travel)
            if showAddJournalTips && currentJournalTip != .none {
                Group {
                    switch currentJournalTip {
                    case .notes:
                        TipView(addNotesJournalTip) { action in
                            if action.id == "add" {
                                addJournal(named: "Notes")
                            } else if action.id == "dismiss" {
                                dismissJournalTip(named: "Notes")
                            }
                        }
                    case .work:
                        TipView(addWorkJournalTip) { action in
                            if action.id == "add" {
                                addJournal(named: "Work Notes")
                            } else if action.id == "dismiss" {
                                dismissJournalTip(named: "Work Notes")
                            }
                        }
                    case .travel:
                        TipView(addTravelJournalTip) { action in
                            if action.id == "add" {
                                addJournal(named: "Travel")
                            } else if action.id == "dismiss" {
                                dismissJournalTip(named: "Travel")
                            }
                        }
                    case .none:
                        EmptyView()
                    }
                }
                .tint(currentTipColor)
                .padding(.top, 16)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 100)
    }

    // Recent journals for horizontal scroll - pick from filtered journals, always including Journal, Work Notes, Daily (if available)
    private var recentJournals: [Journal] {
        var recents: [Journal] = []

        // Always include these three if available
        if let journal = filteredJournals.first(where: { $0.name == "Journal" }) {
            recents.append(journal)
        }
        if let workNotes = filteredJournals.first(where: { $0.name == "Work Notes" }) {
            recents.append(workNotes)
        }
        if let daily = filteredJournals.first(where: { $0.name == "Daily" }) {
            recents.append(daily)
        }

        // Add a few more from the available journals
        let remaining = filteredJournals.filter { journal in
            !["Journal", "Work Notes", "Daily"].contains(journal.name)
        }
        recents.append(contentsOf: remaining.prefix(3))

        return recents
    }

    private var recentEntries: [JournalEntry] {
        // Sample recent entries from various journals
        return [
            JournalEntry(
                id: UUID().uuidString,
                title: "Morning Coffee Thoughts",
                preview: "Started the day with a perfect cup of coffee and some reflection on the week ahead...",
                date: "Today",
                time: "8:30 AM",
                journalName: "Journal",
                journalColor: Color(hex: "44C0FF")
            ),
            JournalEntry(
                id: UUID().uuidString,
                title: "Project Planning Session",
                preview: "Met with the team to discuss Q4 goals. We're aligned on the key deliverables...",
                date: "Yesterday",
                time: "2:15 PM",
                journalName: "Work Notes",
                journalColor: Color(hex: "FF6B6B")
            ),
            JournalEntry(
                id: UUID().uuidString,
                title: "Evening Walk",
                preview: "Beautiful sunset walk through the neighborhood. The weather was perfect...",
                date: "Yesterday",
                time: "6:45 PM",
                journalName: "Daily",
                journalColor: Color(hex: "4ECDC4")
            ),
            JournalEntry(
                id: UUID().uuidString,
                title: "Weekend Plans",
                preview: "Looking forward to hiking this weekend. Need to check the weather forecast...",
                date: "2 days ago",
                time: "9:20 AM",
                journalName: "Journal",
                journalColor: Color(hex: "44C0FF")
            ),
            JournalEntry(
                id: UUID().uuidString,
                title: "Design Review Notes",
                preview: "Reviewed the new UI mockups. The color scheme looks great but we need to adjust...",
                date: "3 days ago",
                time: "3:00 PM",
                journalName: "Work Notes",
                journalColor: Color(hex: "FF6B6B")
            )
        ]
    }

    private var iconsModeView: some View {
        LazyVStack(spacing: 4) {
            // Recent Journals horizontal scroll section
            if showRecentJournals {
                VStack(alignment: .leading, spacing: 12) {
                    // Toggleable header with disclosure arrow
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            recentJournalsExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Recent Journals")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(recentJournalsExpanded ? 90 : 0))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    if recentJournalsExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recentJournals) { journal in
                                    RecentJournalBookView(
                                        journal: journal,
                                        isSelected: false,
                                        onSelect: {
                                            journalViewModel.selectJournal(journal)
                                            selectedJournal = journal
                                        },
                                        onNewEntry: {
                                            journalViewModel.selectJournal(journal)
                                            showingNewEntry = true
                                        }
                                    )
                                    .frame(width: 70)
                                }
                            }
                            .padding(.leading, 0)
                        }
                    }
                }
                .padding(.bottom, 16)
            }

            // Recent Entries horizontal scroll section
            if showRecentEntries {
                VStack(alignment: .leading, spacing: 12) {
                    // Toggleable header with disclosure arrow
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            recentEntriesExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Recent Entries")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(recentEntriesExpanded ? 90 : 0))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    if recentEntriesExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recentEntries) { entry in
                                    RecentEntryCard(entry: entry)
                                        .frame(width: 108)
                                }
                            }
                            .padding(.trailing)
                        }
                    }
                }
                .padding(.bottom, 16)
            }

            // All Entries navigation row (only show if more than one journal)
            if let allEntries = Journal.allEntriesJournal, Journal.visibleJournals.count > 1 {
                Button(action: {
                    journalViewModel.selectJournal(allEntries)
                    selectedJournal = allEntries
                }) {
                    HStack {
                        Text("All Entries")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 16)
            }

            // Journals section header
            Text("Journals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            if useSeparatedCollections {
                // Show only journals (no folders mixed in)
                ForEach(filteredMixedJournalItems) { item in
                    if let journal = item.journal {
                        JournalRow(
                            journal: journal,
                            isSelected: journal.id == journalViewModel.selectedJournal.id,
                            isEditMode: isEditMode,
                            onSelect: {
                                journalViewModel.selectJournal(journal)
                                selectedJournal = journal
                            }
                        )
                    }
                }
                .onMove { indices, newOffset in
                    journalItems.move(fromOffsets: indices, toOffset: newOffset)
                }

                // Collections section header (only show if there are folders)
                if !filteredFolders.isEmpty {
                    Text("Collections")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                }

                // Show folders separately
                ForEach(folders) { folder in
                    FolderRow(
                        folder: folder,
                        isExpanded: expandedFolders.contains(folder.id),
                        isEditMode: isEditMode,
                        onToggle: {
                            withAnimation {
                                if expandedFolders.contains(folder.id) {
                                    expandedFolders.remove(folder.id)
                                } else {
                                    expandedFolders.insert(folder.id)
                                }
                            }
                        },
                        onSelectFolder: {
                            selectedFolder = folder
                        }
                    )
                    .id(folder.id)

                    // Show journals inside expanded folder
                    if expandedFolders.contains(folder.id) {
                        ForEach(folder.journals) { journal in
                            JournalRow(
                                journal: journal,
                                isSelected: journal.id == journalViewModel.selectedJournal.id,
                                isEditMode: isEditMode,
                                onSelect: {
                                    journalViewModel.selectJournal(journal)
                                    selectedJournal = journal
                                }
                            )
                            .padding(.leading, 20) // Indent journals inside folders
                        }
                    }
                }
            } else {
                // Mixed folders and journals (original behavior)
                ForEach(filteredMixedJournalItems) { item in
                    if item.isFolder, let folder = item.folder {
                        FolderRow(
                            folder: folder,
                            isExpanded: expandedFolders.contains(folder.id),
                            isEditMode: isEditMode,
                            onToggle: {
                                withAnimation {
                                    if expandedFolders.contains(folder.id) {
                                        expandedFolders.remove(folder.id)
                                    } else {
                                        expandedFolders.insert(folder.id)
                                    }
                                }
                            },
                            onSelectFolder: {
                                selectedFolder = folder
                            }
                        )
                        .id(folder.id)

                        // Show journals inside expanded folder
                        if expandedFolders.contains(folder.id) {
                            ForEach(folder.journals) { journal in
                                JournalRow(
                                    journal: journal,
                                    isSelected: journal.id == journalViewModel.selectedJournal.id,
                                    isEditMode: isEditMode,
                                    onSelect: {
                                        journalViewModel.selectJournal(journal)
                                        selectedJournal = journal
                                    }
                                )
                                .padding(.leading, 20) // Indent journals inside folders
                            }
                        }
                    } else if let journal = item.journal {
                        JournalRow(
                            journal: journal,
                            isSelected: journal.id == journalViewModel.selectedJournal.id,
                            isEditMode: isEditMode,
                            onSelect: {
                                journalViewModel.selectJournal(journal)
                                selectedJournal = journal
                            }
                        )
                    }
                }
                .onMove { indices, newOffset in
                    journalItems.move(fromOffsets: indices, toOffset: newOffset)
                }
            }

            // New Collection and New Journal buttons
            HStack(spacing: 12) {
                // New Collection button
                Button(action: {
                    // TODO: Add new collection action
                }) {
                    HStack(spacing: 8) {
                        Text(dayOneIcon: .folder_add)
                            .font(.dayOneIcons(size: 18))
                        Text("New Collection")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // New Journal button
                Button(action: {
                    // TODO: Add new journal action
                }) {
                    HStack(spacing: 8) {
                        Text(dayOneIcon: .plus_circle)
                            .font(.dayOneIcons(size: 18))
                        Text("New Journal")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.top, 16)

            // Trash row (List mode - book shape style)
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: {
                        // TODO: Show trash
                    }) {
                        HStack(spacing: 16) {
                            // Book shape with trash icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray4))
                                    .frame(width: 30, height: 40)
                                    .overlay(
                                        // Vertical line inset 2pt from left
                                        GeometryReader { geometry in
                                            Rectangle()
                                                .fill(Color.black.opacity(0.1))
                                                .frame(width: 1)
                                                .offset(x: 3)
                                        }
                                    )

                                Text(dayOneIcon: .trash)
                                    .font(.dayOneIcons(size: 14))
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Trash")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)

                                Text("12 entries")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Menu {
                        Button(action: {
                            // TODO: Empty trash action
                        }) {
                            Label("Empty Trash", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 0)
                .padding(.bottom, 4)

                Divider()
                    .padding(.leading, 0)
            }
            .padding(.top, 16)

            // TipKit tip for adding journals (progression: Notes -> Work -> Travel)
            if showAddJournalTips && currentJournalTip != .none {
                Group {
                    switch currentJournalTip {
                    case .notes:
                        TipView(addNotesJournalTip) { action in
                            if action.id == "add" {
                                addJournal(named: "Notes")
                            } else if action.id == "dismiss" {
                                dismissJournalTip(named: "Notes")
                            }
                        }
                    case .work:
                        TipView(addWorkJournalTip) { action in
                            if action.id == "add" {
                                addJournal(named: "Work Notes")
                            } else if action.id == "dismiss" {
                                dismissJournalTip(named: "Work Notes")
                            }
                        }
                    case .travel:
                        TipView(addTravelJournalTip) { action in
                            if action.id == "add" {
                                addJournal(named: "Travel")
                            } else if action.id == "dismiss" {
                                dismissJournalTip(named: "Travel")
                            }
                        }
                    case .none:
                        EmptyView()
                    }
                }
                .tint(currentTipColor)
                .padding(.top, 16)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 100)
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
    }

    private var gridJournalList: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
            // All Entries at the top (only show when there are 2+ journals)
            if shouldShowAllEntries, let allEntries = Journal.allEntriesJournal {
                JournalBookView(
                    journal: allEntries,
                    isSelected: allEntries.id == journalViewModel.selectedJournal.id,
                    onSelect: {
                        journalViewModel.selectJournal(allEntries)
                        selectedJournal = allEntries
                    },
                    onNewEntry: {
                        journalViewModel.selectJournal(allEntries)
                        showingNewEntry = true
                    }
                )
            }

            // Mixed folders and journals for Books view
            // Note: Books view doesn't support expand/collapse, just shows all journals flat
            ForEach(filteredMixedJournalItems) { item in
                if item.isFolder, let folder = item.folder {
                    // Show folder journals in Books view
                    ForEach(folder.journals) { journal in
                        JournalBookView(
                            journal: journal,
                            isSelected: journal.id == journalViewModel.selectedJournal.id,
                            onSelect: {
                                journalViewModel.selectJournal(journal)
                                selectedJournal = journal
                            },
                            onNewEntry: {
                                journalViewModel.selectJournal(journal)
                                showingNewEntry = true
                            }
                        )
                    }
                } else if let journal = item.journal {
                    JournalBookView(
                        journal: journal,
                        isSelected: journal.id == journalViewModel.selectedJournal.id,
                        onSelect: {
                            journalViewModel.selectJournal(journal)
                            selectedJournal = journal
                        },
                        onNewEntry: {
                            journalViewModel.selectJournal(journal)
                            showingNewEntry = true
                        }
                    )
                }
            }

            // TipKit tip for adding journals (progression: Notes -> Work -> Travel)
            if showAddJournalTips && currentJournalTip != .none {
                Group {
                    switch currentJournalTip {
                    case .notes:
                        TipView(addNotesJournalTip) { action in
                            if action.id == "add" {
                                addJournal(named: "Notes")
                            } else if action.id == "dismiss" {
                                dismissJournalTip(named: "Notes")
                            }
                        }
                    case .work:
                        TipView(addWorkJournalTip) { action in
                            if action.id == "add" {
                                addJournal(named: "Work Notes")
                            } else if action.id == "dismiss" {
                                dismissJournalTip(named: "Work Notes")
                            }
                        }
                    case .travel:
                        TipView(addTravelJournalTip) { action in
                            if action.id == "add" {
                                addJournal(named: "Travel")
                            } else if action.id == "dismiss" {
                                dismissJournalTip(named: "Travel")
                            }
                        }
                    case .none:
                        EmptyView()
                    }
                }
                .tint(currentTipColor)
                .padding(.top, 16)
                .gridCellColumns(3) // Span across all 3 columns
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 100)
    }
}

struct JournalDetailPagedView: View {
    let journal: Journal
    let journalViewModel: JournalSelectionViewModel
    let sheetRegularPosition: CGFloat
    @State private var showingEditView = false
    @State private var showingSettings = false
    @State private var useStandardController = false
    @State private var showCoverImage: Bool
    @StateObject private var sheetState = SheetState()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var useLargeListDates = false

    init(journal: Journal, journalViewModel: JournalSelectionViewModel, sheetRegularPosition: CGFloat) {
        self.journal = journal
        self.journalViewModel = journalViewModel
        self.sheetRegularPosition = sheetRegularPosition
        // Show cover image by default only for Dreams journal
        _showCoverImage = State(initialValue: journal.name == "Dreams")
    }
    
    // Computed properties for orientation-specific values
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var mediumDetentHeight: CGFloat {
        isLandscape ? 240 : 650  // Landscape: 240pt, Portrait: 650pt (increased to show more content by default)
    }
    
    private var largeDetentHeight: CGFloat {
        isLandscape ? 350 : 750  // Landscape: 450pt, Portrait: 750pt
    }

    private var titleTopPadding: CGFloat {
        // Position title between nav bar and sheet
        // Nav bar is ~44pt, safe area top is ~47pt (total ~91pt from top of screen)
        // sheetRegularPosition is 350pt from top
        // Available space: 350 - 91 = 259pt
        // Title height is ~50pt (title + date)
        // Center it: (259 - 50) / 2 = ~104pt from safe area top
        isLandscape ? 1 : 25
    }

    var body: some View {
        ZStack {
            // Full screen journal color background
            journal.color
                .ignoresSafeArea()
            
            // Cover image overlay - use journal's cover or fallback to bike
            if showCoverImage {
                GeometryReader { geometry in
                    VStack {
                        let imageName = !journal.appearance.originalCoverImageData.isEmpty ?
                            journal.appearance.originalCoverImageData : "bike"
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: sheetRegularPosition + 100)
                            .clipped()
                            .ignoresSafeArea()
                            .overlay(
                                VStack {
                                    Spacer()
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            journal.color
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 100)
                                }
                            )

                        Spacer()
                    }
                }
                .ignoresSafeArea()
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(journal.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("2020 – 2025")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(.leading, 18)
                .padding(.top, titleTopPadding)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .zIndex(1)
            
            // Custom sheet overlay with orientation-specific detent positions
            CustomSheetView(
                journal: journal,
                sheetRegularPosition: 350,
                mediumDetentHeight: mediumDetentHeight,
                largeDetentHeight: largeDetentHeight,
                sheetState: sheetState,
                useStandardController: useStandardController,
                useLargeListDates: useLargeListDates
            )
            .id("\(useStandardController)-\(useLargeListDates)") // Recreate when toggles change
            .zIndex(2) // Ensure sheet appears above title text (which has zIndex 1)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(journal.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .opacity(sheetState.isExpanded ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: sheetState.isExpanded)
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditView = true
                    }) {
                        Label("Journal Settings", systemImage: "gear")
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
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white)
                }

                Menu {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Label("Settings", systemImage: "gearshape")
                    }

                    Divider()

                    Section("Journal Detail Options") {
                        Toggle(isOn: $showCoverImage) {
                            Label("Show Cover Image", systemImage: "photo")
                        }

                        Toggle(isOn: $useLargeListDates) {
                            Label("Large List Dates", systemImage: "calendar")
                        }

                        Toggle(isOn: $useStandardController) {
                            Label("Content Controller Standard", systemImage: "switch.2")
                        }
                    }
                } label: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("PM")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .toolbarBackground(showCoverImage ? .hidden : .visible, for: .navigationBar)
        .toolbarBackground(journal.color, for: .navigationBar)
        .toolbarColorScheme(showCoverImage ? .dark : nil, for: .navigationBar)
        .sheet(isPresented: $showingEditView) {
            PagedEditJournalView(journal: journal)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Sheet State
class SheetState: ObservableObject {
    @Published var isExpanded: Bool = false
}

// MARK: - Paged UIKit Sheet Wrapper (No longer used - replaced by CustomSheetView)

/*
struct PagedNativeSheetView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let journal: Journal
    let sheetRegularPosition: CGFloat
    let sheetState: SheetState
    
    func makeUIViewController(context: Context) -> UIViewController {
        let hostingController = UIViewController()
        hostingController.view.backgroundColor = .clear
        hostingController.view.isUserInteractionEnabled = false
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let sheetContent = PagedJournalSheetContent(journal: journal, sheetState: sheetState, sheetRegularPosition: sheetRegularPosition)
            let contentHostingController = UIHostingController(rootView: sheetContent)
            
            if let sheet = contentHostingController.sheetPresentationController {
                // Configure the sheet
                sheet.detents = [
                    .custom { context in
                        // Custom position from top
                        return context.maximumDetentValue - sheetRegularPosition
                    },
                    .large()
                ]
                sheet.selectedDetentIdentifier = .init("custom")
                sheet.largestUndimmedDetentIdentifier = .large
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.delegate = context.coordinator
            }
            
            contentHostingController.isModalInPresentation = true
            uiViewController.present(contentHostingController, animated: true)
        } else if !isPresented && uiViewController.presentedViewController != nil {
            uiViewController.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, sheetState: sheetState)
    }
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        @Binding var isPresented: Bool
        let sheetState: SheetState
        
        init(isPresented: Binding<Bool>, sheetState: SheetState) {
            self._isPresented = isPresented
            self.sheetState = sheetState
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            isPresented = false
        }
        
        func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
            if let selectedDetent = sheetPresentationController.selectedDetentIdentifier {
                if selectedDetent == .large {
                    print("📱 Journals UISheet expanded to large position")
                    sheetState.isExpanded = true
                } else {
                    if sheetPresentationController.containerView != nil {
                        let sheetFrame = sheetPresentationController.presentedView?.frame ?? .zero
                        let yPosition = sheetFrame.origin.y
                        print("📱 Journals UISheet moved to regular position (Y: \(Int(yPosition))pt)")
                    } else {
                        print("📱 Journals UISheet moved to regular position")
                    }
                    sheetState.isExpanded = false
                }
            }
        }
    }
}
*/

// MARK: - Paged Sheet Content

struct PagedJournalSheetContent: View {
    let journal: Journal
    @ObservedObject var sheetState: SheetState
    let sheetRegularPosition: CGFloat
    var showFAB: Bool = true  // Make this configurable
    let useLargeListDates: Bool
    @State private var selectedTab = 1
    @State private var showingEntryView = false
    @State private var showingFABState = false
    @State private var showingAudioRecord = false
    
    // Calculate FAB positions to maintain 80pt from bottom of device
    private var fabRegularPosition: CGFloat {
        // When sheet is at regular position, calculate distance from sheet top
        // Screen height - sheetRegularPosition - 80 (from bottom) - 56 (FAB height) - 50 (adjustment)
        UIScreen.main.bounds.height - sheetRegularPosition - 80 - 56 - 50
    }
    
    private var fabExpandedPosition: CGFloat {
        // When expanded, sheet is roughly at status bar height (~50pt)
        // So we need: Screen height - 50 (expanded position) - 80 (from bottom) - 56 (FAB height)
        UIScreen.main.bounds.height - 50 - 80 - 56
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Content based on selected tab - fills entire sheet area
            Group {
                switch selectedTab {
                case 0:
                    PagedCoverTabView(journal: journal)
                case 1:
                    ListTabView(journal: journal, useLargeListDates: useLargeListDates)
                case 2:
                    CalendarTabView(journal: journal)
                case 3:
                    MediaTabView()
                case 4:
                    MapTabView()
                default:
                    ListTabView(journal: journal, useLargeListDates: useLargeListDates)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // FAB buttons that animate based on sheet position
            if showFAB && showingFABState {
                HStack(spacing: 12) {
                    // Create Entry button
                    Button(action: {
                        showingEntryView = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Create Entry")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(journal.color)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    // Record Audio button
                    Button(action: {
                        showingAudioRecord = true
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(journal.color)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 18)
                .padding(.top, sheetState.isExpanded ? fabExpandedPosition : fabRegularPosition)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: sheetState.isExpanded)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }
        }
        .onAppear {
            // Only show FAB if enabled
            if showFAB {
                // Animate FAB in after a short delay with bounce effect
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.interpolatingSpring(stiffness: 180, damping: 12)) {
                        showingFABState = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEntryView) {
            EntryView(journal: journal)
        }
        .compactAudioSheet(
            isPresented: $showingAudioRecord,
            journal: journal
        )
    }
}

// MARK: - Paged Cover Tab View
struct PagedCoverTabView: View {
    let journal: Journal
    @State private var showingEditView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Description Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Add a description...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.top, 24)  // Normal top padding - segmented control is now fixed
                
                // Stats Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Stats")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatsCard(title: "Journals", value: "5", icon: "book.fill", color: .blue)
                        StatsCard(title: "Entries", value: "234", icon: "doc.text.fill", color: .green)
                        StatsCard(title: "Days", value: "89", icon: "calendar.circle.fill", color: .orange)
                        StatsCard(title: "Media", value: "67", icon: "photo.fill", color: .purple)
                        StatsCard(title: "Words", value: "12.5K", icon: "textformat", color: .red)
                        StatsCard(title: "Streak", value: "7", icon: "flame.fill", color: .yellow)
                    }
                    .padding(.horizontal)
                }
                
                // Edit Button
                Button(action: {
                    showingEditView = true
                }) {
                    Text("Edit")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
        }
        .background(.white)
        .sheet(isPresented: $showingEditView) {
            PagedEditJournalView(journal: journal)
        }
    }
}

// MARK: - Paged Edit Journal View
struct PagedEditJournalView: View {
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

// MARK: - Supporting Views

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Journal Row Views

struct CompactJournalRow: View {
    let journal: Journal
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Small color indicator
                Circle()
                    .fill(journal.color)
                    .frame(width: 12, height: 12)
                
                // Journal name
                Text(journal.name)
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundStyle(.primary)

                Spacer()

                // Journal count and entry count
                if let journalCount = journal.journalCount {
                    // For "All Entries" - show journal count and entry count
                    HStack(spacing: 8) {
                        Text("\(journalCount) journals")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let entryCount = journal.entryCount {
                            Text("\(entryCount)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else if let count = journal.entryCount {
                    // Regular journal - just show entry count
                    Text("\(count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 0)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                // TODO: Edit journal action
            }) {
                Label("Edit Journal", systemImage: "pencil")
            }
            
            Button(action: {
                // TODO: New entry action
            }) {
                Label("New Entry", systemImage: "plus")
            }
        }
    }
}

struct CompactFolderRow: View {
    let folder: JournalFolder
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSelectFolder: () -> Void

    var body: some View {
        Button(action: onSelectFolder) {
            HStack(spacing: 12) {
                // Folder icon
                Text(dayOneIcon: .folder)
                    .font(.dayOneIcons(size: 20))
                    .foregroundStyle(Color(hex: "333B40"))

                // Folder name
                Text(folder.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Spacer()

                // Folder info: journal count and entry count
                HStack(spacing: 8) {
                    Text("\(folder.journalCount) journals")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(folder.entryCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Disclosure toggle - rotates when expanded (on right side)
                Button(action: onToggle) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 8)
        .padding(.horizontal, 0)
    }
}

struct FolderRow: View {
    let folder: JournalFolder
    let isExpanded: Bool
    let isEditMode: Bool
    let onToggle: () -> Void
    let onSelectFolder: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Folder icon and content - tappable to select folder
                Button(action: onSelectFolder) {
                    HStack(spacing: 16) {
                        // Folder icon
                        Text(dayOneIcon: .folder)
                            .font(.dayOneIcons(size: 30))
                            .foregroundStyle(Color(hex: "333B40")) // Deep Blue

                        // Folder info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(folder.name)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            HStack(spacing: 4) {
                                Text("\(folder.journalCount) journals")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("\(folder.entryCount) entries")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                // Show drag handle in edit mode, ellipsis menu otherwise
                if isEditMode {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                } else {
                    Menu {
                        Button(action: {
                            onSelectFolder()
                        }) {
                            Label("Open Collection", systemImage: "folder")
                        }

                        Button(action: {
                            // TODO: Edit folder action
                        }) {
                            Label("Edit Collection", systemImage: "pencil")
                        }

                        Divider()

                        Button(action: {
                            // TODO: Share action
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }

                        Button(role: .destructive, action: {
                            // TODO: Delete action
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                }

                // Disclosure toggle - rotates when expanded (far right)
                Button(action: onToggle) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 0)

            // Only show divider when folder is collapsed
            if !isExpanded {
                Divider()
                    .padding(.leading, 0)
            }
        }
    }
}

struct JournalRow: View {
    let journal: Journal
    let isSelected: Bool
    let isEditMode: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Main content - tappable to select
                Button(action: onSelect) {
                    HStack(spacing: 16) {
                        // Color square
                        RoundedRectangle(cornerRadius: 4)
                            .fill(journal.color)
                            .frame(width: 30, height: 40)
                            .overlay(
                                // Vertical line inset 2pt from left
                                GeometryReader { geometry in
                                    Rectangle()
                                        .fill(Color.black.opacity(0.1))
                                        .frame(width: 1)
                                        .offset(x: 3)
                                }
                            )

                        // Journal info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(journal.name)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            // Show journal count for "All Entries"
                            if let journalCount = journal.journalCount {
                                HStack(spacing: 4) {
                                    Text("\(journalCount) journals")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text("•")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    if let entryCount = journal.entryCount {
                                        Text("\(entryCount) entries")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            } else if let count = journal.entryCount {
                                Text("\(count) entries")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                // Show drag handle in edit mode, ellipsis menu otherwise
                if isEditMode {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                } else {
                    Menu {
                        Button(action: {
                            // TODO: Edit journal action
                        }) {
                            Label("Edit Journal", systemImage: "pencil")
                        }

                        Button(action: {
                            // TODO: New entry action
                        }) {
                            Label("New Entry", systemImage: "plus")
                        }

                        Divider()

                        Button(action: {
                            // TODO: Share action
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }

                        Button(role: .destructive, action: {
                            // TODO: Delete action
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                }
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 0)
            .padding(.bottom, 4)

            Divider()
                .padding(.leading, 0)
        }
        .contextMenu {
            Button(action: {
                // TODO: Edit journal action
            }) {
                Label("Edit Journal", systemImage: "pencil")
            }

            Button(action: {
                // TODO: New entry action
            }) {
                Label("New Entry", systemImage: "plus")
            }
        }
    }
}

struct JournalBookView: View {
    let journal: Journal
    let isSelected: Bool
    let onSelect: () -> Void
    var onNewEntry: (() -> Void)? = nil

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // Book shape
                RoundedRectangle(cornerRadius: 8)
                    .fill(journal.color)
                    .aspectRatio(0.7, contentMode: .fit)
                    .overlay(
                        // Book spine effect
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(journal.color.opacity(0.3))
                                .frame(height: 2)
                                .padding(.horizontal, 8)
                            Spacer()
                        }
                    )
                    .overlay(
                        // Journal title on book cover
                        VStack {
                            Spacer()
                            HStack {
                                Text(journal.name)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                            .padding(.leading, 8)
                        }
                    )
                    .overlay(
                        // Selection indicator
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? .blue : .clear, lineWidth: 3)
                    )
                    .overlay(
                        // New Entry button (top-right corner)
                        Group {
                            if let onNewEntry = onNewEntry {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            onNewEntry()
                                        }) {
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 24, height: 24)
                                                .overlay(
                                                    Image(systemName: "plus")
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundStyle(journal.color)
                                                )
                                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(6)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    )
                    .shadow(color: journal.color.opacity(0.3), radius: 4, x: 2, y: 4)

                // Entry count (and journal count for "All Entries")
                if let journalCount = journal.journalCount {
                    // For "All Entries"
                    HStack(spacing: 4) {
                        Text("\(journalCount) journals")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        if let entryCount = journal.entryCount {
                            Text("\(entryCount)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 4)
                } else if let count = journal.entryCount {
                    Text("\(count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                // TODO: Edit journal action
            }) {
                Label("Edit Journal", systemImage: "pencil")
            }

            Button(action: {
                // TODO: New entry action
            }) {
                Label("New Entry", systemImage: "plus")
            }
        }
    }
}

// MARK: - Recent Journal Book View (smaller, no entry count)
struct RecentJournalBookView: View {
    let journal: Journal
    let isSelected: Bool
    let onSelect: () -> Void
    var onNewEntry: (() -> Void)? = nil

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                // Book shape
                RoundedRectangle(cornerRadius: 6)
                    .fill(journal.color)
                    .aspectRatio(0.7, contentMode: .fit)
                    .overlay(
                        // Book spine effect
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(journal.color.opacity(0.3))
                                .frame(height: 2)
                                .padding(.horizontal, 6)
                            Spacer()
                        }
                    )
                    .overlay(
                        // Journal title on book cover - smaller font
                        VStack {
                            Spacer()
                            HStack {
                                Text(journal.name)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Spacer()
                            }
                            .padding(.bottom, 6)
                            .padding(.leading, 6)
                        }
                    )
                    .overlay(
                        // Selection indicator
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isSelected ? .blue : .clear, lineWidth: 2)
                    )
                    .overlay(
                        // New Entry button (top-right corner)
                        Group {
                            if let onNewEntry = onNewEntry {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            onNewEntry()
                                        }) {
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 26, height: 26)
                                                .overlay(
                                                    Image(systemName: "plus")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundStyle(journal.color)
                                                )
                                                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 0)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(6)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    )
                    .shadow(color: journal.color.opacity(0.3), radius: 4, x: 0, y: 0)
                // No entry count displayed
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Folder Detail View
struct FolderDetailView: View {
    let folder: JournalFolder
    let sheetRegularPosition: CGFloat
    @State private var showingEditView = false
    @State private var useStandardController = false
    @State private var showCoverImage = false
    @State private var useLargeListDates = false
    @StateObject private var sheetState = SheetState()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    // Computed properties for orientation-specific values
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    private var mediumDetentHeight: CGFloat {
        isLandscape ? 240 : 650  // Match journal detail view
    }

    private var largeDetentHeight: CGFloat {
        isLandscape ? 350 : 750  // Match journal detail view
    }

    private var titleTopPadding: CGFloat {
        // Match journal detail view positioning
        isLandscape ? 1 : 25
    }

    // Get journal names as comma-separated string
    private var journalNames: String {
        folder.journals.map { $0.name }.joined(separator: ", ")
    }

    var body: some View {
        ZStack {
            // Full screen folder color background
            folder.color
                .ignoresSafeArea()

            // Cover image overlay - use bike image as fallback
            if showCoverImage {
                GeometryReader { geometry in
                    VStack {
                        Image("bike")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: sheetRegularPosition + 100)
                            .clipped()
                            .ignoresSafeArea()
                            .overlay(
                                VStack {
                                    Spacer()
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            folder.color
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 100)
                                }
                            )

                        Spacer()
                    }
                }
                .ignoresSafeArea()
            }

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(folder.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        // Journal names in the same format as date range
                        Text(journalNames)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Spacer()
                }
                .padding(.leading, 18)
                .padding(.top, titleTopPadding)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .zIndex(1)

            // Custom sheet overlay with orientation-specific detent positions
            CustomSheetView(
                journal: folder.journals.first ?? Journal(name: folder.name, color: folder.color, entryCount: folder.entryCount),
                sheetRegularPosition: 350,
                mediumDetentHeight: mediumDetentHeight,
                largeDetentHeight: largeDetentHeight,
                sheetState: sheetState,
                useStandardController: useStandardController,
                useLargeListDates: useLargeListDates,
                showFAB: false // Don't show FAB in collection detail views
            )
            .id("\(useStandardController)-\(useLargeListDates)") // Recreate when toggles change
            .zIndex(2)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(folder.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .opacity(sheetState.isExpanded ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: sheetState.isExpanded)
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditView = true
                    }) {
                        Label("Folder Settings", systemImage: "gear")
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

                    Divider()

                    Toggle(isOn: $useStandardController) {
                        Label("Content Controller Standard", systemImage: "switch.2")
                    }

                    Toggle(isOn: $showCoverImage) {
                        Label("Show Cover Image", systemImage: "photo")
                    }

                    Toggle(isOn: $useLargeListDates) {
                        Label("Large List Dates", systemImage: "calendar")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white)
                }

                Button {
                    // TODO: Show global settings
                } label: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("PM")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .toolbarBackground(showCoverImage ? .hidden : .visible, for: .navigationBar)
        .toolbarBackground(folder.color, for: .navigationBar)
        .toolbarColorScheme(showCoverImage ? .dark : nil, for: .navigationBar)
        .tint(folder.color)
        .sheet(isPresented: $showingEditView) {
            PagedEditJournalView(journal: folder.journals.first ?? Journal(name: folder.name, color: folder.color, entryCount: folder.entryCount))
        }
    }
}

// MARK: - Recent Entry Card Component

struct RecentEntryCard: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Entry content
            VStack(alignment: .leading, spacing: 0) {
                // Combined title and content
                Text("\(entry.title) \(entry.preview)")
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(minHeight: 80)

            // Journal indicator at bottom
            HStack(spacing: 8) {
                Circle()
                    .fill(entry.journalColor)
                    .frame(width: 8, height: 8)

                Text(entry.journalName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview("Paged") {
    JournalsTabPagedView()
}
