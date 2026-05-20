import SwiftUI

// PROTOTYPE: Seven layout variants for the Today tab, switchable via a
// DEBUG-only floating bottom bar. The skill caps at five; the seventh was
// requested explicitly. When a variant wins, fold it into TodayView and
// delete this file (plus the TodayPrototypeHost wiring in MainTabView).
//
//   A — Sectioned scroll   (current production shape, simplified mock)
//   B — Hero CTA + chips   (single giant entry action, minimal chrome)
//   C — Timeline           (time-anchored chronology down the page)
//   D — Dashboard grid     (2-col widget tiles, glance-first)
//   E — Chat-led           (conversational entry; chat is the page)
//   F — Calendar workspace (month grid top, day detail below)
//   G — Story pager        (horizontal paged carousel of capture modes)

// MARK: - Host (variant dispatch)

struct TodayPrototypeHost: View {
    #if DEBUG
    @AppStorage("todayPrototypeVariant") private var variant: String = "A"
    #endif

    var body: some View {
        #if DEBUG
        ZStack(alignment: .bottom) {
            currentVariant
            PrototypeVariantSwitcher(
                variants: [
                    ("A", "Sectioned scroll"),
                    ("B", "Hero CTA + chips"),
                    ("C", "Timeline"),
                    ("D", "Dashboard grid"),
                    ("E", "Chat-led"),
                    ("F", "Calendar workspace"),
                    ("G", "Story pager")
                ],
                selection: $variant
            )
            .padding(.bottom, 12)
        }
        #else
        TodayVariantA()
        #endif
    }

    #if DEBUG
    @ViewBuilder
    private var currentVariant: some View {
        switch variant {
        case "B": TodayVariantB()
        case "C": TodayVariantC()
        case "D": TodayVariantD()
        case "E": TodayVariantE()
        case "F": TodayVariantF()
        case "G": TodayVariantG()
        default:  TodayVariantA()
        }
    }
    #endif
}

// MARK: - Shared prototype content

enum TodayPrototypeContent {
    static let brandBlue = Color(hex: "44C0FF")
    static let coral = Color(hex: "FF6B6B")
    static let teal = Color(hex: "16D6D9")
    static let amber = Color(hex: "F5A623")

    static let greeting = "Good evening, Paul"
    static let dateString = "Wednesday, May 20"
    static let weatherSummary = "72°F · Partly cloudy"
    static let promptOfDay = "What made today feel different from yesterday?"

    static let weekStrip: [(day: String, num: String, isToday: Bool)] = [
        ("Sun", "17", false),
        ("Mon", "18", false),
        ("Tue", "19", false),
        ("Wed", "20", true),
        ("Thu", "21", false),
        ("Fri", "22", false),
        ("Sat", "23", false)
    ]

    static let timelineEvents: [(time: String, icon: String, title: String, subtitle: String, color: Color)] = [
        ("7:42 AM", "sunrise.fill", "Morning routine", "Sunrise · 68°F",                    amber),
        ("9:15 AM", "figure.walk",   "Walk to coffee",  "1.2 mi · Riverwalk Cafe",          teal),
        ("12:30 PM", "fork.knife",   "Lunch at Hana",   "Tuna poke · with Sam",             coral),
        ("3:08 PM", "camera.fill",   "Photo captured",  "Cherry blossoms at the park",      brandBlue),
        ("6:45 PM", "moon.stars.fill","Evening reflection","Daily prompt generated",         .purple)
    ]

    static let dashboardTiles: [(icon: String, title: String, value: String, color: Color)] = [
        ("flame.fill",         "Streak",   "12 days",   amber),
        ("doc.text.fill",      "Entries",  "1",          brandBlue),
        ("photo.on.rectangle", "Moments",  "4",          coral),
        ("figure.walk",        "Steps",    "8,432",      teal),
        ("face.smiling",       "Mood",     "7 / 10",     .purple),
        ("bubble.left.fill",   "Chat",     "Resume",     brandBlue)
    ]

    static let recentEntries: [(date: String, title: String, preview: String, color: Color)] = [
        ("Today",      "Morning Coffee Thoughts", "Started the day with a perfect cup of coffee…",  brandBlue),
        ("Yesterday",  "Team Meeting Notes",      "Discussed the roadmap for Q4…",                  coral),
        ("2 days ago", "Weekend Adventure",       "Explored a new hiking trail…",                   teal)
    ]

    static let chatGreeting = "Hi Paul — what stood out about today?"
    static let chatSuggestions = ["Best moment", "Something I learned", "A small win", "A challenge"]

    static let captureModes: [(icon: String, title: String, subtitle: String, color: Color)] = [
        ("text.justify",      "Write",   "Compose a written entry",   brandBlue),
        ("bubble.left.fill",  "Chat",    "Talk it through with AI",   .purple),
        ("photo.on.rectangle","Photos",  "Start from today's photos", coral),
        ("mic.fill",          "Voice",   "Record a voice memo",       teal),
        ("face.smiling",      "Trackers","Mood, energy, stress",      amber)
    ]
}

// MARK: - Shared toolbar piece

@ToolbarContentBuilder
private func todayProfileToolbarItem(_ showingSettings: Binding<Bool>) -> some ToolbarContent {
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

// MARK: - Variant A: Sectioned scroll (current shape)

struct TodayVariantA: View {
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            List {
                weekStripSection
                dailyEntrySection
                dailyChatSection
                momentsSection
                trackersSection
                Color.clear.frame(height: 100)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.white)
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { todayProfileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var weekStripSection: some View {
        HStack(spacing: 8) {
            ForEach(Array(TodayPrototypeContent.weekStrip.enumerated()), id: \.offset) { _, day in
                VStack(spacing: 4) {
                    Text(day.day).font(.caption2).foregroundStyle(.secondary)
                    Text(day.num)
                        .font(.system(size: 15, weight: day.isToday ? .bold : .regular))
                        .foregroundStyle(day.isToday ? .white : .primary)
                        .frame(width: 32, height: 32)
                        .background(day.isToday ? TodayPrototypeContent.brandBlue : Color.clear)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
    }

    private var dailyEntrySection: some View {
        sectionCard(title: "Daily Entry", accent: TodayPrototypeContent.brandBlue) {
            VStack(alignment: .leading, spacing: 10) {
                Text(TodayPrototypeContent.dateString).font(.headline)
                Text("Tap to start today's entry. We'll suggest a prompt and pull in moments from your day.")
                    .font(.subheadline).foregroundStyle(.secondary)
                Button { } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Start entry").fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(TodayPrototypeContent.brandBlue, in: Capsule())
                }
            }
        }
    }

    private var dailyChatSection: some View {
        sectionCard(title: "Daily Chat", accent: .purple) {
            VStack(alignment: .leading, spacing: 8) {
                Text(TodayPrototypeContent.chatGreeting).font(.subheadline)
                Text("3 messages so far · tap to resume")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var momentsSection: some View {
        sectionCard(title: "Moments", accent: TodayPrototypeContent.coral) {
            HStack(spacing: 10) {
                miniStat("4", "Photos", "photo.on.rectangle")
                miniStat("2", "Places", "mappin.and.ellipse")
                miniStat("1", "Event",  "calendar")
            }
        }
    }

    private var trackersSection: some View {
        sectionCard(title: "Trackers", accent: TodayPrototypeContent.amber) {
            HStack(spacing: 12) {
                miniStat("7", "Mood",   "face.smiling")
                miniStat("6", "Energy", "bolt.fill")
                miniStat("3", "Stress", "wind")
            }
        }
    }

    private func sectionCard<Content: View>(title: String, accent: Color,
                                            @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle().fill(accent).frame(width: 8, height: 8)
                Text(title).font(.system(size: 13, weight: .semibold)).tracking(0.5)
                    .foregroundStyle(.secondary).textCase(.uppercase)
            }
            content()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }

    private func miniStat(_ value: String, _ label: String, _ icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 13)).foregroundStyle(.secondary)
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Variant B: Hero CTA + chips

struct TodayVariantB: View {
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [TodayPrototypeContent.brandBlue.opacity(0.18), .white],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(TodayPrototypeContent.greeting)
                            .font(.system(size: 28, weight: .bold))
                        Text(TodayPrototypeContent.dateString + " · " + TodayPrototypeContent.weatherSummary)
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    heroCard
                        .padding(.horizontal, 20)

                    Spacer(minLength: 0)

                    chipRow
                        .padding(.bottom, 120)
                }
                .padding(.top, 12)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { todayProfileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Today's prompt")
                    .font(.caption).fontWeight(.semibold).tracking(1).textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Image(systemName: "sparkles").foregroundStyle(.white.opacity(0.85))
            }
            Text(TodayPrototypeContent.promptOfDay)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Button { } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil.line")
                    Text("Start today's entry").fontWeight(.semibold)
                }
                .foregroundStyle(TodayPrototypeContent.brandBlue)
                .padding(.horizontal, 18).padding(.vertical, 12)
                .background(.white, in: Capsule())
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 260, alignment: .topLeading)
        .background(
            LinearGradient(colors: [TodayPrototypeContent.brandBlue, .purple],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: TodayPrototypeContent.brandBlue.opacity(0.25), radius: 18, x: 0, y: 8)
    }

    private var chipRow: some View {
        HStack(spacing: 10) {
            ForEach(Array(TodayPrototypeContent.captureModes.prefix(4).enumerated()), id: \.offset) { _, mode in
                VStack(spacing: 6) {
                    Image(systemName: mode.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(mode.color)
                        .frame(width: 44, height: 44)
                        .background(mode.color.opacity(0.12), in: Circle())
                    Text(mode.title).font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Variant C: Timeline

struct TodayVariantC: View {
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(TodayPrototypeContent.dateString)
                            .font(.system(size: 28, weight: .bold))
                        Text(TodayPrototypeContent.weatherSummary)
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                    ForEach(Array(TodayPrototypeContent.timelineEvents.enumerated()), id: \.offset) { idx, event in
                        timelineRow(event: event, isFirst: idx == 0,
                                    isLast: idx == TodayPrototypeContent.timelineEvents.count - 1)
                    }

                    addToTodayButton
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { todayProfileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private func timelineRow(event: (time: String, icon: String, title: String, subtitle: String, color: Color),
                             isFirst: Bool, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(event.time)
                .font(.caption).foregroundStyle(.secondary)
                .frame(width: 64, alignment: .trailing)
                .padding(.top, 14)

            VStack(spacing: 0) {
                Rectangle().fill(isFirst ? Color.clear : Color(.separator)).frame(width: 2, height: 14)
                Circle().fill(event.color).frame(width: 12, height: 12)
                Rectangle().fill(isLast ? Color.clear : Color(.separator)).frame(width: 2)
            }
            .frame(width: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title).font(.headline)
                Text(event.subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            .padding(.vertical, 8)
            .padding(.trailing, 20)
        }
    }

    private var addToTodayButton: some View {
        Button { } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                Text("Add to today").fontWeight(.semibold)
                Spacer()
                Text("Entry · Chat · Photo").font(.caption).foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 16).padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(TodayPrototypeContent.brandBlue.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Variant D: Dashboard grid

struct TodayVariantD: View {
    @State private var showingSettings = false
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(TodayPrototypeContent.dateString).font(.headline)
                            Text(TodayPrototypeContent.weatherSummary)
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(TodayPrototypeContent.dashboardTiles.enumerated()), id: \.offset) { _, tile in
                            tileView(tile)
                        }
                    }
                    .padding(.horizontal, 16)

                    promptStripe
                        .padding(.horizontal, 16)

                    Spacer(minLength: 120)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { todayProfileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private func tileView(_ tile: (icon: String, title: String, value: String, color: Color)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: tile.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tile.color)
                Spacer()
                Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
            }
            Spacer(minLength: 8)
            Text(tile.value).font(.system(size: 22, weight: .semibold))
            Text(tile.title).font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(height: 110, alignment: .topLeading)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private var promptStripe: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(TodayPrototypeContent.brandBlue, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's prompt").font(.caption).foregroundStyle(.secondary)
                Text(TodayPrototypeContent.promptOfDay)
                    .font(.subheadline).fontWeight(.semibold)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Variant E: Chat-led

struct TodayVariantE: View {
    @State private var showingSettings = false
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(TodayPrototypeContent.dateString).font(.caption).foregroundStyle(.secondary)
                    Text(TodayPrototypeContent.greeting).font(.system(size: 22, weight: .semibold))
                }
                .padding(.top, 8).padding(.bottom, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        chatBubble(TodayPrototypeContent.chatGreeting, isUser: false)
                        chatBubble("It was busy but I got the deck out the door.", isUser: true)
                        chatBubble("Nice — what felt like the turning point?", isUser: false)
                        suggestionChips
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }

                Spacer(minLength: 0)

                composerBar
                    .padding(.horizontal, 12)
                    .padding(.bottom, 110)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { todayProfileToolbarItem($showingSettings) }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Write entry", systemImage: "pencil") { }
                        Button("Add photo",  systemImage: "photo")  { }
                        Button("Trackers",   systemImage: "face.smiling") { }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(TodayPrototypeContent.brandBlue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private func chatBubble(_ text: String, isUser: Bool) -> some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(isUser ? TodayPrototypeContent.brandBlue : Color(.systemBackground),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .foregroundStyle(isUser ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isUser ? Color.clear : Color(.separator), lineWidth: 1)
                )
            if !isUser { Spacer(minLength: 40) }
        }
    }

    private var suggestionChips: some View {
        FlowingChips(items: TodayPrototypeContent.chatSuggestions)
    }

    private var composerBar: some View {
        HStack(spacing: 10) {
            TextField("Message", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color(.systemBackground),
                            in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            Button { } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(TodayPrototypeContent.brandBlue)
            }
        }
    }
}

/// PROTOTYPE-LOCAL chip row; throwaway with the rest of this file.
private struct FlowingChips: View {
    let items: [String]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.footnote).fontWeight(.medium)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(TodayPrototypeContent.brandBlue.opacity(0.12),
                                    in: Capsule())
                        .foregroundStyle(TodayPrototypeContent.brandBlue)
                }
            }
        }
    }
}

// MARK: - Variant F: Calendar workspace

struct TodayVariantF: View {
    @State private var showingSettings = false
    @State private var selectedDay: Int = 20
    private let calendarDays: [Int?] = {
        var days: [Int?] = Array(repeating: nil, count: 4) // May 1 = Friday in this mock
        days.append(contentsOf: (1...31).map { Optional($0) })
        return days
    }()
    private let dotsOn: Set<Int> = [3, 7, 10, 11, 14, 17, 18, 19, 20]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                calendarBlock
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                Divider().padding(.horizontal, 16).padding(.vertical, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        dayHeader
                        dayCardEntry
                        dayCardChat
                        dayCardPhotos
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("May 2026")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { todayProfileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var calendarBlock: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(["S","M","T","W","T","F","S"], id: \.self) { d in
                    Text(d).font(.caption2).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            let cols = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: cols, spacing: 6) {
                ForEach(0..<calendarDays.count, id: \.self) { i in
                    if let day = calendarDays[i] {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
        }
    }

    private func dayCell(_ day: Int) -> some View {
        let isSelected = day == selectedDay
        return Button { selectedDay = day } label: {
            VStack(spacing: 3) {
                Text("\(day)")
                    .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : .primary)
                Circle()
                    .fill(dotsOn.contains(day) ? (isSelected ? .white : TodayPrototypeContent.brandBlue) : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(isSelected ? TodayPrototypeContent.brandBlue : Color.clear, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var dayHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Wednesday, May \(selectedDay)").font(.title3).fontWeight(.semibold)
            Text(TodayPrototypeContent.weatherSummary).font(.caption).foregroundStyle(.secondary)
        }
    }

    private var dayCardEntry: some View {
        dayCard(icon: "doc.text.fill", color: TodayPrototypeContent.brandBlue,
                title: "Morning Coffee Thoughts",
                subtitle: "Started the day with a perfect cup of coffee…")
    }
    private var dayCardChat: some View {
        dayCard(icon: "bubble.left.fill", color: .purple,
                title: "Daily Chat",
                subtitle: "3 messages · tap to resume")
    }
    private var dayCardPhotos: some View {
        dayCard(icon: "photo.on.rectangle", color: TodayPrototypeContent.coral,
                title: "4 photos · 2 places",
                subtitle: "Riverwalk Cafe · Cherry blossom park")
    }

    private func dayCard(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(color, in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).fontWeight(.semibold)
                Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Variant G: Story pager

struct TodayVariantG: View {
    @State private var showingSettings = false
    @State private var pageIndex = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                progressBar
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                TabView(selection: $pageIndex) {
                    ForEach(Array(TodayPrototypeContent.captureModes.enumerated()), id: \.offset) { idx, mode in
                        modePage(mode)
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .padding(.bottom, 120)
            .navigationTitle(TodayPrototypeContent.dateString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { todayProfileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
    }

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<TodayPrototypeContent.captureModes.count, id: \.self) { idx in
                Capsule()
                    .fill(idx == pageIndex
                          ? TodayPrototypeContent.brandBlue
                          : Color(.separator))
                    .frame(height: 3)
            }
        }
    }

    private func modePage(_ mode: (icon: String, title: String, subtitle: String, color: Color)) -> some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(mode.color.opacity(0.15))
                    .frame(width: 180, height: 180)
                Image(systemName: mode.icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(mode.color)
            }
            VStack(spacing: 6) {
                Text(mode.title).font(.system(size: 28, weight: .bold))
                Text(mode.subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Button { } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right")
                    Text("Use \(mode.title)").fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 22).padding(.vertical, 14)
                .background(mode.color, in: Capsule())
            }
            Spacer()
            Text("Swipe for more capture modes")
                .font(.caption).foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
