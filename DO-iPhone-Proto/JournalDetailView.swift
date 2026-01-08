import SwiftUI

// MARK: - Journal Detail View for iPhone
struct JournalDetailPagedView: View, StyleComputedProperties {
    let journal: Journal
    let journalViewModel: JournalSelectionViewModel
    let sheetRegularPosition: CGFloat  // Kept for compatibility with call site
    @State private var showingEditView = false
    @State private var showingSettings = false
    @State private var showCoverImage: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var useLargeListDates = false
    @AppStorage("journalDetailStyle") var selectedStyle: JournalDetailStyle = .colored
    @AppStorage("mediaViewSize") var mediaViewSize: MediaViewSize = .medium

    // StyleComputedProperties requirement
    var color: Color { journal.color }

    init(journal: Journal, journalViewModel: JournalSelectionViewModel, sheetRegularPosition: CGFloat) {
        self.journal = journal
        self.journalViewModel = journalViewModel
        self.sheetRegularPosition = sheetRegularPosition
        // Show cover image by default only for Dreams journal
        _showCoverImage = State(initialValue: journal.name == "Dreams")
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

                    DetailSettingsSection(
                        sectionTitle: "Journal Detail Options",
                        showCoverImage: $showCoverImage,
                        useLargeListDates: $useLargeListDates,
                        selectedStyle: $selectedStyle,
                        mediaViewSize: $mediaViewSize
                    )
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
            PagedEditJournalView(journal: journal)
        }
        .sheet(isPresented: $showingSettings) {
            AppSettingsView()
        }
    }

    // MARK: - Layout
    private var simpleLayout: some View {
        SimpleDetailLayout(
            title: journal.name,
            subtitle: "2020 – 2025",
            headerBackgroundColor: headerBackgroundColor,
            headerTextColor: headerTextColor,
            showCoverImage: showCoverImage,
            coverImageName: !journal.appearance.originalCoverImageData.isEmpty ?
                journal.appearance.originalCoverImageData : "bike",
            style: selectedStyle,
            fabJournal: journal,
            onFabTap: {
                // Present entry view
                // TODO: Implement entry view presentation
            }
        ) {
            simpleLayoutContent
        }
    }

    // MARK: - Simple Layout Content
    @State private var selectedContentTab: JournalDetailTab = .timeline

    private var simpleLayoutContent: some View {
        VStack(spacing: 0) {
            // Pill Picker (Mail-style)
            JournalDetailPillPicker(
                tabs: JournalDetailTab.allTabs,
                selection: $selectedContentTab,
                selectedColor: selectedPillColor,
                style: selectedStyle
            )
            .padding(.bottom, 12)

            // Content based on selected tab
            if selectedContentTab == .map {
                // Map fills from here to bottom of screen
                GeometryReader { geometry in
                    MapTabView()
                        .frame(width: geometry.size.width, height: geometry.size.height + 600)
                        .ignoresSafeArea(.all, edges: .bottom)
                }
            } else {
                Group {
                    switch selectedContentTab {
                    case .book:
                        PagedCoverTabView(journal: journal)
                    case .timeline:
                        ListTabView(journal: journal, useLargeListDates: useLargeListDates)
                    case .calendar:
                        CalendarTabView(journal: journal)
                    case .media:
                        MediaTabView(mediaViewSize: mediaViewSize)
                    case .map:
                        Color.clear // Placeholder, won't be shown
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
                .padding(.bottom, 120) // Extra padding for FAB clearance
            }
        }
    }
}
