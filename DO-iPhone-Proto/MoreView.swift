import SwiftUI

/// More tab view with Quick Start, On This Day, and Daily Prompt
struct MoreView: View {
    @State private var showingSettings = false

    var body: some View {
        MoreTabOriginalView(showingSettings: $showingSettings)
    }
}

/// Original More tab layout
struct MoreTabOriginalView: View {
    @Binding var showingSettings: Bool
    @State private var quickStartExpanded = true
    @State private var onThisDayExpanded = true
    @State private var dailyPromptExpanded = true
    @State private var recentEntriesExpanded = true

    // Section visibility toggles
    @State private var showQuickStart = true
    @State private var showOnThisDay = true
    @State private var showDailyPrompt = true
    @State private var showRecentEntries = true

    // Section ordering
    @State private var showingSectionsOrder = false
    @State private var sectionOrder: [MoreSectionType] = [.recentEntries, .quickStart, .onThisDay, .dailyPrompt]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Render sections in custom order
                    ForEach(sectionOrder, id: \.self) { sectionType in
                        sectionView(for: sectionType)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Sort button
                    Button(action: {
                        showingSectionsOrder = true
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                    }

                    // Settings button
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
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingSectionsOrder) {
            MoreSectionsOrderView(
                sectionOrder: $sectionOrder,
                showQuickStart: $showQuickStart,
                showOnThisDay: $showOnThisDay,
                showDailyPrompt: $showDailyPrompt,
                showRecentEntries: $showRecentEntries
            )
        }
    }

    // MARK: - Section Views
    @ViewBuilder
    private func sectionView(for type: MoreSectionType) -> some View {
        switch type {
        case .recentEntries:
            recentEntriesSection
        case .quickStart:
            quickStartSection
        case .onThisDay:
            onThisDaySection
        case .dailyPrompt:
            dailyPromptSection
        }
    }

    @ViewBuilder
    private var recentEntriesSection: some View {
        if showRecentEntries {
            VStack(alignment: .leading, spacing: 12) {
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

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(recentEntriesExpanded ? 90 : 0))
                    }
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())

                if recentEntriesExpanded {
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
                }
            }
        }
    }

    // Sample recent entries data
    private var recentEntries: [JournalEntry] {
        return [
            JournalEntry(
                id: UUID().uuidString,
                title: "Morning Coffee Thoughts",
                preview: "Started the day with a perfect cup of coffee...",
                date: "Today",
                time: "8:30 AM",
                journalName: "Journal",
                journalColor: Color(hex: "44C0FF")
            ),
            JournalEntry(
                id: UUID().uuidString,
                title: "Team Meeting Notes",
                preview: "Discussed the roadmap for Q4...",
                date: "Yesterday",
                time: "2:00 PM",
                journalName: "Work Notes",
                journalColor: Color(hex: "FF6B6B")
            ),
            JournalEntry(
                id: UUID().uuidString,
                title: "Weekend Adventure",
                preview: "Explored a new hiking trail...",
                date: "2 days ago",
                time: "10:00 AM",
                journalName: "Travel",
                journalColor: Color(hex: "16D6D9")
            )
        ]
    }

    @ViewBuilder
    private var quickStartSection: some View {
        if showQuickStart {
            VStack(alignment: .leading, spacing: 16) {
                // Toggleable header with disclosure arrow
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        quickStartExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text("Quick Start")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(quickStartExpanded ? 90 : 0))
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())

                if quickStartExpanded {
                    Text("Instantly create an entry with one of the following:")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            QuickStartOption(icon: "photo.on.rectangle", title: "Photos")
                                .padding(.leading, 20)
                            QuickStartOption(icon: "mic", title: "Audio")
                            QuickStartOption(icon: "sun.max", title: "Today")
                            QuickStartOption(icon: "doc.text", title: "Templates")
                            QuickStartOption(icon: "bubble.left", title: "Chat")
                            QuickStartOption(icon: "video", title: "Video")
                            QuickStartOption(icon: "pencil.tip", title: "Draw")
                            QuickStartOption(icon: "text.viewfinder", title: "Scan Text")
                        }
                    }
                    .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
        }
    }

    @ViewBuilder
    private var onThisDaySection: some View {
        if showOnThisDay {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onThisDayExpanded.toggle()
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("On This Day")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Text("Jun 12")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(onThisDayExpanded ? 90 : 0))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)

                if onThisDayExpanded {
                    Text("No past memories yet! Create an entry now, and you'll see it here next year.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    HStack(spacing: 16) {
                        YearButton(year: "2024", isSelected: true)
                        YearButton(year: "2023", isSelected: false)
                        YearButton(year: "2022", isSelected: false)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    @ViewBuilder
    private var dailyPromptSection: some View {
        if showDailyPrompt {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dailyPromptExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text("Daily Prompt")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(dailyPromptExpanded ? 90 : 0))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)

                if dailyPromptExpanded {
                    VStack(spacing: 20) {
                        Text("What makes me feel most alive?")
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 24)

                        HStack {
                            Button(action: {
                                // TODO: Answer prompt
                            }) {
                                Text("Answer prompt")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                            }

                            Spacer()

                            Button(action: {
                                // TODO: Shuffle prompt
                            }) {
                                Image(systemName: "shuffle")
                                    .font(.title2)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - More Section Type
enum MoreSectionType: String, CaseIterable, Hashable {
    case recentEntries
    case quickStart
    case onThisDay
    case dailyPrompt

    var displayName: String {
        switch self {
        case .recentEntries: return "Recent Entries"
        case .quickStart: return "Quick Start"
        case .onThisDay: return "On This Day"
        case .dailyPrompt: return "Daily Prompt"
        }
    }

    var icon: String {
        switch self {
        case .recentEntries: return "doc.text"
        case .quickStart: return "bolt.fill"
        case .onThisDay: return "calendar"
        case .dailyPrompt: return "lightbulb"
        }
    }
}

// MARK: - More Sections Order View
struct MoreSectionsOrderView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sectionOrder: [MoreSectionType]
    @Binding var showQuickStart: Bool
    @Binding var showOnThisDay: Bool
    @Binding var showDailyPrompt: Bool
    @Binding var showRecentEntries: Bool

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

    private func bindingForSection(_ section: MoreSectionType) -> Binding<Bool> {
        switch section {
        case .recentEntries:
            return $showRecentEntries
        case .quickStart:
            return $showQuickStart
        case .onThisDay:
            return $showOnThisDay
        case .dailyPrompt:
            return $showDailyPrompt
        }
    }
}
// MARK: - Supporting Views
struct QuickStartOption: View {
    let icon: String
    let title: String

    var body: some View {
        Button(action: {
            // TODO: Handle quick start action
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.primary)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(width: 80)
            .padding(.vertical, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct YearButton: View {
    let year: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {
            // TODO: Select year
        }) {
            Text(year)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? Color(hex: "44C0FF") : .secondary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "44C0FF").opacity(0.1) : .gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MoreView()
}