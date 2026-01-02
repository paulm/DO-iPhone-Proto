import SwiftUI

// MARK: - Simple Layout Style
enum JournalDetailStyle: String, CaseIterable {
    case colored = "Colored"
    case white = "White"
}

// MARK: - Journal Detail View for iPhone
struct JournalDetailPagedView: View {
    let journal: Journal
    let journalViewModel: JournalSelectionViewModel
    let sheetRegularPosition: CGFloat  // Kept for compatibility with call site
    @State private var showingEditView = false
    @State private var showingSettings = false
    @State private var showCoverImage: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var useLargeListDates = false
    @AppStorage("journalDetailStyle") private var selectedStyle: JournalDetailStyle = .colored

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
    private var headerBackgroundColor: Color {
        selectedStyle == .colored ? journal.color : .white
    }

    private var headerTextColor: Color {
        selectedStyle == .colored ? .white : journal.color
    }

    private var toolbarColorScheme: ColorScheme? {
        selectedStyle == .colored ? .dark : nil
    }

    private var selectedPillColor: Color {
        selectedStyle == .colored ? Color(hex: "333B40") : journal.color
    }

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

// MARK: - Journal Detail Tab Model
enum JournalDetailTab: String, Identifiable, Hashable, CaseIterable {
    case book
    case timeline
    case calendar
    case media
    case map

    var id: String { rawValue }

    var title: String {
        switch self {
        case .book: return "Book"
        case .timeline: return "Timeline"
        case .calendar: return "Calendar"
        case .media: return "Media"
        case .map: return "Map"
        }
    }

    var dayOneIcon: DayOneIcon {
        switch self {
        case .book: return .book
        case .timeline: return .unordered_list
        case .calendar: return .calendar
        case .media: return .photo_stack
        case .map: return .map_pin
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
                            Image(dayOneIcon: tab.dayOneIcon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)

                            if selection == tab {
                                Text(tab.title)
                                    .lineLimit(1)
                                    .transition(.opacity.combined(with: .move(edge: .leading)))
                            }
                        }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 7)
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

// MARK: - Journal Detail FAB View
struct JournalDetailFAB: View {
    let journal: Journal
    let onTap: () -> Void
    @State private var showingFAB = false

    var body: some View {
        Button(action: onTap) {
            Text(DayOneIcon.plus.rawValue)
                .dayOneIconFont(size: 24)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
        }
        .background(journal.color)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .offset(y: showingFAB ? 0 : 150) // Slide up/down animation
        .opacity(showingFAB ? 1 : 0)
        .onAppear {
            // Animate FAB in after a short delay with bounce effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.interpolatingSpring(stiffness: 180, damping: 12)) {
                    showingFAB = true
                }
            }
        }
    }
}
