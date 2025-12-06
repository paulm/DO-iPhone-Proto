import SwiftUI

/// iOS 26 version of MainTabView using the new Tab API with separated Search tab
/// This file demonstrates the iOS 26 Tab(role: .search) implementation
/// Uncomment and use this when building with iOS 26 SDK
/*
struct MainTabView: View {
    @State private var selectedTab = 0
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

    var body: some View {
        ZStack {
            TabView {
                // Regular tabs using new Tab API
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
            // Optional: Add a bottom accessory (e.g., mini-player or quick entry bar)
            // .tabViewBottomAccessory {
            //     QuickEntryBar()
            // }
            
            // Floating Action Button - only show on Today tab
            if selectedTab == 0 {
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Spacer()
                            if selectedTab == 0 && showChatFAB {
                                DailyChatFAB(
                                    text: chatCompleted ? "Resume Chat" : "Start Daily Chat",
                                    backgroundColor: chatCompleted ? .white : Color(hex: "44C0FF")
                                ) {
                                    if chatCompleted && hasEntry {
                                        hasResumedChat = true
                                        let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                                        messageCountAtResume = messages.filter { $0.isUser }.count
                                    }
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
                    .padding(.bottom, 90)
                }
            }
        }
        .sheet(isPresented: $showingEntry) {
            EntryView(journal: nil, startInEditMode: true)
        }
    }
    
    private var hasEntry: Bool {
        return DailyContentManager.shared.hasEntry(for: selectedDate)
    }
}

// Optional: Quick Entry Bar for bottom accessory
struct QuickEntryBar: View {
    @State private var quickText = ""
    
    var body: some View {
        HStack {
            TextField("Quick note...", text: $quickText)
                .textFieldStyle(.roundedBorder)
            
            Button(action: {
                // Save quick note
                quickText = ""
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "44C0FF"))
            }
            .disabled(quickText.isEmpty)
        }
        .padding()
        .background(.regularMaterial)
    }
}
*/

// MARK: - Implementation Notes for iOS 26 Search Tab

/*
 iOS 26 Search Tab Implementation Guide:
 
 1. Use Tab(role: .search) for the separated Search pill:
    - This creates a visually separated Search tab at the trailing edge
    - The system handles the Liquid Glass styling automatically
    - On tap, it expands into a bottom-aligned search field
 
 2. Required setup:
    - Attach .searchable() to the TabView container
    - The search query binding connects to the system search field
    - Search scopes can be added to SearchResultsView
 
 3. Key differences from traditional tabs:
    - No .tag() needed on Tab views (handled by position)
    - Selection binding works differently (may need adjustment)
    - Tab reselection detection needs onChange modifier
 
 4. Optional bottom accessory:
    - Use .tabViewBottomAccessory { } for persistent UI above tab bar
    - Good for mini-players, quick entry bars, etc.
    - Separate from the Search pill functionality
 
 5. Platform behavior:
    - iPhone: Search pill at trailing edge, expands at bottom
    - iPad: Search appears in top-center of window
    - Automatic Liquid Glass treatment on iOS 26+
 
 6. Migration strategy:
    - Keep traditional TabView implementation for iOS 15-25
    - Use availability check for iOS 26+ features
    - Gradually adopt new APIs as SDK support improves
*/