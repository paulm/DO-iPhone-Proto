import SwiftUI
import UIKit

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
    @State private var viewMode: ViewMode = .list
    @State private var selectedJournal: Journal?
    
    // Draggable FAB state
    @GestureState private var dragState = CGSize.zero
    @State private var hoveredJournal: Journal?
    @State private var showFAB = false
    @State private var temporaryHoveredJournal: Journal?
    @State private var lastHapticJournal: Journal?
    
    // Sheet regular position from top (in points)
    let sheetRegularPosition: CGFloat = 250
    
    var body: some View {
        ZStack {
            navigationContent
            fabOverlay
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                showFAB = true
            }
        }
    }
    
    // MARK: - Navigation Content
    private var navigationContent: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Combined segmented control and buttons row
                HStack(spacing: 12) {
                    // View mode segmented control
                    Picker("View Mode", selection: $viewMode) {
                        Image(systemName: "line.3.horizontal.decrease").tag(ViewMode.compact)
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                        Image(systemName: "square.grid.3x3").tag(ViewMode.grid)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: .infinity)
                    
                    // Compact Add/Edit buttons
                    HStack(spacing: 8) {
                        Button("+ Add") {
                            // TODO: Add new journal action
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.1))
                        )
                        
                        Button("Edit") {
                            // TODO: Edit journals action
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                Divider()
                    .padding(.bottom, 8)
                
                // Journal content based on view mode
                journalListContent
            }
            .navigationTitle("Journals")
            .navigationBarTitleDisplayMode(.large)
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
            }
            .navigationDestination(item: $selectedJournal) { journal in
                JournalDetailPagedView(journal: journal, journalViewModel: journalViewModel, sheetRegularPosition: sheetRegularPosition)
            }
        }
        .tint(.white)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Journal List Content
    @ViewBuilder
    private var journalListContent: some View {
        ScrollView {
            switch viewMode {
            case .compact:
                compactJournalList
            case .list:
                listJournalList
            case .grid:
                gridJournalList
            }
        }
    }
    
    private var compactJournalList: some View {
        LazyVStack(spacing: 4) {
            ForEach(Journal.visibleJournals) { journal in
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
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var listJournalList: some View {
        LazyVStack(spacing: 8) {
            ForEach(Journal.visibleJournals) { journal in
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
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    private var gridJournalList: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
            ForEach(Journal.visibleJournals) { journal in
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
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    // MARK: - FAB Overlay
    @ViewBuilder
    private var fabOverlay: some View {
        if showFAB && selectedJournal == nil {
            GeometryReader { geometry in
                fabButton(in: geometry)
            }
            .allowsHitTesting(true)
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    // MARK: - FAB Button
    private func fabButton(in geometry: GeometryProxy) -> some View {
        ZStack {
            Circle()
                .fill(getColorForPosition(dragOffset: dragState, geometry: geometry))
                .frame(width: 56, height: 56)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            Image(systemName: "plus")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .position(
            x: geometry.size.width - 46 + dragState.width,
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
        .onTapGesture {
            // Navigate to selected journal when tapped
            selectedJournal = journalViewModel.selectedJournal
        }
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
        
        // Estimate which journal based on Y position and view mode
        let journals = Journal.visibleJournals
        let contentStartY: CGFloat = 180 // Approximate start of content (after nav + segmented control)
        
        switch viewMode {
        case .compact:
            let rowHeight: CGFloat = 40
            let index = Int((fabY - contentStartY) / rowHeight)
            if index >= 0 && index < journals.count {
                hoveredJournal = journals[index]
            } else {
                hoveredJournal = nil
            }
            
        case .list:
            let rowHeight: CGFloat = 76 // Height includes padding
            let index = Int((fabY - contentStartY) / rowHeight)
            if index >= 0 && index < journals.count {
                hoveredJournal = journals[index]
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
            if index >= 0 && index < journals.count {
                hoveredJournal = journals[index]
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
    @State private var showingSheet = false
    @State private var showingEntryView = false
    @State private var showingEditView = false
    @State private var imageEnabled = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Full screen journal color background
            journal.color
                .ignoresSafeArea()
            
            // Cover image overlay when enabled
            if imageEnabled, !journal.appearance.originalCoverImageData.isEmpty {
                VStack {
                    Image(journal.appearance.originalCoverImageData)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea()
                    
                    Spacer()
                }
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
                .padding(.top, sheetRegularPosition - 100)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .zIndex(1)
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingSheet = true
            }
        }
        .onChange(of: showingSheet) { _, newValue in
            if !newValue {
                // When sheet is dismissed, navigate back
                dismiss()
            }
        }
        .sheet(isPresented: $showingEntryView) {
            EntryView()
        }
        .sheet(isPresented: $showingEditView) {
            PagedEditJournalView(journal: journal, imageEnabled: imageEnabled) { newValue in
                imageEnabled = newValue
            }
        }
        .overlay(
            PagedNativeSheetView(isPresented: $showingSheet, journal: journal, sheetRegularPosition: sheetRegularPosition)
        )
    }
}

// MARK: - Sheet State
class SheetState: ObservableObject {
    @Published var isExpanded: Bool = false
}

// MARK: - Paged UIKit Sheet Wrapper

struct PagedNativeSheetView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let journal: Journal
    let sheetRegularPosition: CGFloat
    @StateObject private var sheetState = SheetState()
    
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
            
            contentHostingController.isModalInPresentation = false
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

// MARK: - Paged Sheet Content

struct PagedJournalSheetContent: View {
    let journal: Journal
    @ObservedObject var sheetState: SheetState
    let sheetRegularPosition: CGFloat
    @State private var selectedTab = 1
    @State private var showingEntryView = false
    @State private var showFAB = false
    
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
            VStack(spacing: 0) {
                // Segmented control
                Picker("View", selection: $selectedTab) {
                    Text("Cover").tag(0)
                    Text("List").tag(1)
                    Text("Calendar").tag(2)
                    Text("Media").tag(3)
                    Text("Map").tag(4)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 22)  // Added 10pt extra spacing (12 + 10)
                .padding(.bottom, 12)
                .background(Color(UIColor.systemBackground))
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case 0:
                        PagedCoverTabView(journal: journal)
                    case 1:
                        ListTabView()
                    case 2:
                        CalendarTabView(journal: journal)
                    case 3:
                        MediaTabView()
                    case 4:
                        MapTabView()
                    default:
                        ListTabView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // FAB button that animates based on sheet position
            if showFAB {
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
            // Animate FAB in after a short delay with bounce effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.interpolatingSpring(stiffness: 180, damping: 12)) {
                    showFAB = true
                }
            }
        }
        .sheet(isPresented: $showingEntryView) {
            EntryView()
        }
    }
}

// MARK: - Paged Cover Tab View
struct PagedCoverTabView: View {
    let journal: Journal
    @State private var showingEditView = false
    @State private var imageEnabled = true
    
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
                .padding(.top, 24)
                
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
            PagedEditJournalView(journal: journal, imageEnabled: imageEnabled) { newValue in
                imageEnabled = newValue
            }
        }
    }
}

// MARK: - Paged Edit Journal View
struct PagedEditJournalView: View {
    @Environment(\.dismiss) private var dismiss
    let journal: Journal
    var imageEnabled: Bool
    let onImageEnabledChange: (Bool) -> Void
    @State private var localImageEnabled: Bool
    
    init(journal: Journal, imageEnabled: Bool, onImageEnabledChange: @escaping (Bool) -> Void) {
        self.journal = journal
        self.imageEnabled = imageEnabled
        self.onImageEnabledChange = onImageEnabledChange
        self._localImageEnabled = State(initialValue: imageEnabled)
    }
    
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
                
                Section("Appearance") {
                    if !journal.appearance.originalCoverImageData.isEmpty {
                        Toggle("Show Cover Image", isOn: $localImageEnabled)
                            .onChange(of: localImageEnabled) { _, newValue in
                                onImageEnabledChange(newValue)
                            }
                    } else {
                        Text("No cover image available")
                            .foregroundStyle(.secondary)
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

#Preview("Paged") {
    JournalsTabPagedView()
}
