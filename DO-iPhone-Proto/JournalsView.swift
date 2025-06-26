import SwiftUI

/// Journals tab view showing journal collections
struct JournalsView: View {
    @State private var selectedTab = 1 // Default to List tab
    @State private var showingJournalSelector = false
    @State private var showingSettings = false
    @State private var journalViewModel = JournalSelectionViewModel()
    private var experimentsManager = ExperimentsManager.shared
    
    var body: some View {
        switch experimentsManager.variant(for: .journalsTab) {
        case .original:
            JournalsViewOriginal(
                selectedTab: $selectedTab,
                showingJournalSelector: $showingJournalSelector,
                showingSettings: $showingSettings,
                journalViewModel: journalViewModel
            )
        case .appleSettings:
            JournalsTabSettingsStyleView()
        case .variant2:
            JournalsTabVariant2View()
        case .paged:
            JournalsTabPagedView()
        default:
            // Fallback to original for any unsupported variants
            JournalsViewOriginal(
                selectedTab: $selectedTab,
                showingJournalSelector: $showingJournalSelector,
                showingSettings: $showingSettings,
                journalViewModel: journalViewModel
            )
        }
    }
}

/// Original Journals tab layout
struct JournalsViewOriginal: View {
    @Binding var selectedTab: Int
    @Binding var showingJournalSelector: Bool
    @Binding var showingSettings: Bool
    let journalViewModel: JournalSelectionViewModel
    
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
                        Button(action: {
                            showingSettings = true
                        }) {
                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.white)
                                )
                        }
                        .accessibilityLabel("Settings")
                    }
                    .padding(.horizontal)
                    .padding(.top, geometry.safeAreaInsets.top + 12)
                    
                    // Journal title and date range
                    VStack(alignment: .leading, spacing: 6) {
                        Text(journalViewModel.selectedJournal.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("2020 – 2025")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .background(journalViewModel.headerGradient)
            
            // Segmented control navigation
            VStack(spacing: 0) {
                Picker("View", selection: $selectedTab) {
                    Text("Cover").tag(0)
                    Text("List").tag(1)
                    Text("Calendar").tag(2)
                    Text("Media").tag(3)
                    Text("Map").tag(4)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.white)
            }
            
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
            JournalSelectorView(viewModel: journalViewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}


// MARK: - Tab Content Views
struct CoverTabView: View {
    @State private var showingEditView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Description Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Add a description...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.top, 24)
                
                // Stats Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Stats")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatsCard(title: "Journals", value: "5", icon: "book.fill", color: .blue)
                        StatsCard(title: "Entries", value: "234", icon: "doc.text.fill", color: .green)
                        StatsCard(title: "Days", value: "89", icon: "calendar.circle.fill", color: .orange)
                        StatsCard(title: "Media", value: "67", icon: "photo.fill", color: .purple)
                        StatsCard(title: "Words", value: "12.5K", icon: "textformat", color: .red)
                        StatsCard(title: "Streak", value: "7", icon: "flame.fill", color: .yellow)
                    }
                    .padding(.horizontal)
                }
                
                // Edit Button
                Button(action: {
                    showingEditView = true
                }) {
                    Text("Edit")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
        }
        .background(.white)
        .sheet(isPresented: $showingEditView) {
            EditJournalPlaceholder()
        }
    }
}

// Placeholder for edit journal functionality
struct EditJournalPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
                
                Text("Edit Journal")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Journal editing functionality would be implemented here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Edit Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct ListTabView: View {
    @State private var showingEntryView = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // March 2025 Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("March 2025")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    
                    VStack(spacing: 0) {
                        EntryRow(
                            day: "WED",
                            date: "12",
                            title: "Had a wonderful lunch with Emily today.",
                            preview: "It's refreshing to step away from the daily grind and catch up with old friends. We talked about...",
                            time: "6:11 PM CDT",
                            showingEntryView: $showingEntryView
                        )
                        
                        EntryRow(
                            day: "TUE",
                            date: "11",
                            title: "Morning run through the park",
                            preview: "Felt energized after a good night's sleep. The weather was perfect for running and I...",
                            time: "7:45 AM CDT",
                            showingEntryView: $showingEntryView
                        )
                        
                        EntryRow(
                            day: "MON",
                            date: "10",
                            title: "Started reading a new book",
                            preview: "Picked up 'The Midnight Library' from the bookstore. Already hooked by the first chapter...",
                            time: "9:30 PM CDT",
                            showingEntryView: $showingEntryView
                        )
                    }
                }
                
                // February 2025 Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("February 2025")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                    
                    VStack(spacing: 0) {
                        EntryRow(
                            day: "SUN",
                            date: "23",
                            title: "Family dinner at Mom's house",
                            preview: "Great evening with the whole family. Mom made her famous lasagna and we spent hours...",
                            time: "8:15 PM CST",
                            showingEntryView: $showingEntryView
                        )
                        
                        EntryRow(
                            day: "SAT",
                            date: "15",
                            title: "Weekend project completed",
                            preview: "Finally finished organizing the garage. Found so many things I forgot I had...",
                            time: "4:20 PM CST",
                            showingEntryView: $showingEntryView
                        )
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(.white)
        .sheet(isPresented: $showingEntryView) {
            EntryView()
        }
    }
}

struct EntryRow: View {
    let day: String
    let date: String
    let title: String
    let preview: String
    let time: String
    @Binding var showingEntryView: Bool
    
    var body: some View {
        Button(action: {
            showingEntryView = true
        }) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 2) {
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(preview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.white)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(
            Rectangle()
                .fill(.gray.opacity(0.2))
                .frame(height: 0.5)
                .padding(.leading, 64),
            alignment: .bottom
        )
    }
}

struct CalendarTabView: View {
    @State private var selectedJournal: Journal?
    
    var body: some View {
        JournalCalendarView(selectedJournal: $selectedJournal)
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