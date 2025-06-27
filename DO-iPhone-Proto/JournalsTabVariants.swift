import SwiftUI

// MARK: - Journals Tab Paged Variant

struct JournalEntry {
    let id: String
    let title: String
    let preview: String
    let date: String
    let time: String
}



// MARK: - Journals Tab Paged Variant

struct JournalsTabPagedView: View {
    @State private var journalViewModel = JournalSelectionViewModel()
    @State private var showingSettings = false
    @State private var viewMode: ViewMode = .list
    @State private var selectedJournal: Journal?
    
    // Sheet regular position from top (in points)
    let sheetRegularPosition: CGFloat = 250
    
    var body: some View {
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
                ScrollView {
                    switch viewMode {
                    case .compact:
                        LazyVStack(spacing: 4) {
                            ForEach(Journal.allJournals) { journal in
                                CompactJournalRow(
                                    journal: journal,
                                    isSelected: journal.id == journalViewModel.selectedJournal.id,
                                    onSelect: {
                                        selectedJournal = journal
                                        journalViewModel.selectJournal(journal)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                    case .list:
                        LazyVStack(spacing: 8) {
                            ForEach(Journal.allJournals) { journal in
                                JournalRow(
                                    journal: journal,
                                    isSelected: journal.id == journalViewModel.selectedJournal.id,
                                    onSelect: {
                                        selectedJournal = journal
                                        journalViewModel.selectJournal(journal)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                    case .grid:
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
                            ForEach(Journal.allJournals) { journal in
                                JournalBookView(
                                    journal: journal,
                                    isSelected: journal.id == journalViewModel.selectedJournal.id,
                                    onSelect: {
                                        selectedJournal = journal
                                        journalViewModel.selectJournal(journal)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                }
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
}

struct JournalDetailPagedView: View {
    let journal: Journal
    let journalViewModel: JournalSelectionViewModel
    let sheetRegularPosition: CGFloat
    @State private var showingSheet = false
    @State private var showingEntryView = false
    @State private var showFAB = false
    @AppStorage("journalImageEnabled") private var imageEnabled = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Full screen journal color background
            journal.color
                .ignoresSafeArea()
            
            // Bike image overlay when enabled
            if imageEnabled {
                VStack {
                    Image("bike")
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
                    
                    // White FAB button
                    if showFAB {
                        Button(action: {
                            showingEntryView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(journal.color)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                        }
                        .padding(.trailing, 18)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.leading, 18)
                .padding(.top, sheetRegularPosition - 100)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingSheet = true
            }
            // Animate FAB in after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showFAB = true
                }
            }
        }
        .onChange(of: showingSheet) { _, newValue in
            if !newValue {
                // When sheet is dismissed, navigate back
                dismiss()
            }
        }
        .overlay(
            PagedNativeSheetView(isPresented: $showingSheet, journal: journal, sheetRegularPosition: sheetRegularPosition)
        )
        .sheet(isPresented: $showingEntryView) {
            EntryView()
        }
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
                    if let containerView = sheetPresentationController.containerView {
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
                        PagedCoverTabView()
                    case 1:
                        ListTabView()
                    case 2:
                        CalendarTabView()
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
    @State private var showingEditView = false
    @AppStorage("journalImageEnabled") private var imageEnabled = false
    
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
            PagedEditJournalView(imageEnabled: $imageEnabled)
        }
    }
}

// MARK: - Paged Edit Journal View
struct PagedEditJournalView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var imageEnabled: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Journal Settings") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("Daily Journal")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Color")
                        Spacer()
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 24, height: 24)
                    }
                }
                
                Section("Appearance") {
                    Toggle("Image", isOn: $imageEnabled)
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
