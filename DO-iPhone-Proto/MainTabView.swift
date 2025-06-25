import SwiftUI

/// Main tab view containing all app tabs
struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var tabSelectionCount: [Int: Int] = [0: 0, 1: 0, 2: 0, 3: 0]
    private var experimentsManager = ExperimentsManager.shared
    
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
            
            // Floating Action Button - only show on Today and Journals tabs
            if selectedTab == 0 || selectedTab == 1 {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Spacer()
                        DailyChatFAB {
                            // Send notification to trigger Daily Chat
                            NotificationCenter.default.post(name: NSNotification.Name("TriggerDailyChat"), object: nil)
                        }
                        FloatingActionButton {
                            // FAB action - will be defined later
                            print("FAB tapped on tab \(selectedTab)")
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 90) // Position above tab bar
                }
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Daily Chat")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(height: 56)
                .padding(.horizontal, 20)
        }
        .background(Color(hex: "44C0FF"))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}


#Preview {
    MainTabView()
}