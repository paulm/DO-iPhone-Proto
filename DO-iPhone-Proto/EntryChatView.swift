import SwiftUI

/// Chat view for interacting with AI about a specific journal entry
struct EntryChatView: View {
    @Environment(\.dismiss) private var dismiss
    let entryText: String
    let entryTitle: String
    
    @State private var messages: [ChatMessage] = []
    @State private var newMessage = ""
    @State private var isVoiceChatMode = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with entry reference
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entry Chat")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    HStack {
                        Text("Sample Journal")
                            .foregroundStyle(Color(hex: "44C0FF"))
                        Text(" · ")
                            .foregroundStyle(.secondary)
                        Text(entryTitle)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(.white)
                
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubbleView(message: message)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                                .foregroundStyle(newMessage.isEmpty ? .gray : Color(hex: "44C0FF"))
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
                    
                    // Suggested actions row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            SuggestedActionButton(title: "Why did I feel that way?") {
                                newMessage = "Why did I feel that way?"
                                isTextFieldFocused = true
                            }
                            
                            SuggestedActionButton(title: "Tell me more about this") {
                                newMessage = "Tell me more about this experience"
                                isTextFieldFocused = true
                            }
                            
                            SuggestedActionButton(title: "Summarize this entry") {
                                newMessage = "Can you summarize this entry in simple terms?"
                                isTextFieldFocused = true
                            }
                            
                            SuggestedActionButton(title: "Extract themes") {
                                newMessage = "What themes or emotions do you see in this entry?"
                                isTextFieldFocused = true
                            }
                            
                            SuggestedActionButton(title: "Make it more poetic") {
                                newMessage = "Can you help me rewrite this in a more poetic way?"
                                isTextFieldFocused = true
                            }
                            
                            SuggestedActionButton(title: "Set follow-ups") {
                                newMessage = "What follow-ups should I consider for this entry?"
                                isTextFieldFocused = true
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }
            }
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            generateInitialResponse()
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
        return """
I can see you've written about your walk on a familiar trail. This sounds like a meaningful experience! 

Walking familiar paths often brings a sense of comfort and routine, but can also offer opportunities for new observations and reflections. The fact that you took time to journal about it suggests it held some significance for you.

What stood out to you most during this walk? Was there something different about how you experienced this familiar route today?
"""
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
                    .background(message.isFromUser ? Color(hex: "44C0FF") : Color(.systemGray6))
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
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(hex: "44C0FF").opacity(0.1))
                .foregroundStyle(Color(hex: "44C0FF"))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    EntryChatView(
        entryText: "This afternoon I walked a familiar trail near my house. Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        entryTitle: "A Quiet Walk"
    )
}