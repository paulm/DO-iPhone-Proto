import SwiftUI

/// Main tab view containing all app tabs
struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var tabSelectionCount: [Int: Int] = [0: 0, 1: 0, 2: 0, 3: 0]
    @AppStorage("showChatFAB") private var showChatFAB = true
    @AppStorage("showEntryFAB") private var showEntryFAB = false
    @State private var selectedDate = Date()
    @State private var chatCompleted = false
    @State private var showingPreviewEntry = false
    @State private var hasResumedChat = false
    @State private var messageCountAtResume = 0
    @State private var updateTrigger = false
    @State private var showUpdateEntry = false
    private var experimentsManager = ExperimentsManager.shared
    
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
            TabView(selection: Binding(
                get: { selectedTab },
                set: { newValue in
                    if selectedTab == newValue {
                        // Same tab selected again - cycle experiment
                        handleTabReselection(for: newValue)
                    } else {
                        selectedTab = newValue
                    }
                }
            )) {
                TimelineView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Today")
                    }
                    .tag(0)
                
                JournalsView()
                    .tabItem {
                        Image(systemName: "book")
                        Text("Journals")
                    }
                    .tag(1)
                
                PromptsView()
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right")
                        Text("Prompts")
                    }
                    .tag(2)
                
                MoreView()
                    .tabItem {
                        Image(systemName: "ellipsis")
                        Text("More")
                    }
                    .tag(3)
            }
            .tint(.black)
            
            // Floating Action Button - only show on Today tab
            if selectedTab == 0 {
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        if selectedTab == 0 && showChatFAB && !chatCompleted {
                            // Chat bubble above FAB when no messages
                            HStack {
                                Text("How's your \(dayOfWeek)?")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                Spacer()
                            }
                            .padding(.leading, 16)
                        }
                        
                        HStack(spacing: 12) {
                            Spacer()
                            if selectedTab == 0 && showChatFAB && chatCompleted {
                                // Show View Entry/Update Entry button only when appropriate
                                let _ = updateTrigger // Force dependency on updateTrigger
                                if !hasEntry {
                                    // Show "View Entry" when no entry exists yet
                                    DailyChatFAB(
                                        text: "View Entry",
                                        backgroundColor: .white
                                    ) {
                                        // Send notification to trigger entry generation
                                        NotificationCenter.default.post(name: NSNotification.Name("TriggerEntryGeneration"), object: selectedDate)
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(Color(hex: "44C0FF").opacity(0.2), lineWidth: 1)
                                    )
                                } else if hasEntry && showUpdateEntry {
                                    // Show "Update Entry" only after user has resumed chat AND sent a new message
                                    DailyChatFAB(
                                        text: "Update Entry",
                                        backgroundColor: .white
                                    ) {
                                        showingPreviewEntry = true
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(Color(hex: "44C0FF").opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                            if selectedTab == 0 && showChatFAB {
                                DailyChatFAB(
                                    text: chatCompleted ? "Resume Chat" : "Start Daily Chat",
                                    backgroundColor: chatCompleted ? Color(hex: "333B40") : Color(hex: "44C0FF")
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
                                    // FAB action - will be defined later
                                    print("FAB tapped on tab \(selectedTab)")
                                }
                            }
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 90) // Position above tab bar
                }
            }
        }
        .sheet(isPresented: $showingPreviewEntry) {
            ChatEntryPreviewView(
                selectedDate: selectedDate,
                entryCreated: .constant(false)
            )
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
            // Check every half second while on Today tab
            if selectedTab == 0 {
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
    }
    
    private func handleTabReselection(for tabIndex: Int) {
        let section: AppSection
        
        switch tabIndex {
        case 0:
            section = .todayTab
        case 1:
            section = .journalsTab
        case 2:
            section = .promptsTab
        case 3:
            section = .moreTab
        default:
            return
        }
        
        print("🔄 Cycling experiment for \(section.rawValue)")
        cycleExperiment(for: section)
    }
    
    private func cycleExperiment(for section: AppSection) {
        let availableVariants = experimentsManager.availableVariants(for: section)
        let currentVariant = experimentsManager.variant(for: section)
        
        print("📊 Available variants: \(availableVariants.map { $0.rawValue })")
        print("📍 Current variant: \(currentVariant.rawValue)")
        
        // Find current index and move to next (or wrap to first)
        if let currentIndex = availableVariants.firstIndex(of: currentVariant) {
            let nextIndex = (currentIndex + 1) % availableVariants.count
            let nextVariant = availableVariants[nextIndex]
            print("➡️ Switching to: \(nextVariant.rawValue)")
            experimentsManager.setVariant(nextVariant, for: section)
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