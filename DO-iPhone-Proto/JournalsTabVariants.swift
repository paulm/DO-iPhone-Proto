import SwiftUI

// MARK: - Journals Tab Variants

struct JournalsTabSettingsStyleView: View {
    @State private var journalViewModel = JournalSelectionViewModel()
    @State private var showingJournalSelector = false
    @State private var showingSettings = false
    @State private var showingSearch = false
    @State private var showingEntryView = false
    
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
                        action: { /* TODO: Calendar action */ }
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

#Preview {
    JournalsTabSettingsStyleView()
}