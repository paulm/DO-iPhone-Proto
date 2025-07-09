import SwiftUI

// MARK: - Chat Mode Types
enum EntryChatMode: String, CaseIterable {
    case conversation = "Conversation"
    case interview = "Interview"
    case insight = "Insight"
    case coach = "Coach"
}

// MARK: - Entry Chat Message Model
struct EntryChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - Entry Chat View
struct EntryChatView: View {
    @Environment(\.dismiss) private var dismiss
    let entryText: String
    let entryDate: Date
    let journal: Journal?
    
    @State private var chatText = ""
    @State private var messages: [EntryChatMessage] = []
    @State private var isThinking = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedChatMode: EntryChatMode = .conversation
    @State private var showingSummary = false
    @State private var showingIdeas = false
    
    private var journalColor: Color {
        journal?.color ?? Color(hex: "44C0FF")
    }
    
    private var entryPreview: String {
        let words = entryText.split(separator: " ").prefix(5).joined(separator: " ")
        return words.isEmpty ? "Entry" : words + "..."
    }
    
    private var placeholderText: String {
        "Chat about your entry"
    }
    
    private var showHeaderContent: Bool {
        messages.isEmpty
    }
    
    private let aiResponses = [
        "That's a wonderful reflection. What made this experience particularly meaningful to you?",
        "I can see how that would have impacted your day. Tell me more about how it made you feel.",
        "It sounds like you've gained some valuable insights here. What do you think you'll take away from this?",
        "This entry shows great self-awareness. How might this experience influence your approach moving forward?"
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
                            .foregroundStyle(journalColor)
                        
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
                                    EntryChatBubbleView(message: message, journalColor: journalColor)
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
                                // Small delay to ensure message is fully rendered
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        // Use .top anchor to ensure full message is visible
                                        proxy.scrollTo(lastMessage.id, anchor: .top)
                                    }
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
                        // Chat mode toggle buttons - compact version for 4 modes
                        Menu {
                            ForEach(EntryChatMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    selectedChatMode = mode
                                    // Regenerate initial message when mode changes
                                    if messages.count == 1 && !messages[0].isUser {
                                        messages[0] = getInitialMessage()
                                    }
                                }) {
                                    Label(mode.rawValue, systemImage: selectedChatMode == mode ? "checkmark" : "")
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("Mode:")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text(selectedChatMode.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(journalColor)
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
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
                                        chatText.isEmpty ? Color.gray : journalColor,
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
                        Text("Entry Chat")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 4) {
                            Text(entryDate, style: .date)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Text(entryPreview)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
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
                            showingSummary = true
                        }) {
                            Label("View Summary", systemImage: "doc.text")
                        }
                        
                        Button(action: {
                            showingIdeas = true
                        }) {
                            Label("Ideas", systemImage: "lightbulb")
                        }
                        
                        Divider()
                        
                        // Chat Mode section
                        Section("Chat Mode") {
                            ForEach(EntryChatMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    selectedChatMode = mode
                                }) {
                                    Label(mode.rawValue, systemImage: selectedChatMode == mode ? "checkmark" : "")
                                }
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
                            .foregroundStyle(journalColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(journalColor)
                }
            }
            .onAppear {
                // Auto-insert first AI question based on chat mode
                if messages.isEmpty {
                    let initialMessage = getInitialMessage()
                    messages.append(initialMessage)
                }
                
                // Auto-focus text field when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
        }
        .sheet(isPresented: $showingSummary) {
            // TODO: Implement summary view
            Text("Summary View")
        }
        .sheet(isPresented: $showingIdeas) {
            // TODO: Implement ideas view
            Text("Ideas View")
        }
    }
    
    private func getInitialMessage() -> EntryChatMessage {
        let content = switch selectedChatMode {
        case .conversation:
            "I've read your entry. What would you like to explore about it?"
        case .interview:
            "Let's dive deeper into your entry. What was the most significant moment you described?"
        case .insight:
            "Looking at your entry, I notice some interesting themes. What patterns do you see in your experiences?"
        case .coach:
            "Thanks for sharing your entry. What goals or intentions arise from what you've written?"
        }
        
        return EntryChatMessage(content: content, isUser: false)
    }
    
    private func regenerateResponse() {
        // Find the last AI message and regenerate it
        if let lastAIIndex = messages.lastIndex(where: { !$0.isUser }) {
            // Remove the last AI message
            messages.remove(at: lastAIIndex)
            
            // Show thinking indicator
            isThinking = true
            
            // Generate new response
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.75...1.5)) {
                isThinking = false
                let aiResponse = aiResponses.randomElement() ?? aiResponses[0]
                let aiMessage = EntryChatMessage(content: aiResponse, isUser: false)
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(aiMessage)
                }
            }
        }
    }
    
    private func clearChat() {
        messages.removeAll()
        
        // Re-add initial AI message
        let initialMessage = getInitialMessage()
        messages.append(initialMessage)
    }
    
    private func sendMessage() {
        let userMessage = EntryChatMessage(content: chatText, isUser: true)
        messages.append(userMessage)
        
        chatText = ""
        
        // Show thinking indicator
        isThinking = true
        
        // Simulate AI response after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.75...1.5)) {
            isThinking = false
            let aiResponse = aiResponses.randomElement() ?? aiResponses[0]
            let aiMessage = EntryChatMessage(content: aiResponse, isUser: false)
            withAnimation(.easeIn(duration: 0.3)) {
                messages.append(aiMessage)
            }
        }
    }
}

// MARK: - Entry Chat Bubble View
struct EntryChatBubbleView: View {
    let message: EntryChatMessage
    let journalColor: Color
    
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
                        journalColor,
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