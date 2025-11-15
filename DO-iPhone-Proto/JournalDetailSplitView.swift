import SwiftUI

// MARK: - Journal View Mode
enum JournalViewMode: String, CaseIterable {
    case cover = "Cover"
    case list = "List"
    case calendar = "Calendar"
    case media = "Media"
    case map = "Map"
    
    var icon: String {
        switch self {
        case .cover:
            return "photo"
        case .list:
            return "list.bullet"
        case .calendar:
            return "calendar"
        case .media:
            return "photo.on.rectangle.angled"
        case .map:
            return "map"
        }
    }
}

// MARK: - Two-Column Journal Detail View for iPad
struct JournalDetailSplitView: View {
    @Binding var selectedJournal: Journal?
    @Binding var selectedEntry: EntryView.EntryData?
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    @State private var viewMode: JournalViewMode = .list
    @State private var showingEntryView = false
    @State private var selectedEntryData: EntryView.EntryData?
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Content - Entry timeline for selected journal
            if let journal = selectedJournal {
                VStack(spacing: 0) {
                    // Journal Header with color background and integrated segmented control
                    VStack(spacing: 0) {
                        // Colored header background with journal info
                        LinearGradient(
                            colors: [
                                journal.color.opacity(0.9),
                                journal.color.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 100)
                        .overlay(
                            VStack(spacing: 6) {
                                Text(journal.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("2020 - 2025")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                if let count = journal.entryCount {
                                    Text("\(count) entries")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.top, 8)
                        )
                        
                        // Segmented control section with material background
                        VStack(spacing: 0) {
                            Picker("View Mode", selection: $viewMode) {
                                ForEach(JournalViewMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue)
                                        .tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        .background(.ultraThinMaterial)
                        
                        Divider()
                    }
                    
                    // View content based on selected mode - reusing iPhone components
                    Group {
                        switch viewMode {
                        case .cover:
                            // Reuse the iPhone CoverTabView
                            CoverTabView()
                                .background(Color(UIColor.systemBackground))
                        case .list:
                            // Custom ListTabView that updates selectedEntry binding
                            IPadListTabView(journal: journal, selectedEntry: $selectedEntry)
                                .background(Color(UIColor.systemBackground))
                        case .calendar:
                            // Use existing CalendarTabView from JournalsView
                            CalendarTabView()
                                .background(Color(UIColor.systemBackground))
                        case .media:
                            // Use existing MediaTabView from JournalsView
                            MediaTabView()
                                .background(Color(UIColor.systemBackground))
                        case .map:
                            // Use existing MapTabView from JournalsView
                            MapTabView()
                                .background(Color(UIColor.systemBackground))
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView(
                    "Select a Journal",
                    systemImage: "book.closed",
                    description: Text("Choose a journal from the sidebar to view entries")
                )
            }
        } detail: {
            // Detail - Selected entry content
            if let entry = selectedEntry {
                EntryDetailView(
                    entryData: entry,
                    journal: selectedJournal
                )
            } else {
                ContentUnavailableView(
                    "Select an Entry",
                    systemImage: "doc.text",
                    description: Text("Choose an entry to read")
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - iPad-specific List Tab View
struct IPadListTabView: View {
    let journal: Journal?
    @Binding var selectedEntry: EntryView.EntryData?
    
    // Sample entry data (same as in ListTabView)
    private let marchEntries = [
        (day: "WED", date: "12", title: "Had a wonderful lunch with Emily today.",
         preview: "It's refreshing to step away from the daily grind and catch up with old friends. We talked about...",
         time: "6:11 PM CDT", month: 3, year: 2025),
        (day: "WED", date: "12", title: "Afternoon walk in the sunshine",
         preview: "After lunch, I took a long walk around the neighborhood. The weather was perfect and it felt great to...",
         time: "2:30 PM CDT", month: 3, year: 2025),
        (day: "TUE", date: "11", title: "Morning run through the park",
         preview: "Felt energized after a good night's sleep. The weather was perfect for running and I...",
         time: "7:45 AM CDT", month: 3, year: 2025),
        (day: "MON", date: "10", title: "Started reading a new book",
         preview: "Picked up 'The Midnight Library' from the bookstore. Already hooked by the first chapter...",
         time: "9:30 PM CDT", month: 3, year: 2025)
    ]
    
    private let februaryEntries = [
        (day: "SUN", date: "23", title: "Family dinner at Mom's house",
         preview: "Great evening with the whole family. Mom made her famous lasagna and we spent hours...",
         time: "8:15 PM CST", month: 2, year: 2025),
        (day: "SAT", date: "15", title: "Weekend project completed",
         preview: "Finally finished organizing the garage. Found so many things I forgot I had...",
         time: "4:20 PM CST", month: 2, year: 2025)
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                // Small top padding
                Color.clear.frame(height: 20)
                
                // March 2025 Section
                Section(header: MonthHeaderView(monthYear: "March 2025")) {
                    VStack(spacing: 0) {
                        ForEach(marchEntries, id: \.title) { entry in
                            EntryRow(
                                day: entry.day,
                                date: entry.date,
                                title: entry.title,
                                preview: entry.preview,
                                time: entry.time,
                                month: entry.month,
                                year: entry.year,
                                useLargeListDates: false,
                                showDivider: false,
                                onTap: {
                                    selectEntry(entry)
                                },
                                onDateTap: nil
                            )
                            .background(
                                selectedEntry?.title == entry.title ?
                                Color.accentColor.opacity(0.1) : Color.clear
                            )
                        }
                    }
                }
                
                // February 2025 Section
                Section(header: MonthHeaderView(monthYear: "February 2025")) {
                    VStack(spacing: 0) {
                        ForEach(februaryEntries, id: \.title) { entry in
                            EntryRow(
                                day: entry.day,
                                date: entry.date,
                                title: entry.title,
                                preview: entry.preview,
                                time: entry.time,
                                month: entry.month,
                                year: entry.year,
                                useLargeListDates: false,
                                showDivider: false,
                                onTap: {
                                    selectEntry(entry)
                                },
                                onDateTap: nil
                            )
                            .background(
                                selectedEntry?.title == entry.title ?
                                Color.accentColor.opacity(0.1) : Color.clear
                            )
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(.white)
    }
    
    private func selectEntry(_ entry: (day: String, date: String, title: String, preview: String, time: String, month: Int, year: Int)) {
        // Create date from components
        var components = DateComponents()
        components.year = entry.year
        components.month = entry.month
        components.day = Int(entry.date)
        let date = Calendar.current.date(from: components) ?? Date()
        
        // Create full content based on the title
        let fullContent = generateFullContent(for: entry.title, preview: entry.preview)
        
        // Update the binding to show in detail column
        selectedEntry = EntryView.EntryData(
            title: entry.title,
            content: fullContent,
            date: date,
            time: entry.time
        )
    }
    
    private func generateFullContent(for title: String, preview: String) -> String {
        if title.contains("lunch with Emily") {
            return """
Had a wonderful lunch with Emily today.

It's refreshing to step away from the daily grind and catch up with old friends. We talked about her new job at the tech startup, my recent travels, and how much has changed since college. Time flies but good friendships remain constant.

We went to that little Italian place downtown that we used to love. The food was just as good as I remembered - I had the seafood linguine and Emily got her usual margherita pizza. We split a tiramisu for dessert, just like old times.

The best part was just being able to talk without any agenda. No work calls, no rushing to the next meeting. Just two friends catching up over good food and wine. We laughed about old memories and made plans to not let so much time pass before our next get-together.

Days like this remind me how important it is to nurture these relationships. Work will always be there, but friends like Emily are rare and precious.
"""
        } else if title.contains("Morning run") {
            return """
Morning run through the park

Felt energized after a good night's sleep. The weather was perfect for running and I managed to do my full 5K route without stopping. The park was peaceful at this early hour, with just a few other runners and dog walkers out.

I love how the morning light filters through the trees along the main path. There's something magical about being out there when the day is just beginning. My pace was steady - not trying to break any records, just enjoying the movement and the fresh air.

Saw the usual group of older folks doing tai chi by the pond. Always makes me smile. There's such a nice community feel to the park in the mornings. Everyone waves or nods as they pass by.

Finished with some stretching by the fountain. Feeling ready to tackle whatever the day brings!
"""
        } else if title.contains("Afternoon walk") {
            return """
Afternoon walk in the sunshine

After lunch, I took a long walk around the neighborhood. The weather was perfect and it felt great to be outside. Sometimes the simplest activities bring the most joy.

I noticed all the spring flowers starting to bloom - tulips, daffodils, and cherry blossoms. The fresh air and gentle exercise helped clear my mind and gave me time to think about the day's events.

Walking without any particular destination in mind is one of my favorite ways to relax. No agenda, no rushing, just me and my thoughts.
"""
        } else if title.contains("Started reading") {
            return """
Started reading a new book

Picked up 'The Midnight Library' from the bookstore. Already hooked by the first chapter. The premise is fascinating - a library between life and death where each book represents a different life you could have lived.

The writing style is engaging and the philosophical questions it raises are thought-provoking. I found myself stopping every few pages to think about my own choices and the paths not taken.

Spent the whole evening curled up on the couch, completely absorbed. It's been a while since a book grabbed me like this from the very beginning. Looking forward to seeing where the story goes.
"""
        } else if title.contains("Family dinner") {
            return """
Family dinner at Mom's house

Great evening with the whole family. Mom made her famous lasagna and we spent hours around the dinner table catching up. My brother brought his new girlfriend and she fit right in with our chaotic family dynamic.

The kids were running around playing while the adults lingered over coffee and dessert. Dad told his usual stories that we've all heard a hundred times but still laugh at. Mom kept trying to send everyone home with leftovers.

These gatherings are becoming less frequent as everyone gets busier, which makes them even more special. There's something comforting about being back in my childhood home with all the familiar sounds and smells.

We ended the night looking through old photo albums, laughing at our questionable fashion choices from the 90s. Family is everything.
"""
        } else {
            return title + "\n\n" + preview.replacingOccurrences(of: "...", with: ".")
        }
    }
}

#Preview {
    JournalDetailSplitView(
        selectedJournal: .constant(Journal(
            name: "Personal Journal",
            color: Color(hex: "44C0FF"),
            entryCount: 42
        )),
        selectedEntry: .constant(nil)
    )
}