import SwiftUI

// This file contains all Daily Chat related views and components
// Extracted from TodayView.swift for better organization

// MARK: - Daily Content Manager
class DailyContentManager {
    static let shared = DailyContentManager()
    private var dailyEntries: [String: Bool] = [:]
    private var summaries: [String: Bool] = [:]
    
    private init() {}
    
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
}

// MARK: - Chat Session Manager
class ChatSessionManager {
    static let shared = ChatSessionManager()
    private var sessions: [String: [DailyChatMessage]] = [:]
    private var summariesGenerated: [String: Bool] = [:]
    
    private init() {}
    
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
    
    func isSummaryGenerated(for date: Date = Date()) -> Bool {
        let key = dateKey(for: date)
        return summariesGenerated[key] ?? false
    }
    
    func setSummaryGenerated(_ generated: Bool, for date: Date = Date()) {
        let key = dateKey(for: date)
        summariesGenerated[key] = generated
    }
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
    @State private var isLogDetailsMode: Bool
    @State private var messages: [DailyChatMessage] = []
    @State private var isThinking = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingPreviewEntry = false
    @State private var showingBioView = false
    @State private var contextPreviousChats = false
    @State private var contextDailyEntries = false
    @State private var contextBio = false
    
    private let chatSessionManager = ChatSessionManager.shared
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private var userMessageCount: Int {
        messages.filter { $0.isUser }.count
    }
    
    init(selectedDate: Date, initialLogMode: Bool, entryCreated: Binding<Bool>, onChatStarted: @escaping () -> Void, onMessageCountChanged: @escaping (Int) -> Void) {
        self.selectedDate = selectedDate
        self.initialLogMode = initialLogMode
        self._entryCreated = entryCreated
        self.onChatStarted = onChatStarted
        self.onMessageCountChanged = onMessageCountChanged
        self._isLogDetailsMode = State(initialValue: initialLogMode)
        
        // Load existing messages for the selected date
        let existingMessages = ChatSessionManager.shared.getMessages(for: selectedDate)
        self._messages = State(initialValue: existingMessages)
    }
    
    private var placeholderText: String {
        isLogDetailsMode ? "Log any details about this day" : "Chat about your day"
    }
    
    private var showHeaderContent: Bool {
        messages.isEmpty
    }
    
    private let aiResponses = [
        "That sounds like a great way to spend your day! How did that make you feel?",
        "Thanks for sharing that with me. I can tell this was meaningful to you. What was the most memorable part about it?",
        "Interesting! I'd love to hear more about that experience. It sounds like it had quite an impact on your day.",
        "That's wonderful that you took the time to do that. Sometimes the simple moments can be the most rewarding ones, don't you think?"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header content (disappears when user has messages)
                if showHeaderContent {
                    VStack {
                        Spacer()
                        
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(hex: "44C0FF"))
                        
                        Spacer()
                    }
                    .transition(.opacity)
                }
                
                // Chat messages area
                if !messages.isEmpty || isThinking {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    DailyChatBubbleView(message: message)
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
                
                // Chat input area
                VStack(spacing: 0) {
                    // Text input field
                    TextField(placeholderText, text: $chatText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .lineLimit(1...6)
                    
                    // Keyboard accessory toolbar
                    HStack {
                        // Chat mode toggle buttons
                        HStack(spacing: 8) {
                            Text("Mode:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 4) {
                                Button(action: {
                                    isLogDetailsMode = false
                                }) {
                                    Text("Chat")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            !isLogDetailsMode ? Color(hex: "44C0FF") : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 16)
                                        )
                                        .foregroundStyle(!isLogDetailsMode ? .white : .secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    isLogDetailsMode = true
                                }) {
                                    Text("Log")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            isLogDetailsMode ? Color(.darkGray) : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 16)
                                        )
                                        .foregroundStyle(isLogDetailsMode ? .white : .secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(2)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18))
                        }
                        
                        Spacer()
                        
                        // Audio and submit buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                // TODO: Audio chat functionality
                            }) {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 32, height: 32)
                                    .background(Color(.systemGray5), in: Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                sendMessage()
                            }) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        chatText.isEmpty ? Color.gray : Color(hex: "44C0FF"),
                                        in: Circle()
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(chatText.isEmpty || isThinking)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Daily Chat")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 4) {
                            Text(selectedDate, style: .date)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            if userMessageCount > 0 {
                                Text("•")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                
                                Button(action: {
                                    showingPreviewEntry = true
                                }) {
                                    Text("View Summary")
                                        .font(.caption2)
                                        .foregroundStyle(Color(hex: "44C0FF"))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            regenerateResponse()
                        }) {
                            Label("Regenerate Response", systemImage: "arrow.clockwise")
                        }
                        
                        Button(action: {
                            showingBioView = true
                        }) {
                            Label("Edit Bio", systemImage: "person.circle")
                        }
                        
                        Divider()
                        
                        Section("Include Context") {
                            Button(action: {
                                contextPreviousChats.toggle()
                            }) {
                                Label("Previous Chats", systemImage: contextPreviousChats ? "checkmark" : "")
                            }
                            
                            Button(action: {
                                contextDailyEntries.toggle()
                            }) {
                                Label("Daily Entries", systemImage: contextDailyEntries ? "checkmark" : "")
                            }
                            
                            Button(action: {
                                contextBio.toggle()
                            }) {
                                Label("Bio", systemImage: contextBio ? "checkmark" : "")
                            }
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            clearChat()
                        }) {
                            Label("Clear Chat", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.body)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Set initial log mode
                isLogDetailsMode = initialLogMode
                
                // Auto-insert first AI question if in chat mode and no messages yet
                if !initialLogMode && messages.isEmpty {
                    let initialMessage = DailyChatMessage(content: "How's your \(dayOfWeek)?", isUser: false, isLogMode: false)
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
        .sheet(isPresented: $showingPreviewEntry) {
            ChatEntryPreviewView(
                selectedDate: selectedDate,
                entryCreated: $entryCreated
            )
        }
        .sheet(isPresented: $showingBioView) {
            BioEditView()
        }
    }
    
    private func regenerateResponse() {
        // Find the last AI message and regenerate it
        if let lastAIIndex = messages.lastIndex(where: { !$0.isUser && !$0.isLogMode }) {
            // Remove the last AI message
            messages.remove(at: lastAIIndex)
            
            // Show thinking indicator
            isThinking = true
            
            // Generate new response
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.75...1.5)) {
                isThinking = false
                let aiResponse = aiResponses.randomElement() ?? aiResponses[0]
                let aiMessage = DailyChatMessage(content: aiResponse, isUser: false, isLogMode: false)
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
        
        // Re-add initial AI message if in chat mode
        if !isLogDetailsMode {
            let initialMessage = DailyChatMessage(content: "How's your \(dayOfWeek)?", isUser: false, isLogMode: false)
            messages.append(initialMessage)
            chatSessionManager.saveMessages(messages, for: selectedDate)
        }
    }
    
    private func sendMessage() {
        let userMessage = DailyChatMessage(content: chatText, isUser: true, isLogMode: isLogDetailsMode)
        messages.append(userMessage)
        
        chatText = ""
        
        // Trigger onChatStarted callback if this is the first message
        if messages.count == 1 {
            onChatStarted()
        }
        
        // Only show AI response in Chat mode, not in Log details mode
        if !isLogDetailsMode {
            // Show thinking indicator
            isThinking = true
            
            // Simulate AI response after a delay (reduced by half)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.75...1.5)) {
                isThinking = false
                let aiResponse = aiResponses.randomElement() ?? aiResponses[0]
                let aiMessage = DailyChatMessage(content: aiResponse, isUser: false, isLogMode: false)
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(aiMessage)
                }
            }
        }
    }
}

// MARK: - Daily Chat Message Model
struct DailyChatMessage: Identifiable, Equatable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let isLogMode: Bool
    let timestamp = Date()
}

// MARK: - Daily Chat Bubble View
struct DailyChatBubbleView: View {
    let message: DailyChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
                
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isLogMode ? Color(.darkGray) : Color(hex: "44C0FF"),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
            } else {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 18))
                
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 16)
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
    @AppStorage("includeInDailyChat") private var includeInDailyChat = true
    
    @State private var editingName = ""
    @State private var editingBio = ""
    @State private var editingInclude = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $editingName)
                        .textFieldStyle(.automatic)
                    
                    VStack(alignment: .leading) {
                        Text("Bio")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $editingBio)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                    }
                }
                
                Section {
                    Toggle("Include in Daily Chat", isOn: $editingInclude)
                }
            }
            .navigationTitle("Bio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userName = editingName
                        userBio = editingBio
                        includeInDailyChat = editingInclude
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                editingName = userName
                editingBio = userBio
                editingInclude = includeInDailyChat
            }
        }
    }
}

// MARK: - Chat Entry Preview View (Chat Summary)
struct ChatEntryPreviewView: View {
    let selectedDate: Date
    @Binding var entryCreated: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var entryContent: String = ""
    @State private var isCreatingEntry = false
    @State private var showingEntry = false
    @State private var hasNewInteractions = false
    @State private var isLoadingSummary = true
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gray background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoadingSummary {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Color(hex: "44C0FF"))
                        
                        Text("Generating summary...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 0) {
                        // Entry content in white rounded rectangle
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Morning Reflections and Evening Plans")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("Today I started with my usual morning routine, feeling energized and ready to tackle the day ahead. I spent some time thinking about my work goals and how I want to approach the various projects I have on my plate.")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Text("The conversation helped me organize my thoughts around what's most important right now. We discussed my priorities for the week and how to balance work with personal time.")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Text("As I look toward the evening, I'm planning to wind down with some reading and prepare for tomorrow's meetings. It's been a productive day overall, and I'm grateful for the clarity that comes from taking time to reflect.")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding()
                        }
                        
                            Spacer()
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            // Create/Update Entry button
                            Button(action: {
                                if entryCreated {
                                    // Update existing entry
                                    updateEntry()
                                } else {
                                    // Create new entry
                                    createEntry()
                                }
                            }) {
                                HStack {
                                    if isCreatingEntry {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    } else {
                                        Text(entryCreated ? "Update Entry" : "Create Entry")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(isCreatingEntry || (entryCreated && !hasNewInteractions))
                            .opacity((entryCreated && !hasNewInteractions) ? 0.6 : 1.0)
                            
                            // Open button
                            Button(action: {
                                showingEntry = true
                            }) {
                                Text("Open Entry")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(entryCreated ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(entryCreated ? Color(hex: "44C0FF") : Color.gray.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(!entryCreated)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            copyEntryText()
                        }) {
                            Label("Copy Text", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            // TODO: Edit entry
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            deleteEntry()
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Summary generated from chat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEntry) {
            EntryView(journal: nil)
        }
        .onAppear {
            // Show loading state for 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoadingSummary = false
                // Mark summary as generated when view appears (independent from chat)
                DailyContentManager.shared.setHasSummary(true, for: selectedDate)
                // Post notification to update UI
                NotificationCenter.default.post(name: NSNotification.Name("SummaryGeneratedStatusChanged"), object: selectedDate)
            }
            
            // Check if there are new chat interactions since entry was created
            // This would normally check actual chat data
            if entryCreated {
                // Simulate checking for new interactions
                hasNewInteractions = true
            }
        }
    }
    
    private func createEntry() {
        isCreatingEntry = true
        
        // Simulate entry creation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isCreatingEntry = false
            entryCreated = true
            hasNewInteractions = false
            // Mark entry as created (independent from chat)
            DailyContentManager.shared.setHasEntry(true, for: selectedDate)
            // Post notification to update UI
            NotificationCenter.default.post(name: NSNotification.Name("DailyEntryCreatedStatusChanged"), object: selectedDate)
            // Auto-open the entry after creation
            showingEntry = true
        }
    }
    
    private func updateEntry() {
        isCreatingEntry = true
        
        // Simulate entry update
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isCreatingEntry = false
            hasNewInteractions = false
            // Entry remains created
        }
    }
    
    private func copyEntryText() {
        let entryText = """
        Morning Reflections and Evening Plans
        
        Today I started with my usual morning routine, feeling energized and ready to tackle the day ahead. I spent some time thinking about my work goals and how I want to approach the various projects I have on my plate.
        
        The conversation helped me organize my thoughts around what's most important right now. We discussed my priorities for the week and how to balance work with personal time.
        
        As I look toward the evening, I'm planning to wind down with some reading and prepare for tomorrow's meetings. It's been a productive day overall, and I'm grateful for the clarity that comes from taking time to reflect.
        """
        
        UIPasteboard.general.string = entryText
    }
    
    private func deleteEntry() {
        entryCreated = false
        dismiss()
    }
}