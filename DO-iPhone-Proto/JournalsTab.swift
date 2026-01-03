import SwiftUI
import UIKit
import TipKit

// MARK: - Constants

/// Size for toggle disclosure icons (arrow-right-circle)
let toggleIconSize: CGFloat = 24

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

struct JournalsTabPagedView: View {
    @Environment(JournalSelectionViewModel.self) private var journalViewModel
    @State private var showingSettings = false
    @State private var viewMode: ViewMode = .list // Default to Regular view
    @State private var selectedJournal: Journal?
    @State private var selectedFolder: JournalFolder?
    @State private var showingNewEntry = false
    @State private var shouldShowAudioAfterEntry = false
    @State private var showRecentJournals = false
    @State private var showRecentEntries = false
    @State private var recentJournalsExpanded = true
    @State private var recentEntriesExpanded = true
    @State private var isEditMode = false
    @State private var showingReorderModal = false
    @State private var journalItems: [Journal.MixedJournalItem] = Journal.mixedJournalItems
    @State private var journalsPopulation: JournalsPopulation = .lots
    @State private var showAddJournalTips = false
    @State private var trashCount: Int = 7 // Controlled by Fill/Empty Trash button
    @State private var showNewJournalButtons = false
    @State private var showAllEntries = false
    @State private var showingSectionsOrder = false
    @State private var journalsSectionExpanded = true
    @State private var sectionOrder: [JournalSectionType] = [.recentJournals, .recentEntries, .journals, .newJournalButtons]
    @State private var addNotesJournalTip = AddNotesJournalTip()
    @State private var addWorkJournalTip = AddWorkJournalTip()
    @State private var addTravelJournalTip = AddTravelJournalTip()
    @State private var manuallyAddedJournalNames: Set<String> = []
    @State private var dismissedJournalTips: Set<String> = [] // Track dismissed tips by journal name

    // Rename state
    @State private var renamingCollectionID: String? = nil
    @State private var editedCollectionName = ""
    @FocusState private var collectionNameFieldFocused: Bool

    // New Journal FAB state
    @State private var showingNewJournalFAB = false

    // Folder expansion state - expand all by default
    @State private var expandedFolders: Set<String> = Set(Journal.folders.map { $0.id })

    // Auto-scroll to newly created journal
    @State private var scrollToId: String? = nil

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
        case .lots, .oneHundredOne:
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
        case .lots, .oneHundredOne:
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
        case .lots, .oneHundredOne:
            // Return all mixed items (journals and folders)
            return journalItems
        }
    }

    // Should show All Entries only when there are 2 or more journals
    private var shouldShowAllEntries: Bool {
        return filteredJournals.count > 1
    }

    // Dynamic All Entries journal based on current journalItems
    private var allEntriesJournal: Journal? {
        // Collect all journals from journalItems (both standalone and in folders)
        var allJournals: [Journal] = []

        for item in journalItems {
            if let journal = item.journal {
                allJournals.append(journal)
            } else if let folder = item.folder {
                allJournals.append(contentsOf: folder.journals)
            }
        }

        // Only show if there are 2+ journals
        guard allJournals.count > 1 else { return nil }

        let totalEntryCount = allJournals.compactMap { $0.entryCount }.reduce(0, +)
        let totalJournalCount = allJournals.count

        return Journal(
            name: "All Entries",
            color: Color(hex: "333B40"),
            entryCount: totalEntryCount,
            journalCount: totalJournalCount
        )
    }

    // Extract journals from current journalItems (for reorder modal)
    private var currentJournals: [Journal] {
        var journals: [Journal] = []
        for item in journalItems {
            if let journal = item.journal {
                journals.append(journal)
            } else if let folder = item.folder {
                journals.append(contentsOf: folder.journals)
            }
        }
        return journals
    }

    // Extract folders from current journalItems (for reorder modal)
    private var currentFolders: [JournalFolder] {
        return journalItems.compactMap { item in
            item.folder
        }
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

    // Count available view modes (Icons is always available)
    private var availableViewModesCount: Int {
        return 3 // All three view modes (Compact, Regular, Books) are always available
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

    // Add new collection to the bottom of the list
    private func addNewCollection() {
        let newName = generateNewCollectionName()
        let newId = UUID().uuidString

        // Create new folder
        let newFolder = JournalFolder(id: newId, name: newName, journals: [])

        // Add to journalItems at the end
        journalItems.append(Journal.MixedJournalItem(folder: newFolder))

        // Immediately enter rename mode
        renamingCollectionID = newId
        editedCollectionName = newName

        // Focus the text field after a short delay to ensure it's rendered
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            collectionNameFieldFocused = true
        }
    }

    // Generate unique name for new collections
    private func generateNewCollectionName() -> String {
        let existingNames = Set(journalItems.compactMap { item -> String? in
            if let folder = item.folder {
                return folder.name
            }
            return nil
        })

        var counter = 1
        while existingNames.contains("Collection \(counter)") {
            counter += 1
        }

        return "Collection \(counter)"
    }

    // Add new journal to the bottom of the list
    private func addNewJournal() {
        let newName = generateNewJournalName()

        // Create new journal with a random color from Day One palette
        let colors = [
            Color(hex: "44C0FF"), Color(hex: "FFC107"), Color(hex: "2DCC71"),
            Color(hex: "3398DB"), Color(hex: "6A6DCD"), Color(hex: "607D8B"),
            Color(hex: "C27BD2"), Color(hex: "FF983B"), Color(hex: "E91E63"),
            Color(hex: "16D6D9")
        ]
        let randomColor = colors.randomElement() ?? Color(hex: "44C0FF")

        let newJournal = Journal(name: newName, color: randomColor, entryCount: 0)

        // Add to journalItems at the end
        journalItems.append(Journal.MixedJournalItem(journal: newJournal))

        // Scroll to make the new journal visible
        scrollToId = newJournal.id
    }

    // Generate unique name for new journals
    private func generateNewJournalName() -> String {
        // Get all journal names from both standalone and folders
        var existingNames = Set<String>()

        for item in journalItems {
            if let journal = item.journal {
                existingNames.insert(journal.name)
            } else if let folder = item.folder {
                for journal in folder.journals {
                    existingNames.insert(journal.name)
                }
            }
        }

        var counter = 1
        while existingNames.contains("Journal \(counter)") {
            counter += 1
        }

        return "Journal \(counter)"
    }

    // Repopulate journals with the selected option
    private func repopulateJournals(with option: JournalsPopulation) {
        // Clear existing journals
        journalItems.removeAll()

        // Empty trash when New User is selected
        if option == .newUser {
            trashCount = 0
        }

        switch option {
        case .newUser:
            // Add only "Journal"
            let journal = Journal(name: "Journal", color: Color(hex: "44C0FF"), entryCount: 0)
            journalItems.append(Journal.MixedJournalItem(journal: journal))

        case .threeJournals:
            // Add Journal, Notes, Daily
            let journals = [
                Journal(name: "Journal", color: Color(hex: "44C0FF"), entryCount: 22),
                Journal(name: "Notes", color: Color(hex: "FFC107"), entryCount: 19),
                Journal(name: "Daily", color: Color(hex: "2DCC71"), entryCount: 8)
            ]
            journalItems = journals.map { Journal.MixedJournalItem(journal: $0) }

        case .lots:
            // Load from sample journals and folders
            journalItems = Journal.mixedJournalItems

        case .oneHundredOne:
            // Create 101 journals across 8 collections
            let colors = [
                Color(hex: "44C0FF"), Color(hex: "FFC107"), Color(hex: "2DCC71"),
                Color(hex: "3398DB"), Color(hex: "6A6DCD"), Color(hex: "607D8B"),
                Color(hex: "C27BD2"), Color(hex: "FF983B"), Color(hex: "E91E63"),
                Color(hex: "16D6D9")
            ]

            // Create 8 collections with journals
            let collectionNames = [
                "Work", "Personal", "Travel", "Health & Fitness",
                "Learning", "Projects", "Creative", "Archive"
            ]

            var journalCounter = 1

            for (index, collectionName) in collectionNames.enumerated() {
                // 10-15 journals per collection
                let journalsInCollection = (10...15).randomElement() ?? 12
                var collectionJournals: [Journal] = []

                for i in 0..<journalsInCollection {
                    let color = colors[journalCounter % colors.count]
                    let entryCount = Int.random(in: 0...150)

                    // Add some long journal names for testing
                    let name: String
                    if journalCounter == 5 {
                        name = "My Very Long Journal Name That Goes On and On to Test Truncation"
                    } else if journalCounter == 23 {
                        name = "Another Extremely Long Journal Title for Testing UI Layout and Truncation Behavior"
                    } else if journalCounter == 47 {
                        name = "Weekly Reflections and Personal Growth Journey Through Life's Adventures"
                    } else {
                        name = "Journal \(journalCounter)"
                    }

                    let journal = Journal(
                        name: name,
                        color: color,
                        entryCount: entryCount
                    )
                    collectionJournals.append(journal)
                    journalCounter += 1

                    if journalCounter > 101 { break }
                }

                let folder = JournalFolder(
                    id: UUID().uuidString,
                    name: collectionName,
                    journals: collectionJournals
                )
                journalItems.append(Journal.MixedJournalItem(folder: folder))

                if journalCounter > 101 { break }
            }
        }
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
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                Group {
                    // List-based views (compact and list modes) use List which has built-in scrolling
                    // Grid mode uses ScrollView with LazyVStack
                    if viewMode == .list || viewMode == .compact {
                        journalListContent
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                journalListContent
                                    .padding(.top, 12)
                            }
                        }
                    }
                }
                .navigationTitle("Journals")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    // New Collection button
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            addNewCollection()
                        }) {
                            Image("media-library-folder-add")
                                .renderingMode(.template)
                        }
                    }

                    // Spacer to separate buttons into different pill backgrounds
                    ToolbarSpacer(.fixed, placement: .navigationBarLeading)

                    // Edit button to open reorder modal
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingReorderModal = true
                        }) {
                            Text("Edit")
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                showingReorderModal = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button(action: {
                                addNewJournal()
                            }) {
                                Label("New Journal", systemImage: "plus")
                            }

                            Button(action: {
                                addNewCollection()
                            }) {
                                Label("New Collection", systemImage: "folder.badge.plus")
                            }

                            Divider()

                            Toggle(isOn: $showRecentJournals) {
                                Label("Show Recent Journals", systemImage: "clock")
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
                                Toggle(isOn: $showAddJournalTips) {
                                    Label("Show Add Journal Tips", systemImage: "lightbulb")
                                }

                                Toggle(isOn: $showRecentEntries) {
                                    Label("Show Recent Entries", systemImage: "doc.text")
                                }

                                Menu {
                                    Picker("Journals View", selection: $viewMode) {
                                        Label("Compact", systemImage: "list.bullet")
                                            .tag(ViewMode.compact)
                                        Label("Regular", systemImage: "square.grid.3x3")
                                            .tag(ViewMode.list)
                                        Label("Books", systemImage: "books.vertical")
                                            .tag(ViewMode.grid)
                                    }
                                } label: {
                                    HStack {
                                        Label("Journals View", systemImage: "square.grid.3x3")
                                        Spacer()
                                        Text(viewMode == .compact ? "Compact" : viewMode == .list ? "Regular" : "Books")
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Button {
                                    if trashCount > 0 {
                                        trashCount = 0
                                    } else {
                                        trashCount = 7
                                    }
                                } label: {
                                    Label(trashCount > 0 ? "Empty Trash" : "Fill Trash", systemImage: "trash")
                                }
                            }

                            Section("Repopulate Journals") {
                                ForEach(JournalsPopulation.allCases, id: \.self) { option in
                                    Button(option.rawValue) {
                                        repopulateJournals(with: option)
                                    }
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
                .navigationDestination(item: $selectedJournal) { journal in
                    JournalDetailPagedView(journal: journal, journalViewModel: journalViewModel, sheetRegularPosition: sheetRegularPosition)
                }
                .navigationDestination(item: $selectedFolder) { folder in
                    FolderDetailView(folder: folder, sheetRegularPosition: sheetRegularPosition)
                }
            }
            .sheet(isPresented: $showingSettings) {
                AppSettingsView()
            }
            .sheet(isPresented: $showingSectionsOrder) {
                JournalsSectionsOrderView(
                    sectionOrder: $sectionOrder,
                    showRecentJournals: $showRecentJournals,
                    showRecentEntries: $showRecentEntries,
                    showJournalsSection: $journalsSectionExpanded,
                    showNewJournalButtons: $showNewJournalButtons
                )
            }
            .sheet(isPresented: $showingReorderModal) {
                JournalsReorderView(
                    journals: currentJournals,
                    folders: currentFolders,
                    journalItems: $journalItems
                )
            }

            // New Journal FAB
            Button(action: {
                addNewJournal()
            }) {
                HStack(spacing: 8) {
                    Text("+ New Journal")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(hex: "333B40"))
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .padding(.trailing, 18)
            .padding(.bottom, 30) // Position above tab bar (similar to Today tab FABs)
            .offset(y: showingNewJournalFAB ? 0 : 150) // Slide up/down animation
            .opacity(showingNewJournalFAB ? 1 : 0)
        }
        .onAppear {
            // Animate FAB in after a short delay with bounce effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.interpolatingSpring(stiffness: 180, damping: 12)) {
                    showingNewJournalFAB = true
                }
            }
        }
        .onChange(of: selectedJournal) { oldValue, newValue in
            // Hide FAB when navigating to journal detail, show when coming back
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showingNewJournalFAB = newValue == nil
            }
        }
        .onChange(of: selectedFolder) { oldValue, newValue in
            // Hide FAB when navigating to folder detail, show when coming back
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showingNewJournalFAB = newValue == nil
            }
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
        List {
            // Render sections in custom order
            ForEach(sectionOrder, id: \.self) { sectionType in
                sectionView(for: sectionType)
            }

            // Fixed items that don't reorder
            tipKitSection
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
    }

    // MARK: - Section Views
    @ViewBuilder
    private func sectionView(for type: JournalSectionType) -> some View {
        switch type {
        case .recentJournals:
            recentJournalsSection
        case .recentEntries:
            recentEntriesSection
        case .journals:
            journalsSection
        case .newJournalButtons:
            newJournalButtonsSection
        }
    }

    @ViewBuilder
    private var recentJournalsSection: some View {
        if showRecentJournals {
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

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: toggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(recentJournalsExpanded ? 90 : 0))
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(PlainButtonStyle())
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        if showRecentJournals && recentJournalsExpanded {
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
                .padding(.leading, 16)
            }
            .padding(.bottom, 16)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private var recentEntriesSection: some View {
        if showRecentEntries {
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

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: toggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(recentEntriesExpanded ? 90 : 0))
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(PlainButtonStyle())
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        if showRecentEntries && recentEntriesExpanded {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recentEntries) { entry in
                        RecentEntryCard(entry: entry)
                            .frame(width: 108)
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing)
            }
            .padding(.bottom, 16)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
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
        ScrollViewReader { proxy in
            List {
                // Render sections in custom order
                ForEach(sectionOrder, id: \.self) { sectionType in
                    iconsSectionView(for: sectionType)
                }

                // Fixed items that don't reorder
                tipKitSection
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            .onChange(of: scrollToId) { _, newId in
                if let id = newId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                        scrollToId = nil
                    }
                }
            }
        }
    }

    // MARK: - Icons Mode Section Views
    @ViewBuilder
    private func iconsSectionView(for type: JournalSectionType) -> some View {
        switch type {
        case .recentJournals:
            iconsRecentJournalsSection
        case .recentEntries:
            iconsRecentEntriesSection
        case .journals:
            iconsJournalsSection
        case .newJournalButtons:
            iconsNewJournalButtonsSection
        }
    }
    @ViewBuilder
    private var iconsRecentJournalsSection: some View {
        if showRecentJournals {
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

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: toggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(recentJournalsExpanded ? 90 : 0))
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(PlainButtonStyle())
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        if showRecentJournals && recentJournalsExpanded {
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
                .padding(.leading, 16)
            }
            .padding(.bottom, 16)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private var iconsRecentEntriesSection: some View {
        if showRecentEntries {
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

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: toggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(recentEntriesExpanded ? 90 : 0))
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(PlainButtonStyle())
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        if showRecentEntries && recentEntriesExpanded {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recentEntries) { entry in
                        RecentEntryCard(entry: entry)
                            .frame(width: 108)
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing)
            }
            .padding(.bottom, 16)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private var iconsJournalsSection: some View {
        // All Entries collection-style row at the top
            if let allEntries = allEntriesJournal {
                AllEntriesCollectionRow(
                    totalJournalCount: allEntries.journalCount ?? 0,
                    totalEntryCount: allEntries.entryCount ?? 0,
                    onSelect: {
                        journalViewModel.selectJournal(allEntries)
                        selectedJournal = allEntries
                    }
                )
            }

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
                        },
                        isRenaming: renamingCollectionID == folder.id,
                        editedName: $editedCollectionName,
                        onRenameSubmit: {
                            if !editedCollectionName.isEmpty {
                                // Find the folder in journalItems and update it
                                if let index = journalItems.firstIndex(where: { $0.id == folder.id }) {
                                    // Create new folder with updated name
                                    let updatedFolder = folder.withName(editedCollectionName)

                                    // Replace in journalItems with new wrapper
                                    journalItems[index] = Journal.MixedJournalItem(folder: updatedFolder)
                                }
                            }
                            renamingCollectionID = nil
                        },
                        nameFieldFocused: $collectionNameFieldFocused,
                        onRename: {
                            editedCollectionName = folder.name
                            renamingCollectionID = folder.id
                            collectionNameFieldFocused = true
                        },
                        onDelete: {
                            // Find the folder index
                            if let folderIndex = journalItems.firstIndex(where: { $0.id == folder.id }) {
                                // Get all journals from the folder to preserve them
                                let journalsToPreserve = folder.journals

                                // Remove the folder
                                journalItems.remove(at: folderIndex)

                                // Insert the journals at the same position
                                let journalItems = journalsToPreserve.map { Journal.MixedJournalItem(journal: $0) }
                                self.journalItems.insert(contentsOf: journalItems, at: folderIndex)
                            }
                        }
                    )
                    .id(folder.id)

                    if expandedFolders.contains(folder.id) {
                        ForEach(folder.journals) { journal in
                            JournalRow(
                                journal: journal,
                                isSelected: journal.id == journalViewModel.selectedJournal.id,
                                isEditMode: isEditMode,
                                onSelect: {
                                    journalViewModel.selectJournal(journal)
                                    selectedJournal = journal
                                },
                                onNewEntry: {
                                    journalViewModel.selectJournal(journal)
                                    showingNewEntry = true
                                },
                                onRename: { newName in
                                    // Find the parent folder and update the journal within it
                                    if let folderIndex = journalItems.firstIndex(where: { $0.id == folder.id }),
                                       let currentFolder = journalItems[folderIndex].folder {

                                        // Update the journal in the folder's journals array
                                        var updatedJournals = currentFolder.journals
                                        if let journalIndex = updatedJournals.firstIndex(where: { $0.id == journal.id }) {
                                            updatedJournals[journalIndex] = journal.withName(newName)

                                            // Create new folder with updated journals array
                                            let updatedFolder = currentFolder.withJournals(updatedJournals)

                                            // Replace folder in journalItems
                                            journalItems[folderIndex] = Journal.MixedJournalItem(folder: updatedFolder)
                                        }
                                    }
                                },
                                onDelete: {
                                    // Find the parent folder and remove the journal from it
                                    if let folderIndex = journalItems.firstIndex(where: { $0.id == folder.id }),
                                       let currentFolder = journalItems[folderIndex].folder {

                                        // Remove the journal from the folder's journals array
                                        var updatedJournals = currentFolder.journals
                                        updatedJournals.removeAll(where: { $0.id == journal.id })

                                        if updatedJournals.isEmpty {
                                            // If folder is now empty, remove the folder
                                            journalItems.remove(at: folderIndex)
                                        } else {
                                            // Create new folder with updated journals array
                                            let updatedFolder = currentFolder.withJournals(updatedJournals)

                                            // Replace folder in journalItems
                                            journalItems[folderIndex] = Journal.MixedJournalItem(folder: updatedFolder)
                                        }
                                    }
                                }
                            )
                            .padding(.leading, 20)
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
                        },
                        onNewEntry: {
                            journalViewModel.selectJournal(journal)
                            showingNewEntry = true
                        },
                        onRename: { newName in
                            // Find the journal in journalItems and update it
                            if let index = journalItems.firstIndex(where: { $0.id == journal.id }) {
                                // Create new journal with updated name
                                let updatedJournal = journal.withName(newName)

                                // Replace in journalItems
                                journalItems[index] = Journal.MixedJournalItem(journal: updatedJournal)
                            }
                        },
                        onDelete: {
                            // Remove standalone journal from journalItems
                            journalItems.removeAll(where: { $0.id == journal.id })
                        }
                    )
                }
            }

        // Trash row at the bottom
        if trashCount > 0 {
            TrashRow(
                itemCount: trashCount,
                onSelect: {
                    // TODO: Handle trash selection
                }
            )
        }
    }

    @ViewBuilder
    private var iconsNewJournalButtonsSection: some View {
        if showNewJournalButtons {
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image("media-library-folder-add")
                        .renderingMode(.template)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(width: 48)

                Button(action: {
                    addNewJournal()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 18))
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
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 16)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private var iconsTrashSection: some View {
        if trashCount > 0 {
            Button(action: {}) {
                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Text("Trash")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(trashCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                Button(action: {}) {
                    Label("Empty Trash", systemImage: "trash")
                }
            }
            .padding(.top, 16)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
        }
    }

    private var gridJournalList: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
            // All Entries at the top (only show when there are 2+ journals)
            if shouldShowAllEntries, let allEntries = allEntriesJournal {
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

    @ViewBuilder
    private var journalsSection: some View {
        // All Entries collection-style row at the top
            if let allEntries = allEntriesJournal {
                CompactAllEntriesCollectionRow(
                    totalJournalCount: allEntries.journalCount ?? 0,
                    totalEntryCount: allEntries.entryCount ?? 0,
                    onSelect: {
                        journalViewModel.selectJournal(allEntries)
                        selectedJournal = allEntries
                    }
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .padding(.vertical, 8)
            }

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
                            },
                            isRenaming: renamingCollectionID == folder.id,
                            editedName: $editedCollectionName,
                            onRenameSubmit: {
                                if !editedCollectionName.isEmpty {
                                    // Find the folder in journalItems and update it
                                    if let index = journalItems.firstIndex(where: { $0.id == folder.id }) {
                                        // Create new folder with updated name
                                        let updatedFolder = folder.withName(editedCollectionName)

                                        // Replace in journalItems with new wrapper
                                        journalItems[index] = Journal.MixedJournalItem(folder: updatedFolder)
                                    }
                                }
                                renamingCollectionID = nil
                            },
                            nameFieldFocused: $collectionNameFieldFocused
                        )

                        if expandedFolders.contains(folder.id) {
                            ForEach(folder.journals) { journal in
                                CompactJournalRow(
                                    journal: journal,
                                    isSelected: journal.id == journalViewModel.selectedJournal.id,
                                    onSelect: {
                                        journalViewModel.selectJournal(journal)
                                        selectedJournal = journal
                                    },
                                    onNewEntry: {
                                        selectedJournal = journal
                                        showingNewEntry = true
                                    }
                                )
                                .padding(.leading, 20)
                            }
                        }
                    } else if let journal = item.journal {
                        CompactJournalRow(
                            journal: journal,
                            isSelected: journal.id == journalViewModel.selectedJournal.id,
                            onSelect: {
                                journalViewModel.selectJournal(journal)
                                selectedJournal = journal
                            },
                            onNewEntry: {
                                selectedJournal = journal
                                showingNewEntry = true
                            },
                            onRename: { newName in
                                // Find the journal in journalItems and update it
                                if let index = journalItems.firstIndex(where: { $0.id == journal.id }) {
                                    // Create new journal with updated name
                                    let updatedJournal = journal.withName(newName)

                                    // Replace in journalItems
                                    journalItems[index] = Journal.MixedJournalItem(journal: updatedJournal)
                                }
                            },
                            onDelete: {
                                // Remove standalone journal from journalItems
                                journalItems.removeAll(where: { $0.id == journal.id })
                            }
                        )
                    }
                }

        // Trash row at the bottom
        if trashCount > 0 {
            CompactTrashRow(
                itemCount: trashCount,
                onSelect: {
                    // TODO: Handle trash selection
                }
            )
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var newJournalButtonsSection: some View {
        if showNewJournalButtons {
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image("media-library-folder-add")
                        .renderingMode(.template)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(width: 48)

                Button(action: {
                    addNewJournal()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 18))
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
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 16)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private var trashSection: some View {
        if trashCount > 0 {
            Button(action: {}) {
                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Text("Trash")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(trashCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                Button(action: {}) {
                    Label("Empty Trash", systemImage: "trash")
                }
            }
            .padding(.top, 16)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private var tipKitSection: some View {
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
                            addJournal(named: "Work")
                        } else if action.id == "dismiss" {
                            dismissJournalTip(named: "Work")
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
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }
}

// MARK: - Journal Detail View
// JournalDetailPagedView has been moved to JournalDetailView.swift

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
    @AppStorage("mediaViewSize") var mediaViewSize: MediaViewSize = .medium
    
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
                    MediaTabView(mediaViewSize: mediaViewSize)
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
    var onNewEntry: (() -> Void)? = nil
    var onRename: ((String) -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    @State private var showingEditJournal = false
    @State private var isRenaming = false
    @State private var editedName = ""
    @State private var showingDeleteConfirmation = false
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Small color indicator
                Circle()
                    .fill(journal.color)
                    .frame(width: 12, height: 12)

                // Journal name
                if isRenaming {
                    TextField("Journal Name", text: $editedName)
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(.primary)
                        .focused($isNameFieldFocused)
                        .onSubmit {
                            if !editedName.isEmpty {
                                onRename?(editedName)
                            }
                            isRenaming = false
                        }
                        .submitLabel(.done)
                } else {
                    Text(journal.name)
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(.primary)
                }

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

                            if journal.isShared == true, let memberCount = journal.memberCount {
                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(memberCount)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else if let count = journal.entryCount {
                    // Regular journal - just show entry count
                    HStack(spacing: 4) {
                        Text("\(count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if journal.isShared == true, let memberCount = journal.memberCount {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(memberCount)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, -5)
            .padding(.horizontal, 0)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            if let newEntry = onNewEntry {
                Button {
                    newEntry()
                } label: {
                    Label("New Entry", systemImage: "plus")
                }
            }

            Button {
                showingEditJournal = true
            } label: {
                Label("Edit Journal", systemImage: "pencil")
            }

            Button {
                editedName = journal.name
                isRenaming = true
                isNameFieldFocused = true
            } label: {
                Label("Rename", systemImage: "character.cursor.ibeam")
            }
        }
    }
}

struct CompactFolderRow: View {
    let folder: JournalFolder
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSelectFolder: () -> Void
    var isRenaming: Bool = false
    @Binding var editedName: String
    var onRenameSubmit: (() -> Void)? = nil
    var nameFieldFocused: FocusState<Bool>.Binding
    var onRename: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    @State private var showingDeleteConfirmation = false

    var body: some View {
        Button(action: onSelectFolder) {
            HStack(spacing: 12) {
                // Folder icon
                Image("media-library-folder")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color(hex: "333B40"))

                // Folder name
                if isRenaming {
                    TextField("Collection Name", text: $editedName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .focused(nameFieldFocused)
                        .onSubmit {
                            onRenameSubmit?()
                        }
                        .submitLabel(.done)
                } else {
                    Text(folder.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }

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
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: toggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button {
                onRename?()
            } label: {
                Label("Rename", systemImage: "character.cursor.ibeam")
            }

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Collection", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            if folder.journalCount > 0 {
                Text("This collection contains \(folder.journalCount) \(folder.journalCount == 1 ? "journal" : "journals"). All journals will be preserved and moved out of the collection.")
            } else {
                Text("Are you sure you want to delete this collection?")
            }
        }
        .padding(.vertical, 0)
        .padding(.horizontal, 0)
    }
}

struct FolderRow: View {
    let folder: JournalFolder
    let isExpanded: Bool
    let isEditMode: Bool
    let onToggle: () -> Void
    let onSelectFolder: () -> Void
    var isRenaming: Bool = false
    @Binding var editedName: String
    var onRenameSubmit: (() -> Void)? = nil
    var nameFieldFocused: FocusState<Bool>.Binding
    var onRename: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Folder icon and content - tappable to select folder
                Button(action: onSelectFolder) {
                    HStack(spacing: 16) {
                        // Folder icon
                        Image("media-library-folder")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color(hex: "333B40")) // Deep Blue

                        // Folder info
                        VStack(alignment: .leading, spacing: 2) {
                            if isRenaming {
                                TextField("Collection Name", text: $editedName)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .focused(nameFieldFocused)
                                    .onSubmit {
                                        onRenameSubmit?()
                                    }
                                    .submitLabel(.done)
                            } else {
                                Text(folder.name)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                            }

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

                // Disclosure toggle - rotates when expanded (far right)
                Button(action: onToggle) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: toggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
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
        .contextMenu {
            Button {
                onRename?()
            } label: {
                Label("Rename", systemImage: "character.cursor.ibeam")
            }

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Collection", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            if folder.journalCount > 0 {
                Text("This collection contains \(folder.journalCount) \(folder.journalCount == 1 ? "journal" : "journals"). All journals will be preserved and moved out of the collection.")
            } else {
                Text("Are you sure you want to delete this collection?")
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

struct JournalRow: View {
    let journal: Journal
    let isSelected: Bool
    let isEditMode: Bool
    let onSelect: () -> Void
    var onNewEntry: (() -> Void)? = nil
    var onRename: ((String) -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    @State private var showingEditJournal = false
    @State private var isRenaming = false
    @State private var editedName = ""
    @State private var showingDeleteConfirmation = false
    @FocusState private var isNameFieldFocused: Bool

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
                            .overlay(
                                // Shared or Concealed icon
                                Group {
                                    if journal.isShared == true {
                                        Text(DayOneIcon.users.rawValue)
                                            .font(.custom("DayOneIcons", size: 16))
                                            .foregroundStyle(.white)
                                    } else if journal.isConcealed == true {
                                        Text(DayOneIcon.eye_cross.rawValue)
                                            .font(.custom("DayOneIcons", size: 16))
                                            .foregroundStyle(.white)
                                    }
                                }
                            )

                        // Journal info
                        VStack(alignment: .leading, spacing: 4) {
                            if isRenaming {
                                TextField("Journal Name", text: $editedName)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .focused($isNameFieldFocused)
                                    .onSubmit {
                                        if !editedName.isEmpty {
                                            onRename?(editedName)
                                        }
                                        isRenaming = false
                                    }
                                    .submitLabel(.done)
                            } else {
                                Text(journal.name)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                            }

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

                                        if journal.isShared == true, let memberCount = journal.memberCount {
                                            Text("•")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text("\(memberCount) members")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            } else if let count = journal.entryCount {
                                HStack(spacing: 4) {
                                    Text("\(count) entries")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    if journal.isShared == true, let memberCount = journal.memberCount {
                                        Text("•")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("\(memberCount) members")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 0)
            .padding(.bottom, 4)

            Divider()
                .padding(.leading, 0)
        }
        .contextMenu {
            if let newEntry = onNewEntry {
                Button {
                    newEntry()
                } label: {
                    Label("New Entry", systemImage: "plus")
                }
            }

            Button {
                showingEditJournal = true
            } label: {
                Label("Edit Journal", systemImage: "pencil")
            }

            Button {
                editedName = journal.name
                isRenaming = true
                isNameFieldFocused = true
            } label: {
                Label("Rename", systemImage: "character.cursor.ibeam")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            // New Entry (journal color)
            if let newEntry = onNewEntry {
                Button(action: newEntry) {
                    Label("New Entry", systemImage: "plus")
                }
                .tint(journal.color)
            }

            // Edit Journal (gray)
            Button(action: {
                showingEditJournal = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.gray)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
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

                            if journal.isShared == true, let memberCount = journal.memberCount {
                                Text("•")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text("\(memberCount)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                } else if let count = journal.entryCount {
                    HStack(spacing: 4) {
                        Text("\(count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        if journal.isShared == true, let memberCount = journal.memberCount {
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(memberCount)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
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
struct FolderDetailView: View, StyleComputedProperties {
    let folder: JournalFolder
    let sheetRegularPosition: CGFloat  // Kept for compatibility
    @State private var showingEditView = false
    @State private var showCoverImage = false
    @State private var useLargeListDates = false
    @State private var selectedContentTab: JournalDetailTab = .timeline
    @Environment(\.dismiss) private var dismiss
    @AppStorage("journalDetailStyle") var selectedStyle: JournalDetailStyle = .colored
    @AppStorage("mediaViewSize") var mediaViewSize: MediaViewSize = .medium

    // StyleComputedProperties requirement
    var color: Color { folder.color }

    // Get journal names as comma-separated string
    private var journalNames: String {
        folder.journals.map { $0.name }.joined(separator: ", ")
    }

    var body: some View {
        simpleLayout
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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

                    DetailSettingsSection(
                        sectionTitle: "Folder Detail Options",
                        showCoverImage: $showCoverImage,
                        useLargeListDates: $useLargeListDates,
                        selectedStyle: $selectedStyle,
                        mediaViewSize: $mediaViewSize
                    )
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
        .toolbarBackground(.automatic, for: .navigationBar)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(toolbarColorScheme, for: .navigationBar)
        .sheet(isPresented: $showingEditView) {
            PagedEditJournalView(journal: folder.journals.first ?? Journal(name: folder.name, color: folder.color, entryCount: folder.entryCount))
        }
    }

    // MARK: - Simple Layout
    private var simpleLayout: some View {
        SimpleDetailLayout(
            title: folder.name,
            subtitle: journalNames,
            headerBackgroundColor: headerBackgroundColor,
            headerTextColor: headerTextColor,
            showCoverImage: showCoverImage,
            coverImageName: "bike",
            fabJournal: folder.journals.first ?? Journal(name: folder.name, color: folder.color, entryCount: folder.entryCount),
            onFabTap: {
                // Present entry view
                // TODO: Implement entry view presentation
            }
        ) {
            simpleLayoutContent
        }
    }

    // MARK: - Simple Layout Content
    private var simpleLayoutContent: some View {
        VStack(spacing: 0) {
            // Pill Picker (Mail-style)
            JournalDetailPillPicker(
                tabs: JournalDetailTab.allTabs,
                selection: $selectedContentTab,
                selectedColor: selectedPillColor
            )
            .padding(.bottom, 12)

            // Content based on selected tab
            Group {
                switch selectedContentTab {
                case .book:
                    PagedCoverTabView(journal: folder.journals.first ?? Journal(name: folder.name, color: folder.color, entryCount: folder.entryCount))
                case .timeline:
                    ListTabView(journal: folder.journals.first ?? Journal(name: folder.name, color: folder.color, entryCount: folder.entryCount), useLargeListDates: useLargeListDates)
                case .calendar:
                    CalendarTabView(journal: folder.journals.first ?? Journal(name: folder.name, color: folder.color, entryCount: folder.entryCount))
                case .media:
                    MediaTabView(mediaViewSize: mediaViewSize)
                case .map:
                    MapTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 120) // Extra padding for FAB clearance
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

// MARK: - Journals Sections Order View
struct JournalsSectionsOrderView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sectionOrder: [JournalSectionType]
    @Binding var showRecentJournals: Bool
    @Binding var showRecentEntries: Bool
    @Binding var showJournalsSection: Bool
    @Binding var showNewJournalButtons: Bool

    var body: some View {
        NavigationStack {
            List {
                ForEach(sectionOrder, id: \.self) { section in
                    HStack {
                        Image(systemName: section.icon)
                            .foregroundStyle(.secondary)
                            .frame(width: 24)

                        Text(section.displayName)
                            .font(.body)

                        Spacer()

                        Toggle("", isOn: bindingForSection(section))
                    }
                }
                .onMove { from, to in
                    sectionOrder.move(fromOffsets: from, toOffset: to)
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Sort Sections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func bindingForSection(_ section: JournalSectionType) -> Binding<Bool> {
        switch section {
        case .recentJournals:
            return $showRecentJournals
        case .recentEntries:
            return $showRecentEntries
        case .journals:
            return $showJournalsSection
        case .newJournalButtons:
            return $showNewJournalButtons
        }
    }
}

// MARK: - All Entries Collection-Style Rows

struct CompactAllEntriesCollectionRow: View {
    let totalJournalCount: Int
    let totalEntryCount: Int
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // All Entries icon (library icon)
                Image("files-library-media-library")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color(hex: "333B40"))

                // All Entries text
                Text("All Entries")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Spacer()

                // Journal count and entry count
                HStack(spacing: 8) {
                    Text("\(totalJournalCount) journals")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(totalEntryCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // No disclosure toggle for All Entries
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 0)
        .padding(.horizontal, 0)
    }
}

struct AllEntriesCollectionRow: View {
    let totalJournalCount: Int
    let totalEntryCount: Int
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // All Entries icon and content - tappable to select
                Button(action: onSelect) {
                    HStack(spacing: 16) {
                        // All Entries icon (library icon)
                        Image("files-library-media-library")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color(hex: "333B40"))

                        // All Entries info
                        VStack(alignment: .leading, spacing: 2) {
                            Text("All Entries")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            HStack(spacing: 4) {
                                Text("\(totalJournalCount) journals")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("\(totalEntryCount) entries")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                // No disclosure toggle for All Entries
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 0)

            // Divider at bottom
            Divider()
                .padding(.leading, 0)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

// MARK: - Trash Collection-Style Rows

struct CompactTrashRow: View {
    let itemCount: Int
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Trash icon
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                // Trash text
                Text("Trash")
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundStyle(.primary)

                Spacer()

                // Item count
                Text("\(itemCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // No disclosure toggle for Trash
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 0)
        .padding(.horizontal, 0)
    }
}

struct TrashRow: View {
    let itemCount: Int
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Trash icon and content - tappable to select
                Button(action: onSelect) {
                    HStack(spacing: 16) {
                        // Trash icon
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                            .frame(width: 30)

                        // Trash info
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Trash")
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundStyle(.primary)

                            Text("\(itemCount) items")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                // No disclosure toggle for Trash
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 0)

            // Divider at bottom
            Divider()
                .padding(.leading, 0)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

// MARK: - Journal Section Type
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

// Simple adapter node for journals
struct JournalNode: Identifiable, Equatable {
    let id: String
    let journal: Journal

    var name: String { journal.name }
    var color: Color { journal.color }
    var entryCount: Int? { journal.entryCount }
}

// Collection (formerly Folder) node with expandable contents
struct CollectionNode: Identifiable, Equatable {
    let id: String
    var name: String
    var contents: [JournalNode]
    var isExpanded: Bool = false

    var itemCount: Int { contents.count }
    var color: Color { Color(hex: "333B40") }
}

// Display node union type for rendering
enum DisplayNode: Identifiable, Equatable {
    case journal(JournalNode, isNested: Bool = false)
    case collection(CollectionNode)
    case dropZone

    var id: String {
        switch self {
        case .journal(let journal, _): return journal.id
        case .collection(let collection): return collection.id
        case .dropZone: return "dropZone"
        }
    }
}

// MARK: - Journals Reorder View

struct JournalsReorderView: View {
    // MARK: - Layout Constants
    private enum Layout {
        static let nestedIndentation: CGFloat = 32
        static let rowVerticalPadding: CGFloat = 4
        static let iconSize: CGFloat = 20
        static let rowSpacing: CGFloat = 12
    }

    // MARK: - Haptics
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    @Environment(\.dismiss) private var dismiss

    // Input data
    let journals: [Journal]
    let folders: [JournalFolder]
    @Binding var journalItems: [Journal.MixedJournalItem]

    // State management
    @State private var rootItems: [DisplayNode] = []
    @State private var collections: [String: CollectionNode] = [:]

    // Cached computed properties
    @State private var cachedDisplayedItems: [DisplayNode] = []
    @State private var cachedOrderedCollections: [CollectionNode] = []

    // Flash animation state
    @State private var flashingCollectionId: String? = nil
    @State private var flashColor: Color = .blue
    @State private var flashingJournalId: String? = nil
    @State private var flashingJournalColor: Color = .blue

    // Scroll state
    @State private var scrollToId: String? = nil

    // Toolbar hint overlays
    @State private var showToolbarHints = true

    let accentColor = Color(hex: "44C0FF")

    // Computed counts for navigation title
    private var totalJournalCount: Int {
        var count = 0
        for item in rootItems {
            switch item {
            case .journal:
                count += 1
            case .collection(let collection):
                count += collection.contents.count
            case .dropZone:
                break
            }
        }
        return count
    }

    private var totalCollectionCount: Int {
        return collections.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    List {
                        ForEach(cachedDisplayedItems) { item in
                        switch item {
                        case .journal(let journalNode, let isNested):
                            JournalReorderRow(
                                journalNode: journalNode,
                                isNested: isNested,
                                orderedCollections: cachedOrderedCollections,
                                accentColor: accentColor,
                                isFlashing: flashingJournalId == journalNode.id,
                                flashColor: flashingJournalColor,
                                onMoveToCollection: { collectionId in
                                    moveJournalToCollection(journal: journalNode, collectionId: collectionId)
                                },
                                onRemoveFromCollection: {
                                    removeJournalFromCollection(journal: journalNode)
                                },
                                onRename: { newName in
                                    renameJournal(id: journalNode.id, newName: newName)
                                },
                                onEdit: {
                                    // TODO: Implement edit journal action
                                },
                                onPreviewBook: {
                                    // TODO: Implement preview book action
                                },
                                onExport: {
                                    // TODO: Implement export action
                                },
                                onDelete: {
                                    deleteJournal(id: journalNode.id)
                                }
                            )
                        case .collection(let collection):
                            CollectionReorderRow(
                                collection: collection,
                                accentColor: accentColor,
                                isFlashing: flashingCollectionId == collection.id,
                                flashColor: flashColor,
                                onTap: { toggleCollection(id: collection.id) },
                                onRename: { newName in
                                    renameCollection(id: collection.id, newName: newName)
                                },
                                onPreviewBook: {
                                    // TODO: Implement preview book action
                                },
                                onExport: {
                                    // TODO: Implement export action
                                },
                                onDelete: {
                                    deleteCollection(id: collection.id)
                                }
                            )
                        case .dropZone:
                            EmptyView()
                        }
                    }
                        .onMove(perform: moveItem)
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, .constant(.active)) // Always in edit mode
                    .onChange(of: scrollToId) { _, newId in
                        if let id = newId {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    proxy.scrollTo(id, anchor: .bottom)
                                }
                                scrollToId = nil
                            }
                        }
                    }
                }

                // Empty state
                if rootItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.5))

                        Text("No Journals Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Text("Tap the + button below to create your first journal")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .navigationTitle("\(totalJournalCount) \(totalJournalCount == 1 ? "Journal" : "Journals"), \(totalCollectionCount) \(totalCollectionCount == 1 ? "Collection" : "Collections")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Top trailing - Done button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        applyChangesAndDismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(accentColor)
                            .fontWeight(.semibold)
                    }
                }

                // Bottom bar - New Collection button
                ToolbarItem(placement: .bottomBar) {
                    Button("New Collection", systemImage: "folder.badge.plus") {
                        addNewCollection()
                        showToolbarHints = false
                    }
                    .labelStyle(.titleAndIcon)
                }

                // Bottom bar - New Journal button
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }

                ToolbarItem(placement: .bottomBar) {
                    Button("New Journal", systemImage: "plus") {
                        addNewJournal()
                        showToolbarHints = false
                    }
                    .labelStyle(.titleAndIcon)
                }
            }
            .overlay(alignment: .bottom) {
                if showToolbarHints {
                    HStack(spacing: 0) {
                        // New Collection hint overlay
                        Image("journals-new-collection")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 163)
                            .padding(.leading, 56)

                        Spacer()

                        // New Journal hint overlay
                        Image("journals-new-journal")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 118)
                            .padding(.trailing, 56)
                    }
                    .padding(.bottom, 0)
                    .allowsHitTesting(false)
                }
            }
            .onTapGesture {
                showToolbarHints = false
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            initializeFromJournals()
            rebuildCache()
        }
    }

    // MARK: - Initialization

    private func initializeFromJournals() {
        // Convert existing data to our node structure
        rootItems = []
        collections = [:]

        // Build collections dictionary from folders
        for folder in folders {
            let journalNodes = folder.journals.map { JournalNode(id: $0.id, journal: $0) }
            let collection = CollectionNode(
                id: folder.id,
                name: folder.name,
                contents: journalNodes,
                isExpanded: false
            )
            collections[collection.id] = collection
        }

        // Build root items based on journalItems order
        for item in journalItems {
            if item.isFolder, let folder = item.folder {
                if let collection = collections[folder.id] {
                    rootItems.append(.collection(collection))
                }
            } else if let journal = item.journal {
                let journalNode = JournalNode(id: journal.id, journal: journal)
                rootItems.append(.journal(journalNode, isNested: false))
            }
        }
    }

    // MARK: - Cache Management

    private func rebuildCache() {
        var result: [DisplayNode] = []
        for item in rootItems {
            result.append(item)
            if case .collection(let collection) = item, collection.isExpanded {
                result.append(contentsOf: collection.contents.map { .journal($0, isNested: true) })
            }
        }
        cachedDisplayedItems = result

        cachedOrderedCollections = rootItems.compactMap { item in
            if case .collection(let collection) = item {
                return collection
            }
            return nil
        }
    }

    // MARK: - Collection Operations

    func toggleCollection(id: String) {
        selectionFeedback.selectionChanged()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let index = findCollectionIndex(id: id),
               case .collection(var collection) = rootItems[index] {
                collection.isExpanded.toggle()
                updateCollection(collection)
                rebuildCache()
                applyChangesLive()
            }
        }
    }

    func renameCollection(id: String, newName: String) {
        withAnimation {
            if let index = findCollectionIndex(id: id),
               case .collection(var collection) = rootItems[index] {
                collection.name = newName
                updateCollection(collection)
                rootItems[index] = .collection(collection)
                rebuildCache()
                applyChangesLive()
            }
        }
    }

    func renameJournal(id: String, newName: String) {
        withAnimation {
            // Find journal in root items
            if let index = rootItems.firstIndex(where: {
                if case .journal(let node, _) = $0, node.id == id {
                    return true
                }
                return false
            }), case .journal(let node, let isNested) = rootItems[index] {
                // Create new journal with updated name
                let updatedJournal = node.journal.withName(newName)
                let updatedNode = JournalNode(id: node.id, journal: updatedJournal)
                rootItems[index] = .journal(updatedNode, isNested: isNested)
                rebuildCache()
                applyChangesLive()
                return
            }

            // Find journal in collections
            for (collectionId, var collection) in collections {
                if let journalIndex = collection.contents.firstIndex(where: { $0.id == id }) {
                    // Create new journal with updated name
                    let updatedJournal = collection.contents[journalIndex].journal.withName(newName)
                    let updatedNode = JournalNode(id: collection.contents[journalIndex].id, journal: updatedJournal)
                    collection.contents[journalIndex] = updatedNode
                    updateCollection(collection)
                    rebuildCache()
                    applyChangesLive()
                    return
                }
            }
        }
    }

    func deleteJournal(id: String) {
        impactMedium.impactOccurred()
        withAnimation {
            // Find and remove journal from root items
            if let index = rootItems.firstIndex(where: {
                if case .journal(let node, _) = $0, node.id == id {
                    return true
                }
                return false
            }) {
                rootItems.remove(at: index)
                rebuildCache()
                applyChangesLive()
                return
            }

            // Find and remove journal from collections
            for (collectionId, var collection) in collections {
                if let journalIndex = collection.contents.firstIndex(where: { $0.id == id }) {
                    collection.contents.remove(at: journalIndex)
                    updateCollection(collection)
                    rebuildCache()
                    applyChangesLive()
                    return
                }
            }
        }
    }

    func deleteCollection(id: String) {
        impactMedium.impactOccurred()
        withAnimation {
            // Find the collection in rootItems
            guard let index = findCollectionIndex(id: id),
                  case .collection(let collection) = rootItems[index] else {
                return
            }

            // Extract journals from the collection
            let journalsToPreserve = collection.contents.map { journalNode in
                DisplayNode.journal(journalNode, isNested: false)
            }

            // Remove the collection from rootItems
            rootItems.remove(at: index)

            // Insert the journals at the position where the collection was
            rootItems.insert(contentsOf: journalsToPreserve, at: index)

            // Remove from collections dictionary
            collections.removeValue(forKey: id)

            rebuildCache()
            applyChangesLive()
        }
    }

    func addNewCollection() {
        impactMedium.impactOccurred()
        let newId = UUID().uuidString
        withAnimation {
            let newName = generateNextCollectionName()

            // Create the collection node
            let newCollection = CollectionNode(id: newId, name: newName, contents: [], isExpanded: false)
            collections[newCollection.id] = newCollection
            rootItems.append(.collection(newCollection))

            rebuildCache()
            applyChangesLive()
        }

        // Scroll to the newly created collection
        scrollToId = newId
    }

    private func generateNextCollectionName() -> String {
        let existingNames = Set(collections.values.map { $0.name })
        var counter = 1

        while existingNames.contains("Collection \(counter)") {
            counter += 1
        }

        return "Collection \(counter)"
    }

    private func incrementSuffix(_ suffix: String) -> String {
        var chars = Array(suffix)
        var index = chars.count - 1

        while index >= 0 {
            if chars[index] < "Z" {
                chars[index] = Character(UnicodeScalar(chars[index].asciiValue! + 1))
                return String(chars)
            } else {
                chars[index] = "A"
                index -= 1
            }
        }

        return "A" + String(chars)
    }

    func addNewJournal() {
        impactMedium.impactOccurred()

        // Generate a unique name for the new journal
        let newName = generateNextJournalName()

        // Create a new journal with a random color from Day One palette
        let colors = [
            Color(hex: "44C0FF"), Color(hex: "FFC107"), Color(hex: "2DCC71"),
            Color(hex: "3398DB"), Color(hex: "6A6DCD"), Color(hex: "607D8B"),
            Color(hex: "C27BD2"), Color(hex: "FF983B"), Color(hex: "E91E63"),
            Color(hex: "16D6D9")
        ]
        let randomColor = colors.randomElement() ?? Color(hex: "44C0FF")

        // Create a new journal with random color
        let newJournal = Journal(
            name: newName,
            color: randomColor,
            entryCount: 0
        )

        // Create node and add to bottom of root items
        let journalNode = JournalNode(id: newJournal.id, journal: newJournal)
        let newId = journalNode.id
        rootItems.append(.journal(journalNode, isNested: false))

        // Rebuild cache and apply changes
        rebuildCache()
        applyChangesLive()

        // Scroll to the newly created journal
        scrollToId = newId
    }

    private func generateNextJournalName() -> String {
        // Collect all existing journal names from rootItems
        var existingNames = Set<String>()
        for item in rootItems {
            switch item {
            case .journal(let journalNode, _):
                existingNames.insert(journalNode.name)
            case .collection(let collection):
                for journalNode in collection.contents {
                    existingNames.insert(journalNode.name)
                }
            case .dropZone:
                break
            }
        }

        var counter = 1
        while existingNames.contains("Journal \(counter)") {
            counter += 1
        }

        return "Journal \(counter)"
    }

    // MARK: - Save and Dismiss

    /// Apply current state to journalItems binding in real-time
    private func applyChangesLive() {
        var updatedItems: [Journal.MixedJournalItem] = []

        for item in rootItems {
            switch item {
            case .journal(let journalNode, _):
                // Root-level journal - use the journal stored in the node
                updatedItems.append(Journal.MixedJournalItem(journal: journalNode.journal))

            case .collection(let collection):
                // Collection with its journals - rebuild folder with reordered contents
                let reorderedJournals = collection.contents.map { journalNode in
                    journalNode.journal
                }
                let updatedFolder = JournalFolder(
                    id: collection.id,
                    name: collection.name,
                    journals: reorderedJournals
                )
                updatedItems.append(Journal.MixedJournalItem(folder: updatedFolder))

            case .dropZone:
                break
            }
        }

        // Update the binding immediately (live updates)
        journalItems = updatedItems
    }

    func applyChangesAndDismiss() {
        // Apply any final changes
        applyChangesLive()

        // Dismiss the modal
        dismiss()
    }

    func findCollectionIndex(id: String) -> Int? {
        rootItems.firstIndex { item in
            if case .collection(let c) = item, c.id == id {
                return true
            }
            return false
        }
    }

    func updateCollection(_ collection: CollectionNode) {
        collections[collection.id] = collection
        if let index = findCollectionIndex(id: collection.id) {
            rootItems[index] = .collection(collection)
        }
    }

    // MARK: - Journal Movement

    func moveJournalToCollection(journal: JournalNode, collectionId: String) {
        guard var collection = collections[collectionId] else { return }

        withAnimation {
            removeJournalFromSource(journal)
            collection.contents.append(journal)
            updateCollection(collection)
            rebuildCache()
            applyChangesLive()
        }

        // Trigger flash animation on both the collection and the journal with journal's color
        flashingCollectionId = collectionId
        flashingJournalId = journal.id
        flashColor = journal.journal.color
        flashingJournalColor = journal.journal.color
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            flashingCollectionId = nil
            flashingJournalId = nil
        }
    }

    func removeJournalFromCollection(journal: JournalNode) {
        withAnimation {
            var parentCollectionId: String?
            var parentCollectionIndex: Int?

            for (index, item) in rootItems.enumerated() {
                if case .collection(let collection) = item {
                    if collection.contents.contains(where: { $0.id == journal.id }) {
                        parentCollectionId = collection.id
                        parentCollectionIndex = index
                        break
                    }
                }
            }

            guard let collectionId = parentCollectionId,
                  let collectionIndex = parentCollectionIndex,
                  var collection = collections[collectionId] else { return }

            collection.contents.removeAll { $0.id == journal.id }
            updateCollection(collection)

            rootItems.insert(.journal(journal, isNested: false), at: collectionIndex + 1)
            rebuildCache()
            applyChangesLive()
        }
    }

    func removeJournalFromSource(_ journal: JournalNode) {
        if let index = rootItems.firstIndex(where: {
            if case .journal(let j, _) = $0, j.id == journal.id { return true }
            return false
        }) {
            rootItems.remove(at: index)
            return
        }

        for (_, var collection) in collections {
            if let index = collection.contents.firstIndex(where: { $0.id == journal.id }) {
                collection.contents.remove(at: index)
                updateCollection(collection)
                return
            }
        }
    }

    // MARK: - Drag & Drop

    func moveItem(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        let movedItem = cachedDisplayedItems[sourceIndex]

        let operation = determineMoveOperation(movedItem: movedItem, sourceIndex: sourceIndex, destination: destination)

        withAnimation {
            switch operation {
            case .collectionMove(let fromRootIndex, let toRootIndex):
                rootItems.move(fromOffsets: IndexSet(integer: fromRootIndex), toOffset: toRootIndex)

            case .sameContextMove(let sourceContext, let fromIndex, let toIndex):
                performSameContextMove(sourceContext: sourceContext, fromIndex: fromIndex, toIndex: toIndex)

            case .crossLevelMove(let journal, _, let toContext, let destination):
                performCrossLevelMove(journal: journal, fromContext: getItemContext(at: sourceIndex), toContext: toContext, destination: destination)

            case .invalid:
                return
            }

            impactLight.impactOccurred()
            rebuildCache()
            applyChangesLive()
        }
    }

    private func determineMoveOperation(movedItem: DisplayNode, sourceIndex: Int, destination: Int) -> MoveOperation {
        if case .dropZone = movedItem { return .invalid }

        if case .collection = movedItem {
            let rootIndex = mapDisplayIndexToRootIndex(sourceIndex)
            let destRootIndex = mapDisplayIndexToRootIndex(destination)
            guard rootIndex >= 0 && rootIndex < rootItems.count else { return .invalid }
            guard destRootIndex >= 0 && destRootIndex <= rootItems.count else { return .invalid }
            return .collectionMove(fromRootIndex: rootIndex, toRootIndex: destRootIndex)
        }

        guard case .journal(let journal, _) = movedItem else { return .invalid }

        let sourceContext = getItemContext(at: sourceIndex)
        var destinationContext = getItemContext(at: destination)

        if case .inCollection(let sourceCollectionId) = sourceContext,
           destinationContext != sourceContext {
            if let collectionIndex = cachedDisplayedItems.firstIndex(where: { item in
                if case .collection(let c) = item, c.id == sourceCollectionId { return true }
                return false
            }),
               case .collection(let sourceCollection) = cachedDisplayedItems[collectionIndex] {
                let collectionEndIndex = collectionIndex + sourceCollection.contents.count
                if destination == collectionEndIndex + 1 {
                    destinationContext = .inCollection(sourceCollectionId)
                }
            }
        }

        if sourceContext == destinationContext {
            return .sameContextMove(sourceContext: sourceContext, fromIndex: sourceIndex, toIndex: destination)
        }

        return .crossLevelMove(journal: journal, fromContext: sourceContext, toContext: destinationContext, destination: destination)
    }

    private func performSameContextMove(sourceContext: ItemContext, fromIndex: Int, toIndex: Int) {
        if sourceContext == .root {
            let rootIndex = mapDisplayIndexToRootIndex(fromIndex)
            let destRootIndex = mapDisplayIndexToRootIndex(toIndex)
            guard rootIndex >= 0 && rootIndex < rootItems.count else { return }
            guard destRootIndex >= 0 && destRootIndex <= rootItems.count else { return }
            rootItems.move(fromOffsets: IndexSet(integer: rootIndex), toOffset: destRootIndex)
        } else if case .inCollection(let collectionId) = sourceContext,
                  var collection = collections[collectionId] {
            let collectionStartIndex = cachedDisplayedItems.firstIndex { item in
                if case .collection(let c) = item, c.id == collectionId { return true }
                return false
            }

            if let collectionStart = collectionStartIndex {
                let sourceInCollection = fromIndex - collectionStart - 1
                let destInCollection = toIndex - collectionStart - 1
                guard sourceInCollection >= 0 && sourceInCollection < collection.contents.count else { return }
                guard destInCollection >= 0 && destInCollection <= collection.contents.count else { return }
                collection.contents.move(fromOffsets: IndexSet(integer: sourceInCollection), toOffset: destInCollection)
                updateCollection(collection)
            }
        }
    }

    private func performCrossLevelMove(journal: JournalNode, fromContext: ItemContext, toContext: ItemContext, destination: Int) {
        var calculatedInsertPosition: Int?
        var calculatedCollectionId: String?

        if case .inCollection(let destCollectionId) = toContext,
           let destCollection = collections[destCollectionId] {
            if let collectionStartIndex = cachedDisplayedItems.firstIndex(where: { item in
                if case .collection(let c) = item, c.id == destCollectionId { return true }
                return false
            }) {
                let positionInCollection = destination - collectionStartIndex - 1
                calculatedInsertPosition = max(0, min(positionInCollection, destCollection.contents.count))
                calculatedCollectionId = destCollectionId
            }
        } else {
            calculatedInsertPosition = mapDisplayIndexToRootIndex(destination)
        }

        removeJournalFromSource(journal)

        if let collectionId = calculatedCollectionId,
           let insertPos = calculatedInsertPosition,
           var destCollection = collections[collectionId] {
            let finalInsertPosition = min(insertPos, destCollection.contents.count)
            destCollection.contents.insert(journal, at: finalInsertPosition)
            if !destCollection.isExpanded {
                destCollection.isExpanded = true
            }
            updateCollection(destCollection)
        } else if let insertPos = calculatedInsertPosition {
            let finalInsertPosition = min(insertPos, rootItems.count)
            rootItems.insert(.journal(journal, isNested: false), at: finalInsertPosition)
        }
    }

    func mapDisplayIndexToRootIndex(_ displayIndex: Int) -> Int {
        var rootCount = 0
        var currentDisplayIndex = 0

        for item in rootItems {
            if currentDisplayIndex >= displayIndex {
                return rootCount
            }
            currentDisplayIndex += 1
            if case .collection(let collection) = item, collection.isExpanded {
                currentDisplayIndex += collection.contents.count
            }
            rootCount += 1
        }

        return rootCount
    }

    enum ItemContext: Equatable {
        case root
        case inCollection(String)
    }

    enum MoveOperation {
        case collectionMove(fromRootIndex: Int, toRootIndex: Int)
        case sameContextMove(sourceContext: ItemContext, fromIndex: Int, toIndex: Int)
        case crossLevelMove(journal: JournalNode, fromContext: ItemContext, toContext: ItemContext, destination: Int)
        case invalid
    }

    func getItemContext(at index: Int) -> ItemContext {
        guard index < cachedDisplayedItems.count else { return .root }

        for i in stride(from: index, through: 0, by: -1) {
            if case .collection(let collection) = cachedDisplayedItems[i] {
                if collection.isExpanded && i < index {
                    let collectionEndIndex = i + collection.contents.count
                    if index > i && index <= collectionEndIndex {
                        return .inCollection(collection.id)
                    }
                }
                if i == index {
                    return .root
                }
            }
        }

        return .root
    }
}

// MARK: - Journal Reorder Row

struct JournalReorderRow: View {
    let journalNode: JournalNode
    let isNested: Bool
    let orderedCollections: [CollectionNode]
    let accentColor: Color
    let isFlashing: Bool
    let flashColor: Color
    let onMoveToCollection: (String) -> Void
    let onRemoveFromCollection: () -> Void
    let onRename: ((String) -> Void)?
    let onEdit: (() -> Void)?
    let onPreviewBook: (() -> Void)?
    let onExport: (() -> Void)?
    let onDelete: (() -> Void)?

    @State private var isRenaming = false
    @State private var editedName = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var showingDeleteConfirmation = false

    private enum Layout {
        static let iconSize: CGFloat = 12
        static let rowSpacing: CGFloat = 14
        static let rowVerticalPadding: CGFloat = 0
        static let nestedIndentation: CGFloat = 32
    }

    var body: some View {
        HStack(spacing: Layout.rowSpacing) {
            // Use smaller circle with journal's color
            Circle()
                .fill(journalNode.color)
                .frame(width: Layout.iconSize, height: Layout.iconSize)

            if isRenaming {
                TextField("Journal Name", text: $editedName)
                    .font(.body)
                    .focused($isNameFieldFocused)
                    .onSubmit {
                        if !editedName.isEmpty {
                            onRename?(editedName)
                        }
                        isRenaming = false
                    }
                    .submitLabel(.done)
                    .onChange(of: isNameFieldFocused) { _, isFocused in
                        if !isFocused && isRenaming {
                            if !editedName.isEmpty {
                                onRename?(editedName)
                            }
                            isRenaming = false
                        }
                    }
            } else {
                Text(journalNode.name)
                    .font(.body)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }

            Spacer()

            // Shared or Concealed icon
            if journalNode.journal.isShared == true {
                Text(DayOneIcon.users.rawValue)
                    .font(.custom("DayOneIcons", size: 14))
                    .foregroundStyle(.secondary)
            } else if journalNode.journal.isConcealed == true {
                Text(DayOneIcon.eye_cross.rawValue)
                    .font(.custom("DayOneIcons", size: 14))
                    .foregroundStyle(.secondary)
            }

            // Entry count
            if let count = journalNode.entryCount {
                Text("\(count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Ellipsis menu
            Menu {
                if let onEdit = onEdit {
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit Journal", systemImage: "pencil")
                    }
                }

                if let onRename = onRename {
                    Button {
                        editedName = journalNode.name
                        isRenaming = true
                        isNameFieldFocused = true
                    } label: {
                        Label("Rename", systemImage: "character.cursor.ibeam")
                    }
                }

                if !orderedCollections.isEmpty {
                    Menu {
                        ForEach(orderedCollections, id: \.id) { collection in
                            Button {
                                onMoveToCollection(collection.id)
                            } label: {
                                Label(collection.name, systemImage: "folder")
                            }
                        }
                    } label: {
                        Label("Move to Collection", systemImage: "folder.badge.plus")
                    }
                }

                if isNested {
                    Button {
                        onRemoveFromCollection()
                    } label: {
                        Label("Remove from Collection", systemImage: "folder.badge.minus")
                    }
                }

                Divider()

                if let onExport = onExport {
                    Button {
                        onExport()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }

                if let onPreviewBook = onPreviewBook {
                    Button {
                        onPreviewBook()
                    } label: {
                        Label("Preview Book", systemImage: "book")
                    }
                }

                if let onDelete = onDelete {
                    Divider()

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .font(.body)
            }
            .buttonStyle(.plain)

            // Collection add/remove icon (always visible in edit mode)
            if isNested {
                Button {
                    onRemoveFromCollection()
                } label: {
                    Image(systemName: "folder.badge.minus")
                        .foregroundColor(.secondary)
                        .font(.body)
                }
                .buttonStyle(.plain)
            } else {
                Menu {
                    ForEach(orderedCollections, id: \.id) { collection in
                        Button {
                            onMoveToCollection(collection.id)
                        } label: {
                            Label(collection.name, systemImage: "folder")
                        }
                    }
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(accentColor)
                        .font(.body)
                }
            }
        }
        .padding(.vertical, Layout.rowVerticalPadding)
        .padding(.leading, isNested ? Layout.nestedIndentation : 0)
        .listRowBackground(
            Rectangle()
                .fill(flashColor.opacity(isFlashing ? 0.1 : 0))
                .animation(.easeOut(duration: 0.4), value: isFlashing)
        )
        .onTapGesture(count: 2) {
            editedName = journalNode.name
            isRenaming = true
            isNameFieldFocused = true
        }
        .alert("Delete Journal", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("Are you sure you want to delete \"\(journalNode.name)\"? This action cannot be undone.")
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 24))
    }
}

// MARK: - Collection Reorder Row

struct CollectionReorderRow: View {
    let collection: CollectionNode
    let accentColor: Color
    let isFlashing: Bool
    let flashColor: Color
    let onTap: () -> Void
    let onRename: ((String) -> Void)?
    let onPreviewBook: (() -> Void)?
    let onExport: (() -> Void)?
    let onDelete: (() -> Void)?

    @State private var isRenaming = false
    @State private var editedName = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var showingDeleteConfirmation = false

    private enum Layout {
        static let iconSize: CGFloat = 20
        static let rowSpacing: CGFloat = 12
        static let rowVerticalPadding: CGFloat = 4
    }

    var body: some View {
        HStack(spacing: Layout.rowSpacing) {
            // Use media-library-folder icon like main journals page
            Image("media-library-folder")
                .resizable()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .foregroundStyle(collection.color)

            if isRenaming {
                TextField("Collection Name", text: $editedName)
                    .font(.body)
                    .fontWeight(.semibold)
                    .focused($isNameFieldFocused)
                    .onSubmit {
                        if !editedName.isEmpty {
                            onRename?(editedName)
                        }
                        isRenaming = false
                    }
                    .submitLabel(.done)
                    .onChange(of: isNameFieldFocused) { _, isFocused in
                        if !isFocused && isRenaming {
                            if !editedName.isEmpty {
                                onRename?(editedName)
                            }
                            isRenaming = false
                        }
                    }
            } else {
                Text(collection.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }

            Spacer()

            // Journal count on right side
            Text("\(collection.itemCount) Journals")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Ellipsis menu
            Menu {
                if let onRename = onRename {
                    Button {
                        editedName = collection.name
                        isRenaming = true
                        isNameFieldFocused = true
                    } label: {
                        Label("Rename", systemImage: "character.cursor.ibeam")
                    }
                }

                if let onPreviewBook = onPreviewBook {
                    Button {
                        onPreviewBook()
                    } label: {
                        Label("Preview Book", systemImage: "book")
                    }
                }

                if let onExport = onExport {
                    Button {
                        onExport()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }

                if let onDelete = onDelete {
                    Divider()

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .font(.body)
            }
            .buttonStyle(.plain)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(collection.isExpanded ? 90 : 0))
        }
        .padding(.vertical, Layout.rowVerticalPadding)
        .listRowBackground(
            Rectangle()
                .fill(flashColor.opacity(isFlashing ? 0.1 : 0))
                .animation(.easeOut(duration: 0.4), value: isFlashing)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onTapGesture(count: 2) {
            editedName = collection.name
            isRenaming = true
            isNameFieldFocused = true
        }
        .alert("Delete Collection", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            if collection.itemCount > 0 {
                Text("This collection contains \(collection.itemCount) \(collection.itemCount == 1 ? "journal" : "journals"). All journals will be preserved and moved out of the collection.")
            } else {
                Text("Are you sure you want to delete this collection?")
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
}

#Preview("Paged") {
    JournalsTabPagedView()
}
