import SwiftUI

/// Main tab view containing all app tabs with iOS 26 separated Search tab
struct MainTabView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var searchQuery = ""
    @AppStorage("showChatFAB") private var showChatFAB = false
    @AppStorage("showEntryFAB") private var showEntryFAB = false
    private var dateManager = DateManager.shared
    @State private var chatCompleted = false

    private var selectedDate: Date {
        dateManager.selectedDate
    }
    @State private var showingEntry = false
    @State private var hasResumedChat = false
    @State private var messageCountAtResume = 0
    @State private var updateTrigger = false
    @State private var showUpdateEntry = false
    @State private var journalViewModel = JournalSelectionViewModel()

    enum AppTab: Hashable {
        case today, journals, prompts, more
    }
    @State private var selectedTab: AppTab = .today

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
        // Use split view for iPad, tab view for iPhone
        if horizontalSizeClass == .regular {
            // iPad layout with split view
            MainSplitView()
        } else {
            // iPhone layout with tabs
            iPhoneTabView
        }
    }
    
    // MARK: - iPhone Tab View
    @ViewBuilder
    private var iPhoneTabView: some View {
        ZStack {
            mainTabView
            floatingActionButtons
        }
        .sheet(isPresented: $showingEntry) {
            // Check if selected date is today
            let calendar = Calendar.current
            let isToday = calendar.isDateInToday(selectedDate)
            let entryDate = isToday ? Date() : calendar.startOfDay(for: selectedDate)
            let isAllDay = !isToday

            EntryView(
                journal: nil,
                initialDate: entryDate,
                isAllDay: isAllDay,
                startInEditMode: true
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
        .onChange(of: selectedDate) { oldValue, newValue in
            // Reset state when date changes
            hasResumedChat = false
            messageCountAtResume = 0
            showUpdateEntry = false
            // Check for messages on the new date immediately
            let messages = ChatSessionManager.shared.getMessages(for: newValue)
            chatCompleted = !messages.isEmpty && messages.contains { $0.isUser }
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

    @MainActor
    private var mainTabView: some View {
        @Bindable var dateManager = DateManager.shared

        return TabView {
            // Regular tabs using iOS 26 Tab API with Day One Icons
            Tab {
                TimelineView()
                    .onAppear { selectedTab = .today }
            } label: {
                Label {
                    Text("Today")
                } icon: {
                    Image(dayOneIcon: .sunrise_filled)
                        .renderingMode(.template)
                }
            }

            Tab {
                JournalsView()
                    .environment(journalViewModel)
                    .onAppear { selectedTab = .journals }
            } label: {
                Label {
                    Text("Journals")
                } icon: {
                    Image(dayOneIcon: .books_filled)
                        .renderingMode(.template)
                }
            }

            Tab {
                PromptsView()
                    .onAppear { selectedTab = .prompts }
            } label: {
                Label {
                    Text("Prompts")
                } icon: {
                    Image(dayOneIcon: .prompt_filled)
                        .renderingMode(.template)
                }
            }

            Tab {
                MoreView()
                    .onAppear { selectedTab = .more }
            } label: {
                Label {
                    Text("More")
                } icon: {
                    Image(dayOneIcon: .dots_horizontal)
                        .renderingMode(.template)
                }
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
    }

    @ViewBuilder
    private var floatingActionButtons: some View {
        // Floating Action Button - simplified for iOS 26
        // Only show FAB on Today tab
        // Use Deep Blue color
        if (showChatFAB || showEntryFAB) && selectedTab == .today {
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
                            // Use Deep Blue on Today tab
                            FloatingActionButton(action: {
                                showingEntry = true
                            }, backgroundColor: Color(hex: "333B40"))
                        }
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 90) // Position above tab bar
            }
        }
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    var backgroundColor: Color = Color(hex: "44C0FF")

    var body: some View {
        Button(action: action) {
            Text(DayOneIcon.plus.rawValue)
                .dayOneIconFont(size: 24)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
        }
        .background(backgroundColor)
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
