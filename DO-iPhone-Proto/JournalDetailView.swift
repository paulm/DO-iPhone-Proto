import SwiftUI

// MARK: - Layout Type
enum JournalDetailLayout: String, CaseIterable {
    case customSheet = "Custom Sheet"
    case simple = "Simple"
}

// MARK: - Journal Detail View for iPhone
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
    @AppStorage("journalDetailLayout") private var selectedLayout: JournalDetailLayout = .simple

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
        Group {
            switch selectedLayout {
            case .customSheet:
                customSheetLayout
            case .simple:
                simpleLayout
            }
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
                        Menu {
                            Picker("Layout", selection: $selectedLayout) {
                                ForEach(JournalDetailLayout.allCases, id: \.self) { layout in
                                    Text(layout.rawValue).tag(layout)
                                }
                            }
                        } label: {
                            HStack {
                                Label("Layouts", systemImage: "rectangle.3.group")
                                Spacer()
                                Text(selectedLayout.rawValue)
                                    .foregroundStyle(.secondary)
                            }
                        }

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
        .toolbarBackground(selectedLayout == .customSheet ? (showCoverImage ? .hidden : .visible) : .automatic, for: .navigationBar)
        .toolbarBackground(selectedLayout == .customSheet ? journal.color : .clear, for: .navigationBar)
        .toolbarColorScheme(selectedLayout == .customSheet ? (showCoverImage ? .dark : nil) : .dark, for: .navigationBar)
        .sheet(isPresented: $showingEditView) {
            PagedEditJournalView(journal: journal)
        }
        .sheet(isPresented: $showingSettings) {
            AppSettingsView()
        }
    }

    // MARK: - Custom Sheet Layout
    private var customSheetLayout: some View {
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
    }

    // MARK: - Simple Layout
    private var simpleLayout: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header section with journal color background
                        ZStack(alignment: .bottom) {
                            // Background color extends behind nav bar
                            journal.color
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
                                                journal.color.opacity(0.7)
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
                                        .foregroundStyle(.white)

                                    Text("2020 – 2025")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.8))
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
    @State private var selectedContentTab: JournalDetailTab = .list

    private var simpleLayoutContent: some View {
        VStack(spacing: 0) {
            // Pill Picker (Mail-style)
            JournalDetailPillPicker(
                tabs: JournalDetailTab.allTabs,
                selection: $selectedContentTab,
                selectedColor: journal.color
            )
            .padding(.bottom, 12)

            // Content based on selected tab
            VStack(spacing: 16) {
                switch selectedContentTab {
                case .book:
                    // Book view placeholder
                    Text("Book View")
                        .foregroundStyle(.secondary)
                        .padding()
                case .list:
                    // List view placeholder
                    ForEach(0..<10, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Entry \(index + 1)")
                                    .font(.headline)
                                Text("March \(index + 1), 2025")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                case .calendar:
                    // Calendar view placeholder
                    Text("Calendar View")
                        .foregroundStyle(.secondary)
                        .padding()
                case .media:
                    // Media view placeholder
                    Text("Media View")
                        .foregroundStyle(.secondary)
                        .padding()
                case .map:
                    // Map view placeholder
                    Text("Map View")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding(.bottom, 120) // Extra padding for FAB clearance
        }
    }
}

// MARK: - Journal Detail Tab Model
enum JournalDetailTab: String, Identifiable, Hashable, CaseIterable {
    case book
    case list
    case calendar
    case media
    case map

    var id: String { rawValue }

    var title: String {
        switch self {
        case .book: return "Book"
        case .list: return "List"
        case .calendar: return "Calendar"
        case .media: return "Media"
        case .map: return "Map"
        }
    }

    var systemImage: String {
        switch self {
        case .book: return "book"
        case .list: return "list.bullet"
        case .calendar: return "calendar"
        case .media: return "photo.on.rectangle"
        case .map: return "map"
        }
    }

    static let allTabs: [JournalDetailTab] = allCases
}

// MARK: - Journal Detail Pill Picker
struct JournalDetailPillPicker: View {
    let tabs: [JournalDetailTab]
    @Binding var selection: JournalDetailTab
    let selectedColor: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tabs) { tab in
                    Button {
                        withAnimation(.bouncy) {
                            selection = tab
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: tab.systemImage)
                                .symbolVariant(selection == tab ? .fill : .none)

                            if selection == tab {
                                Text(tab.title)
                                    .lineLimit(1)
                                    .transition(.opacity.combined(with: .move(edge: .leading)))
                            }
                        }
                        .font(.body.weight(.regular))
                        .padding(.horizontal, 26)
                        .padding(.vertical, 10)
                        .contentShape(Capsule())
                    }
                    .foregroundStyle(selection == tab ? .white : .secondary)
                    .background {
                        Capsule()
                            .fill(selection == tab ? selectedColor : Color(uiColor: .secondarySystemFill))
                    }
                    .accessibilityLabel(Text(tab.title))
                    .accessibilityAddTraits(selection == tab ? [.isSelected] : [])
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
