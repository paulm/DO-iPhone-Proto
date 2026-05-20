import SwiftUI

// PROTOTYPE: Seven layout variants for the More tab, switchable via a
// DEBUG-only floating bottom bar. The skill caps at five; the seventh was
// requested explicitly. When a variant wins, fold it into a real MoreView
// and delete the rest.
//
//   A — Stacked cards     (current production design)
//   B — Tabs              (segmented; one section at a time)
//   C — Dashboard grid    (widget tiles, Apple-Home-style glance)
//   D — Hero + rows       (Daily Prompt featured, others compact)
//   E — Action-led list   (Quick Start dominates as a tall list)
//   F — Toolbar + workspace (Quick Start sticky toolbar; rest workspace)
//   G — Magazine          (editorial framing — lead story + sub-sections)

// MARK: - Host (variant dispatch)

struct MoreView: View {
    #if DEBUG
    @AppStorage("morePrototypeVariant") private var variant: String = "A"
    #endif

    var body: some View {
        #if DEBUG
        ZStack(alignment: .bottom) {
            currentVariant
            PrototypeVariantSwitcher(
                variants: [
                    ("A", "Stacked cards"),
                    ("B", "Tabs"),
                    ("C", "Dashboard grid"),
                    ("D", "Hero + rows"),
                    ("E", "Action-led list"),
                    ("F", "Toolbar + workspace"),
                    ("G", "Magazine")
                ],
                selection: $variant
            )
            .padding(.bottom, 12)
        }
        #else
        MoreVariantA()
        #endif
    }

    #if DEBUG
    @ViewBuilder
    private var currentVariant: some View {
        switch variant {
        case "B": MoreVariantB()
        case "C": MoreVariantC()
        case "D": MoreVariantD()
        case "E": MoreVariantE()
        case "F": MoreVariantF()
        case "G": MoreVariantG()
        default:  MoreVariantA()
        }
    }
    #endif
}

// MARK: - Shared prototype content

enum MorePrototypeContent {
    static let quickStartOptions: [(icon: String, title: String, subtitle: String)] = [
        ("photo.on.rectangle", "Photos", "Start from your photo library"),
        ("mic", "Audio", "Capture a voice memo"),
        ("sun.max", "Today", "Open today's entry"),
        ("doc.text", "Templates", "Pick a journaling template"),
        ("bubble.left", "Chat", "Ask the AI assistant"),
        ("video", "Video", "Record a video moment"),
        ("pencil.tip", "Draw", "Sketch a freeform note"),
        ("text.viewfinder", "Scan Text", "OCR handwriting or print")
    ]

    static let years = ["2024", "2023", "2022"]
    static let onThisDayDate = "Jun 12"
    static let onThisDayMessage = "No past memories yet! Create an entry now, and you'll see it here next year."

    static let dailyPromptQuestion = "What makes me feel most alive?"

    static let recentEntries: [(date: String, title: String, preview: String, color: Color)] = [
        ("Today", "Morning Coffee Thoughts", "Started the day with a perfect cup of coffee…", Color(hex: "44C0FF")),
        ("Yesterday", "Team Meeting Notes", "Discussed the roadmap for Q4…", Color(hex: "FF6B6B")),
        ("2 days ago", "Weekend Adventure", "Explored a new hiking trail…", Color(hex: "16D6D9"))
    ]

    static let brandBlue = Color(hex: "44C0FF")
}

// MARK: - Shared toolbar piece

@ToolbarContentBuilder
private func profileToolbarItem(_ showingSettings: Binding<Bool>) -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button {
            showingSettings.wrappedValue = true
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

// MARK: - Variant A: Stacked cards (current design)

struct MoreVariantA: View {
    @State private var showingSettings = false
    @State private var quickStartExpanded = true
    @State private var onThisDayExpanded = true
    @State private var dailyPromptExpanded = true
    @State private var recentEntriesExpanded = true

    @State private var showQuickStart = true
    @State private var showOnThisDay = true
    @State private var showDailyPrompt = true
    @State private var showRecentEntries = false

    @State private var showingSectionsOrder = false
    @State private var sectionOrder: [MoreSectionType] = [.recentEntries, .quickStart, .onThisDay, .dailyPrompt]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    ForEach(sectionOrder, id: \.self) { type in
                        sectionView(for: type)
                    }
                    Spacer(minLength: 80)
                }
                .padding(.top, 20)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { showingSectionsOrder = true } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    Button { showingSettings = true } label: {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .pink],
                                                  startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 32, height: 32)
                            .overlay(Text("PM").font(.system(size: 12, weight: .semibold)).foregroundColor(.white))
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
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

    @ViewBuilder
    private func sectionView(for type: MoreSectionType) -> some View {
        switch type {
        case .recentEntries: if showRecentEntries { recentEntriesSection }
        case .quickStart:    if showQuickStart    { quickStartSection }
        case .onThisDay:     if showOnThisDay     { onThisDaySection }
        case .dailyPrompt:   if showDailyPrompt   { dailyPromptSection }
        }
    }

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Recent Entries", expanded: $recentEntriesExpanded)
            if recentEntriesExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(MorePrototypeContent.recentEntries.enumerated()), id: \.offset) { _, entry in
                            recentEntryCard(entry)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Quick Start", expanded: $quickStartExpanded)
            if quickStartExpanded {
                Text("Instantly create an entry with one of the following:")
                    .font(.body).foregroundStyle(.secondary).padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(MorePrototypeContent.quickStartOptions.enumerated()), id: \.offset) { i, opt in
                            quickStartTile(icon: opt.icon, title: opt.title)
                                .padding(.leading, i == 0 ? 20 : 0)
                        }
                    }
                }
                .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private var onThisDaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button { withAnimation { onThisDayExpanded.toggle() } } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("On This Day").font(.title2).fontWeight(.bold).foregroundStyle(.primary)
                        Text(MorePrototypeContent.onThisDayDate).font(.title3).foregroundStyle(.secondary)
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
                Text(MorePrototypeContent.onThisDayMessage)
                    .font(.body).foregroundStyle(.secondary).padding(.horizontal)
                HStack(spacing: 16) {
                    ForEach(Array(MorePrototypeContent.years.enumerated()), id: \.offset) { i, year in
                        yearButton(year: year, isSelected: i == 0)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var dailyPromptSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Daily Prompt", expanded: $dailyPromptExpanded)
            if dailyPromptExpanded {
                VStack(spacing: 20) {
                    Text(MorePrototypeContent.dailyPromptQuestion)
                        .font(.title3).foregroundStyle(.primary)
                        .multilineTextAlignment(.center).padding(.top, 24)
                    HStack {
                        Button(action: {}) { Text("Answer prompt").font(.headline).foregroundStyle(.primary) }
                        Spacer()
                        Button(action: {}) { Image(systemName: "shuffle").font(.title2).foregroundStyle(.primary) }
                    }
                    .padding(.bottom, 24)
                }
                .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private func sectionHeader(_ title: String, expanded: Binding<Bool>) -> some View {
        Button { withAnimation { expanded.wrappedValue.toggle() } } label: {
            HStack {
                Text(title).font(.title2).fontWeight(.bold).foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(expanded.wrappedValue ? 90 : 0))
            }
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func quickStartTile(icon: String, title: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 24)).foregroundStyle(.primary)
            Text(title).font(.caption).foregroundStyle(.primary)
        }
        .frame(width: 80, height: 80)
    }

    private func yearButton(year: String, isSelected: Bool) -> some View {
        Text(year)
            .font(.headline)
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? MorePrototypeContent.brandBlue : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func recentEntryCard(_ entry: (date: String, title: String, preview: String, color: Color)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 4).fill(entry.color).frame(height: 4)
            Text(entry.date).font(.caption2).foregroundStyle(.secondary)
            Text(entry.title).font(.subheadline).fontWeight(.semibold).lineLimit(2)
            Text(entry.preview).font(.caption).foregroundStyle(.secondary).lineLimit(3)
            Spacer()
        }
        .padding(10)
        .frame(width: 130, height: 130, alignment: .topLeading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Variant B: Tabs

struct MoreVariantB: View {
    enum Tab: String, CaseIterable, Identifiable {
        case quickStart = "Quick Start"
        case onThisDay = "On This Day"
        case dailyPrompt = "Daily Prompt"
        case recent = "Recent"
        var id: String { rawValue }
    }

    @State private var tab: Tab = .quickStart
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $tab) {
                    ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Group {
                    switch tab {
                    case .quickStart:  quickStartContent
                    case .onThisDay:   onThisDayContent
                    case .dailyPrompt: dailyPromptContent
                    case .recent:      recentContent
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { profileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var quickStartContent: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Array(MorePrototypeContent.quickStartOptions.enumerated()), id: \.offset) { _, opt in
                    VStack(spacing: 10) {
                        Image(systemName: opt.icon).font(.system(size: 28)).foregroundStyle(MorePrototypeContent.brandBlue)
                        Text(opt.title).font(.subheadline).fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 28)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(16)
            Color.clear.frame(height: 80)
        }
    }

    private var onThisDayContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("On This Day").font(.largeTitle).fontWeight(.bold)
                Text(MorePrototypeContent.onThisDayDate).font(.title3).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20).padding(.top, 12)

            Text(MorePrototypeContent.onThisDayMessage)
                .font(.body).foregroundStyle(.secondary).padding(.horizontal, 20)

            VStack(spacing: 10) {
                ForEach(Array(MorePrototypeContent.years.enumerated()), id: \.offset) { i, year in
                    HStack {
                        Text(year).font(.headline)
                        Spacer()
                        if i == 0 { Image(systemName: "checkmark").foregroundStyle(MorePrototypeContent.brandBlue) }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }

    private var dailyPromptContent: some View {
        VStack(spacing: 28) {
            Spacer()
            Text("DAILY PROMPT").font(.caption).fontWeight(.semibold).tracking(2).foregroundStyle(MorePrototypeContent.brandBlue)
            Text(MorePrototypeContent.dailyPromptQuestion)
                .font(.system(size: 26, weight: .light, design: .serif))
                .multilineTextAlignment(.center).padding(.horizontal, 32)
            VStack(spacing: 10) {
                Button(action: {}) {
                    Text("Answer prompt").font(.headline).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(MorePrototypeContent.brandBlue).clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle()).padding(.horizontal, 32)
                Button(action: {}) {
                    HStack(spacing: 6) { Image(systemName: "shuffle"); Text("Shuffle") }
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
    }

    private var recentContent: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(Array(MorePrototypeContent.recentEntries.enumerated()), id: \.offset) { _, entry in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 3).fill(entry.color).frame(width: 4, height: 50)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date).font(.caption2).foregroundStyle(.secondary)
                            Text(entry.title).font(.subheadline).fontWeight(.semibold)
                            Text(entry.preview).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                    }
                    .padding(14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Variant C: Dashboard grid

struct MoreVariantC: View {
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        todayTile
                        dailyPromptTile
                    }
                    quickStartWideTile
                    recentTile
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { profileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var todayTile: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("On This Day").font(.caption).fontWeight(.medium).foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "clock.arrow.circlepath").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            Text(MorePrototypeContent.onThisDayDate).font(.title).fontWeight(.semibold)
            Text("No past memories yet").font(.caption).foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var dailyPromptTile: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily Prompt").font(.caption).fontWeight(.medium).foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "lightbulb").font(.caption).foregroundStyle(MorePrototypeContent.brandBlue)
            }
            Spacer(minLength: 4)
            Text(MorePrototypeContent.dailyPromptQuestion)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(action: {}) {
                Text("Answer →").font(.caption).fontWeight(.semibold)
                    .foregroundStyle(MorePrototypeContent.brandBlue)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var quickStartWideTile: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start").font(.caption).fontWeight(.medium).foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(MorePrototypeContent.quickStartOptions.enumerated()), id: \.offset) { _, opt in
                        VStack(spacing: 6) {
                            Image(systemName: opt.icon).font(.system(size: 22)).foregroundStyle(MorePrototypeContent.brandBlue)
                            Text(opt.title).font(.caption2).foregroundStyle(.primary)
                        }
                        .frame(width: 68)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var recentTile: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Entries").font(.caption).fontWeight(.medium).foregroundStyle(.secondary)
                Spacer()
                Text("View all").font(.caption).foregroundStyle(MorePrototypeContent.brandBlue)
            }
            ForEach(Array(MorePrototypeContent.recentEntries.enumerated()), id: \.offset) { _, entry in
                HStack(spacing: 10) {
                    Circle().fill(entry.color).frame(width: 8, height: 8)
                    Text(entry.title).font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Text(entry.date).font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Variant D: Hero (Daily Prompt) + compact rows

struct MoreVariantD: View {
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    dailyPromptHero
                    quickStartStrip
                    onThisDayRow
                    recentList
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { profileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var dailyPromptHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DAILY PROMPT")
                .font(.caption2).fontWeight(.bold).tracking(1.2)
                .foregroundStyle(.white.opacity(0.75))
            Text(MorePrototypeContent.dailyPromptQuestion)
                .font(.system(size: 26, weight: .light, design: .serif))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                Button(action: {}) {
                    Text("Answer prompt").font(.subheadline).fontWeight(.semibold)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(.white).foregroundStyle(MorePrototypeContent.brandBlue)
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                Button(action: {}) {
                    Image(systemName: "shuffle").font(.system(size: 14, weight: .semibold))
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.18)).foregroundStyle(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MorePrototypeContent.brandBlue)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: MorePrototypeContent.brandBlue.opacity(0.3), radius: 16, x: 0, y: 6)
    }

    private var quickStartStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Start").font(.subheadline).fontWeight(.semibold).padding(.horizontal, 4)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(MorePrototypeContent.quickStartOptions.enumerated()), id: \.offset) { _, opt in
                        VStack(spacing: 4) {
                            Image(systemName: opt.icon).font(.system(size: 22)).foregroundStyle(MorePrototypeContent.brandBlue)
                                .frame(width: 56, height: 56).background(Color(.systemBackground)).clipShape(Circle())
                            Text(opt.title).font(.caption2)
                        }
                    }
                }
            }
        }
    }

    private var onThisDayRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("On This Day").font(.subheadline).fontWeight(.semibold)
                Text(MorePrototypeContent.onThisDayDate).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 6) {
                ForEach(MorePrototypeContent.years, id: \.self) { y in
                    Text(y).font(.caption).fontWeight(.semibold)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(y == "2024" ? MorePrototypeContent.brandBlue : Color.gray.opacity(0.15))
                        .foregroundStyle(y == "2024" ? .white : .primary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var recentList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent").font(.subheadline).fontWeight(.semibold).padding(.horizontal, 4)
            VStack(spacing: 8) {
                ForEach(Array(MorePrototypeContent.recentEntries.enumerated()), id: \.offset) { _, entry in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 3).fill(entry.color).frame(width: 4, height: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.title).font(.subheadline).fontWeight(.medium)
                            Text(entry.date).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

// MARK: - Variant E: Action-led list

struct MoreVariantE: View {
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    todayBanner
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                }
                Section("Quick Start") {
                    ForEach(Array(MorePrototypeContent.quickStartOptions.enumerated()), id: \.offset) { _, opt in
                        actionRow(opt: opt)
                    }
                }
                Section("Recent Entries") {
                    ForEach(Array(MorePrototypeContent.recentEntries.enumerated()), id: \.offset) { _, entry in
                        HStack {
                            RoundedRectangle(cornerRadius: 3).fill(entry.color).frame(width: 4, height: 24)
                            VStack(alignment: .leading) {
                                Text(entry.title).font(.subheadline)
                                Text(entry.date).font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { profileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var todayBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "calendar").font(.caption).foregroundStyle(MorePrototypeContent.brandBlue)
                Text("Today, \(MorePrototypeContent.onThisDayDate)").font(.caption).fontWeight(.medium).foregroundStyle(.secondary)
            }
            Text(MorePrototypeContent.dailyPromptQuestion)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .lineLimit(2)
            Button(action: {}) {
                Text("Answer today's prompt →").font(.caption).fontWeight(.semibold)
                    .foregroundStyle(MorePrototypeContent.brandBlue)
            }
        }
        .padding(.vertical, 4)
    }

    private func actionRow(opt: (icon: String, title: String, subtitle: String)) -> some View {
        HStack(spacing: 14) {
            Image(systemName: opt.icon)
                .font(.system(size: 18))
                .foregroundStyle(MorePrototypeContent.brandBlue)
                .frame(width: 36, height: 36)
                .background(MorePrototypeContent.brandBlue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 2) {
                Text(opt.title).font(.body).foregroundStyle(.primary)
                Text(opt.subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Variant F: Toolbar + workspace

struct MoreVariantF: View {
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                toolbar
                ScrollView {
                    VStack(spacing: 16) {
                        dailyPromptCard
                        onThisDayCard
                        recentCard
                        Color.clear.frame(height: 80)
                    }
                    .padding(16)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { profileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var toolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(MorePrototypeContent.quickStartOptions.enumerated()), id: \.offset) { _, opt in
                    HStack(spacing: 6) {
                        Image(systemName: opt.icon).font(.system(size: 14))
                        Text(opt.title).font(.subheadline)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(MorePrototypeContent.brandBlue.opacity(0.12))
                    .foregroundStyle(MorePrototypeContent.brandBlue)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle().frame(height: 1).foregroundStyle(Color.gray.opacity(0.15)),
            alignment: .bottom
        )
    }

    private var dailyPromptCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Daily Prompt").font(.caption).fontWeight(.semibold).tracking(1).foregroundStyle(.secondary)
            Text(MorePrototypeContent.dailyPromptQuestion)
                .font(.system(size: 22, weight: .light, design: .serif))
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button(action: {}) {
                    Text("Answer").font(.subheadline).fontWeight(.semibold)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(MorePrototypeContent.brandBlue).foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                Button(action: {}) {
                    Image(systemName: "shuffle").font(.system(size: 14, weight: .semibold))
                        .padding(8).background(Color.gray.opacity(0.12)).foregroundStyle(.primary)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var onThisDayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("On This Day").font(.subheadline).fontWeight(.semibold)
                    Text(MorePrototypeContent.onThisDayDate).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            HStack(spacing: 10) {
                ForEach(Array(MorePrototypeContent.years.enumerated()), id: \.offset) { i, year in
                    Text(year)
                        .font(.subheadline).fontWeight(.medium)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(i == 0 ? MorePrototypeContent.brandBlue : Color.gray.opacity(0.1))
                        .foregroundStyle(i == 0 ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var recentCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent").font(.subheadline).fontWeight(.semibold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(MorePrototypeContent.recentEntries.enumerated()), id: \.offset) { _, entry in
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 3).fill(entry.color).frame(height: 4)
                            Text(entry.date).font(.caption2).foregroundStyle(.secondary)
                            Text(entry.title).font(.caption).fontWeight(.semibold).lineLimit(2)
                            Spacer()
                        }
                        .padding(10)
                        .frame(width: 130, height: 110, alignment: .topLeading)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Variant G: Magazine

struct MoreVariantG: View {
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    leadStory
                    yesteryearSection
                    latelySection
                    toolsSection
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { profileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var leadStory: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TODAY'S PROMPT")
                .font(.caption).fontWeight(.bold).tracking(2)
                .foregroundStyle(MorePrototypeContent.brandBlue)
            Text("“\(MorePrototypeContent.dailyPromptQuestion)”")
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 6) {
                Rectangle().fill(.primary.opacity(0.6)).frame(width: 16, height: 1)
                Text("A prompt for your day")
                    .font(.caption).foregroundStyle(.secondary).italic()
            }
            Button(action: {}) {
                Text("Reflect on this →").font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(MorePrototypeContent.brandBlue)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
        }
    }

    private var yesteryearSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Yesteryear", subtitle: "Memories from \(MorePrototypeContent.onThisDayDate)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(MorePrototypeContent.years.enumerated()), id: \.offset) { i, year in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(year).font(.system(size: 28, weight: .light, design: .serif))
                            Text(i == 0 ? "— Selected" : "Tap to view").font(.caption).foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(14)
                        .frame(width: 140, height: 120, alignment: .topLeading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(i == 0 ? MorePrototypeContent.brandBlue : .clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }

    private var latelySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Lately", subtitle: "Your recent entries")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Array(MorePrototypeContent.recentEntries.enumerated()), id: \.offset) { _, entry in
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4).fill(entry.color).frame(height: 4)
                        Text(entry.date.uppercased()).font(.caption2).fontWeight(.semibold).foregroundStyle(.secondary).tracking(0.5)
                        Text(entry.title).font(.subheadline).fontWeight(.semibold).lineLimit(2)
                        Text(entry.preview).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Tools", subtitle: "Quick ways to start an entry")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(MorePrototypeContent.quickStartOptions.enumerated()), id: \.offset) { _, opt in
                        VStack(spacing: 6) {
                            Image(systemName: opt.icon).font(.system(size: 22))
                                .frame(width: 56, height: 56)
                                .background(MorePrototypeContent.brandBlue.opacity(0.12))
                                .foregroundStyle(MorePrototypeContent.brandBlue)
                                .clipShape(Circle())
                            Text(opt.title).font(.caption2).foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
    }

    private func sectionHeader(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle().fill(.primary).frame(height: 1).padding(.bottom, 4)
            Text(title).font(.title3).fontWeight(.bold)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Section type + ordering sheet (used by Variant A)

enum MoreSectionType: String, CaseIterable, Hashable {
    case recentEntries, quickStart, onThisDay, dailyPrompt
}

struct MoreSectionsOrderView: View {
    @Binding var sectionOrder: [MoreSectionType]
    @Binding var showQuickStart: Bool
    @Binding var showOnThisDay: Bool
    @Binding var showDailyPrompt: Bool
    @Binding var showRecentEntries: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Visibility") {
                    Toggle("Quick Start", isOn: $showQuickStart)
                    Toggle("On This Day", isOn: $showOnThisDay)
                    Toggle("Daily Prompt", isOn: $showDailyPrompt)
                    Toggle("Recent Entries", isOn: $showRecentEntries)
                }
                Section("Order") {
                    ForEach(sectionOrder, id: \.self) { type in
                        Text(label(for: type))
                    }
                    .onMove { sectionOrder.move(fromOffsets: $0, toOffset: $1) }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Sections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func label(for t: MoreSectionType) -> String {
        switch t {
        case .recentEntries: return "Recent Entries"
        case .quickStart:    return "Quick Start"
        case .onThisDay:     return "On This Day"
        case .dailyPrompt:   return "Daily Prompt"
        }
    }
}

#Preview {
    MoreView()
}
