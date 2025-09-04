import SwiftUI

// MARK: - Navigation Items
enum NavigationItem: String, CaseIterable {
    case today = "Today"
    case journals = "Journals"
    case prompts = "Prompts"
    case more = "More"
    
    var icon: String {
        switch self {
        case .today:
            return "calendar"
        case .journals:
            return "book"
        case .prompts:
            return "lightbulb"
        case .more:
            return "ellipsis"
        }
    }
    
    var dayOneIcon: DayOneIcon {
        switch self {
        case .today:
            return .calendar
        case .journals:
            return .book
        case .prompts:
            return .prompt
        case .more:
            return .dots_horizontal
        }
    }
}

// MARK: - Main Split View for iPad
struct MainSplitView: View {
    @State private var selectedItem: NavigationItem? = .today
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var showingSettings = false
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            sidebarContent
        } detail: {
            // Detail view based on selection
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Sidebar Content
    @ViewBuilder
    private var sidebarContent: some View {
        List(selection: $selectedItem) {
            // Profile button at the top
            Section {
                Button {
                    showingSettings = true
                } label: {
                    HStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("PM")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Paul Mayne")
                                .font(.headline)
                            Text("View Profile")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }
            
            // Navigation items
            Section {
                ForEach(NavigationItem.allCases, id: \.self) { item in
                    Label {
                        Text(item.rawValue)
                    } icon: {
                        Image(dayOneIcon: item.dayOneIcon)
                            .foregroundColor(.primary)
                    }
                    .tag(item)
                }
            }
            
            // Search section
            Section {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search", text: $searchQuery)
                        .textFieldStyle(.plain)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .navigationTitle("Day One")
        .listStyle(.sidebar)
    }
    
    // MARK: - Detail Content
    @ViewBuilder
    private var detailContent: some View {
        Group {
            switch selectedItem {
            case .today:
                NavigationStack {
                    TodayView()
                }
            case .journals:
                NavigationStack {
                    JournalsView()
                }
            case .prompts:
                NavigationStack {
                    PromptsView()
                }
            case .more:
                NavigationStack {
                    MoreView()
                }
            case .none:
                NavigationStack {
                    ContentUnavailableView(
                        "Select an Item",
                        systemImage: "sidebar.left",
                        description: Text("Choose an item from the sidebar to get started")
                    )
                }
            }
        }
        .id(selectedItem) // Force view refresh on selection change
    }
}

#Preview {
    MainSplitView()
}