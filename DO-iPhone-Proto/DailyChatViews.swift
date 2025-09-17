import SwiftUI
import UIKit

// This file contains all Daily Chat related views and components
// Extracted from TodayView.swift for better organization

// MARK: - Daily Content Manager
class DailyContentManager {
    static let shared = DailyContentManager()
    private var dailyEntries: [String: Bool] = [:]
    private var summaries: [String: Bool] = [:]
    private var entryMessageCounts: [String: Int] = [:] // Track message count when entry was created
    private var entryUpdateDates: [String: Date] = [:] // Track when entries were last updated
    
    private init() {
        // Data will be loaded from JSON via DailyDataManager
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func hasEntry(for date: Date) -> Bool {
        let key = dateKey(for: date)
        return dailyEntries[key] ?? false
    }
    
    func setHasEntry(_ hasEntry: Bool, for date: Date) {
        let key = dateKey(for: date)
        dailyEntries[key] = hasEntry
    }
    
    func hasSummary(for date: Date) -> Bool {
        let key = dateKey(for: date)
        return summaries[key] ?? false
    }
    
    func setHasSummary(_ hasSummary: Bool, for date: Date) {
        let key = dateKey(for: date)
        summaries[key] = hasSummary
    }
    
    func setEntryMessageCount(_ count: Int, for date: Date) {
        let key = dateKey(for: date)
        entryMessageCounts[key] = count
    }
    
    func getEntryMessageCount(for date: Date) -> Int {
        let key = dateKey(for: date)
        return entryMessageCounts[key] ?? 0
    }
    
    func hasNewMessagesSinceEntry(for date: Date) -> Bool {
        let key = dateKey(for: date)
        let entryMessageCount = entryMessageCounts[key] ?? 0
        let currentMessages = ChatSessionManager.shared.getMessages(for: date)
        let currentUserMessageCount = currentMessages.filter { $0.isUser }.count
        return currentUserMessageCount > entryMessageCount
    }
    
    func setEntryUpdateDate(_ updateDate: Date, for date: Date) {
        let key = dateKey(for: date)
        entryUpdateDates[key] = updateDate
    }
    
    func getEntryUpdateDate(for date: Date) -> Date? {
        let key = dateKey(for: date)
        return entryUpdateDates[key]
    }
}

// MARK: - Chat Session Manager
class ChatSessionManager {
    static let shared = ChatSessionManager()
    private var sessions: [String: [DailyChatMessage]] = [:]
    private var summariesGenerated: [String: Bool] = [:]
    
    private init() {
        // Data will be loaded from JSON via DailyDataManager
    }
    
    private func dateKey(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func getMessages(for date: Date = Date()) -> [DailyChatMessage] {
        let key = dateKey(for: date)
        return sessions[key] ?? []
    }
    
    func saveMessages(_ messages: [DailyChatMessage], for date: Date = Date()) {
        let key = dateKey(for: date)
        sessions[key] = messages
    }
    
    func clearSession(for date: Date = Date()) {
        let key = dateKey(for: date)
        sessions.removeValue(forKey: key)
        summariesGenerated.removeValue(forKey: key)
    }
    
    func removeMessage(withId messageId: UUID, for date: Date = Date()) {
        let key = dateKey(for: date)
        if var messages = sessions[key] {
            messages.removeAll { $0.id == messageId }
            sessions[key] = messages
        }
    }
    
    func toggleIgnoreStatus(withId messageId: UUID, for date: Date = Date()) {
        let key = dateKey(for: date)
        if var messages = sessions[key] {
            if let index = messages.firstIndex(where: { $0.id == messageId }) {
                messages[index].isIgnoredInEntry.toggle()
                sessions[key] = messages
            }
        }
    }
    
    func isSummaryGenerated(for date: Date = Date()) -> Bool {
        let key = dateKey(for: date)
        return summariesGenerated[key] ?? false
    }
    
    func setSummaryGenerated(_ generated: Bool, for date: Date = Date()) {
        let key = dateKey(for: date)
        summariesGenerated[key] = generated
    }
    
    func clearAllSessions() {
        sessions.removeAll()
        summariesGenerated.removeAll()
    }
}

// MARK: - Chat Mode Enum
enum ChatMode: String, CaseIterable, Codable {
    case log = "Log"
    case chat = "Chat"
}

// MARK: - Daily Chat View
struct DailyChatView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    let initialLogMode: Bool
    @Binding var entryCreated: Bool
    let onChatStarted: () -> Void
    let onMessageCountChanged: (Int) -> Void
    
    @State private var chatText = ""
    @State private var currentMode: ChatMode
    @State private var messages: [DailyChatMessage] = []
    @State private var isThinking = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingPreviewEntry = false
    @State private var isGeneratingEntry = false
    @State private var showingEntry = false
    @State private var showingChatSettings = false
    @State private var showingClearChatAlert = false
    @State private var showingUpdateConfirmation = false
    @State private var isUpdatingEntry = false
    @State private var showingVoiceMode = false
    
    private let chatSessionManager = ChatSessionManager.shared
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private var userMessageCount: Int {
        messages.filter { $0.isUser }.count
    }
    
    private var relativeDateString: String {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            // Return empty string to use the default date formatting
            return ""
        }
    }
    
    init(selectedDate: Date, initialLogMode: Bool, entryCreated: Binding<Bool>, onChatStarted: @escaping () -> Void, onMessageCountChanged: @escaping (Int) -> Void) {
        self.selectedDate = selectedDate
        self.initialLogMode = initialLogMode
        self._entryCreated = entryCreated
        self.onChatStarted = onChatStarted
        self.onMessageCountChanged = onMessageCountChanged
        // Default to chat mode unless explicitly set to log mode
        self._currentMode = State(initialValue: initialLogMode ? .log : .chat)
        
        // Load existing messages for the selected date
        let existingMessages = ChatSessionManager.shared.getMessages(for: selectedDate)
        self._messages = State(initialValue: existingMessages)
    }
    
    private var placeholderText: String {
        switch currentMode {
        case .log:
            return "Log any details about this day"
        case .chat:
            return "Chat about your day"
        }
    }
    
    private var showHeaderContent: Bool {
        messages.isEmpty
    }
    
    private func getColorForMode(_ mode: ChatMode) -> Color {
        switch mode {
        case .log:
            return Color(.darkGray)
        case .chat:
            return Color(hex: "44C0FF")
        }
    }
    
    private func getPromptMessageForTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: selectedDate)
        
        switch hour {
        case 6..<11: // Morning
            let morningMessages = [
                "Good morning! What's one intention you're setting for today?",
                "How did you sleep, and what's first on your agenda?"
            ]
            return morningMessages.randomElement() ?? morningMessages[0]
            
        case 11..<17: // Afternoon
            let afternoonMessages = [
                "Mid-day check: what's been the highlight so far?",
                "Anything surprising or amusing happen since breakfast?"
            ]
            return afternoonMessages.randomElement() ?? afternoonMessages[0]
            
        case 17..<24: // Evening
            let eveningMessages = [
                "Day's winding down—what will you remember most about today?",
                "On a scale of 1-10, how satisfied do you feel right now?"
            ]
            return eveningMessages.randomElement() ?? eveningMessages[0]
            
        default: // Late Night (0-6)
            return "Burning the midnight oil? What's keeping you up, and how are you feeling about it?"
        }
    }
    
    private func getReflectiveSummary(for messages: [DailyChatMessage]) -> String {
        // Analyze user messages to create a reflective summary
        let userMessages = messages.filter { $0.isUser }
        let combinedText = userMessages.map { $0.content }.joined(separator: " ").lowercased()
        
        // Check for different day patterns
        if combinedText.contains("stress") || combinedText.contains("pressure") || combinedText.contains("difficult") || 
           combinedText.contains("tough") || combinedText.contains("frustrated") || combinedText.contains("anxious") {
            // Stressful day pattern
            let stressResponses = [
                "Rough edges today—travel snafu, high-pressure client call that felt off. Your notes hint at frustration > anxiety. What small win (even micro) can you salvage from the chaos?",
                "I'm noticing tension threads through your day. Between the challenges, where did you find moments of control or clarity?",
                "Today tested you in multiple ways. Looking at the pattern, what's one thing you handled better than you might have in the past?"
            ]
            return stressResponses.randomElement() ?? stressResponses[0]
        }
        
        if combinedText.contains("dream") || combinedText.contains("dreamt") || combinedText.contains("nightmare") {
            // Dream pattern
            let dreamResponses = [
                "Dream recap: you're steering a boat through fog, searchlight flickers, finally land on a quiet shore. Classic symbols of navigation and arriving at clarity. Any waking-life decisions feel 'foggy' right now?",
                "Your dream imagery suggests transition and searching. What in your waking life feels like it's shifting or needs direction?",
                "Dreams often process what we can't during the day. What unresolved feelings might your subconscious be working through?"
            ]
            return dreamResponses.randomElement() ?? dreamResponses[0]
        }
        
        // Analyze activities mentioned
        var activities: [String] = []
        var emojis: [String] = []
        
        if combinedText.contains("hike") || combinedText.contains("walk") || combinedText.contains("run") {
            activities.append("morning movement")
            emojis.append("⛰️")
        }
        if combinedText.contains("work") || combinedText.contains("meeting") || combinedText.contains("project") || combinedText.contains("design") {
            activities.append("deep work")
            emojis.append("⚙️")
        }
        if combinedText.contains("family") || combinedText.contains("dinner") || combinedText.contains("kids") {
            activities.append("family time")
            emojis.append("🍔")
        }
        if combinedText.contains("gym") || combinedText.contains("workout") || combinedText.contains("exercise") {
            activities.append("physical activity")
            emojis.append("💪")
        }
        if combinedText.contains("friend") || combinedText.contains("coffee") || combinedText.contains("lunch") {
            activities.append("social connection")
            emojis.append("☕")
        }
        
        // Generate balanced day response if activities detected
        if activities.count >= 2 {
            let activityList = emojis.joined(separator: " ")
            let themes = ["quality time + productive cadence", "personal care + meaningful connections", "achievement + restoration", "focus + flexibility"]
            let theme = themes.randomElement() ?? themes[0]
            
            return "Here's the shape of your day: \(activityList). Theme emerging: \(theme). Anything about that balance surprise you?"
        }
        
        // Default reflective responses
        let defaultReflections = [
            "Looking at your day's arc, I notice moments of both effort and ease. What felt most aligned with who you're becoming?",
            "Your experiences today paint an interesting pattern. If today had a title, what would it be?",
            "Reading between the lines, there's a rhythm to how you moved through today. What part of that rhythm serves you best?"
        ]
        return defaultReflections.randomElement() ?? defaultReflections[0]
    }
    
    private func getContextualResponse(for userMessage: String) -> String {
        // Check for various keywords and themes in the user's message
        let message = userMessage.lowercased()
        
        // Sports + work combination (like soccer and design sprint)
        if (message.contains("soccer") || message.contains("game") || message.contains("match") || message.contains("sport")) &&
           (message.contains("work") || message.contains("design") || message.contains("sprint") || message.contains("project")) {
            let comboResponses = [
                "Soccer wins and design wins—nice combo! Did either leave you energized or wiped out this evening?",
                "You packed a lot into the afternoon—family sports and a sprint finish. What's one moment you'd like to remember from each?",
                "Balancing family time at the game with work deadlines—how did you manage that transition?"
            ]
            return comboResponses.randomElement() ?? comboResponses[0]
        }
        
        // Kids' activities with follow-up about the child
        if message.contains("soccer") || message.contains("game") || message.contains("practice") || message.contains("match") {
            let kidsResponses = [
                "How's your child feeling after the match? And did the rest of your day wrap up as smoothly as you hoped?",
                "Sounds like an eventful game! What was the highlight for your family?",
                "Kids' sports can be such an adventure. How did everyone handle the excitement?"
            ]
            return kidsResponses.randomElement() ?? kidsResponses[0]
        }
        
        // Work-related responses
        if message.contains("work") || message.contains("meeting") || message.contains("project") || message.contains("deadline") || message.contains("sprint") {
            let workResponses = [
                "How did the work sprint wrap up? Are you feeling accomplished or is there more on your plate?",
                "Sounds like a productive push at work! What's been the most challenging part, and what went surprisingly well?",
                "Work sprints can be intense. Did you manage to find any moments to breathe between all those tasks?"
            ]
            return workResponses.randomElement() ?? workResponses[0]
        }
        
        // Family/social responses
        if message.contains("family") || message.contains("friend") || message.contains("kids") || message.contains("daughter") || message.contains("son") {
            let socialResponses = [
                "Family time sounds wonderful! What was the highlight of being together, and did anything unexpected come up?",
                "It's great you got to connect with loved ones. How's everyone doing, and what made you smile during that time?",
                "Those moments with family are precious. Was it relaxing or more of an adventure today?"
            ]
            return socialResponses.randomElement() ?? socialResponses[0]
        }
        
        // Activity/exercise responses
        if message.contains("gym") || message.contains("run") || message.contains("walk") || message.contains("exercise") || message.contains("workout") {
            let exerciseResponses = [
                "Nice job getting that workout in! How's your body feeling now—energized or ready for some rest?",
                "Physical activity can really shift the day's energy. What motivated you to get moving, and how do you feel afterward?",
                "Exercise is such a good reset. Was this part of your routine or something spontaneous today?"
            ]
            return exerciseResponses.randomElement() ?? exerciseResponses[0]
        }
        
        // Multiple activities mentioned
        if message.split(separator: " ").count > 20 || (message.contains("and") && message.contains("then")) {
            let busyResponses = [
                "You packed a lot into today! Looking back, what stands out as the most meaningful moment?",
                "Quite a full day you've had. How are you feeling about the balance between everything you did?",
                "That's an impressive amount of activity! What gave you energy and what drained it today?"
            ]
            return busyResponses.randomElement() ?? busyResponses[0]
        }
        
        // Default contextual responses
        let defaultResponses = [
            "Thanks for sharing that with me. What made this particularly meaningful for you today?",
            "I appreciate you taking the time to reflect on this. How does this connect to what's been on your mind lately?",
            "That's interesting! What surprised you most about how this unfolded?"
        ]
        return defaultResponses.randomElement() ?? defaultResponses[0]
    }
    
    @ViewBuilder
    private var headerView: some View {
        if showHeaderContent {
            VStack {
                Spacer()
                
                Image(dayOneIcon: .message)
                    .font(.system(size: 60))
                    .foregroundStyle(Color(hex: "44C0FF"))
                
                Spacer()
            }
            .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var messagesScrollView: some View {
        if !messages.isEmpty || isThinking {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            DailyChatBubbleView(
                                message: message,
                                selectedDate: selectedDate,
                                onRemove: {
                                    ChatSessionManager.shared.removeMessage(withId: message.id, for: selectedDate)
                                    messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                                    NotificationCenter.default.post(name: NSNotification.Name("ChatMessagesUpdated"), object: nil)
                                },
                                onToggleIgnore: {
                                    ChatSessionManager.shared.toggleIgnoreStatus(withId: message.id, for: selectedDate)
                                    messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                                }
                            )
                            .id(message.id)
                        }
                        
                        // Thinking indicator
                        if isThinking {
                            HStack {
                                ThinkingIndicatorView()
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .id("thinking")
                        }
                    }
                    .padding(.vertical, 16)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isThinking) { _, newValue in
                    if newValue {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo("thinking", anchor: .bottom)
                        }
                    }
                }
            }
        } else {
            Spacer()
        }
    }
    
    private var chatInputView: some View {
        VStack(spacing: 0) {
            // Text input field with buttons
            HStack(alignment: .center, spacing: 0) {
                // Rounded text field container
                HStack(spacing: 12) {
                    TextField(placeholderText, text: $chatText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .textFieldStyle(.plain)
                        .lineLimit(1...6)
                        .tint(Color(hex: "44C0FF"))
                        .onSubmit {
                            if !chatText.isEmpty && !isThinking {
                                sendMessage()
                                // Refocus the text field after sending
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isTextFieldFocused = true
                                }
                            }
                        }
                    
                    // Voice Mode button (always visible)
                    Button(action: {
                        showingVoiceMode = true
                    }) {
                        Image(dayOneIcon: .audio_wave)
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Send button
                    Button(action: {
                        if !chatText.isEmpty {
                            sendMessage()
                        }
                    }) {
                        Image(dayOneIcon: .arrow_up)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(chatText.isEmpty ? Color.secondary : Color.white)
                            .frame(width: 32, height: 32)
                            .background(
                                chatText.isEmpty ? Color(.systemGray5) : Color(hex: "44C0FF"),
                                in: Circle()
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isThinking || chatText.isEmpty)
                }
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .padding(.vertical, 8)
                .background(.regularMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.clear)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header content (disappears when user has messages)
                headerView
                
                // Chat messages area
                messagesScrollView
                
                // Chat input area
                chatInputView
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Daily Chat")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 4) {
                            if !relativeDateString.isEmpty {
                                Text(relativeDateString)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(selectedDate, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if userMessageCount > 0 {
                                Text("•")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                
                                if isGeneratingEntry || isUpdatingEntry {
                                    ProgressView()
                                        .scaleEffect(0.5)
                                        .frame(width: 14, height: 14)
                                } else {
                                    Button(action: {
                                        if DailyContentManager.shared.hasEntry(for: selectedDate) {
                                            // Entry exists
                                            if DailyContentManager.shared.hasNewMessagesSinceEntry(for: selectedDate) {
                                                // New messages - show update confirmation alert
                                                showingUpdateConfirmation = true
                                            } else {
                                                // No new messages - just view entry
                                                showingEntry = true
                                            }
                                        } else {
                                            // No entry exists - generate directly
                                            generateEntryDirectly()
                                        }
                                    }) {
                                        Text(getButtonText())
                                            .font(.caption2)
                                            .foregroundStyle(Color(hex: "44C0FF"))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(isGeneratingEntry || isUpdatingEntry)
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            regenerateResponse()
                        }) {
                            Label("Regenerate Response", dayOneIcon: .sync)
                        }
                        
                        Button(action: {
                            // Dismiss keyboard before showing settings
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            showingChatSettings = true
                        }) {
                            Label("Chat Settings", dayOneIcon: .settings)
                        }
                        
                        Divider()
                        
                        Section("Chat Mode") {
                            Button(action: {
                                let previousMode = currentMode
                                currentMode = .chat
                                handleModeChange(from: previousMode, to: .chat)
                            }) {
                                Label {
                                    Text("Chat")
                                } icon: {
                                    if currentMode == .chat {
                                        Image(dayOneIcon: .checkmark)
                                    }
                                }
                            }
                            
                            Button(action: {
                                let previousMode = currentMode
                                currentMode = .log
                                handleModeChange(from: previousMode, to: .log)
                            }) {
                                Label {
                                    Text("Log (no response)")
                                } icon: {
                                    if currentMode == .log {
                                        Image(dayOneIcon: .checkmark)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            showingClearChatAlert = true
                        }) {
                            Label("Clear Chat", dayOneIcon: .trash)
                                .foregroundStyle(.red)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.body)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                    .labelStyle(.titleAndIcon)
                    .tint(Color(hex: "333B40"))
                }
            }
            .onAppear {
                // Set to the initial mode (chat by default unless specified)
                currentMode = initialLogMode ? .log : .chat
                
                // Auto-insert first AI message based on mode and no messages yet
                if messages.isEmpty {
                    let initialMessage: DailyChatMessage
                    
                    switch currentMode {
                    case .chat:
                        // Use time-based contextual prompt for Chat mode
                        initialMessage = DailyChatMessage(
                            content: getPromptMessageForTimeOfDay(),
                            isUser: false,
                            isLogMode: false,
                            mode: currentMode
                        )
                    case .log:
                        // Initial log mode message
                        initialMessage = DailyChatMessage(
                            content: "Log memories and highlights from this day without a reply.",
                            isUser: false,
                            isLogMode: false,
                            mode: currentMode
                        )
                    }
                    
                    messages.append(initialMessage)
                    chatSessionManager.saveMessages(messages, for: selectedDate)
                }
                
                // Notify that chat has been started if there are existing messages
                if !messages.isEmpty {
                    onChatStarted()
                    onMessageCountChanged(userMessageCount)
                }
                
                // Auto-focus text field when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
            .onChange(of: messages) { _, newMessages in
                // Save messages whenever they change
                chatSessionManager.saveMessages(newMessages, for: selectedDate)
                // Update message count
                onMessageCountChanged(userMessageCount)
                // Post notification to update FAB state
                NotificationCenter.default.post(name: NSNotification.Name("ChatMessagesUpdated"), object: nil)
            }
        }
        .sheet(isPresented: $showingEntry) {
            EntryView(journal: nil)
        }
        .sheet(isPresented: $showingChatSettings) {
            DailyChatSettingsView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showingVoiceMode) {
            VoiceModeView()
        }
        .alert("Clear Chat?", isPresented: $showingClearChatAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear Chat", role: .destructive) {
                clearChat()
            }
        } message: {
            Text("This will remove all messages from the current chat. This action can't be undone.")
        }
        .alert("Update Journal Entry", isPresented: $showingUpdateConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Update", role: .none) {
                // Start the update process
                isUpdatingEntry = true
                
                // Simulate update process
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    // Mark entry as updated
                    DailyContentManager.shared.setHasEntry(true, for: selectedDate)
                    
                    // Update the message count to current count
                    let messages = chatSessionManager.getMessages(for: selectedDate)
                    let userMessageCount = messages.filter { $0.isUser }.count
                    DailyContentManager.shared.setEntryMessageCount(userMessageCount, for: selectedDate)
                    
                    // Reset the updating state
                    isUpdatingEntry = false
                    
                    // Update local state
                    entryCreated = true
                    
                    // Post notification to refresh the UI
                    NotificationCenter.default.post(name: NSNotification.Name("DailyEntryUpdatedStatusChanged"), object: selectedDate)
                }
            }
            .tint(Color(hex: "44C0FF"))
        } message: {
            Text("Your update will resummarize parts of the current entry. Do you wish to continue?")
        }
    }
    
    private func regenerateResponse() {
        // Find the last AI message and regenerate it
        if let lastAIIndex = messages.lastIndex(where: { !$0.isUser && !$0.isLogMode }) {
            // Remove the last AI message
            messages.remove(at: lastAIIndex)
            
            // Show thinking indicator
            isThinking = true
            
            // Generate new response based on the last user message
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.75...1.5)) {
                isThinking = false
                
                // Find the last user message to generate contextual response
                let lastUserMessage = messages.last(where: { $0.isUser })?.content ?? ""
                
                // Chat mode uses contextual responses
                let aiResponse = getContextualResponse(for: lastUserMessage)
                
                let aiMessage = DailyChatMessage(content: aiResponse, isUser: false, isLogMode: false, mode: currentMode)
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(aiMessage)
                }
            }
        }
    }
    
    private func clearChat() {
        messages.removeAll()
        chatSessionManager.clearSession(for: selectedDate)
        onMessageCountChanged(0)
        
        // Re-add initial AI message based on mode
        let initialMessage: DailyChatMessage
        switch currentMode {
        case .chat:
            initialMessage = DailyChatMessage(content: getPromptMessageForTimeOfDay(), isUser: false, isLogMode: false, mode: currentMode)
        case .log:
            initialMessage = DailyChatMessage(content: "Log memories and highlights from this day without a reply.", isUser: false, isLogMode: false, mode: currentMode)
        }
        messages.append(initialMessage)
        chatSessionManager.saveMessages(messages, for: selectedDate)
    }
    
    private func sendMessage() {
        let userMessage = DailyChatMessage(content: chatText, isUser: true, isLogMode: currentMode == .log, mode: currentMode)
        messages.append(userMessage)
        
        chatText = ""
        
        // Trigger onChatStarted callback if this is the first message
        if messages.count == 1 {
            onChatStarted()
        }
        
        // Only show AI response in Prompt and Reflect modes, not in Capture mode
        if currentMode != .log {
            // Show thinking indicator
            isThinking = true
            
            // Chat mode uses contextual responses based on user's message
            let aiResponse = getContextualResponse(for: userMessage.content)
            
            // Simulate AI response after a delay (reduced by half)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.75...1.5)) {
                isThinking = false
                let aiMessage = DailyChatMessage(content: aiResponse, isUser: false, isLogMode: false, mode: currentMode)
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(aiMessage)
                }
            }
        }
    }
    
    private func handleModeChange(from previousMode: ChatMode, to newMode: ChatMode) {
        // Only add mode change messages if switching to a different mode
        if previousMode != newMode {
            switch newMode {
            case .log:
                // When switching to log mode - show system notification
                let notification = DailyChatMessage(
                    content: "Jot down moments of your day as they happen. Responses will be paused until you turn it back on.",
                    isUser: false,
                    isLogMode: false,
                    mode: newMode,
                    isSystemNotification: true,
                    notificationTitle: "Log Mode On"
                )
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(notification)
                }
            case .chat:
                // When switching to chat mode - show system notification
                let notification = DailyChatMessage(
                    content: "AI responses are now active. Continue your conversation.",
                    isUser: false,
                    isLogMode: false,
                    mode: newMode,
                    isSystemNotification: true,
                    notificationTitle: "Chat Mode On"
                )
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(notification)
                }
            }
        }
    }
    
    private func getButtonText() -> String {
        if DailyContentManager.shared.hasEntry(for: selectedDate) {
            // Check if there are new messages since entry was created
            if DailyContentManager.shared.hasNewMessagesSinceEntry(for: selectedDate) {
                return "Update Entry"
            } else {
                return "View Entry"
            }
        } else {
            return "Generate Entry"
        }
    }
    
    private func generateEntryDirectly() {
        isGeneratingEntry = true
        
        // Simulate entry generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isGeneratingEntry = false
            
            // Mark entry as created
            DailyContentManager.shared.setHasEntry(true, for: selectedDate)
            
            // Track current message count when entry is created
            let userMessageCount = messages.filter { $0.isUser }.count
            DailyContentManager.shared.setEntryMessageCount(userMessageCount, for: selectedDate)
            
            // Update local state
            entryCreated = true
            
            // Post notification to update UI
            NotificationCenter.default.post(name: NSNotification.Name("DailyEntryCreatedStatusChanged"), object: selectedDate)
            
            // Open the entry view directly
            showingEntry = true
        }
    }
}

// MARK: - Daily Chat Message Model
struct DailyChatMessage: Identifiable, Equatable, Codable {
    var id = UUID()
    let content: String
    let isUser: Bool
    let isLogMode: Bool
    var timestamp = Date()
    var isIgnoredInEntry: Bool = false
    let mode: ChatMode?
    let isSystemNotification: Bool
    let notificationTitle: String?
    
    init(content: String, isUser: Bool, isLogMode: Bool, mode: ChatMode? = nil, isSystemNotification: Bool = false, notificationTitle: String? = nil) {
        self.content = content
        self.isUser = isUser
        self.isLogMode = isLogMode
        self.mode = mode
        self.isSystemNotification = isSystemNotification
        self.notificationTitle = notificationTitle
    }
}

// MARK: - System Notification View
struct SystemNotificationView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.4))
            
            Text(description)
                .font(.system(size: 13))
                .foregroundStyle(.primary.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
}

// MARK: - Daily Chat Bubble View
struct DailyChatBubbleView: View {
    let message: DailyChatMessage
    let selectedDate: Date
    let onRemove: () -> Void
    let onToggleIgnore: () -> Void
    
    private func getBubbleColor(for message: DailyChatMessage) -> Color {
        // Use the same blue color for both chat and log modes
        return Color(hex: "44C0FF")
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = message.content
    }
    
    var body: some View {
        if message.isSystemNotification {
            SystemNotificationView(
                title: message.notificationTitle ?? "",
                description: message.content
            )
        } else {
            HStack {
                if message.isUser {
                    Spacer(minLength: 50)
                    
                    Text(message.content)
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            getBubbleColor(for: message).opacity(message.isIgnoredInEntry ? 0.5 : 1.0),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                        .contextMenu {
                            Button(action: copyToClipboard) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            
                            Button(action: onToggleIgnore) {
                                Label(message.isIgnoredInEntry ? "Include in Entry" : "Ignore in Entry", 
                                      systemImage: message.isIgnoredInEntry ? "checkmark.circle" : "xmark.circle")
                            }
                            
                            Button(role: .destructive, action: onRemove) {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                } else {
                    Text(message.content)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5).opacity(message.isIgnoredInEntry ? 0.5 : 1.0), in: RoundedRectangle(cornerRadius: 18))
                        .contextMenu {
                            Button(action: copyToClipboard) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            
                            Button(action: onToggleIgnore) {
                                Label(message.isIgnoredInEntry ? "Include in Entry" : "Ignore in Entry", 
                                      systemImage: message.isIgnoredInEntry ? "checkmark.circle" : "xmark.circle")
                            }
                            
                            Button(role: .destructive, action: onRemove) {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    
                    Spacer(minLength: 50)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Thinking Indicator View
struct ThinkingIndicatorView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0 + 0.3 * sin(animationOffset + Double(index) * 0.5))
                        .animation(
                            Animation.easeInOut(duration: 1.0).repeatForever(),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 18))
        }
        .onAppear {
            animationOffset = 0
            withAnimation {
                animationOffset = .pi * 2
            }
        }
    }
}

// MARK: - Bio Edit View
struct BioEditView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userBioName") private var userName = ""
    @AppStorage("userBioBio") private var userBio = ""

    @State private var editingName = ""
    @State private var editingBio = ""
    @State private var bioData = BioData.shared
    @State private var showingImagePicker = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name
        case bio
    }

    var body: some View {
        NavigationStack {
            List {
                // Profile Photo Section
                Section {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Circle()
                                .fill(.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.title3)
                                        .foregroundStyle(.gray)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Add Photo")
                                .font(.headline)
                            Text("Add a profile photo")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)

                // Name Section
                Section {
                    TextField("Scotty Simpson", text: $editingName)
                        .focused($focusedField, equals: .name)
                } header: {
                    Text("Name")
                }

                // About You Section
                Section {
                    TextEditor(text: $editingBio)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .bio)
                        .overlay(alignment: .topLeading) {
                            if editingBio.isEmpty {
                                Text("Tell us about yourself")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                } header: {
                    Text("About you")
                }

                // Personal Information Section
                Section {
                    DatePicker("Birthdate", selection: $bioData.birthdate, displayedComponents: .date)
                    TextField("Gender", text: $bioData.gender)
                    TextField("Home Location", text: $bioData.homeLocation)
                    TextField("Marital Status", text: $bioData.maritalStatus)
                } header: {
                    Text("Personal Information")
                }

                // Extended Bio Sections
                Section {
                    NavigationLink("People") {
                        PeopleView()
                    }

                    NavigationLink("Pets") {
                        PetsView()
                    }

                    NavigationLink("Places Lived") {
                        PlacesLivedView()
                    }

                    NavigationLink("Work Experience") {
                        WorkExperienceView()
                    }

                    NavigationLink("Education") {
                        EducationView()
                    }

                    NavigationLink("Travel") {
                        TravelView()
                    }

                    NavigationLink("Physical Attributes") {
                        BioPhysicalAttributesView()
                    }

                    NavigationLink("Preferences & Tastes") {
                        PreferencesAndTastesView()
                    }

                    NavigationLink("Digital Life") {
                        DigitalLifeView()
                    }

                    NavigationLink("Financial & Assets") {
                        FinancialAssetsView()
                    }

                    NavigationLink("Beliefs & Values") {
                        BeliefsValuesView()
                    }
                } header: {
                    Text("Extended Information")
                }

                // Health Sections
                Section {
                    NavigationLink("Health Data") {
                        BioHealthDataView()
                    }

                    NavigationLink("Enhanced Health Data") {
                        BioEnhancedHealthDataView()
                    }
                } header: {
                    Text("Health")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Bio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        userName = editingName
                        userBio = editingBio
                        bioData.name = editingName
                        dismiss()
                    }
                    .labelStyle(.titleAndIcon)
                    .tint(Color(hex: "44C0FF"))
                }
            }
            .onAppear {
                editingName = userName.isEmpty ? bioData.name : userName
                editingBio = userBio
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerPlaceholder()
            }
        }
    }
}

// ChatSettingsView has been replaced with DailyChatSettingsView
