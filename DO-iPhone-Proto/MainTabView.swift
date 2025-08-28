import SwiftUI

/// Main tab view containing all app tabs with iOS 26 separated Search tab
struct MainTabView: View {
    @State private var searchQuery = ""
    @AppStorage("showChatFAB") private var showChatFAB = false
    @AppStorage("showEntryFAB") private var showEntryFAB = false
    @State private var selectedDate = Date()
    @State private var chatCompleted = false
    @State private var showingEntry = false
    @State private var hasResumedChat = false
    @State private var messageCountAtResume = 0
    @State private var updateTrigger = false
    @State private var showUpdateEntry = false
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private var hasChatMessages: Bool {
        let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
        return !messages.isEmpty && messages.contains { $0.isUser }
    }
    
    private var hasEntry: Bool {
        return DailyContentManager.shared.hasEntry(for: selectedDate)
    }
    
    private var hasNewMessagesSinceEntry: Bool {
        return DailyContentManager.shared.hasNewMessagesSinceEntry(for: selectedDate)
    }
    
    private var hasNewMessagesSinceResume: Bool {
        let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
        let currentUserMessageCount = messages.filter { $0.isUser }.count
        let hasNew = currentUserMessageCount > messageCountAtResume
        print("DEBUG: hasEntry=\(hasEntry), hasResumedChat=\(hasResumedChat), messageCountAtResume=\(messageCountAtResume), currentCount=\(currentUserMessageCount), hasNew=\(hasNew)")
        return hasNew
    }
    
    var body: some View {
        ZStack {
            TabView {
                // Regular tabs using iOS 26 Tab API
                Tab("Today", systemImage: "calendar") {
                    TimelineView()
                }
                
                Tab("Journals", systemImage: "book") {
                    JournalsView()
                }
                
                Tab("Prompts", systemImage: "bubble.left.and.bubble.right") {
                    PromptsView()
                }
                
                Tab("More", systemImage: "ellipsis") {
                    MoreView()
                }
                
                // iOS 26 system-provided Search tab (separated pill in tab bar)
                Tab(role: .search) {
                    NavigationStack {
                        SearchResultsView(searchText: $searchQuery)
                            .navigationTitle("Search")
                    }
                }
            }
            .tint(.black)
            // Attach the search field to the container so the Search tab can expand it
            .searchable(text: $searchQuery, prompt: "Search everything")
            
            // Floating Action Button - simplified for iOS 26
            // Note: FABs should ideally be within individual tab views for proper state management
            if showChatFAB || showEntryFAB {
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Spacer()
                            if showChatFAB {
                                DailyChatFAB(
                                    text: chatCompleted ? "Resume Chat" : "Start Daily Chat",
                                    backgroundColor: chatCompleted ? .white : Color(hex: "44C0FF")
                                ) {
                                    // Set hasResumedChat to true when Resume Chat is tapped on a day with an entry
                                    if chatCompleted && hasEntry {
                                        hasResumedChat = true
                                        // Track current message count when resuming
                                        let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                                        messageCountAtResume = messages.filter { $0.isUser }.count
                                    }
                                    // Send notification to trigger Daily Chat
                                    NotificationCenter.default.post(name: NSNotification.Name("TriggerDailyChat"), object: nil)
                                }
                            }
                            if showEntryFAB {
                                FloatingActionButton {
                                    showingEntry = true
                                }
                            }
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 90) // Position above tab bar
                }
            }
        }
        .sheet(isPresented: $showingEntry) {
            EntryView(journal: nil, startInEditMode: true)
        }
        .onAppear {
            // Check for chat messages on appear
            chatCompleted = hasChatMessages
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh chat status when app comes to foreground
            chatCompleted = hasChatMessages
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ChatMessagesUpdated"))) { _ in
            // Refresh chat status when messages are updated
            DispatchQueue.main.async {
                chatCompleted = hasChatMessages
                // Check if Update Entry should show
                if hasResumedChat && hasEntry {
                    let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                    let currentUserMessageCount = messages.filter { $0.isUser }.count
                    let shouldShowUpdate = currentUserMessageCount > messageCountAtResume
                    showUpdateEntry = shouldShowUpdate
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Also check when app becomes active
            DispatchQueue.main.async {
                chatCompleted = hasChatMessages
            }
        }
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            // Check every half second for chat updates
            let hasMessages = hasChatMessages
            if chatCompleted != hasMessages {
                chatCompleted = hasMessages
            }
            // Also trigger update for message count changes
            if hasResumedChat && hasEntry {
                let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                let currentUserMessageCount = messages.filter { $0.isUser }.count
                let shouldShowUpdate = currentUserMessageCount > messageCountAtResume
                if shouldShowUpdate != showUpdateEntry {
                    showUpdateEntry = shouldShowUpdate
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SelectedDateChanged"))) { notification in
            // Update selected date and check chat state
            if let newDate = notification.object as? Date {
                selectedDate = newDate
                // Reset hasResumedChat and message count when date changes
                hasResumedChat = false
                messageCountAtResume = 0
                showUpdateEntry = false
                // Check for messages on the new date immediately
                let messages = ChatSessionManager.shared.getMessages(for: newDate)
                chatCompleted = !messages.isEmpty && messages.contains { $0.isUser }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DailyEntryCreatedStatusChanged"))) { _ in
            // Force UI update when entry status changes
            DispatchQueue.main.async {
                // Trigger a view update by modifying state
                let currentState = chatCompleted
                chatCompleted = !currentState
                chatCompleted = currentState
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenEntryView"))) { _ in
            // Open Entry view when notification is received
            showingEntry = true
        }
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
        }
        .background(Color(hex: "44C0FF"))
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct DailyChatFAB: View {
    let text: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(backgroundColor == .white ? Color(hex: "44C0FF") : .white)
                .frame(height: 56)
                .padding(.horizontal, 20)
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}


#Preview {
    MainTabView()
}
