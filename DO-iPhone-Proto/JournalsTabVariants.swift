import SwiftUI

// MARK: - Journals Tab Variants

struct JournalsTabSettingsStyleView: View {
    @State private var journalViewModel = JournalSelectionViewModel()
    @State private var showingJournalSelector = false
    @State private var showingSettings = false
    @State private var showingSearch = false
    @State private var showingEntryView = false
    @State private var showingCalendarView = false
    
    var body: some View {
        NavigationStack {
            List {
                // Current Journal Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(journalViewModel.selectedJournal.color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(journalViewModel.selectedJournal.name)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                
                                Text("2020 – 2025")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingJournalSelector = true
                            }) {
                                Text("Switch")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Quick stats
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("0")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Entries")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("0")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Day Streak")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                // Browse Entries Section
                Section("Browse Entries") {
                    JournalsViewRow(
                        icon: "list.bullet",
                        iconColor: .blue,
                        title: "Recent Entries",
                        subtitle: "View all entries chronologically",
                        action: { /* TODO: Recent entries action */ }
                    )
                    
                    JournalsViewRow(
                        icon: "calendar",
                        iconColor: .red,
                        title: "Calendar View",
                        subtitle: "Browse entries by date",
                        action: { showingCalendarView = true }
                    )
                    
                    JournalsViewRow(
                        icon: "magnifyingglass",
                        iconColor: .gray,
                        title: "Search",
                        subtitle: "Find specific entries",
                        action: { showingSearch = true }
                    )
                    
                    JournalsViewRow(
                        icon: "photo.on.rectangle.angled",
                        iconColor: .purple,
                        title: "Media Gallery",
                        subtitle: "Photos and videos from entries",
                        action: { /* TODO: Media gallery action */ }
                    )
                    
                    JournalsViewRow(
                        icon: "location.fill",
                        iconColor: .green,
                        title: "Map View",
                        subtitle: "Entries by location",
                        action: { /* TODO: Map view action */ }
                    )
                }
                
                // Quick Actions Section
                Section("Quick Actions") {
                    JournalsActionRow(
                        icon: "plus.circle.fill",
                        iconColor: .blue,
                        title: "New Entry",
                        subtitle: "Start writing today",
                        action: { showingEntryView = true }
                    )
                    
                    JournalsActionRow(
                        icon: "camera.fill",
                        iconColor: .orange,
                        title: "Photo Entry",
                        subtitle: "Add an image with caption",
                        action: { /* TODO: Photo entry action */ }
                    )
                    
                    JournalsActionRow(
                        icon: "mic.fill",
                        iconColor: .red,
                        title: "Voice Entry",
                        subtitle: "Record audio thoughts",
                        action: { /* TODO: Voice entry action */ }
                    )
                }
                
                // Journal Management Section
                Section("Journal Management") {
                    JournalsManagementRow(
                        icon: "gear",
                        iconColor: .gray,
                        title: "Journal Settings",
                        subtitle: "Edit name, color, and preferences",
                        action: { /* TODO: Journal settings action */ }
                    )
                    
                    JournalsManagementRow(
                        icon: "chart.bar.fill",
                        iconColor: .indigo,
                        title: "Statistics",
                        subtitle: "Writing patterns and insights",
                        action: { /* TODO: Statistics action */ }
                    )
                    
                    JournalsManagementRow(
                        icon: "square.and.arrow.up.fill",
                        iconColor: .teal,
                        title: "Export",
                        subtitle: "Backup or share entries",
                        action: { /* TODO: Export action */ }
                    )
                }
                
                // Recent Entries Preview
                Section("Recent Entries") {
                    ForEach(sampleRecentEntries(), id: \.id) { entry in
                        JournalsRecentEntryRow(
                            entry: entry,
                            action: { showingEntryView = true }
                        )
                    }
                    
                    Button("View All Entries") {
                        // TODO: View all entries action
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Journals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .sheet(isPresented: $showingJournalSelector) {
            JournalSelectorView(viewModel: journalViewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingSearch) {
            SearchPlaceholder()
        }
        .sheet(isPresented: $showingEntryView) {
            EntryView()
        }
        .sheet(isPresented: $showingCalendarView) {
            NavigationStack {
                JournalCalendarView(selectedJournal: .constant(journalViewModel.selectedJournal))
                    .navigationTitle("Calendar")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingCalendarView = false
                            }
                        }
                    }
            }
        }
    }
    
    private func sampleRecentEntries() -> [JournalEntry] {
        return [
            JournalEntry(
                id: "1",
                title: "Had a wonderful lunch with Emily today.",
                preview: "It's refreshing to step away from the daily grind and catch up with old friends. We talked about...",
                date: "WED 12",
                time: "6:11 PM CDT"
            ),
            JournalEntry(
                id: "2",
                title: "Morning run through the park",
                preview: "Felt energized after a good night's sleep. The weather was perfect for running and I...",
                date: "TUE 11",
                time: "7:45 AM CDT"
            ),
            JournalEntry(
                id: "3",
                title: "Started reading a new book",
                preview: "Picked up 'The Midnight Library' from the bookstore. Already hooked by the first chapter...",
                date: "MON 10",
                time: "9:30 PM CDT"
            )
        ]
    }
}

struct JournalEntry {
    let id: String
    let title: String
    let preview: String
    let date: String
    let time: String
}

struct JournalsViewRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with colored background
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JournalsActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with colored background
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JournalsManagementRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with colored background
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JournalsRecentEntryRow: View {
    let entry: JournalEntry
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Date indicator
                VStack(spacing: 2) {
                    Text(String(entry.date.suffix(2)))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(String(entry.date.prefix(3)))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 28, height: 28)
                .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(entry.preview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(entry.time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Placeholder for search functionality
struct SearchPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
                
                Text("Search Entries")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Search functionality would be implemented here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Journals Tab Variant 2

struct JournalsTabVariant2View: View {
    @State private var journalViewModel = JournalSelectionViewModel()
    @State private var showingSettings = false
    @State private var showingAllJournals = false
    @State private var showingEntryView = false
    @State private var selectedViewMode: JournalViewMode = .timeline
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    searchSection
                    recentJournalsSection
                    recentEntriesSection
                    viewSelectorSection
                    statsSection
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Journals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    profileButton
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAllJournals) {
            JournalSelectorView(viewModel: journalViewModel)
        }
        .sheet(isPresented: $showingEntryView) {
            EntryView()
        }
    }
    
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search journals and entries...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var recentJournalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Journals")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("View All") {
                    showingAllJournals = true
                }
                .font(.subheadline)
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sampleRecentJournals(), id: \.id) { journal in
                        RecentJournalCard(journal: journal) {
                            // TODO: Navigate to journal timeline
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Entries")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("View All") {
                    // TODO: View all entries action
                }
                .font(.subheadline)
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding(.horizontal)
            }
            
            VStack(spacing: 0) {
                let entries = sampleRecentEntries()
                ForEach(Array(entries.prefix(3).enumerated()), id: \.offset) { index, entry in
                    RecentEntryCard(entry: entry) {
                        showingEntryView = true
                    }
                    
                    if index < 2 && index < entries.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(.white, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
    
    private var viewSelectorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Browse")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                ForEach(JournalViewMode.allCases, id: \.self) { mode in
                    ViewModeButton(
                        mode: mode,
                        isSelected: selectedViewMode == mode,
                        action: { selectedViewMode = mode }
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.bold)
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
    }
    
    private var profileButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            Circle()
                .fill(.gray.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.gray)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sampleRecentJournals() -> [RecentJournal] {
        return [
            RecentJournal(id: "1", name: "Daily Journal", color: .blue, lastUsed: Date()),
            RecentJournal(id: "2", name: "Travel 2024", color: .green, lastUsed: Date()),
            RecentJournal(id: "3", name: "Work Notes", color: .purple, lastUsed: Date()),
            RecentJournal(id: "4", name: "Dreams", color: .pink, lastUsed: Date())
        ]
    }
    
    private func sampleRecentEntries() -> [JournalEntry] {
        return [
            JournalEntry(
                id: "1",
                title: "Had a wonderful lunch with Emily today.",
                preview: "It's refreshing to step away from the daily grind and catch up with old friends. We talked about...",
                date: "WED 12",
                time: "6:11 PM CDT"
            ),
            JournalEntry(
                id: "2",
                title: "Morning run through the park",
                preview: "Felt energized after a good night's sleep. The weather was perfect for running and I...",
                date: "TUE 11",
                time: "7:45 AM CDT"
            ),
            JournalEntry(
                id: "3",
                title: "Started reading a new book",
                preview: "Picked up 'The Midnight Library' from the bookstore. Already hooked by the first chapter...",
                date: "MON 10",
                time: "9:30 PM CDT"
            )
        ]
    }
}

enum JournalViewMode: String, CaseIterable {
    case timeline = "Timeline"
    case media = "Media"
    case calendar = "Calendar"
    case map = "Map"
    
    var icon: String {
        switch self {
        case .timeline:
            return "list.bullet"
        case .media:
            return "photo.on.rectangle.angled"
        case .calendar:
            return "calendar"
        case .map:
            return "map"
        }
    }
}

struct RecentJournal {
    let id: String
    let name: String
    let color: Color
    let lastUsed: Date
}

struct RecentJournalCard: View {
    let journal: RecentJournal
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(journal.color)
                    .frame(width: 80, height: 60)
                    .overlay(
                        Image(systemName: "book.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    )
                
                Text(journal.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentEntryCard: View {
    let entry: JournalEntry
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Date indicator
                VStack(spacing: 2) {
                    Text(String(entry.date.suffix(2)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(String(entry.date.prefix(3)))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 36, height: 36)
                .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(entry.preview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(entry.time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ViewModeButton: View {
    let mode: JournalViewMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? Color(hex: "44C0FF") : .gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: mode.icon)
                            .font(.title3)
                            .foregroundStyle(isSelected ? .white : .gray)
                    )
                
                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? Color(hex: "44C0FF") : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    JournalsTabSettingsStyleView()
}

// MARK: - Journals Tab Paged Variant

struct JournalsTabPagedView: View {
    @State private var journalViewModel = JournalSelectionViewModel()
    @State private var showingSettings = false
    @State private var viewMode: ViewMode = .list
    @State private var selectedJournal: Journal?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Combined segmented control and buttons row
                HStack(spacing: 12) {
                    // View mode segmented control
                    Picker("View Mode", selection: $viewMode) {
                        Image(systemName: "line.3.horizontal.decrease").tag(ViewMode.compact)
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                        Image(systemName: "square.grid.3x3").tag(ViewMode.grid)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: .infinity)
                    
                    // Compact Add/Edit buttons
                    HStack(spacing: 8) {
                        Button("+ Add") {
                            // TODO: Add new journal action
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.1))
                        )
                        
                        Button("Edit") {
                            // TODO: Edit journals action
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                Divider()
                    .padding(.bottom, 8)
                
                // Journal content based on view mode
                ScrollView {
                    switch viewMode {
                    case .compact:
                        LazyVStack(spacing: 4) {
                            ForEach(Journal.allJournals) { journal in
                                CompactJournalRow(
                                    journal: journal,
                                    isSelected: journal.id == journalViewModel.selectedJournal.id,
                                    onSelect: {
                                        selectedJournal = journal
                                        journalViewModel.selectJournal(journal)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                    case .list:
                        LazyVStack(spacing: 8) {
                            ForEach(Journal.allJournals) { journal in
                                JournalRow(
                                    journal: journal,
                                    isSelected: journal.id == journalViewModel.selectedJournal.id,
                                    onSelect: {
                                        selectedJournal = journal
                                        journalViewModel.selectJournal(journal)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                    case .grid:
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
                            ForEach(Journal.allJournals) { journal in
                                JournalBookView(
                                    journal: journal,
                                    isSelected: journal.id == journalViewModel.selectedJournal.id,
                                    onSelect: {
                                        selectedJournal = journal
                                        journalViewModel.selectJournal(journal)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("Journals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationDestination(item: $selectedJournal) { journal in
                JournalDetailPagedView(journal: journal, journalViewModel: journalViewModel)
            }
        }
        .tint(.white)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct JournalDetailPagedView: View {
    let journal: Journal
    let journalViewModel: JournalSelectionViewModel
    @State private var showingSheet = false
    @State private var showingEntryView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Full screen journal color background
            journal.color
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(journal.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("2020 – 2025")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // White FAB button
                    Button(action: {
                        showingEntryView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(journal.color)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                    .padding(.trailing, 18)
                }
                .padding(.leading, 18)
                .padding(.top, 100)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingSheet = true
            }
        }
        .onChange(of: showingSheet) { _, newValue in
            if !newValue {
                // When sheet is dismissed, navigate back
                dismiss()
            }
        }
        .overlay(
            PagedNativeSheetView(isPresented: $showingSheet, journal: journal)
        )
        .sheet(isPresented: $showingEntryView) {
            EntryView()
        }
    }
}

// MARK: - Paged UIKit Sheet Wrapper

struct PagedNativeSheetView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let journal: Journal
    
    func makeUIViewController(context: Context) -> UIViewController {
        let hostingController = UIViewController()
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let sheetContent = PagedJournalSheetContent(journal: journal)
            let contentHostingController = UIHostingController(rootView: sheetContent)
            
            if let sheet = contentHostingController.sheetPresentationController {
                // Configure the sheet
                sheet.detents = [
                    .custom { context in
                        // 230pt from top
                        return context.maximumDetentValue - 200
                    },
                    .large()
                ]
                sheet.selectedDetentIdentifier = .init("custom")
                sheet.largestUndimmedDetentIdentifier = .large
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.delegate = context.coordinator
            }
            
            contentHostingController.isModalInPresentation = false
            uiViewController.present(contentHostingController, animated: true)
        } else if !isPresented && uiViewController.presentedViewController != nil {
            uiViewController.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        @Binding var isPresented: Bool
        
        init(isPresented: Binding<Bool>) {
            self._isPresented = isPresented
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            isPresented = false
        }
    }
}

// MARK: - Paged Sheet Content

struct PagedJournalSheetContent: View {
    let journal: Journal
    @State private var selectedTab = 1
    @State private var showingEntryView = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented control
            Picker("View", selection: $selectedTab) {
                Text("Cover").tag(0)
                Text("List").tag(1)
                Text("Calendar").tag(2)
                Text("Media").tag(3)
                Text("Map").tag(4)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 22)  // Added 10pt extra spacing (12 + 10)
            .padding(.bottom, 12)
            .background(Color(UIColor.systemBackground))
            
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
        .sheet(isPresented: $showingEntryView) {
            EntryView()
        }
    }
}

#Preview("Variant 2") {
    JournalsTabVariant2View()
}

#Preview("Paged") {
    JournalsTabPagedView()
}
