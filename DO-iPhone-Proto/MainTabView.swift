import SwiftUI

/// Main tab view containing all app tabs
struct MainTabView: View {
    var body: some View {
        TabView {
            TimelineView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Today")
                }
            
            JournalsView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Journals")
                }
            
            PromptsView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Prompts")
                }
            
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis")
                    Text("More")
                }
        }
        .tint(.black)
    }
}

#Preview {
    MainTabView()
}