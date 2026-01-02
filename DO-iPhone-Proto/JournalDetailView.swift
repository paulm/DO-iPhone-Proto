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

                    Section("Journal Detail Options") {
                        Toggle(isOn: $showCoverImage) {
                            Label("Show Cover Image", systemImage: "photo")
                        }

                        Toggle(isOn: $useLargeListDates) {
                            Label("Large List Dates", systemImage: "calendar")
                        }

                        Menu {
                            Picker("Style", selection: $selectedStyle) {
                                ForEach(JournalDetailStyle.allCases, id: \.self) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                        } label: {
                            HStack {
                                Label("Style", systemImage: "paintbrush")
                                Spacer()
                                Text(selectedStyle.rawValue)
                                    .foregroundStyle(.secondary)
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
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header section with journal color background
                        ZStack(alignment: .bottom) {
                            // Background color extends behind nav bar
                            headerBackgroundColor
                                .frame(height: 300 + geometry.safeAreaInsets.top)
                                .offset(y: -geometry.safeAreaInsets.top)
                                .zIndex(0)

                            // Cover image overlay if enabled
                            if showCoverImage {
                                let imageName = !journal.appearance.originalCoverImageData.isEmpty ?
                                    journal.appearance.originalCoverImageData : "bike"
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 300 + geometry.safeAreaInsets.top)
                                    .offset(y: -geometry.safeAreaInsets.top)
                                    .clipped()
                                    .overlay(
                                        LinearGradient(
                                            colors: [
                                                Color.clear,
                                                headerBackgroundColor.opacity(0.7)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .zIndex(1)
                            }

                            // Journal title - positioned at bottom of visible colored area
                            VStack(spacing: 0) {
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(journal.name)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(headerTextColor)

                                    Text("2020 – 2025")
                                        .font(.subheadline)
                                        .foregroundStyle(headerTextColor.opacity(0.8))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                            }
                            .frame(height: 300 + geometry.safeAreaInsets.top)
                            .offset(y: -geometry.safeAreaInsets.top)
                            .zIndex(2)
                        }
                        .frame(height: 300 - geometry.safeAreaInsets.top)

                        // Content section - simple SwiftUI content
                        simpleLayoutContent
                            .padding(.top, 14)
                    }
                }
                .background(Color(UIColor.systemBackground))
            }

            // Floating FAB (separate from scroll view)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    JournalDetailFAB(journal: journal, onTap: {
                        // Present entry view
                        // TODO: Implement entry view presentation
                    })
                    .padding(.trailing, 18)
                    .padding(.bottom, 30)
                }
            }
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
                selectedColor: selectedPillColor
            )
            .padding(.bottom, 12)

            // Content based on selected tab
            Group {
                switch selectedContentTab {
                case .book:
                    PagedCoverTabView(journal: journal)
                case .timeline:
                    ListTabView(journal: journal, useLargeListDates: useLargeListDates)
                case .calendar:
                    CalendarTabView(journal: journal)
                case .media:
                    MediaTabView()
                case .map:
                    MapTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 120) // Extra padding for FAB clearance
        }
    }
}
