import SwiftUI

// PROTOTYPE: Three layout variants for Settings > Support, switchable via a
// DEBUG-only floating bottom bar. When a variant wins, fold it into a real
// SupportView and delete the rest.
//
//   A — Chat-first list   (current production design)
//   B — Hero + Grid       (search-led hero card, guides as 2-col tile grid)
//   C — Segmented tabs    (Chat | Browse as mutually-exclusive modes)

// MARK: - Host (variant dispatch)

struct SupportView: View {
    #if DEBUG
    @AppStorage("supportPrototypeVariant") private var variant: String = "A"
    #endif

    var body: some View {
        #if DEBUG
        ZStack(alignment: .bottom) {
            currentVariant
            PrototypeVariantSwitcher(
                variants: [
                    ("A", "Chat-first list"),
                    ("B", "Hero + Grid"),
                    ("C", "Segmented tabs")
                ],
                selection: $variant
            )
            .padding(.bottom, 12)
        }
        #else
        SupportVariantA()
        #endif
    }

    #if DEBUG
    @ViewBuilder
    private var currentVariant: some View {
        switch variant {
        case "B": SupportVariantB()
        case "C": SupportVariantC()
        default:  SupportVariantA()
        }
    }
    #endif
}

// MARK: - Shared prototype content

enum SupportPrototypeContent {
    // Stub account snapshot used in the opening greeting.
    // TODO: replace with real values when the support assistant is wired up.
    static let userFirstName = "Paul"
    static let encryptedJournalCount = 16
    static let recentlyActiveDeviceCount = 3

    static var welcomeMessage: String {
        "Hi \(userFirstName), I'm Day One's customer help chat. I see you have \(encryptedJournalCount) encrypted journals and you've been active on \(recentlyActiveDeviceCount) devices recently. All your data appears synced up as expected."
    }

    static let suggestedIssues = [
        "My entries aren't syncing",
        "How do I import from another app?",
        "I can't sign in"
    ]

    static func stubReply(for question: String) -> String {
        "Thanks for reaching out. Support content for “\(question)” will appear here once the assistant is wired up."
    }
}

// MARK: - Variant A: Chat-first list (current design)

struct SupportVariantA: View {
    @State private var draftText: String = ""
    @State private var conversation: [SupportChatMessage] = []
    @State private var isThinking = false
    @State private var hasShownWelcome = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        List {
            chatForHelpSection
            browseGuidesSection
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .task { await showWelcomeIfNeeded() }
    }

    @ViewBuilder
    private var chatForHelpSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(conversation) { message in
                    SupportChatBubble(message: message)
                }
                if isThinking {
                    SupportThinkingDots()
                }

                chatInputRow

                if !conversation.contains(where: { $0.isUser }) {
                    suggestedIssuesGroup
                }
            }
            .padding(.vertical, 4)
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .listRowBackground(Color.clear)
        } header: {
            Text("Chat for Help")
        }
    }

    private var chatInputRow: some View {
        HStack(spacing: 8) {
            TextField("How can we help?", text: $draftText, axis: .vertical)
                .lineLimit(1...4)
                .focused($inputFocused)
                .submitLabel(.send)
                .onSubmit { sendDraft() }

            Button(action: sendDraft) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(isDraftEmpty ? Color.secondary.opacity(0.4) : Color(hex: "44C0FF"))
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isDraftEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var suggestedIssuesGroup: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trending")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            ForEach(SupportPrototypeContent.suggestedIssues, id: \.self) { issue in
                Button { send(issue) } label: {
                    HStack {
                        Text(issue).font(.subheadline).foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    @ViewBuilder
    private var browseGuidesSection: some View {
        Section("Browse Guides") {
            ForEach(SupportCategory.all) { category in
                NavigationLink {
                    SupportCategoryPlaceholderView(category: category)
                } label: {
                    HStack {
                        Image(systemName: category.systemImage)
                            .frame(width: 24)
                            .foregroundStyle(.primary)
                        Text(category.title)
                    }
                }
            }
        }
    }

    private var isDraftEmpty: Bool {
        draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendDraft() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draftText = ""
        send(text)
    }

    private func send(_ text: String) {
        inputFocused = false
        withAnimation(.easeOut(duration: 0.2)) {
            conversation.append(SupportChatMessage(text: text, isUser: true))
            isThinking = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                isThinking = false
                conversation.append(SupportChatMessage(text: SupportPrototypeContent.stubReply(for: text), isUser: false))
            }
        }
    }

    @MainActor
    private func showWelcomeIfNeeded() async {
        guard !hasShownWelcome else { return }
        hasShownWelcome = true
        withAnimation(.easeOut(duration: 0.2)) { isThinking = true }
        try? await Task.sleep(nanoseconds: 600_000_000)
        guard !Task.isCancelled else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            isThinking = false
            conversation.append(SupportChatMessage(text: SupportPrototypeContent.welcomeMessage, isUser: false))
        }
    }
}

// MARK: - Variant B: Hero card + 2-column tile grid

struct SupportVariantB: View {
    @State private var draftText: String = ""
    @State private var conversation: [SupportChatMessage] = []
    @State private var isThinking = false
    @State private var hasShownWelcome = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroCard
                browseGrid
                Color.clear.frame(height: 80) // breathing room for the switcher bar
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .task { await showWelcomeIfNeeded() }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DAY ONE HELP")
                .font(.caption2)
                .fontWeight(.bold)
                .tracking(1)
                .foregroundStyle(Color(hex: "44C0FF"))

            // Welcome / conversation
            VStack(alignment: .leading, spacing: 10) {
                ForEach(conversation) { message in
                    SupportChatBubble(message: message)
                }
                if isThinking {
                    SupportThinkingDots()
                }
            }

            // Chat input
            HStack(spacing: 8) {
                TextField("Ask a question…", text: $draftText, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($inputFocused)
                    .submitLabel(.send)
                    .onSubmit { sendDraft() }
                Button(action: sendDraft) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(isDraftEmpty ? Color.secondary.opacity(0.4) : Color(hex: "44C0FF"))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isDraftEmpty)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Trending chips (horizontal scroll)
            if !conversation.contains(where: { $0.isUser }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trending")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(SupportPrototypeContent.suggestedIssues, id: \.self) { issue in
                                Button { send(issue) } label: {
                                    Text(issue)
                                        .font(.subheadline)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "44C0FF").opacity(0.12))
                                        .foregroundStyle(Color(hex: "44C0FF"))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private var browseGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse Guides")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(SupportCategory.all) { category in
                    NavigationLink {
                        SupportCategoryPlaceholderView(category: category)
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: category.systemImage)
                                .font(.system(size: 28))
                                .foregroundStyle(Color(hex: "44C0FF"))
                                .frame(height: 32)
                            Text(category.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var isDraftEmpty: Bool {
        draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendDraft() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draftText = ""
        send(text)
    }

    private func send(_ text: String) {
        inputFocused = false
        withAnimation(.easeOut(duration: 0.2)) {
            conversation.append(SupportChatMessage(text: text, isUser: true))
            isThinking = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                isThinking = false
                conversation.append(SupportChatMessage(text: SupportPrototypeContent.stubReply(for: text), isUser: false))
            }
        }
    }

    @MainActor
    private func showWelcomeIfNeeded() async {
        guard !hasShownWelcome else { return }
        hasShownWelcome = true
        withAnimation(.easeOut(duration: 0.2)) { isThinking = true }
        try? await Task.sleep(nanoseconds: 600_000_000)
        guard !Task.isCancelled else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            isThinking = false
            conversation.append(SupportChatMessage(text: SupportPrototypeContent.welcomeMessage, isUser: false))
        }
    }
}

// MARK: - Variant C: Segmented tabs (Chat | Browse)

struct SupportVariantC: View {
    enum Mode: String, CaseIterable, Identifiable {
        case chat = "Chat"
        case browse = "Browse"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .chat
    @State private var draftText: String = ""
    @State private var conversation: [SupportChatMessage] = []
    @State private var isThinking = false
    @State private var hasShownWelcome = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))

            Group {
                switch mode {
                case .chat:   chatTab
                case .browse: browseTab
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .task { await showWelcomeIfNeeded() }
    }

    // Chat tab: messages scroll above, input pinned at bottom.
    private var chatTab: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(conversation) { message in
                            SupportChatBubble(message: message)
                                .id(message.id)
                        }
                        if isThinking {
                            SupportThinkingDots().id("thinking")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                }
                .onChange(of: conversation.count) { _, _ in
                    if let last = conversation.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            if !conversation.contains(where: { $0.isUser }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trending")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(SupportPrototypeContent.suggestedIssues, id: \.self) { issue in
                                Button { send(issue) } label: {
                                    Text(issue)
                                        .font(.subheadline)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(Color(.tertiarySystemGroupedBackground))
                                        .foregroundStyle(.primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground).opacity(0.4))
            }

            // Input pinned at bottom
            HStack(spacing: 8) {
                TextField("Message", text: $draftText, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($inputFocused)
                    .submitLabel(.send)
                    .onSubmit { sendDraft() }
                Button(action: sendDraft) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(isDraftEmpty ? Color.secondary.opacity(0.4) : Color(hex: "44C0FF"))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isDraftEmpty)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.gray.opacity(0.15))
                    .frame(maxHeight: .infinity, alignment: .top)
            )
        }
        .background(Color(.systemGroupedBackground))
    }

    private var browseTab: some View {
        List {
            ForEach(SupportCategory.all) { category in
                NavigationLink {
                    SupportCategoryPlaceholderView(category: category)
                } label: {
                    HStack {
                        Image(systemName: category.systemImage)
                            .frame(width: 24)
                            .foregroundStyle(.primary)
                        Text(category.title)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var isDraftEmpty: Bool {
        draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendDraft() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draftText = ""
        send(text)
    }

    private func send(_ text: String) {
        inputFocused = false
        withAnimation(.easeOut(duration: 0.2)) {
            conversation.append(SupportChatMessage(text: text, isUser: true))
            isThinking = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                isThinking = false
                conversation.append(SupportChatMessage(text: SupportPrototypeContent.stubReply(for: text), isUser: false))
            }
        }
    }

    @MainActor
    private func showWelcomeIfNeeded() async {
        guard !hasShownWelcome else { return }
        hasShownWelcome = true
        withAnimation(.easeOut(duration: 0.2)) { isThinking = true }
        try? await Task.sleep(nanoseconds: 600_000_000)
        guard !Task.isCancelled else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            isThinking = false
            conversation.append(SupportChatMessage(text: SupportPrototypeContent.welcomeMessage, isUser: false))
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

// MARK: - Models

private struct SupportChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct SupportCategory: Identifiable {
    let id: String
    let title: String
    let systemImage: String

    static let all: [SupportCategory] = [
        SupportCategory(id: "get-started", title: "Get Started", systemImage: "book.fill"),
        SupportCategory(id: "account-and-billing", title: "Account & Billing", systemImage: "creditcard"),
        SupportCategory(id: "writing", title: "Writing", systemImage: "pencil"),
        SupportCategory(id: "organizing", title: "Organizing", systemImage: "folder"),
        SupportCategory(id: "sync-and-backup", title: "Sync & Backup", systemImage: "arrow.triangle.2.circlepath"),
        SupportCategory(id: "privacy-and-encryption", title: "Privacy & Encryption", systemImage: "lock.shield"),
        SupportCategory(id: "troubleshooting", title: "Troubleshooting", systemImage: "wrench.and.screwdriver"),
        SupportCategory(id: "integrations", title: "Integrations", systemImage: "bolt"),
        SupportCategory(id: "reference", title: "Reference", systemImage: "book"),
        SupportCategory(id: "release-notes", title: "Release Notes", systemImage: "doc.text")
    ]
}

// MARK: - Supporting Views

private struct SupportChatBubble: View {
    let message: SupportChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 40) }
            Text(message.text)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(message.isUser ? Color(hex: "44C0FF") : Color(.systemBackground))
                .foregroundStyle(message.isUser ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(message.isUser ? 0 : 0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            if !message.isUser { Spacer(minLength: 40) }
        }
    }
}

private struct SupportThinkingDots: View {
    @State private var phase: Int = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 6, height: 6)
                    .opacity(phase == i ? 1 : 0.3)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .onReceive(timer) { _ in
            phase = (phase + 1) % 3
        }
    }
}

private struct SupportCategoryPlaceholderView: View {
    let category: SupportCategory

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: category.systemImage)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text(category.title)
                .font(.title2)
                .fontWeight(.medium)
            Text("Guide content coming soon.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SupportView()
    }
}
