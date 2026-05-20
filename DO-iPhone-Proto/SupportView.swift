import SwiftUI

struct SupportView: View {
    @State private var draftText: String = ""
    @State private var conversation: [SupportChatMessage] = []
    @State private var isThinking = false
    @State private var hasShownWelcome = false
    @FocusState private var inputFocused: Bool

    private let suggestedIssues = [
        "My entries aren't syncing",
        "How do I import from another app?",
        "I can't sign in"
    ]

    // Stub account snapshot used in the opening greeting.
    // TODO: replace with real values when the support assistant is wired up.
    private let userFirstName = "Paul"
    private let encryptedJournalCount = 16
    private let recentlyActiveDeviceCount = 3

    private var welcomeMessage: String {
        """
        Hi \(userFirstName), I'm Day One's customer help chat. I see you have \(encryptedJournalCount) encrypted journals and you've been active on \(recentlyActiveDeviceCount) devices recently. All your data appears synced up as expected.
        """
    }

    var body: some View {
        List {
            chatForHelpSection
            browseGuidesSection
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .task { await showWelcomeIfNeeded() }
    }

    // MARK: - Chat for Help

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

                // Suggestions remain visible until the user sends their first
                // message; the seeded welcome from the assistant doesn't count.
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

            ForEach(suggestedIssues, id: \.self) { issue in
                Button {
                    send(issue)
                } label: {
                    HStack {
                        Text(issue)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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

    // MARK: - Browse Guides

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

    @MainActor
    private func showWelcomeIfNeeded() async {
        guard !hasShownWelcome else { return }
        hasShownWelcome = true
        withAnimation(.easeOut(duration: 0.2)) {
            isThinking = true
        }
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
                .padding(.vertical, 8)
                .background(message.isUser ? Color(hex: "44C0FF") : Color(.tertiarySystemGroupedBackground))
                .foregroundStyle(message.isUser ? .white : .primary)
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
