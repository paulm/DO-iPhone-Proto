import SwiftUI
import UIKit

// MARK: - View Mode Enum

enum ViewMode: Int, CaseIterable {
    case compact = 0
    case list = 1
    case grid = 2
}

// MARK: - Journals Tab Paged Variant

struct JournalEntry {
    let id: String
    let title: String
    let preview: String
    let date: String
    let time: String
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
    @State private var journalViewModel = JournalSelectionViewModel()
    @State private var showingSettings = false
    @State private var viewMode: ViewMode = .compact // Default to List view
    @State private var selectedJournal: Journal?
    @State private var selectedFolder: JournalFolder?
    @State private var showingNewEntry = false
    @State private var shouldShowAudioAfterEntry = false

    // Folder expansion state
    @State private var expandedFolders: Set<String> = []

    // Draggable FAB state
    @GestureState private var dragState = CGSize.zero
    @State private var hoveredJournal: Journal?
    @State private var showFAB = false
    @State private var temporaryHoveredJournal: Journal?
    @State private var lastHapticJournal: Journal?

    // Sheet regular position from top (in points)
    let sheetRegularPosition: CGFloat = 250

    // Get visible journals and folders
    private var folders: [JournalFolder] {
        return Journal.folders
    }

    private var unfolderedJournals: [Journal] {
        return Journal.unfolderedJournals
    }
    
    var body: some View {
        ZStack {
            navigationContent
            
            // FAB overlay always visible
            if showFAB {
                GeometryReader { geometry in
                    fabButton(in: geometry)
                }
                .allowsHitTesting(true)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                showFAB = true
            }
        }
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
                            // TODO: Edit journals action
                        }) {
                            Label("Edit", systemImage: "pencil")
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
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    
                    Button {
                        showingSettings = true
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
            compactJournalList
        case .list:
            listJournalList
        case .grid:
            gridJournalList
        }
    }
    
    private var compactJournalList: some View {
        LazyVStack(spacing: 4) {
            // Recent Journals horizontal scroll section
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Journals")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recentJournals) { journal in
                            JournalBookView(
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
                            .frame(width: 80)
                        }
                    }
                }
            }
            .padding(.bottom, 16)

            // All Entries at the top
            if let allEntries = Journal.allEntriesJournal {
                CompactJournalRow(
                    journal: allEntries,
                    isSelected: temporaryHoveredJournal?.id == allEntries.id || (temporaryHoveredJournal == nil && allEntries.id == journalViewModel.selectedJournal.id),
                    onSelect: {
                        journalViewModel.selectJournal(allEntries)
                        selectedJournal = allEntries
                    }
                )
            }

            // Mixed folders and journals
            ForEach(Journal.mixedJournalItems) { item in
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
                                isSelected: temporaryHoveredJournal?.id == journal.id || (temporaryHoveredJournal == nil && journal.id == journalViewModel.selectedJournal.id),
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
                        isSelected: temporaryHoveredJournal?.id == journal.id || (temporaryHoveredJournal == nil && journal.id == journalViewModel.selectedJournal.id),
                        onSelect: {
                            journalViewModel.selectJournal(journal)
                            selectedJournal = journal
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 100)
    }
    
    // Recent journals for horizontal scroll
    private var recentJournals: [Journal] {
        return [
            Journal(name: "Travel 2025", color: Color(hex: "FF6B6B"), entryCount: 42),
            Journal(name: "Work Notes", color: Color(hex: "4ECDC4"), entryCount: 156),
            Journal(name: "Gratitude", color: Color(hex: "FFD93D"), entryCount: 89),
            Journal(name: "Reading Log", color: Color(hex: "95E1D3"), entryCount: 34),
            Journal(name: "Fitness", color: Color(hex: "F38181"), entryCount: 67),
            Journal(name: "Recipes", color: Color(hex: "AA96DA"), entryCount: 23)
        ]
    }

    private var listJournalList: some View {
        LazyVStack(spacing: 8) {
            // Recent Journals horizontal scroll section
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Journals")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recentJournals) { journal in
                            JournalBookView(
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
                            .frame(width: 80)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 16)

            // All Entries at the top
            if let allEntries = Journal.allEntriesJournal {
                JournalRow(
                    journal: allEntries,
                    isSelected: temporaryHoveredJournal?.id == allEntries.id || (temporaryHoveredJournal == nil && allEntries.id == journalViewModel.selectedJournal.id),
                    onSelect: {
                        journalViewModel.selectJournal(allEntries)
                        selectedJournal = allEntries
                    }
                )
            }

            // Mixed folders and journals
            ForEach(Journal.mixedJournalItems) { item in
                if item.isFolder, let folder = item.folder {
                    FolderRow(
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
                            JournalRow(
                                journal: journal,
                                isSelected: temporaryHoveredJournal?.id == journal.id || (temporaryHoveredJournal == nil && journal.id == journalViewModel.selectedJournal.id),
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
                        isSelected: temporaryHoveredJournal?.id == journal.id || (temporaryHoveredJournal == nil && journal.id == journalViewModel.selectedJournal.id),
                        onSelect: {
                            journalViewModel.selectJournal(journal)
                            selectedJournal = journal
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 100)
    }
    
    private var gridJournalList: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
            // All Entries at the top
            if let allEntries = Journal.allEntriesJournal {
                JournalBookView(
                    journal: allEntries,
                    isSelected: temporaryHoveredJournal?.id == allEntries.id || (temporaryHoveredJournal == nil && allEntries.id == journalViewModel.selectedJournal.id),
                    onSelect: {
                        journalViewModel.selectJournal(allEntries)
                        selectedJournal = allEntries
                    }
                )
            }

            // Mixed folders and journals for Books view
            // Note: Books view doesn't support expand/collapse, just shows all journals flat
            ForEach(Journal.mixedJournalItems) { item in
                if item.isFolder, let folder = item.folder {
                    // Show folder journals in Books view
                    ForEach(folder.journals) { journal in
                        JournalBookView(
                            journal: journal,
                            isSelected: temporaryHoveredJournal?.id == journal.id || (temporaryHoveredJournal == nil && journal.id == journalViewModel.selectedJournal.id),
                            onSelect: {
                                journalViewModel.selectJournal(journal)
                                selectedJournal = journal
                            }
                        )
                    }
                } else if let journal = item.journal {
                    JournalBookView(
                        journal: journal,
                        isSelected: temporaryHoveredJournal?.id == journal.id || (temporaryHoveredJournal == nil && journal.id == journalViewModel.selectedJournal.id),
                        onSelect: {
                            journalViewModel.selectJournal(journal)
                            selectedJournal = journal
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 100)
    }
    
    
    // MARK: - FAB Button
    private func fabButton(in geometry: GeometryProxy) -> some View {
        HStack(spacing: 12) {
            // Create Entry button
            Button(action: {
                showingNewEntry = true
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
                .background(getColorForPosition(dragOffset: dragState, geometry: geometry))
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // Record Audio button
            Button(action: {
                // Select the journal if hovering over one
                if let journal = hoveredJournal ?? temporaryHoveredJournal {
                    journalViewModel.selectedJournal = journal
                }
                // Otherwise, keep the currently selected journal
                
                // Set flag to show audio after entry
                shouldShowAudioAfterEntry = true
                // Open Entry view as sheet
                showingNewEntry = true
            }) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(getColorForPosition(dragOffset: dragState, geometry: geometry))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .position(
            x: geometry.size.width - 130 + dragState.width,
            y: geometry.size.height - 80 + dragState.height
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hoveredJournal?.color)
        .gesture(
            DragGesture()
                .updating($dragState) { value, state, _ in
                    state = value.translation
                }
                .onChanged { value in
                    // Calculate which journal based on Y position
                    updateHoveredJournal(for: value.location, in: geometry)
                    temporaryHoveredJournal = hoveredJournal
                    
                    // Trigger haptic feedback when hovering over a new journal
                    if let currentHovered = hoveredJournal, currentHovered.id != lastHapticJournal?.id {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.prepare()
                        impactFeedback.impactOccurred()
                        lastHapticJournal = currentHovered
                    } else if hoveredJournal == nil {
                        lastHapticJournal = nil
                    }
                }
                .onEnded { _ in
                    // Update the actual selection to the hovered journal
                    if let hoveredJournal = hoveredJournal {
                        journalViewModel.selectJournal(hoveredJournal)
                        // Heavier haptic for selection
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.prepare()
                        impactFeedback.impactOccurred()
                    }
                    hoveredJournal = nil
                    temporaryHoveredJournal = nil
                    lastHapticJournal = nil
                }
        )
    }
    
    // Helper function to get color based on position
    private func getColorForPosition(dragOffset: CGSize, geometry: GeometryProxy) -> Color {
        // While dragging, show hovered color
        if let hoveredJournal = hoveredJournal {
            return hoveredJournal.color
        }
        // When not dragging, always show selected journal color
        return journalViewModel.selectedJournal.color
    }
    
    // Helper function to update hovered journal based on position
    private func updateHoveredJournal(for location: CGPoint, in geometry: GeometryProxy) {
        // Get the current FAB position
        let fabX = geometry.size.width - 46 + dragState.width
        let fabY = geometry.size.height - 80 + dragState.height

        // Collect all journals in display order for FAB hover detection
        var allVisibleJournals: [Journal] = []
        if let allEntries = Journal.allEntriesJournal {
            allVisibleJournals.append(allEntries)
        }
        // Add journals from mixed items
        for item in Journal.mixedJournalItems {
            if item.isFolder, let folder = item.folder {
                allVisibleJournals.append(contentsOf: folder.journals)
            } else if let journal = item.journal {
                allVisibleJournals.append(journal)
            }
        }
        let contentStartY: CGFloat = 180 // Approximate start of content (after nav + segmented control)
        
        switch viewMode {
        case .compact:
            let rowHeight: CGFloat = 40
            let index = Int((fabY - contentStartY) / rowHeight)
            if index >= 0 && index < allVisibleJournals.count {
                hoveredJournal = allVisibleJournals[index]
            } else {
                hoveredJournal = nil
            }

        case .list:
            let rowHeight: CGFloat = 76 // Height includes padding
            let index = Int((fabY - contentStartY) / rowHeight)
            if index >= 0 && index < allVisibleJournals.count {
                hoveredJournal = allVisibleJournals[index]
            } else {
                hoveredJournal = nil
            }
            
        case .grid:
            // Grid is more complex, simplified approximation
            let gridCellHeight: CGFloat = 140 // Approximate height with spacing
            let columns = 3
            let row = Int((fabY - contentStartY) / gridCellHeight)
            let col = Int(fabX / (geometry.size.width / CGFloat(columns)))
            let index = row * columns + col
            if index >= 0 && index < allVisibleJournals.count {
                hoveredJournal = allVisibleJournals[index]
            } else {
                hoveredJournal = nil
            }
        }
    }
}

struct JournalDetailPagedView: View {
    let journal: Journal
    let journalViewModel: JournalSelectionViewModel
    let sheetRegularPosition: CGFloat
    @State private var showingEditView = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // Computed properties for orientation-specific values
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var mediumDetentHeight: CGFloat {
        isLandscape ? 240 : 540  // Landscape: 320pt, Portrait: 540pt
    }
    
    private var largeDetentHeight: CGFloat {
        isLandscape ? 350 : 750  // Landscape: 450pt, Portrait: 750pt
    }
    
    private var titleTopPadding: CGFloat {
        isLandscape ? 50 : (sheetRegularPosition - 100)
    }
    
    var body: some View {
        ZStack {
            // Full screen journal color background
            journal.color
                .ignoresSafeArea()
            
            // Cover image overlay from journals.json
            if !journal.appearance.originalCoverImageData.isEmpty {
                GeometryReader { geometry in
                    VStack {
                        Image(journal.appearance.originalCoverImageData)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: sheetRegularPosition + 100)
                            .clipped()
                            .ignoresSafeArea()
                        
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
                    
                    // Ellipsis menu button
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
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.001))
                            .contentShape(Rectangle())
                    }
                    .padding(.trailing, 18)
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
                sheetRegularPosition: sheetRegularPosition,
                mediumDetentHeight: mediumDetentHeight,
                largeDetentHeight: largeDetentHeight
            )
            .zIndex(2) // Ensure sheet appears above title text (which has zIndex 1)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditView) {
            PagedEditJournalView(journal: journal)
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
                    .fontWeight(isSelected ? .medium : .regular)
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
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? .gray.opacity(0.1) : .clear)
            )
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
        HStack(spacing: 12) {
            // Folder icon - tappable to toggle expand/collapse
            Button(action: onToggle) {
                Image(systemName: isExpanded ? "folder.fill" : "folder")
                    .font(.body)
                    .foregroundStyle(folder.color)
                    .frame(width: 12)
            }
            .buttonStyle(PlainButtonStyle())

            // Folder content - tappable to select folder
            Button(action: onSelectFolder) {
                HStack(spacing: 12) {
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
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

struct FolderRow: View {
    let folder: JournalFolder
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSelectFolder: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Folder icon - tappable to toggle expand/collapse
            Button(action: onToggle) {
                Image(systemName: isExpanded ? "folder.fill" : "folder")
                    .font(.title2)
                    .foregroundStyle(folder.color)
                    .frame(width: 32)
            }
            .buttonStyle(PlainButtonStyle())

            // Folder content - tappable to select folder
            Button(action: onSelectFolder) {
                HStack(spacing: 16) {
                    // Folder info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(folder.name)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        HStack(spacing: 4) {
                            Text("\(folder.journalCount) journals")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("•")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("\(folder.entryCount) entries")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

struct JournalRow: View {
    let journal: Journal
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Color square
                RoundedRectangle(cornerRadius: 6)
                    .fill(journal.color)
                    .frame(width: 32, height: 32)
                
                // Journal info
                VStack(alignment: .leading, spacing: 2) {
                    Text(journal.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    // Show journal count for "All Entries"
                    if let journalCount = journal.journalCount {
                        HStack(spacing: 4) {
                            Text("\(journalCount) journals")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("•")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let entryCount = journal.entryCount {
                                Text("\(entryCount) entries")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else if let count = journal.entryCount {
                        Text("\(count) entries")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .gray.opacity(0.15) : .clear)
            )
            .contentShape(Rectangle())
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

#Preview("Paged") {
    JournalsTabPagedView()
}
