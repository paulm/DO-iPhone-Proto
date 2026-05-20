import SwiftUI

// PROTOTYPE: Three layout variants for the Prompts tab, switchable via a
// DEBUG-only floating bottom bar. When a variant wins, fold it into a real
// PromptsView and delete the rest.
//
//   A — List              (current production design: paged carousel + list)
//   B — Featured + Grid   (large featured prompt + 2-col visual pack grid)
//   C — Daily ritual      (huge today's prompt dominates; packs as a row)

// MARK: - Data Models

struct PromptPack: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let promptCount: Int
    let author: String
    let description: String
}

// MARK: - Host (variant dispatch)

struct PromptsView: View {
    #if DEBUG
    @AppStorage("promptsPrototypeVariant") private var variant: String = "A"
    #endif

    var body: some View {
        #if DEBUG
        ZStack(alignment: .bottom) {
            currentVariant
            PrototypeVariantSwitcher(
                variants: [
                    ("A", "List"),
                    ("B", "Featured + Grid"),
                    ("C", "Daily ritual")
                ],
                selection: $variant
            )
            .padding(.bottom, 12)
        }
        #else
        PromptsVariantA()
        #endif
    }

    #if DEBUG
    @ViewBuilder
    private var currentVariant: some View {
        switch variant {
        case "B": PromptsVariantB()
        case "C": PromptsVariantC()
        default:  PromptsVariantA()
        }
    }
    #endif
}

// MARK: - Shared prototype content

enum PromptsPrototypeContent {
    static let todaysPrompts: [(question: String, category: String, icon: String, color: Color)] = [
        ("What is my earliest childhood memory?", "Childhood Memories", "figure.child", BrandColors.journalBlue),
        ("What moment changed my perspective?", "Life Lessons", "lightbulb", BrandColors.journalFire),
        ("If I could have dinner with anyone, who would it be and why?", "Imagination", "person.2", BrandColors.journalLavender)
    ]

    static let promptPacks: [PromptPack] = [
        PromptPack(icon: "heart.text.square", title: "Gratitude",
                   promptCount: 37, author: "Day One Team",
                   description: "Spark everyday thankfulness by noticing the large and small blessings that color your life."),
        PromptPack(icon: "envelope", title: "Friendships Through the Years",
                   promptCount: 25, author: "Day One Team",
                   description: "Explore the bonds that have shaped your life through meaningful friendships."),
        PromptPack(icon: "figure.child", title: "Childhood Memories",
                   promptCount: 42, author: "Day One Team",
                   description: "Journey back to your earliest experiences and rediscover forgotten moments."),
        PromptPack(icon: "face.smiling", title: "Firsts in Life",
                   promptCount: 30, author: "Day One Team",
                   description: "Celebrate the milestone moments that marked new chapters in your story."),
        PromptPack(icon: "cloud.sun", title: "Seasons of Life",
                   promptCount: 28, author: "Day One Team",
                   description: "Reflect on how different seasons have influenced your journey and growth.")
    ]

    static let defaultSavedPacks: Set<String> = ["Gratitude", "Childhood Memories"]
    static let defaultAnsweredCounts: [String: Int] = [
        "Gratitude": 2,
        "Friendships Through the Years": 5,
        "Childhood Memories": 0
    ]
}

// MARK: - Variant A: List (current design)

struct PromptsVariantA: View {
    @State private var showingSettings = false
    @State private var selectedPromptPack: PromptPack?
    @State private var currentPromptIndex = 0
    @State private var savedPacks: Set<String> = PromptsPrototypeContent.defaultSavedPacks
    @State private var answeredCounts: [String: Int] = PromptsPrototypeContent.defaultAnsweredCounts

    private let promptPacks = PromptsPrototypeContent.promptPacks
    private let todaysPrompts = PromptsPrototypeContent.todaysPrompts

    var body: some View {
        NavigationStack {
            List {
                todaysPromptSection
                promptPacksSection
            }
            .navigationTitle("Prompts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { profileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
        .sheet(item: $selectedPromptPack) { pack in
            PromptPackDetailView(packTitle: pack.title, packIcon: pack.icon,
                                 promptCount: pack.promptCount, author: pack.author)
        }
    }

    @ViewBuilder
    private var todaysPromptSection: some View {
        Section {
            VStack(spacing: 0) {
                TabView(selection: $currentPromptIndex) {
                    ForEach(Array(todaysPrompts.enumerated()), id: \.0) { index, prompt in
                        Text(prompt.question)
                            .font(.system(size: 19, weight: .thin, design: .serif))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(prompt.color)
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                            )
                            .padding(.horizontal, 6)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 150)

                Text("from \(todaysPrompts[currentPromptIndex].category)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                HStack(spacing: 8) {
                    ForEach(0..<todaysPrompts.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPromptIndex ? Color.gray : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } header: {
            Text("Today's Prompts")
        }
    }

    @ViewBuilder
    private var promptPacksSection: some View {
        let savedPacksList = promptPacks.filter { savedPacks.contains($0.title) }
        let unsavedPacksList = promptPacks.filter { !savedPacks.contains($0.title) }

        if !savedPacksList.isEmpty {
            Section("Saved Packs") {
                ForEach(savedPacksList) { pack in
                    Button { selectedPromptPack = pack } label: { row(for: pack) }
                }
            }
        }

        Section("Prompt Packs") {
            ForEach(unsavedPacksList) { pack in
                Button { selectedPromptPack = pack } label: { row(for: pack) }
            }
        }
    }

    private func row(for pack: PromptPack) -> some View {
        HStack {
            Image(systemName: pack.icon).font(.title2).foregroundStyle(.tint).frame(width: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(pack.title).font(.body).foregroundStyle(.primary)
                if let subtitle = subtitle(for: pack) {
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func subtitle(for pack: PromptPack) -> String? {
        var parts: [String] = []
        if savedPacks.contains(pack.title) { parts.append("✓ Saved") }
        let answered = answeredCounts[pack.title] ?? 0
        if answered > 0 { parts.append("\(answered) Answered") }
        return parts.isEmpty ? nil : parts.joined(separator: " • ")
    }
}

// MARK: - Variant B: Featured + Grid

struct PromptsVariantB: View {
    @State private var showingSettings = false
    @State private var selectedPromptPack: PromptPack?
    @State private var featuredIndex = 0
    @State private var savedPacks: Set<String> = PromptsPrototypeContent.defaultSavedPacks
    @State private var answeredCounts: [String: Int] = PromptsPrototypeContent.defaultAnsweredCounts

    private let promptPacks = PromptsPrototypeContent.promptPacks
    private let todaysPrompts = PromptsPrototypeContent.todaysPrompts

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    featuredCard
                    packsGrid
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Prompts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { profileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
        .sheet(item: $selectedPromptPack) { pack in
            PromptPackDetailView(packTitle: pack.title, packIcon: pack.icon,
                                 promptCount: pack.promptCount, author: pack.author)
        }
    }

    private var featuredCard: some View {
        let prompt = todaysPrompts[featuredIndex]
        return VStack(alignment: .leading, spacing: 14) {
            Text("TODAY'S PROMPT")
                .font(.caption2).fontWeight(.bold).tracking(1.2)
                .foregroundStyle(.white.opacity(0.75))

            Text(prompt.question)
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: prompt.icon)
                    .font(.system(size: 12))
                Text(prompt.category)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: 10) {
                Button(action: {}) {
                    Text("Answer this prompt")
                        .font(.subheadline).fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.white)
                        .foregroundStyle(prompt.color)
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: shuffleFeatured) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.18))
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(prompt.color)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: prompt.color.opacity(0.3), radius: 16, x: 0, y: 6)
        .animation(.easeOut(duration: 0.25), value: featuredIndex)
    }

    private var packsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prompt Packs")
                .font(.title3).fontWeight(.semibold)
                .padding(.horizontal, 4)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(promptPacks) { pack in
                    Button { selectedPromptPack = pack } label: { tile(for: pack) }
                        .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private func tile(for pack: PromptPack) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: pack.icon)
                    .font(.system(size: 26))
                    .foregroundStyle(Color(hex: "44C0FF"))
                Spacer()
                if savedPacks.contains(pack.title) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "44C0FF"))
                }
            }
            .frame(height: 28)

            Spacer(minLength: 4)

            Text(pack.title)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            let answered = answeredCounts[pack.title] ?? 0
            HStack(spacing: 6) {
                Text("\(pack.promptCount) prompts")
                if answered > 0 {
                    Text("•")
                    Text("\(answered) answered")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }

    private func shuffleFeatured() {
        withAnimation { featuredIndex = (featuredIndex + 1) % todaysPrompts.count }
    }
}

// MARK: - Variant C: Daily ritual

struct PromptsVariantC: View {
    @State private var showingSettings = false
    @State private var selectedPromptPack: PromptPack?
    @State private var featuredIndex = 0

    private let promptPacks = PromptsPrototypeContent.promptPacks
    private let todaysPrompts = PromptsPrototypeContent.todaysPrompts

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ritualHero
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)

                packsRow
                    .padding(.bottom, 24)
            }
            .background(
                LinearGradient(
                    colors: [
                        todaysPrompts[featuredIndex].color.opacity(0.18),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
            )
            .animation(.easeInOut(duration: 0.35), value: featuredIndex)
            .navigationTitle("Prompts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { profileToolbarItem($showingSettings) }
        }
        .sheet(isPresented: $showingSettings) { AppSettingsView() }
        .sheet(item: $selectedPromptPack) { pack in
            PromptPackDetailView(packTitle: pack.title, packIcon: pack.icon,
                                 promptCount: pack.promptCount, author: pack.author)
        }
    }

    private var ritualHero: some View {
        let prompt = todaysPrompts[featuredIndex]
        return VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 14) {
                Text(prompt.category.uppercased())
                    .font(.caption).fontWeight(.semibold).tracking(2)
                    .foregroundStyle(prompt.color)

                Text(prompt.question)
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 28)
            }

            VStack(spacing: 10) {
                Button(action: {}) {
                    Text("Answer this prompt")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(prompt.color)
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 32)

                Button(action: shuffleFeatured) {
                    HStack(spacing: 6) {
                        Image(systemName: "shuffle").font(.system(size: 13))
                        Text("Shuffle")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    private var packsRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Browse packs")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(promptPacks.count) packs")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(promptPacks) { pack in
                        Button { selectedPromptPack = pack } label: { packCard(for: pack) }
                            .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func packCard(for pack: PromptPack) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: pack.icon)
                .font(.system(size: 22))
                .foregroundStyle(Color(hex: "44C0FF"))
            Spacer(minLength: 4)
            Text(pack.title)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(pack.promptCount) prompts")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 140, height: 130, alignment: .topLeading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }

    private func shuffleFeatured() {
        withAnimation { featuredIndex = (featuredIndex + 1) % todaysPrompts.count }
    }
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

// MARK: - PROTOTYPE switcher (DEBUG builds only)

#if DEBUG
struct PrototypeVariantSwitcher: View {
    let variants: [(key: String, name: String)]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 10) {
            Button(action: previous) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(spacing: 0) {
                Text("PROTOTYPE")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.55))
                Text("\(selection) — \(currentName)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .frame(minWidth: 130)

            Button(action: next) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.82))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
    }

    private var currentIndex: Int {
        variants.firstIndex(where: { $0.key == selection }) ?? 0
    }
    private var currentName: String {
        variants[safe: currentIndex]?.name ?? "?"
    }

    private func previous() {
        let new = (currentIndex - 1 + variants.count) % variants.count
        selection = variants[new].key
    }

    private func next() {
        let new = (currentIndex + 1) % variants.count
        selection = variants[new].key
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
#endif

#Preview {
    PromptsView()
}
