import SwiftUI

struct SearchResultsView: View {
    @Binding var searchText: String
    @State private var selectedScope = SearchScope.all
    @State private var recentSearches: [String] = ["Morning reflections", "Travel", "Coffee", "Meeting notes", "Weekend plans"]
    @State private var showingFilters = false
    
    enum SearchScope: String, CaseIterable {
        case all = "All"
        case entries = "Entries"
        case journals = "Journals"
        case media = "Media"
        case places = "Places"
        
        var systemImage: String {
            switch self {
            case .all: return "magnifyingglass"
            case .entries: return "doc.text"
            case .journals: return "book"
            case .media: return "photo"
            case .places: return "location"
            }
        }
    }
    
    private var hasSearchText: Bool {
        !searchText.isEmpty
    }
    
    // Sample search results
    private var searchResults: [(title: String, subtitle: String, type: SearchScope, date: Date)] {
        guard hasSearchText else { return [] }
        
        // Mock search results based on search text
        return [
            ("Morning coffee ritual", "Started the day with a perfect cup of coffee...", .entries, Date().addingTimeInterval(-86400)),
            ("Weekend at the beach", "Beautiful sunset photos from our beach trip...", .media, Date().addingTimeInterval(-172800)),
            ("Team meeting notes", "Discussed the Q4 roadmap and upcoming deadlines...", .entries, Date().addingTimeInterval(-259200)),
            ("Favorite coffee shop", "The new place downtown has amazing atmosphere...", .places, Date().addingTimeInterval(-345600)),
            ("Travel Journal", "Planning our upcoming trip to Japan...", .journals, Date().addingTimeInterval(-432000))
        ].filter { item in
            selectedScope == .all || item.type == selectedScope
        }
    }
    
    var body: some View {
        List {
                if !hasSearchText {
                    // Recent searches section
                    if !recentSearches.isEmpty {
                        Section {
                            ForEach(recentSearches, id: \.self) { search in
                                Button(action: {
                                    searchText = search
                                }) {
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.secondary)
                                            .frame(width: 20)
                                        
                                        Text(search)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } header: {
                            HStack {
                                Text("Recent")
                                    .textCase(.uppercase)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Button("Clear") {
                                    recentSearches.removeAll()
                                }
                                .font(.caption)
                                .textCase(.uppercase)
                            }
                        }
                    }
                    
                    // Suggested searches section
                    Section("Suggested") {
                        SuggestedSearchRow(icon: "calendar", text: "This week", color: .blue)
                        SuggestedSearchRow(icon: "photo", text: "Photos from today", color: .green)
                        SuggestedSearchRow(icon: "location", text: "Places visited", color: .orange)
                        SuggestedSearchRow(icon: "star", text: "Favorites", color: .yellow)
                    }
                } else {
                    // Search results
                    if searchResults.isEmpty {
                        ContentUnavailableView(
                            "No Results",
                            systemImage: "magnifyingglass",
                            description: Text("No results found for '\(searchText)'")
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(searchResults, id: \.title) { result in
                            SearchResultRow(
                                title: result.title,
                                subtitle: result.subtitle,
                                type: result.type,
                                date: result.date
                            )
                        }
                    }
                }
        }
        .searchScopes($selectedScope) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Label(scope.rawValue, systemImage: scope.systemImage)
                    .tag(scope)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingFilters = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .symbolVariant(showingFilters ? .fill : .none)
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            SearchFiltersView()
        }
    }
}

struct SuggestedSearchRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct SearchResultRow: View {
    let title: String
    let subtitle: String
    let type: SearchResultsView.SearchScope
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: type.systemImage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

struct SearchFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dateRange = DateRange.allTime
    @State private var includeEntries = true
    @State private var includeMedia = true
    @State private var includePlaces = true
    @State private var includeJournals = true
    @State private var sortBy = SortOption.newest
    
    enum DateRange: String, CaseIterable {
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case thisYear = "This Year"
        case allTime = "All Time"
    }
    
    enum SortOption: String, CaseIterable {
        case newest = "Newest First"
        case oldest = "Oldest First"
        case relevance = "Relevance"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Date Range") {
                    Picker("Date Range", selection: $dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Include") {
                    Toggle("Entries", isOn: $includeEntries)
                    Toggle("Media", isOn: $includeMedia)
                    Toggle("Places", isOn: $includePlaces)
                    Toggle("Journals", isOn: $includeJournals)
                }
                
                Section("Sort By") {
                    Picker("Sort By", selection: $sortBy) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Search Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        // Reset all filters
                        dateRange = .allTime
                        includeEntries = true
                        includeMedia = true
                        includePlaces = true
                        includeJournals = true
                        sortBy = .newest
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SearchResultsView(searchText: .constant(""))
}