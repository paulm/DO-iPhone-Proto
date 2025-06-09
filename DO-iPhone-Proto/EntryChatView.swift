import SwiftUI

enum ChatMode: CaseIterable {
    case conversation
    case interview
    case listen
    case insight
    case rewrite
    case calmDown
    case coach
    
    var emoji: String {
        switch self {
        case .conversation: return "🗣"
        case .interview: return "❓"
        case .listen: return "👂"
        case .insight: return "🧠"
        case .rewrite: return "✍️"
        case .calmDown: return "🧘"
        case .coach: return "🛠"
        }
    }
    
    var title: String {
        switch self {
        case .conversation: return "Conversation"
        case .interview: return "Interview"
        case .listen: return "Listen"
        case .insight: return "Insight"
        case .rewrite: return "Rewrite"
        case .calmDown: return "Calm Down"
        case .coach: return "Coach Mode"
        }
    }
    
    var description: String {
        switch self {
        case .conversation: return "Default mode: two-way, thoughtful dialogue about the entry\nReflective, curious, asks questions, makes observations"
        case .interview: return "Ask me questions only — help me open up or structure my thoughts\nRapid-fire thoughtful questions, no statements"
        case .listen: return "Just listen and acknowledge what I'm saying\nShort affirming responses like \"I hear you,\" \"That sounds important\""
        case .insight: return "Analyze and extract meaning — patterns, emotions, themes\nObservational, analytical, provides reflection"
        case .rewrite: return "Help me edit, enhance, or rephrase what I wrote\nSuggests rewrites, poetic edits, grammar fixes"
        case .calmDown: return "Help me emotionally regulate or ground myself\nSoothing responses, mindfulness prompts, grounding questions"
        case .coach: return "Help me make a plan or take action from this entry\nFocused on goal-setting, next steps, priorities"
        }
    }
}

/// Chat view for interacting with AI about a specific journal entry
struct EntryChatView: View {
    @Environment(\.dismiss) private var dismiss
    let entryText: String
    let entryTitle: String
    
    @State private var messages: [ChatMessage] = []
    @State private var newMessage = ""
    @State private var isVoiceChatMode = false
    @State private var selectedEntryType = "Reflection"
    @State private var showingEntryTypePicker = false
    @State private var selectedChatMode = ChatMode.conversation
    @State private var showingChatModePicker = false
    @State private var showingDeveloperSettings = false
    @State private var showChatMode = true
    @State private var showEntryType = true
    @State private var showSuggestions = true
    @State private var showEntryAssistant = true
    @State private var iconMode = true
    @State private var showingEntryAssistant = false
    @State private var showingSuggestionsMenu = false
    @FocusState private var isTextFieldFocused: Bool
    
    let entryTypes = ["Dream", "Reflection", "Travel log", "Emotional venting", "Daily recap", "Memory", "Creative writing", "Gratitude", "Goal setting", "Freewriting / stream of consciousness"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Icon Mode or Traditional Interface
                if iconMode {
                    // Icon-based interface
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            if showChatMode {
                                IconButton(
                                    icon: selectedChatMode.emoji,
                                    label: "Mode",
                                    action: { showingChatModePicker = true }
                                )
                            }
                            
                            if showEntryType {
                                IconButton(
                                    icon: "📝",
                                    label: "Type",
                                    action: { showingEntryTypePicker = true }
                                )
                            }
                            
                            if showEntryAssistant {
                                IconButton(
                                    icon: "🤖",
                                    label: "Assistant",
                                    action: { showingEntryAssistant = true }
                                )
                            }
                            
                            if showSuggestions {
                                IconButton(
                                    icon: "💡",
                                    label: "Ideas",
                                    action: { showingSuggestionsMenu = true }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .background(.white)
                } else {
                    // Traditional interface
                    // Chat Mode selector
                    if showChatMode {
                    Button {
                        showingChatModePicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Text(selectedChatMode.emoji)
                                .font(.title2)
                            Text(selectedChatMode.title)
                                .font(.body)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white)
                }
                
                // Entry Type selector
                if showEntryType {
                    Button {
                        showingEntryTypePicker = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Entry Type")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(selectedEntryType)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                    }
                    .background(.white)
                }
                
                // Entry Assistant row
                if showEntryAssistant {
                    Button {
                        showingEntryAssistant = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Entry Assistant")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text("AI-powered editing and enhancement")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                    }
                    .background(.white)
                }
                
                // Suggested actions header
                if showSuggestions {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            SuggestedActionButton(title: "Reflect") {
                                newMessage = "Why did I feel that way?"
                                isTextFieldFocused = true
                            }
                            
                            SuggestedActionButton(title: "Expand") {
                                newMessage = "Tell me more about this experience"
                                isTextFieldFocused = true
                            }
                            
                            SuggestedActionButton(title: "Summarize") {
                                newMessage = "Can you summarize this entry in simple terms?"
                                isTextFieldFocused = true
                            }
                            
                            SuggestedActionButton(title: "Rewrite") {
                                newMessage = "Can you help me rewrite this in a more poetic way?"
                                isTextFieldFocused = true
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .background(.white)
                    }
                }
                
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            Spacer()
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    ChatBubbleView(message: message)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Message input section
                VStack(spacing: 12) {
                    // Text input row
                    HStack(spacing: 12) {
                        TextField("Ask about your entry...", text: $newMessage, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .focused($isTextFieldFocused)
                            .lineLimit(1...4)
                        
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundStyle(newMessage.isEmpty ? .gray : .black)
                        }
                        .disabled(newMessage.isEmpty)
                        
                        Button {
                            isVoiceChatMode.toggle()
                        } label: {
                            Image(systemName: isVoiceChatMode ? "mic.fill" : "mic")
                                .font(.title2)
                                .foregroundStyle(.black)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: { showingDeveloperSettings = true }) {
                    Text(entryTitle)
                        .font(.subheadline)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                },
                trailing: Button("Done") {
                    dismiss()
                }
                .foregroundStyle(.black)
            )
        }
        .onAppear {
            generateInitialResponse()
            // Auto-focus the text input when chat opens
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .sheet(isPresented: $showingEntryTypePicker) {
            EntryTypePickerView(selectedType: $selectedEntryType, entryTypes: entryTypes)
        }
        .sheet(isPresented: $showingChatModePicker) {
            ChatModePickerView(selectedMode: $selectedChatMode)
        }
        .sheet(isPresented: $showingDeveloperSettings) {
            DeveloperSettingsView(
                showChatMode: $showChatMode,
                showEntryType: $showEntryType,
                showSuggestions: $showSuggestions,
                showEntryAssistant: $showEntryAssistant,
                iconMode: $iconMode
            )
        }
        .sheet(isPresented: $showingEntryAssistant) {
            EntryAssistantSheet(entryText: entryText, entryTitle: entryTitle)
        }
        .sheet(isPresented: $showingSuggestionsMenu) {
            SuggestionsMenuView(newMessage: $newMessage, onSuggestionSelected: {
                isTextFieldFocused = true
                showingSuggestionsMenu = false
            })
        }
    }
    
    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            content: newMessage,
            isFromUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        
        let messageToProcess = newMessage
        newMessage = ""
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let aiResponse = generateAIResponse(for: messageToProcess)
            let aiMessage = ChatMessage(
                content: aiResponse,
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(aiMessage)
        }
    }
    
    private func generateInitialResponse() {
        let initialResponse = generateInitialAIResponse()
        let aiMessage = ChatMessage(
            content: initialResponse,
            isFromUser: false,
            timestamp: Date()
        )
        messages.append(aiMessage)
    }
    
    private func generateInitialAIResponse() -> String {
        return "I can see you've written about your walk on a familiar trail. This sounds like a meaningful experience!"
    }
    
    private func generateAIResponse(for message: String) -> String {
        // Simple response generation based on common patterns
        let lowerMessage = message.lowercased()
        
        if lowerMessage.contains("feel") || lowerMessage.contains("emotion") {
            return "It sounds like you're exploring some deep emotions. Journaling can be such a powerful way to process feelings. What emotions are coming up most strongly for you right now?"
        } else if lowerMessage.contains("why") || lowerMessage.contains("understand") {
            return "That's a thoughtful question. Sometimes the act of writing itself helps us discover answers we didn't know we had. What insights have emerged as you've been reflecting on this?"
        } else if lowerMessage.contains("thank") || lowerMessage.contains("help") {
            return "I'm glad I could help you think through this! Your willingness to reflect and explore your experiences through journaling is really valuable. Is there anything else about this entry you'd like to explore?"
        } else {
            return "That's an interesting perspective. Your journal entry shows a lot of thoughtfulness. What other aspects of this experience would you like to explore further?"
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.isFromUser ? .black : Color(.systemGray6))
                    .foregroundStyle(message.isFromUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if !message.isFromUser {
                Spacer(minLength: 50)
            }
        }
    }
}

struct SuggestedActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.black)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct EntryTypePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedType: String
    let entryTypes: [String]
    
    var body: some View {
        NavigationStack {
            List(entryTypes, id: \.self) { type in
                Button {
                    selectedType = type
                    dismiss()
                } label: {
                    HStack {
                        Text(type)
                            .foregroundStyle(.primary)
                        Spacer()
                        if type == selectedType {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
            .navigationTitle("Entry Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct ChatModePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMode: ChatMode
    
    var body: some View {
        NavigationStack {
            List(ChatMode.allCases, id: \.self) { mode in
                Button {
                    selectedMode = mode
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(mode.emoji)
                                .font(.title2)
                            Text(mode.title)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Spacer()
                            if mode == selectedMode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text(mode.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Chat Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct DeveloperSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showChatMode: Bool
    @Binding var showEntryType: Bool
    @Binding var showSuggestions: Bool
    @Binding var showEntryAssistant: Bool
    @Binding var iconMode: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Interface Mode") {
                    Toggle("Icon Mode", isOn: $iconMode)
                }
                
                Section("Entry Chat Features") {
                    Toggle("Show Chat Mode", isOn: $showChatMode)
                    Toggle("Show Entry Type", isOn: $showEntryType)
                    Toggle("Show Entry Assistant", isOn: $showEntryAssistant)
                    Toggle("Show Suggestions", isOn: $showSuggestions)
                }
            }
            .navigationTitle("Developer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct EntryAssistantSheet: View {
    @Environment(\.dismiss) private var dismiss
    let entryText: String
    let entryTitle: String
    
    @State private var showingUpdateEntry = false
    @State private var showingSummary = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Entry Assistant")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 32)
                
                VStack(spacing: 16) {
                    AssistantActionButton(
                        title: "Update Entry",
                        subtitle: "Edit with AI suggestions",
                        icon: "pencil.circle"
                    ) {
                        showingUpdateEntry = true
                    }
                    
                    AssistantActionButton(
                        title: "View Summary",
                        subtitle: "See key points and themes",
                        icon: "doc.text"
                    ) {
                        showingSummary = true
                    }
                    
                    AssistantActionButton(
                        title: "Use as New Entry",
                        subtitle: "Create a new journal entry",
                        icon: "plus.circle"
                    ) {
                        // TODO: Implement new entry creation
                        dismiss()
                    }
                    
                    AssistantActionButton(
                        title: "Copy to Clipboard",
                        subtitle: "Copy AI-enhanced version",
                        icon: "doc.on.clipboard"
                    ) {
                        // TODO: Implement clipboard copy
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingUpdateEntry) {
            UpdateEntryView(entryText: entryText, entryTitle: entryTitle)
        }
        .sheet(isPresented: $showingSummary) {
            SummaryView(entryText: entryText, entryTitle: entryTitle)
        }
    }
}

struct AssistantActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.black)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

struct UpdateEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let entryText: String
    let entryTitle: String
    
    @State private var originalText: String
    @State private var aiText: String
    @State private var showingEditOptions = false
    
    init(entryText: String, entryTitle: String) {
        self.entryText = entryText
        self.entryTitle = entryTitle
        self._originalText = State(initialValue: entryText)
        self._aiText = State(initialValue: UpdateEntryView.generateAIVersion(of: entryText))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Original Entry
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Original Entry")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text(originalText)
                            .font(.body)
                            .padding(16)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // AI Enhanced Version
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Enhanced Version")
                            .font(.headline)
                            .foregroundStyle(.black)
                        TextEditor(text: $aiText)
                            .font(.body)
                            .padding(16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .frame(minHeight: 200)
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Update Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        showingEditOptions = true
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingEditOptions) {
            EditOptionsSheet(aiText: aiText, originalText: originalText)
        }
    }
    
    static func generateAIVersion(of text: String) -> String {
        return text + "\n\n[AI Enhanced: This entry has been refined for clarity and emotional depth, while preserving the original voice and meaning.]"
    }
}

struct EditOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let aiText: String
    let originalText: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("How would you like to apply the changes?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
                
                VStack(spacing: 16) {
                    EditOptionButton(title: "Replace Original", subtitle: "Use AI version only") {
                        // TODO: Replace original
                        dismiss()
                    }
                    
                    EditOptionButton(title: "Append to Entry", subtitle: "Add AI version at the end") {
                        // TODO: Append to entry
                        dismiss()
                    }
                    
                    EditOptionButton(title: "Prepend to Entry", subtitle: "Add AI version at the beginning") {
                        // TODO: Prepend to entry
                        dismiss()
                    }
                    
                    EditOptionButton(title: "Edit Before Saving", subtitle: "Make more changes first") {
                        // TODO: Return to edit view
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditOptionButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

struct SummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let entryText: String
    let entryTitle: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("A reflective walk on a familiar trail that brought moments of peace and introspection. The experience highlights the value of routine paths in providing comfort while still offering opportunities for new observations.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Themes")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ThemeTag(text: "Nature & Walking")
                            ThemeTag(text: "Reflection")
                            ThemeTag(text: "Routine & Comfort")
                            ThemeTag(text: "Mindfulness")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Emotional Tone")
                            .font(.headline)
                        
                        Text("Calm, contemplative, peaceful")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(entryTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct ThemeTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.1))
            .foregroundStyle(.black)
            .clipShape(Capsule())
    }
}

struct SuggestionsMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var newMessage: String
    let onSuggestionSelected: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Quick Ideas")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 32)
                
                VStack(spacing: 16) {
                    SuggestedActionButton(title: "Reflect") {
                        newMessage = "Why did I feel that way?"
                        onSuggestionSelected()
                        dismiss()
                    }
                    
                    SuggestedActionButton(title: "Expand") {
                        newMessage = "Tell me more about this experience"
                        onSuggestionSelected()
                        dismiss()
                    }
                    
                    SuggestedActionButton(title: "Summarize") {
                        newMessage = "Can you summarize this entry in simple terms?"
                        onSuggestionSelected()
                        dismiss()
                    }
                    
                    SuggestedActionButton(title: "Rewrite") {
                        newMessage = "Can you help me rewrite this in a more poetic way?"
                        onSuggestionSelected()
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct IconButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.title)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(minWidth: 60)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    EntryChatView(
        entryText: "This afternoon I walked a familiar trail near my house. Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        entryTitle: "A Quiet Walk"
    )
}