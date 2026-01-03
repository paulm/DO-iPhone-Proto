import SwiftUI

// MARK: - Calendar Data Models

struct CalendarEntry: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let preview: String
    let date: Date
    let journalId: String
    let journalName: String
    let journalColor: Color
    let hasPhoto: Bool
    
    static func == (lhs: CalendarEntry, rhs: CalendarEntry) -> Bool {
        lhs.id == rhs.id
    }
}

@Observable
class CalendarViewModel {
    var selectedDate: Date = Date()
    var currentDisplayedMonth: Date = Date()
    var entries: [CalendarEntry] = []
    var selectedJournal: Journal?
    
    private let calendar = Calendar.current
    
    init() {
        generateSampleData()
    }
    
    // Get entries for a specific date
    func entries(for date: Date) -> [CalendarEntry] {
        let filteredByDate = entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
        
        if let selectedJournal = selectedJournal {
            return filteredByDate.filter { $0.journalId == selectedJournal.id }
        }
        
        return filteredByDate
    }
    
    // Get all years that have entries
    func yearsWithEntries() -> [Int] {
        let years = Set(entries.map { calendar.component(.year, from: $0.date) })
        return Array(years).sorted()
    }
    
    // Get months for a specific year that have entries
    func monthsWithEntries(for year: Int) -> [Date] {
        let yearEntries = entries.filter { 
            calendar.component(.year, from: $0.date) == year 
        }
        
        let months = Set(yearEntries.map { entry in
            let components = calendar.dateComponents([.year, .month], from: entry.date)
            return calendar.date(from: components) ?? Date()
        })
        
        return Array(months).sorted()
    }
    
    // Check if a date has any entries
    func hasEntries(for date: Date) -> Bool {
        return !entries(for: date).isEmpty
    }
    
    // Get entry count for a date
    func entryCount(for date: Date) -> Int {
        return entries(for: date).count
    }
    
    // Navigation helpers
    func moveToNextMonth() {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDisplayedMonth) {
            currentDisplayedMonth = nextMonth
        }
    }
    
    func moveToPreviousMonth() {
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDisplayedMonth) {
            currentDisplayedMonth = previousMonth
        }
    }
    
    func moveToToday() {
        currentDisplayedMonth = Date()
        selectedDate = Date()
    }
}

// MARK: - Sample Data Generation

extension CalendarViewModel {
    private func generateSampleData() {
        let sampleJournals = [
            (name: "Personal", color: Color(hex: "44C0FF"), id: UUID().uuidString),
            (name: "Travel", color: Color(hex: "FF6B6B"), id: UUID().uuidString),
            (name: "Work", color: Color(hex: "4ECDC4"), id: UUID().uuidString),
            (name: "Health", color: Color(hex: "45B7D1"), id: UUID().uuidString)
        ]
        
        let sampleTitles = [
            "Morning Reflection", "Weekend Adventures", "Project Updates", "Family Time",
            "Travel Memories", "Daily Workout", "Reading Notes", "Cooking Experiments",
            "Meeting Highlights", "Evening Thoughts", "Nature Walk", "Creative Session"
        ]
        
        let samplePreviews = [
            "Had a wonderful start to the day with coffee and journaling...",
            "Explored the local hiking trail and discovered amazing views...",
            "Made significant progress on the quarterly project goals...",
            "Spent quality time with family playing board games...",
            "Visited the historic downtown area and tried new restaurants...",
            "Completed a challenging workout session at the gym...",
            "Read an inspiring chapter about productivity and mindfulness...",
            "Tried a new recipe for homemade pasta with fresh herbs..."
        ]
        
        var generatedEntries: [CalendarEntry] = []
        
        // Generate entries for multiple years (2022-2025)
        for year in 2022...2025 {
            // Skip 2023 to create a gap like in the example
            if year == 2023 { continue }
            
            let entriesForYear = year == 2024 ? 40 : 25 // More entries in 2024
            
            for _ in 0..<entriesForYear {
                let randomMonth = Int.random(in: 1...12)
                let daysInMonth = calendar.range(of: .day, in: .month, for: calendar.date(from: DateComponents(year: year, month: randomMonth))!)?.count ?? 30
                let randomDay = Int.random(in: 1...daysInMonth)
                
                let components = DateComponents(year: year, month: randomMonth, day: randomDay)
                if let date = calendar.date(from: components) {
                    let journal = sampleJournals.randomElement()!
                    
                    let entry = CalendarEntry(
                        title: sampleTitles.randomElement()!,
                        preview: samplePreviews.randomElement()!,
                        date: date,
                        journalId: journal.id,
                        journalName: journal.name,
                        journalColor: journal.color,
                        hasPhoto: Bool.random()
                    )
                    
                    generatedEntries.append(entry)
                }
            }
        }
        
        self.entries = generatedEntries.sorted { $0.date < $1.date }
    }
}

// MARK: - Calendar UI Components

struct CalendarHeaderView: View {
    let month: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    let onTodayTap: () -> Void
    var viewModel: CalendarViewModel
    var tintColor: Color?
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var entryCountForMonth: Int {
        let calendar = Calendar.current
        let monthEntries = viewModel.entries.filter { entry in
            calendar.isDate(entry.date, equalTo: month, toGranularity: .month)
        }
        return monthEntries.count
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(monthYearFormatter.string(from: month))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                if entryCountForMonth > 0 {
                    Text("\(entryCountForMonth) entries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onTodayTap) {
                    Text("Today")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(tintColor ?? Color(hex: "44C0FF"))
                }
                .buttonStyle(.plain)
                
                Button(action: onPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                
                Button(action: onNextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let entryCount: Int
    let hasPhoto: Bool
    let onTap: () -> Void
    let tintColor: Color?
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(dayNumber)
                .font(.system(size: 18, weight: isToday ? .bold : .medium))
                .foregroundStyle(textColor)
                .frame(width: 44, height: 44)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    private var textColor: Color {
        let defaultColor = tintColor ?? Color(hex: "44C0FF")
        if !isCurrentMonth {
            return .secondary.opacity(0.6)
        } else if entryCount > 0 {
            return .white
        } else if isSelected {
            return .white
        } else if isToday {
            return defaultColor
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        let defaultColor = tintColor ?? Color(hex: "44C0FF")
        if entryCount > 0 {
            return defaultColor
        } else if isSelected {
            return .gray.opacity(0.8)
        } else if isToday {
            return defaultColor.opacity(0.1)
        } else {
            return .clear
        }
    }
}

struct CalendarWeekdayHeader: View {
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        HStack {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct CalendarGridView: View {
    let month: Date
    var viewModel: CalendarViewModel
    let onDateTap: ((Date) -> Void)?
    let tintColor: Color?
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init(month: Date, viewModel: CalendarViewModel, onDateTap: ((Date) -> Void)? = nil, tintColor: Color? = nil) {
        self.month = month
        self.viewModel = viewModel
        self.onDateTap = onDateTap
        self.tintColor = tintColor
    }
    
    private var monthDates: [Date] {
        guard let _ = calendar.dateInterval(of: .month, for: month),
              let firstOfMonth = calendar.dateInterval(of: .month, for: month)?.start else {
            return []
        }
        
        let firstDayOfWeek = calendar.component(.weekday, from: firstOfMonth) - 1
        let startDate = calendar.date(byAdding: .day, value: -firstDayOfWeek, to: firstOfMonth) ?? firstOfMonth
        
        var dates: [Date] = []
        var currentDate = startDate
        
        // Generate 6 weeks worth of dates (42 days) to cover full month grid
        for _ in 0..<42 {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(monthDates, id: \.self) { date in
                let isCurrentMonth = calendar.isDate(date, equalTo: month, toGranularity: .month)
                let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
                let isToday = calendar.isDateInToday(date)
                let entryCount = viewModel.entryCount(for: date)
                let hasPhoto = viewModel.entries(for: date).contains { $0.hasPhoto }
                
                if isCurrentMonth {
                    CalendarDayView(
                        date: date,
                        isSelected: isSelected,
                        isToday: isToday,
                        isCurrentMonth: isCurrentMonth,
                        entryCount: entryCount,
                        hasPhoto: hasPhoto,
                        onTap: {
                            if let onDateTap = onDateTap {
                                onDateTap(date)
                            } else {
                                viewModel.selectedDate = date
                            }
                        },
                        tintColor: tintColor
                    )
                } else {
                    // Empty space for days from other months
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct CalendarEntryListView: View {
    let entries: [CalendarEntry]
    let selectedDate: Date
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !entries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                LazyVStack(spacing: 12) {
                    ForEach(entries) { entry in
                        CalendarEntryRowView(entry: entry)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Text("No entries for \(dateFormatter.string(from: selectedDate))")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Tap the + button to create your first entry for this day")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
    }
}

struct CalendarEntryRowView: View {
    let entry: CalendarEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Journal color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(entry.journalColor)
                .frame(width: 4, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if entry.hasPhoto {
                        Image(systemName: "photo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(entry.preview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                Text(entry.journalName)
                    .font(.caption2)
                    .foregroundStyle(entry.journalColor)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

// MARK: - Main Calendar View

struct JournalCalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @Binding var selectedJournal: Journal?
    @State private var showingEntryPreview = false
    @State private var showingDayMenu = false
    var journalColor: Color?
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    CalendarWeekdayHeader()
                        .padding(.top, 8)
                    
                    LazyVStack(spacing: 24) {
                        // Generate calendar months for years that have entries
                        ForEach(viewModel.yearsWithEntries(), id: \.self) { year in
                            ForEach(viewModel.monthsWithEntries(for: year), id: \.self) { month in
                                VStack(spacing: 16) {
                                    // Month/Year header
                                    Text(monthYearFormatter.string(from: month))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                        .id("month-\(monthYearFormatter.string(from: month))")
                                    
                                    CalendarGridView(month: month, viewModel: viewModel, onDateTap: { date in
                                        viewModel.selectedDate = date
                                        if viewModel.entryCount(for: date) > 0 {
                                            showingEntryPreview = true
                                        } else {
                                            showingDayMenu = true
                                        }
                                    }, tintColor: journalColor ?? selectedJournal?.color)
                                }
                            }
                            
                            // Year gap indicator if there's a gap
                            if let nextYear = viewModel.yearsWithEntries().first(where: { $0 > year }),
                               nextYear > year + 1 {
                                Text("Gap: \(year + 1) - \(nextYear - 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary.opacity(0.6))
                                    .padding()
                            }
                        }
                    }
                    .padding(.bottom, 100) // Space for FAB
                }
                .onAppear {
                    // Auto-scroll to current month when calendar opens
                    let currentMonth = Date()
                    let currentMonthString = monthYearFormatter.string(from: currentMonth)
                    
                    // Check if current month exists in the calendar
                    let calendar = Calendar.current
                    let currentYear = calendar.component(.year, from: currentMonth)
                    let monthsForCurrentYear = viewModel.monthsWithEntries(for: currentYear)
                    
                    if monthsForCurrentYear.contains(where: { calendar.isDate($0, equalTo: currentMonth, toGranularity: .month) }) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("month-\(currentMonthString)", anchor: .top)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: selectedJournal) { _, newJournal in
            viewModel.selectedJournal = newJournal
        }
        .sheet(isPresented: $showingEntryPreview) {
            CalendarEntryPreviewSheet(
                entries: viewModel.entries(for: viewModel.selectedDate),
                selectedDate: viewModel.selectedDate
            )
        }
        .sheet(isPresented: $showingDayMenu) {
            CalendarDayMenuSheet(
                selectedDate: viewModel.selectedDate,
                onCreateEntry: {
                    showingDayMenu = false
                    // TODO: Navigate to EntryView
                },
                onViewDay: {
                    showingDayMenu = false
                    // TODO: Navigate to day view
                }
            )
        }
    }
}

// MARK: - Calendar Entry Preview Sheet

struct CalendarEntryPreviewSheet: View {
    let entries: [CalendarEntry]
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if !entries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(entries) { entry in
                                CalendarEntryRowView(entry: entry)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("No entries for \(dateFormatter.string(from: selectedDate))")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Tap the + button to create your first entry for this day")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle(dateFormatter.string(from: selectedDate))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Create new entry for this date
                        dismiss()
                    }) {
                        Image(systemName: "plus")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Calendar Day Menu Sheet

struct CalendarDayMenuSheet: View {
    let selectedDate: Date
    let onCreateEntry: () -> Void
    let onViewDay: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("No entries for this day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 32)
                
                VStack(spacing: 16) {
                    MenuActionButton(
                        title: "Create Entry",
                        subtitle: "Start writing for this day",
                        icon: "plus.circle.fill",
                        iconColor: Color(hex: "44C0FF"),
                        action: onCreateEntry
                    )
                    
                    MenuActionButton(
                        title: "View Day",
                        subtitle: "See day overview and options",
                        icon: "calendar.circle.fill",
                        iconColor: .gray,
                        action: onViewDay
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct MenuActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}