import SwiftUI

/// Settings > Support landing page.
///
/// Hero card pairs a personalized welcome with a free-form ask field and a row
/// of trending issues; below it, the ten top-level help categories appear as a
/// 2-column tile grid. Selected from a prototype with three layout variants —
/// see commit history for the alternatives that were considered.
struct SupportView: View {
    @State private var draftText: String = ""
    @State private var conversation: [SupportChatMessage] = []
    @State private var isThinking = false
    @State private var hasShownWelcome = false
    @State private var humanHandoffRequested = false
    @State private var handoffConfirmed = false
    @FocusState private var inputFocused: Bool

    // Stub account snapshot used in the opening greeting.
    // TODO: replace with real values when the support assistant is wired up.
    private let userFirstName = "Paul"
    private let userEmail = "paul.mayne@a8c.com"
    private let encryptedJournalCount = 16
    private let recentlyActiveDeviceCount = 3

    private let suggestedIssues = [
        "My entries aren't syncing",
        "How do I import from another app?",
        "I can't sign in"
    ]

    private var welcomeMessage: String {
        "Hi \(userFirstName), I'm Day One's customer help chat. I see you have \(encryptedJournalCount) encrypted journals and you've been active on \(recentlyActiveDeviceCount) devices recently. All your data appears synced up as expected."
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroCard
                browseGrid
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .task { await showWelcomeIfNeeded() }
    }

    // MARK: - Hero card

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DAY ONE HELP")
                .font(.caption2)
                .fontWeight(.bold)
                .tracking(1)
                .foregroundStyle(Color(hex: "44C0FF"))

            if handoffConfirmed {
                handoffConfirmationPanel
            } else {
                chatExperience
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private var chatExperience: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(conversation) { message in
                    SupportChatBubble(message: message)
                }
                if isThinking {
                    SupportThinkingDots()
                }
            }

            chatInputRow

            // Trending chips only appear before the user sends their first
            // message; the seeded welcome from the assistant doesn't count.
            if !conversation.contains(where: { $0.isUser }) {
                trendingChips
            }

            // Escape hatch to a human appears after the user has sent at
            // least two messages without finding a resolution.
            if shouldOfferHumanHandoff {
                humanHandoffOffer
            }
        }
    }

    private var handoffConfirmationPanel: some View {
        VStack(spacing: 14) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding(.top, 4)

            VStack(spacing: 6) {
                Text("We'll continue by email")
                    .font(.headline)

                (Text("A Day One support agent will reach out at ")
                    + Text(userEmail).fontWeight(.semibold)
                    + Text(" shortly to follow up on your question."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: startNewChat) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14))
                    Text("Start a new chat")
                        .font(.subheadline)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(hex: "44C0FF").opacity(0.12))
                .foregroundStyle(Color(hex: "44C0FF"))
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private var chatInputRow: some View {
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
    }

    private var trendingChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trending")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestedIssues, id: \.self) { issue in
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

    private var shouldOfferHumanHandoff: Bool {
        !humanHandoffRequested
            && conversation.filter(\.isUser).count >= 2
    }

    private var humanHandoffOffer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Still need help?")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Button(action: requestHumanHandoff) {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 16))
                    Text("Talk to a human")
                        .font(.subheadline)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(hex: "44C0FF").opacity(0.12))
                .foregroundStyle(Color(hex: "44C0FF"))
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Browse Guides

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

    // MARK: - Actions

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
                conversation.append(SupportChatMessage(text: stubReply(for: text), isUser: false))
            }
        }
    }

    private func stubReply(for question: String) -> String {
        "Thanks for reaching out. Support content for “\(question)” will appear here once the assistant is wired up."
    }

    private func requestHumanHandoff() {
        inputFocused = false
        withAnimation(.easeOut(duration: 0.25)) {
            humanHandoffRequested = true
            handoffConfirmed = true
            conversation.removeAll()
            isThinking = false
            draftText = ""
        }
    }

    private func startNewChat() {
        withAnimation(.easeOut(duration: 0.25)) {
            handoffConfirmed = false
            humanHandoffRequested = false
            hasShownWelcome = false
            conversation.removeAll()
            isThinking = false
            draftText = ""
        }
        Task { await showWelcomeIfNeeded() }
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
            conversation.append(SupportChatMessage(text: welcomeMessage, isUser: false))
        }
    }
}

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
