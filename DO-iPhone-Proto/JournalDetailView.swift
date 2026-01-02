import SwiftUI

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
            AppSettingsView()
        }
    }
}
