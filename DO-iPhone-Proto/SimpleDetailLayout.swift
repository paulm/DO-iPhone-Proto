import SwiftUI

// MARK: - Simple Detail Layout Component
struct SimpleDetailLayout<Content: View>: View {
    // Required parameters
    let title: String
    let subtitle: String
    let headerBackgroundColor: Color
    let headerTextColor: Color
    let showCoverImage: Bool
    let coverImageName: String
    let content: Content

    // Optional FAB
    let fabJournal: Journal?
    let onFabTap: (() -> Void)?

    init(
        title: String,
        subtitle: String,
        headerBackgroundColor: Color,
        headerTextColor: Color,
        showCoverImage: Bool = false,
        coverImageName: String = "bike",
        fabJournal: Journal? = nil,
        onFabTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.headerBackgroundColor = headerBackgroundColor
        self.headerTextColor = headerTextColor
        self.showCoverImage = showCoverImage
        self.coverImageName = coverImageName
        self.fabJournal = fabJournal
        self.onFabTap = onFabTap
        self.content = content()
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header section with colored background
                        ZStack(alignment: .bottom) {
                            // Background color extends behind nav bar
                            headerBackgroundColor
                                .frame(height: 220 + geometry.safeAreaInsets.top)
                                .offset(y: -geometry.safeAreaInsets.top)
                                .zIndex(0)

                            // Cover image overlay if enabled
                            if showCoverImage {
                                ZStack {
                                    Image(coverImageName)
                                        .resizable()
                                        .scaledToFill()
                                }
                                .frame(height: 220 + geometry.safeAreaInsets.top)
                                .offset(y: -geometry.safeAreaInsets.top)
                                .clipped()
                                .zIndex(1)
                            }

                            // Title and subtitle - positioned at bottom of visible colored area
                            VStack(spacing: 0) {
                                Spacer()
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(title)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(headerTextColor)

                                    Text(subtitle)
                                        .font(.caption)
                                        .foregroundStyle(headerTextColor.opacity(0.8))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                            }
                            .frame(height: 220 + geometry.safeAreaInsets.top)
                            .offset(y: -geometry.safeAreaInsets.top)
                            .zIndex(2)
                        }
                        .frame(height: 220 - geometry.safeAreaInsets.top)

                        // Content section
                        content
                            .padding(.top, 14)
                    }
                }
                .background(Color(UIColor.systemBackground))
            }

            // Floating FAB (separate from scroll view)
            if let fabJournal = fabJournal, let onFabTap = onFabTap {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        JournalDetailFAB(journal: fabJournal, onTap: onFabTap)
                            .padding(.trailing, 18)
                            .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}
