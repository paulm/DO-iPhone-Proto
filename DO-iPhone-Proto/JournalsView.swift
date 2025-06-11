import SwiftUI

/// Journals tab view showing journal collections
struct JournalsView: View {
    @State private var selectedTab = 1 // Default to List tab
    @State private var showingJournalSelector = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header section with blue gradient background
                VStack(alignment: .leading, spacing: 12) {
                    // Journal selector and actions
                    HStack {
                        Button(action: {
                            showingJournalSelector = true
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.white)
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.white)
                                .font(.title2)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.white)
                                .font(.title2)
                        }
                        
                        // Profile image placeholder
                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.white)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top, geometry.safeAreaInsets.top + 12)
                    
                    // Journal title and date range
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Journal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("2020 – 2025")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .background(
                    LinearGradient(
                        colors: [Color(hex: "44C0FF"), Color(hex: "44C0FF").opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Tab navigation
            HStack(spacing: 0) {
                TabButton(title: "Cover", index: 0, selectedTab: $selectedTab)
                TabButton(title: "List", index: 1, selectedTab: $selectedTab)
                TabButton(title: "Calendar", index: 2, selectedTab: $selectedTab)
                TabButton(title: "Media", index: 3, selectedTab: $selectedTab)
                TabButton(title: "Map", index: 4, selectedTab: $selectedTab)
            }
            .background(.white)
            
            // Content based on selected tab
            Group {
                switch selectedTab {
                case 0:
                    CoverTabView()
                case 1:
                    ListTabView()
                case 2:
                    CalendarTabView()
                case 3:
                    MediaTabView()
                case 4:
                    MapTabView()
                default:
                    ListTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea(edges: .top)
        }
        .sheet(isPresented: $showingJournalSelector) {
            JournalSelectorView()
        }
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            selectedTab = index
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: selectedTab == index ? .medium : .regular))
                    .foregroundStyle(selectedTab == index ? .black : .secondary)
                
                if selectedTab == index {
                    Circle()
                        .fill(.black)
                        .frame(width: 4, height: 4)
                } else {
                    Circle()
                        .fill(.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Tab Content Views
struct CoverTabView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Cover View")
                    .font(.title)
                    .padding()
                Text("Journal cover, description, stats, and recently edited entries would appear here.")
                    .padding()
                    .foregroundStyle(.secondary)
            }
        }
        .background(.gray.opacity(0.1))
    }
}

struct ListTabView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // March 2025 Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("March 2025")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    // Entry item
                    HStack(alignment: .top, spacing: 16) {
                        VStack(spacing: 4) {
                            Text("WED")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("12")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                        .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Had a wonderful lunch with Emily today.")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Text("It's refreshing to step away from the daily grind and catch up with old friends. We talked about...")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            
                            Text("6:11 PM CDT")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(.white)
    }
}

struct CalendarTabView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Calendar View")
                    .font(.title)
                    .padding()
                Text("Calendar view of entries would appear here.")
                    .padding()
                    .foregroundStyle(.secondary)
            }
        }
        .background(.gray.opacity(0.1))
    }
}

struct MediaTabView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Media View")
                    .font(.title)
                    .padding()
                Text("Photos and videos from entries would appear here.")
                    .padding()
                    .foregroundStyle(.secondary)
            }
        }
        .background(.gray.opacity(0.1))
    }
}

struct MapTabView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Map View")
                    .font(.title)
                    .padding()
                Text("Geolocation view of where entries were written would appear here.")
                    .padding()
                    .foregroundStyle(.secondary)
            }
        }
        .background(.gray.opacity(0.1))
    }
}

#Preview {
    JournalsView()
}