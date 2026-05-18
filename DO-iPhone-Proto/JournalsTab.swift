import SwiftUI
import UIKit
import TipKit

// MARK: - Constants

/// Size for toggle disclosure icons (arrow-right-circle)
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
    @State private var shouldAddCollectionOnModalOpen = false
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
    @State private var showingCreateJournal = false
    @State private var showingCreateCollection = false

    // Select Mode state
    @State private var isSelectMode = false
    @State private var selectedJournalIds: Set<String> = []

    // New Journal button style
    enum NewJournalButtonStyle: String, CaseIterable {
        case fab = "FAB"
        case topToolbar = "Top Toolbar"
    }
    @State private var newJournalButtonStyle: NewJournalButtonStyle = .fab
    @State private var showingNewJournalFAB = false

    // Rename state
    @State private var renamingCollectionID: String? = nil
    @State private var editedCollectionName = ""
    @FocusState private var collectionNameFieldFocused: Bool

    // Folder expansion state - expand all by default
    @State private var expandedFolders: Set<String> = Set(Journal.folders.map { $0.id })

    // Auto-scroll to newly created journal
    @State private var scrollToId: String? = nil

    // Sheet regular position from top (in points)
    let sheetRegularPosition: CGFloat = 250

    // Get visible journals and folders based on population setting
    private var filteredJournals: [Journal] {
        // Extract all journals from journalItems (dynamic data that gets updated by modal)
        var allJournals: [Journal] = []
        for item in journalItems {
            if let journal = item.journal {
                allJournals.append(journal)
            } else if let folder = item.folder {
                allJournals.append(contentsOf: folder.journals)
            }
        }

        // Return all journals - the filtering is already done in journalItems by repopulateJournals
        return allJournals
    }

    // Get all available collections (folders) for collection management menu
    private var availableCollections: [JournalFolder] {
        journalItems.compactMap { $0.folder }
    }

    // Select Mode computed properties
    private var selectedJournals: [Journal] {
        filteredJournals.filter { selectedJournalIds.contains($0.id) }
    }

    private var totalSelectedEntryCount: Int {
        selectedJournals.compactMap { $0.entryCount }.reduce(0, +)
    }

    private var selectModeNavigationTitle: String {
        selectedJournalIds.isEmpty ? "Journals" : "\(selectedJournalIds.count) Selected"
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
        // Return journalItems directly - it's already filtered by repopulateJournals
        return journalItems
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
        showingCreateJournal = true
    }

    private func createJournal(name: String, color: Color, isPersonal: Bool) {
        let newJournal = Journal(name: name, color: color, entryCount: 0)

        // Add to journalItems at the end
        journalItems.append(Journal.MixedJournalItem(journal: newJournal))

        // Scroll to make the new journal visible
        scrollToId = newJournal.id
    }

    private func createCollection(name: String, journalIds: [String]) {
        // Collect journals with matching IDs and remove them from their current locations
        var journalsToAdd: [Journal] = []
        var updatedItems: [Journal.MixedJournalItem] = []

        for item in journalItems {
            if let journal = item.journal {
                // Item is a journal
                if journalIds.contains(journal.id) {
                    journalsToAdd.append(journal)
                } else {
                    updatedItems.append(item)
                }
            } else if let folder = item.folder {
                // Item is a folder - remove selected journals from folder
                let remainingJournals = folder.journals.filter { journal in
                    if journalIds.contains(journal.id) {
                        journalsToAdd.append(journal)
                        return false
                    }
                    return true
                }

                // Only keep folder if it still has journals
                if !remainingJournals.isEmpty {
                    let updatedFolder = JournalFolder(
                        id: folder.id,
                        name: folder.name,
                        journals: remainingJournals
                    )
                    updatedItems.append(Journal.MixedJournalItem(folder: updatedFolder))
                }
            }
        }

        // Create new folder with collected journals
        let newFolderId = UUID().uuidString
        let newFolder = JournalFolder(id: newFolderId, name: name, journals: journalsToAdd)

        // Add new folder to the end
        updatedItems.append(Journal.MixedJournalItem(folder: newFolder))

        // Update journalItems
        journalItems = updatedItems

        // Expand the new collection before scrolling
        expandedFolders.insert(newFolderId)

        // Scroll to the new collection
        scrollToId = newFolderId
    }

    // Move selected journals to a collection (Select Mode)
    private func moveJournalsToCollection(_ collectionId: String) {
        guard let targetFolderIndex = journalItems.firstIndex(where: { $0.id == collectionId }),
              journalItems[targetFolderIndex].folder != nil else { return }

        let journalsToMove = selectedJournals

        // First, update all folders (remove journals from source folders, add to target)
        for i in 0..<journalItems.count {
            if let folder = journalItems[i].folder {
                if folder.id == collectionId {
                    // This is the target - add journals
                    let updatedFolder = folder.withJournals(folder.journals + journalsToMove)
                    journalItems[i] = Journal.MixedJournalItem(folder: updatedFolder)
                } else {
                    // This is a source folder - remove journals
                    let updatedJournals = folder.journals.filter { !selectedJournalIds.contains($0.id) }
                    if updatedJournals.count != folder.journals.count {
                        journalItems[i] = Journal.MixedJournalItem(folder: folder.withJournals(updatedJournals))
                    }
                }
            }
        }

        // Then remove standalone journals
        journalItems.removeAll { item in
            if let journal = item.journal {
                return selectedJournalIds.contains(journal.id)
            }
            return false
        }

        // Expand the target collection
        expandedFolders.insert(collectionId)

        // Deselect moved journals but remain in Select Mode
        selectedJournalIds.removeAll()
    }

    // View selected journals in detail view (Select Mode)
    private func viewSelectedJournals() {
        // Create temporary folder from selected journals
        let tempFolder = JournalFolder(
            id: "temp-selection",
            name: "\(selectedJournalIds.count) Selected",
            journals: selectedJournals
        )
        selectedFolder = tempFolder
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
        // Update the population setting
        journalsPopulation = option

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

            for (_, collectionName) in collectionNames.enumerated() {
                // 10-15 journals per collection
                let journalsInCollection = (10...15).randomElement() ?? 12
                var collectionJournals: [Journal] = []

                for _ in 0..<journalsInCollection {
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
                    // List mode use List which has built-in scrolling
                    // Grid mode uses ScrollView with LazyVStack
                    if viewMode == .list {
                        journalListContent
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                journalListContent
                                    .padding(.top, 12)
                                    .padding(.bottom, 70)
                            }
                        }
                    }
                }
                .navigationTitle(isSelectMode ? selectModeNavigationTitle : "Journals")
                .navigationBarTitleDisplayMode(isSelectMode ? .inline : .large)
                .toolbar {
                    if isSelectMode {
                        // SELECT MODE TOOLBAR

                        // Leading: Select All / Deselect All
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(selectedJournalIds.count == filteredJournals.count ? "Deselect All" : "Select All") {
                                if selectedJournalIds.count == filteredJournals.count {
                                    selectedJournalIds.removeAll()
                                } else {
                                    selectedJournalIds = Set(filteredJournals.map { $0.id })
                                }
                            }
                        }

                        // Trailing: X exit button
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                isSelectMode = false
                                selectedJournalIds.removeAll()
                            }) {
                                Image(systemName: "xmark")
                            }
                        }

                        // Custom title with subtitle when items are selected
                        if !selectedJournalIds.isEmpty {
                            ToolbarItem(placement: .principal) {
                                VStack(spacing: 2) {
                                    Text(selectModeNavigationTitle)
                                        .font(.headline)
                                    Text("\(totalSelectedEntryCount) Entries")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        // BOTTOM TOOLBAR - Native iOS 26 style
                        ToolbarItemGroup(placement: .bottomBar) {
                            // Left: "Move to..." menu
                            Menu {
                                ForEach(availableCollections.reversed(), id: \.id) { collection in
                                    Button(action: {
                                        moveJournalsToCollection(collection.id)
                                    }) {
                                        Label(collection.name, systemImage: "folder")
                                    }
                                }
                            } label: {
                                Text("Move to...")
                            }
                            .disabled(selectedJournalIds.isEmpty)

                            Spacer()

                            // Center: ellipsis menu
                            Menu {
                                Button(action: {
                                    // TODO: Export
                                }) {
                                    Label("Export", systemImage: "square.and.arrow.up")
                                }

                                Button(action: {
                                    // TODO: Preview book
                                }) {
                                    Label("Preview Book", systemImage: "book")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                            }
                            .disabled(selectedJournalIds.isEmpty)

                            Spacer()

                            // Right: "View" button
                            Button("View", action: viewSelectedJournals)
                                .disabled(selectedJournalIds.isEmpty)
                        }

                    } else {
                        // NORMAL MODE TOOLBAR
                        // Reorder button (arrows icon)
                        ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingReorderModal = true
                        }) {
                            Text(DayOneIcon.arrows_up_down.rawValue)
                                .font(.custom("DayOneIcons", size: 18))
                        }
                    }

                    // + Journal button - only shown when Top Toolbar is selected
                    if newJournalButtonStyle == .topToolbar {
                        // Spacer to separate buttons into different pill backgrounds
                        ToolbarSpacer(.fixed, placement: .navigationBarLeading)

                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                addNewJournal()
                            }) {
                                Text("+ Journal")
                            }
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Menu {

                            Button(action: {
                                addNewJournal()
                            }) {
                                Label("New Journal", systemImage: "plus")
                            }

                            Button(action: {
                                showingCreateCollection = true
                            }) {
                                Label("New Collection", systemImage: "folder.badge.plus")
                            }
                            
                            Button(action: {
                                showingReorderModal = true
                            }) {
                                Label("Reorder", systemImage: "arrow.up.arrow.down")
                            }

                            Button(action: {
                                isSelectMode = true
                                selectedJournalIds.removeAll()
                            }) {
                                Label("Select", systemImage: "checkmark.circle")
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
                                        Label("Regular", systemImage: "square.grid.3x3")
                                            .tag(ViewMode.list)
                                        Label("Books", systemImage: "books.vertical")
                                            .tag(ViewMode.grid)
                                    }
                                } label: {
                                    HStack {
                                        Label("Journals View", systemImage: "square.grid.3x3")
                                        Spacer()
                                        Text(viewMode == .list ? "Regular" : "Books")
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Menu {
                                    Picker("New Journal", selection: $newJournalButtonStyle) {
                                        ForEach(NewJournalButtonStyle.allCases, id: \.self) { style in
                                            Text(style.rawValue).tag(style)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Label("New Journal", systemImage: "plus.circle")
                                        Spacer()
                                        Text(newJournalButtonStyle.rawValue)
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
                    } // end else (normal mode toolbar)
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
                    journalItems: $journalItems,
                    journalsPopulation: journalsPopulation,
                    shouldAddCollectionOnOpen: $shouldAddCollectionOnModalOpen
                )
            }
            .sheet(isPresented: $showingCreateJournal) {
                CreateJournalView(onCreate: { name, color, isPersonal in
                    createJournal(name: name, color: color, isPersonal: isPersonal)
                    showingCreateJournal = false
                })
            }
            .sheet(isPresented: $showingCreateCollection) {
                CreateCollectionView(journalItems: journalItems, onCreate: { collectionName, journalIds in
                    createCollection(name: collectionName, journalIds: journalIds)
                    showingCreateCollection = false
                })
            }
            .overlay(alignment: .bottomTrailing) {
                // New Journal FAB - only shown when FAB style is selected and not in select mode
                if newJournalButtonStyle == .fab && !isSelectMode {
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
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.trailing, 18)
                    .padding(.bottom, 30) // Position above tab bar (similar to Today tab FABs)
                    .offset(y: showingNewJournalFAB ? 0 : 150) // Slide up/down animation
                    .opacity(showingNewJournalFAB ? 1 : 0)
                }
            }
            .onAppear {
                // Animate FAB in after a short delay with bounce effect
                // Only show FAB if we're in the list view (not in a detail view) and FAB style is selected
                if newJournalButtonStyle == .fab && selectedJournal == nil && selectedFolder == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.interpolatingSpring(stiffness: 180, damping: 12)) {
                            showingNewJournalFAB = true
                        }
                    }
                }
            }
            .onChange(of: selectedJournal) { oldValue, newValue in
                // Hide FAB when navigating to journal detail, show when coming back
                if newJournalButtonStyle == .fab {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingNewJournalFAB = newValue == nil
                    }
                }
            }
            .onChange(of: selectedFolder) { oldValue, newValue in
                // Hide FAB when navigating to folder detail, show when coming back
                if newJournalButtonStyle == .fab {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingNewJournalFAB = newValue == nil
                    }
                }
            }
            .onChange(of: newJournalButtonStyle) { oldValue, newValue in
                // Update FAB visibility when style changes
                if newValue == .fab && selectedJournal == nil && selectedFolder == nil {
                    withAnimation(.interpolatingSpring(stiffness: 180, damping: 12)) {
                        showingNewJournalFAB = true
                    }
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingNewJournalFAB = false
                    }
                }
            }
        }
    }

    // MARK: - Journal List Content
    @ViewBuilder
    private var journalListContent: some View {
        switch viewMode {
        case .list:
            iconsModeView
        case .grid:
            gridJournalList
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
            Group {
                if isSelectMode {
                    // Select Mode: List with selection enabled
                    List(selection: $selectedJournalIds) {
                        // Render sections in custom order
                        ForEach(sectionOrder, id: \.self) { sectionType in
                            iconsSectionView(for: sectionType)
                        }

                        // Fixed items that don't reorder
                        tipKitSection
                    }
                } else {
                    // Normal Mode: List without selection parameter
                    List {
                        // Render sections in custom order
                        ForEach(sectionOrder, id: \.self) { sectionType in
                            iconsSectionView(for: sectionType)
                        }

                        // Fixed items that don't reorder
                        tipKitSection
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant((isEditMode || isSelectMode) ? .active : .inactive))
            .toolbar(isSelectMode ? .hidden : .visible, for: .tabBar)
            .onChange(of: scrollToId) { _, newId in
                if let id = newId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(id, anchor: .center)
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
            .buttonStyle(.plain)
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
            .buttonStyle(.plain)
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
        // All Entries collection-style row at the top (hidden in Select Mode)
            if !isSelectMode {
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
            }

            ForEach(filteredMixedJournalItems) { item in
                if item.isFolder, let folder = item.folder {
                    FolderRow(
                        folder: folder,
                        isExpanded: expandedFolders.contains(folder.id),
                        isEditMode: isEditMode,
                        isSelectMode: isSelectMode,
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
                        },
                        onReorder: {
                            showingReorderModal = true
                        }
                    )
                    .id(folder.id)
                    .selectionDisabled()
                    .contextMenu {
                        Button {
                            selectedFolder = folder
                        } label: {
                            Label("View", systemImage: "square.grid.2x2")
                        }

                        Button {
                            editedCollectionName = folder.name
                            renamingCollectionID = folder.id
                            collectionNameFieldFocused = true
                        } label: {
                            Label("Rename", systemImage: "character.cursor.ibeam")
                        }

                        Button {
                            showingReorderModal = true
                        } label: {
                            Label("Reorder", systemImage: "arrow.up.arrow.down")
                        }

                        Divider()

                        Button(role: .destructive) {
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
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }

                    if expandedFolders.contains(folder.id) {
                        ForEach(folder.journals) { journal in
                            JournalRow(
                                journal: journal,
                                isSelected: journal.id == journalViewModel.selectedJournal.id,
                                isEditMode: isEditMode,
                                isSelectMode: isSelectMode,
                                onSelect: {
                                    if !isSelectMode {
                                        journalViewModel.selectJournal(journal)
                                        selectedJournal = journal
                                    }
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

                                        // Keep the collection even if empty
                                        let updatedFolder = currentFolder.withJournals(updatedJournals)
                                        journalItems[folderIndex] = Journal.MixedJournalItem(folder: updatedFolder)
                                    }
                                },
                                onMoveToCollection: { targetFolderId in
                                    // Move journal from current folder to target folder
                                    if let sourceFolderIndex = journalItems.firstIndex(where: { $0.id == folder.id }),
                                       let sourceFolder = journalItems[sourceFolderIndex].folder,
                                       let targetFolderIndex = journalItems.firstIndex(where: { $0.id == targetFolderId }),
                                       let targetFolder = journalItems[targetFolderIndex].folder {

                                        // Remove from source folder
                                        var updatedSourceJournals = sourceFolder.journals
                                        updatedSourceJournals.removeAll(where: { $0.id == journal.id })

                                        // Add to target folder
                                        var updatedTargetJournals = targetFolder.journals
                                        updatedTargetJournals.append(journal)

                                        // Update both folders - keep source even if empty
                                        journalItems[sourceFolderIndex] = Journal.MixedJournalItem(folder: sourceFolder.withJournals(updatedSourceJournals))
                                        journalItems[targetFolderIndex] = Journal.MixedJournalItem(folder: targetFolder.withJournals(updatedTargetJournals))
                                    }
                                },
                                onRemoveFromCollection: {
                                    // Remove journal from folder and add as standalone
                                    if let folderIndex = journalItems.firstIndex(where: { $0.id == folder.id }),
                                       let currentFolder = journalItems[folderIndex].folder {

                                        // Remove from folder
                                        var updatedJournals = currentFolder.journals
                                        updatedJournals.removeAll(where: { $0.id == journal.id })

                                        // Keep the collection even if empty
                                        journalItems[folderIndex] = Journal.MixedJournalItem(folder: currentFolder.withJournals(updatedJournals))

                                        // Add journal as standalone item
                                        journalItems.append(Journal.MixedJournalItem(journal: journal))
                                    }
                                },
                                onReorder: {
                                    showingReorderModal = true
                                },
                                onEnterSelectMode: {
                                    // Enter Select Mode and select this journal
                                    isSelectMode = true
                                    selectedJournalIds = [journal.id]
                                },
                                availableCollections: availableCollections.filter { $0.id != folder.id },
                                isInCollection: true
                            )
                            .padding(.leading, 20)
                            .tag(journal.id)
                        }
                    }
                } else if let journal = item.journal {
                    JournalRow(
                        journal: journal,
                        isSelected: journal.id == journalViewModel.selectedJournal.id,
                        isEditMode: isEditMode,
                        isSelectMode: isSelectMode,
                        onSelect: {
                            if !isSelectMode {
                                journalViewModel.selectJournal(journal)
                                selectedJournal = journal
                            }
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
                        },
                        onMoveToCollection: { targetFolderId in
                            // Move standalone journal to a collection
                            if let targetFolderIndex = journalItems.firstIndex(where: { $0.id == targetFolderId }),
                               let targetFolder = journalItems[targetFolderIndex].folder {

                                // Update folder first, THEN remove journal
                                var updatedJournals = targetFolder.journals
                                updatedJournals.append(journal)
                                journalItems[targetFolderIndex] = Journal.MixedJournalItem(folder: targetFolder.withJournals(updatedJournals))

                                // Now remove the standalone journal
                                journalItems.removeAll(where: { $0.id == journal.id })
                            }
                        },
                        onEnterSelectMode: {
                            // Enter Select Mode and select this journal
                            isSelectMode = true
                            selectedJournalIds = [journal.id]
                        },
                        availableCollections: availableCollections,
                        isInCollection: false
                    )
                    .tag(journal.id)
                }
            }

        // Trash row at the bottom (hidden in Select Mode)
        if trashCount > 0 && !isSelectMode {
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
            .buttonStyle(.plain)
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
                            },
                            onRename: { newName in
                                if let folderIndex = journalItems.firstIndex(where: { $0.id == folder.id }),
                                   let currentFolder = journalItems[folderIndex].folder {
                                    var updatedJournals = currentFolder.journals
                                    if let journalIndex = updatedJournals.firstIndex(where: { $0.id == journal.id }) {
                                        updatedJournals[journalIndex] = journal.withName(newName)
                                        journalItems[folderIndex] = Journal.MixedJournalItem(folder: currentFolder.withJournals(updatedJournals))
                                    }
                                }
                            },
                            onDelete: {
                                if let folderIndex = journalItems.firstIndex(where: { $0.id == folder.id }),
                                   let currentFolder = journalItems[folderIndex].folder {
                                    var updatedJournals = currentFolder.journals
                                    updatedJournals.removeAll(where: { $0.id == journal.id })
                                    // Keep the collection even if empty
                                    journalItems[folderIndex] = Journal.MixedJournalItem(folder: currentFolder.withJournals(updatedJournals))
                                }
                            },
                            onMoveToCollection: { targetFolderId in
                                if let sourceFolderIndex = journalItems.firstIndex(where: { $0.id == folder.id }),
                                   let sourceFolder = journalItems[sourceFolderIndex].folder,
                                   let targetFolderIndex = journalItems.firstIndex(where: { $0.id == targetFolderId }),
                                   let targetFolder = journalItems[targetFolderIndex].folder {
                                    var updatedSourceJournals = sourceFolder.journals
                                    updatedSourceJournals.removeAll(where: { $0.id == journal.id })
                                    var updatedTargetJournals = targetFolder.journals
                                    updatedTargetJournals.append(journal)
                                    // Keep source collection even if empty
                                    journalItems[sourceFolderIndex] = Journal.MixedJournalItem(folder: sourceFolder.withJournals(updatedSourceJournals))
                                    journalItems[targetFolderIndex] = Journal.MixedJournalItem(folder: targetFolder.withJournals(updatedTargetJournals))
                                }
                            },
                            onRemoveFromCollection: {
                                if let folderIndex = journalItems.firstIndex(where: { $0.id == folder.id }),
                                   let currentFolder = journalItems[folderIndex].folder {
                                    var updatedJournals = currentFolder.journals
                                    updatedJournals.removeAll(where: { $0.id == journal.id })

                                    // Keep the collection even if empty
                                    journalItems[folderIndex] = Journal.MixedJournalItem(folder: currentFolder.withJournals(updatedJournals))

                                    journalItems.append(Journal.MixedJournalItem(journal: journal))
                                }
                            },
                            availableCollections: availableCollections.filter { $0.id != folder.id },
                            isInCollection: true
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
                        },
                        onRename: { newName in
                            if let index = journalItems.firstIndex(where: { $0.id == journal.id }) {
                                let updatedJournal = journal.withName(newName)
                                journalItems[index] = Journal.MixedJournalItem(journal: updatedJournal)
                            }
                        },
                        onDelete: {
                            journalItems.removeAll(where: { $0.id == journal.id })
                        },
                        onMoveToCollection: { targetFolderId in
                            if let targetFolderIndex = journalItems.firstIndex(where: { $0.id == targetFolderId }),
                               let targetFolder = journalItems[targetFolderIndex].folder {
                                // Update folder first, THEN remove journal
                                var updatedJournals = targetFolder.journals
                                updatedJournals.append(journal)
                                journalItems[targetFolderIndex] = Journal.MixedJournalItem(folder: targetFolder.withJournals(updatedJournals))

                                // Now remove the standalone journal
                                journalItems.removeAll(where: { $0.id == journal.id })
                            }
                        },
                        availableCollections: availableCollections,
                        isInCollection: false
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
            .buttonStyle(.plain)
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

// MARK: - Paged Cover Tab View

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
                    ListTabView(journal: folder.journals.first ?? Journal(name: folder.name, color: folder.color, entryCount: folder.entryCount), useLargeListDates: useLargeListDates, populatedEntries: [])
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

