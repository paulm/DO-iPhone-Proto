import SwiftUI
import MapKit

/// Journals tab view showing journal collections
struct JournalsView: View {
    var body: some View {
        JournalsTabPagedView()
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
    @State private var selectedEntryData: EntryView.EntryData?
    @State private var showingDateDialog = false
    @State private var selectedDateForToday: Date?
    @Environment(\.dismiss) private var dismiss
    let journal: Journal?
    let useLargeListDates: Bool
    
    // Sample entry data
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
                // March 2025 Section
                Section(header: MonthHeaderView(monthYear: "March 2025")) {
                    VStack(spacing: 0) {
                        renderEntries(marchEntries)
                    }
                }
                
                // February 2025 Section
                Section(header: MonthHeaderView(monthYear: "February 2025")) {
                    VStack(spacing: 0) {
                        renderEntries(februaryEntries)
                    }
                }
            }
        }
        .background(.white)
        .sheet(isPresented: $showingEntryView) {
            EntryView(journal: journal, entryData: selectedEntryData, startInEditMode: false)
        }
        .confirmationDialog(
            "",
            isPresented: $showingDateDialog,
            titleVisibility: .hidden
        ) {
            if let date = selectedDateForToday {
                Button(formattedDateForDialog(date)) {
                    openDateInToday(date)
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    private func formattedDateForDialog(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return "Open \(formatter.string(from: date)) in Today"
    }

    private func openDateInToday(_ date: Date) {
        // Update the shared DateManager
        DateManager.shared.selectedDate = date

        // Dismiss current view to return to tabs
        dismiss()
    }

    @ViewBuilder
    private func renderEntries(_ entries: [(day: String, date: String, title: String, preview: String, time: String, month: Int, year: Int)]) -> some View {
        if useLargeListDates {
            // Original mode: show date on each row with dividers
            ForEach(entries, id: \.title) { entry in
                EntryRow(
                    day: entry.day,
                    date: entry.date,
                    title: entry.title,
                    preview: entry.preview,
                    time: entry.time,
                    month: entry.month,
                    year: entry.year,
                    useLargeListDates: useLargeListDates,
                    showDivider: true,
                    onTap: { handleEntryTap(entry) },
                    onDateTap: { date in
                        selectedDateForToday = date
                        showingDateDialog = true
                    }
                )
            }
        } else {
            // New mode: group by date with date headers
            let groupedEntries = Dictionary(grouping: entries) { "\($0.day) \($0.date)" }
            let sortedDates = groupedEntries.keys.sorted { key1, key2 in
                let date1 = groupedEntries[key1]!.first!.date
                let date2 = groupedEntries[key2]!.first!.date
                return Int(date1)! > Int(date2)!
            }

            ForEach(sortedDates, id: \.self) { dateKey in
                let entriesForDate = groupedEntries[dateKey]!
                let firstEntry = entriesForDate.first!
                let isMultiEntry = entriesForDate.count > 1

                // Date header row
                DateHeaderRow(
                    day: firstEntry.day,
                    date: firstEntry.date,
                    month: firstEntry.month,
                    year: firstEntry.year,
                    onDateTap: { date in
                        selectedDateForToday = date
                        showingDateDialog = true
                    }
                )

                // Entry rows for this date (without date column)
                ForEach(Array(entriesForDate.enumerated()), id: \.element.title) { index, entry in
                    let isLastEntry = index == entriesForDate.count - 1
                    let shouldShowDivider = isMultiEntry && !isLastEntry

                    EntryRow(
                        day: entry.day,
                        date: entry.date,
                        title: entry.title,
                        preview: entry.preview,
                        time: entry.time,
                        month: entry.month,
                        year: entry.year,
                        useLargeListDates: useLargeListDates,
                        showDivider: shouldShowDivider,
                        onTap: { handleEntryTap(entry) },
                        onDateTap: nil  // No date tap in compact mode (has DateHeaderRow)
                    )
                }
            }
        }
    }

    private func handleEntryTap(_ entry: (day: String, date: String, title: String, preview: String, time: String, month: Int, year: Int)) {
        // Create date from components
        var components = DateComponents()
        components.year = entry.year
        components.month = entry.month
        components.day = Int(entry.date)
        let date = Calendar.current.date(from: components) ?? Date()

        // Create full content based on the title
        let fullContent = generateFullContent(for: entry.title, preview: entry.preview)

        selectedEntryData = EntryView.EntryData(
            title: entry.title,
            content: fullContent,
            date: date,
            time: entry.time
        )
        showingEntryView = true
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
        } else {
            return title + "\n\n" + preview.replacingOccurrences(of: "...", with: ".")
        }
    }
}

struct MonthHeaderView: View {
    let monthYear: String

    var body: some View {
        HStack {
            Text(monthYear)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemBackground))
        }
    }
}

struct DateHeaderRow: View {
    let day: String
    let date: String
    let month: Int
    let year: Int
    let onDateTap: (Date) -> Void

    private var formattedDate: String {
        let fullDay = dayNameFromAbbreviation(day)
        return "\(date) · \(fullDay)"
    }

    private var dateObject: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = Int(date)
        return Calendar.current.date(from: components) ?? Date()
    }

    private func dayNameFromAbbreviation(_ abbr: String) -> String {
        let days = [
            "MON": "Monday",
            "TUE": "Tuesday",
            "WED": "Wednesday",
            "THU": "Thursday",
            "FRI": "Friday",
            "SAT": "Saturday",
            "SUN": "Sunday"
        ]
        return days[abbr] ?? abbr
    }

    var body: some View {
        Button(action: { onDateTap(dateObject) }) {
            HStack(spacing: 8) {
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 0.5)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EntryRow: View {
    let day: String
    let date: String
    let title: String
    let preview: String
    let time: String
    let month: Int
    let year: Int
    let useLargeListDates: Bool
    let showDivider: Bool
    let onTap: () -> Void
    let onDateTap: ((Date) -> Void)?

    private var dateObject: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = Int(date)
        return Calendar.current.date(from: components) ?? Date()
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Only show date column when useLargeListDates is true
                if useLargeListDates {
                    Button(action: {
                        onDateTap?(dateObject)
                    }) {
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
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text(preview)
                        .font(.subheadline)
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
            Group {
                if showDivider {
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .frame(height: 0.5)
                        // Adjust leading padding based on mode
                        .padding(.leading, useLargeListDates ? 64 : 16)
                }
            },
            alignment: .bottom
        )
    }
}

struct CalendarTabView: View {
    @State private var selectedJournal: Journal?
    var journal: Journal?
    
    var body: some View {
        JournalCalendarView(selectedJournal: $selectedJournal, journalColor: journal?.color)
    }
}

struct MediaTabView: View {
    let mediaViewSize: MediaViewSize
    @State private var availableWidth: CGFloat = UIScreen.main.bounds.width

    private let spacing: CGFloat = 1

    // Static shuffled array - generated only once and shared across all instances
    private static let sampleImages: [String] = {
        var images: [String] = []
        for i in 0..<40 {
            images.append("do-sample - \((i % 22) + 1)")
        }
        return images.shuffled()
    }()

    // Smart column calculation based on available width and target size
    private func calculateColumns(availableWidth: CGFloat) -> Int {
        let targetWidth = mediaViewSize.targetWidth
        // Calculate max columns that fit within target width (use ceil to fit more columns)
        let columns = Int(ceil((availableWidth + spacing) / (targetWidth + spacing)))
        return max(1, columns) // Ensure at least 1 column
    }

    var body: some View {
        let columnCount = calculateColumns(availableWidth: availableWidth)
        let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)

        ScrollView {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(0..<40, id: \.self) { index in
                    GeometryReader { geo in
                        Image(Self.sampleImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.width)
                            .clipped()
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        availableWidth = geo.size.width
                    }
                    .onChange(of: geo.size.width) { oldWidth, newWidth in
                        availableWidth = newWidth
                    }
            }
        )
        .ignoresSafeArea(.all, edges: .horizontal)
    }
}

struct MapTabView: View {
    // Park City, Utah coordinates
    private let parkCityCoordinate = CLLocationCoordinate2D(latitude: 40.6461, longitude: -111.4980)
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        // Full-screen map
        Map(position: $cameraPosition) {
            // Add a marker for Park City
            Marker("Park City", coordinate: parkCityCoordinate)
                .tint(.blue)
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            // Zoom to Park City, Utah
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: parkCityCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            )
        }
    }
}


#Preview {
    JournalsView()
}
