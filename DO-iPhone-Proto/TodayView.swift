import SwiftUI
import TipKit

// MARK: - Bio Tip Definition
struct BioCompletionTip: Tip {
    var title: Text {
        Text("Complete Your Bio")
    }
    
    var message: Text? {
        Text("Add personal details to enhance your daily chat experience with AI-powered insights.")
    }
    
    var image: Image? {
        Image(systemName: "person.text.rectangle")
    }
    
    var actions: [Action] {
        [
            Action(id: "fill-bio", title: "Fill Bio Now"),
            Action(id: "later", title: "Maybe Later")
        ]
    }
}

/// Today tab view
struct TodayView: View {
    @State private var showingSettings = false
    @State private var showingDatePicker = false
    @State private var showingDailySurvey = false
    @State private var showingMoments = false
    @State private var showingTrackers = false
    @State private var selectedDate = Date()
    @State private var surveyCompleted = false
    
    // Trackers state
    @State private var moodRating = 0
    @State private var energyRating = 0
    @State private var stressRating = 0
    @State private var foodInput = ""
    @State private var prioritiesInput = ""
    @State private var mediaInput = ""
    @State private var peopleInput = ""
    
    // Moments state
    @State private var selectedLocations: Set<String> = []
    @State private var selectedEvents: Set<String> = []
    @State private var selectedPhotos: Set<String> = []
    @State private var selectedHealth: Set<String> = []
    
    private var dateRange: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        let today = Date()
        
        // Calculate how many dates we need based on screen width
        // Assuming we want to fit as many as possible in 3 rows
        let approximateWidth = UIScreen.main.bounds.width - 40
        let columnsPerRow = Int((approximateWidth + DatePickerConstants.spacing) / (DatePickerConstants.circleSize + DatePickerConstants.spacing))
        let totalDates = columnsPerRow * 3
        
        // Calculate the starting date to ensure we end 4 days in the future
        let endDate = 4
        let startDate = endDate - totalDates + 1
        
        // Generate dates from calculated start to 4 days in the future
        for i in startDate...endDate {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    var body: some View {
        TodayViewV1i2(
            showingSettings: $showingSettings,
            showingDatePicker: $showingDatePicker,
            showingDailySurvey: $showingDailySurvey,
            showingMoments: $showingMoments,
            showingTrackers: $showingTrackers,
            selectedDate: $selectedDate,
            surveyCompleted: $surveyCompleted,
            moodRating: $moodRating,
            energyRating: $energyRating,
            stressRating: $stressRating,
            foodInput: $foodInput,
            prioritiesInput: $prioritiesInput,
            mediaInput: $mediaInput,
            peopleInput: $peopleInput,
            selectedLocations: $selectedLocations,
            selectedEvents: $selectedEvents,
            selectedPhotos: $selectedPhotos,
            selectedHealth: $selectedHealth
        )
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingDatePicker = false
                        }
                    }
                })
            }
        }
        .sheet(isPresented: $showingDailySurvey) {
            DailySurveyView(onCompletion: {
                surveyCompleted = true
            })
        }
        .sheet(isPresented: $showingMoments) {
            MomentsView(
                selectedLocations: $selectedLocations,
                selectedEvents: $selectedEvents,
                selectedPhotos: $selectedPhotos,
                selectedHealth: $selectedHealth
            )
        }
        .sheet(isPresented: $showingTrackers) {
            TrackerView(
                moodRating: $moodRating,
                energyRating: $energyRating,
                stressRating: $stressRating,
                foodInput: $foodInput,
                prioritiesInput: $prioritiesInput,
                mediaInput: $mediaInput,
                peopleInput: $peopleInput
            )
        }
    }
}

// MARK: - Date Picker Components
private struct DatePickerConstants {
    static let circleSize: CGFloat = 18
    static let spacing: CGFloat = 12
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DatePickerGrid: View {
    let dates: [Date]
    @Binding var selectedDate: Date
    
    @State private var availableWidth: CGFloat = UIScreen.main.bounds.width - 40 // Approximate initial width
    
    // Static storage for completed dates - generated once and reused
    private static let completedDates: Set<Date> = {
        let calendar = Calendar.current
        let today = Date()
        var completed = Set<Date>()
        
        // Get past 10 days (excluding today)
        var pastDates: [Date] = []
        for i in 1...10 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                pastDates.append(calendar.startOfDay(for: date))
            }
        }
        
        // Randomly select 6 of them
        let shuffled = pastDates.shuffled()
        for i in 0..<min(6, shuffled.count) {
            completed.insert(shuffled[i])
        }
        
        return completed
    }()
    
    init(dates: [Date], selectedDate: Binding<Date>) {
        self.dates = dates
        self._selectedDate = selectedDate
    }
    
    private func isDateCompleted(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: date)
        return Self.completedDates.contains(dateStart)
    }
    
    private var columns: Int {
        guard availableWidth > 0 else { return 10 } // Default to 10 columns if width not yet calculated
        let totalCircleWidth = DatePickerConstants.circleSize + DatePickerConstants.spacing
        let possibleColumns = Int((availableWidth + DatePickerConstants.spacing) / totalCircleWidth)
        return max(1, possibleColumns)
    }
    
    private var rows: [[Date]] {
        var result: [[Date]] = []
        var currentRow: [Date] = []
        
        // Force exactly 3 rows
        let datesPerRow = (dates.count + 2) / 3 // Round up division
        
        for (index, date) in dates.enumerated() {
            currentRow.append(date)
            if currentRow.count == datesPerRow || index == dates.count - 1 {
                result.append(currentRow)
                currentRow = []
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: DatePickerConstants.spacing) {
            // Streak and Today text
            HStack(spacing: 0) {
                Text("2 Day Streak")
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.7))
                
                Text(" • ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Button(action: {
                    selectedDate = Date()
                }) {
                    Text("Today")
                        .font(.caption)
                        .foregroundStyle(Calendar.current.isDateInToday(selectedDate) ? .secondary : Color(hex: "44C0FF"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)
            
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: DatePickerConstants.spacing) {
                    ForEach(Array(row.enumerated()), id: \.offset) { index, date in
                        DateCircle(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(date),
                            isFuture: date > Date(),
                            isCompleted: isDateCompleted(date),
                            onTap: {
                                selectedDate = date
                            }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size.width)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { width in
            if width > 0 {
                availableWidth = width
            }
        }
    }
}

struct DateCircle: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isFuture: Bool
    let isCompleted: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var circleColor: Color {
        if isSelected {
            return Color(hex: "44C0FF") // Day One Blue for selected
        } else if isToday {
            return .gray.opacity(0.3) // Light gray for today
        } else if isCompleted {
            return Color(hex: "333B40") // Dark gray for completed chat days
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    private var textColor: Color {
        if isSelected || isCompleted {
            return .white
        } else if isToday {
            return .primary // Dark text for light gray background
        } else if isFuture {
            return .secondary
        } else {
            return .primary
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(circleColor)
                .frame(width: DatePickerConstants.circleSize, height: DatePickerConstants.circleSize)
                .overlay(
                    Text(dayNumber)
                        .font(.system(size: 8))
                        .fontWeight(.medium)
                        .foregroundStyle(textColor)
                )
                .opacity(isFuture && !isSelected ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// V1i2 Today tab layout - Enhanced with Daily Activities section
struct TodayViewV1i2: View {
    @Binding var showingSettings: Bool
    @Binding var showingDatePicker: Bool
    @Binding var showingDailySurvey: Bool
    @Binding var showingMoments: Bool
    @Binding var showingTrackers: Bool
    @Binding var selectedDate: Date
    @Binding var surveyCompleted: Bool
    
    // Create an instance of the bio tip
    private let bioTip = BioCompletionTip()
    
    @State private var showingDailyChat = false
    @State private var chatCompleted = false
    @State private var openChatInLogMode = false
    @State private var chatMessageCount = 0
    @State private var momentsCompleted = false
    @State private var trackersCompleted = false
    @State private var showingProfileMenu = false
    @State private var isGeneratingPreview = false
    @State private var summaryGenerated = false
    @State private var hasInteractedWithChat = false
    
    // Today Insights state
    @State private var showingWeather = false
    @State private var showingEntries = false
    @State private var showingOnThisDay = false
    @State private var showingPreviewEntry = false
    @State private var entryCreated = false
    @State private var showingEntry = false
    @State private var showingBioView = false
    
    // Show/hide toggles for Daily Activities
    @State private var showDatePickerGrid = true
    @State private var showDateNavigation = true
    @State private var showChat = false
    @State private var showChatSimple = true
    @State private var showMoments = false
    @State private var showTrackers = false
    @State private var showInsights = false
    @State private var showBioTooltip = false
    @AppStorage("showChatFAB") private var showChatFAB = true
    @AppStorage("showEntryFAB") private var showEntryFAB = false
    @Binding var moodRating: Int
    @Binding var energyRating: Int
    @Binding var stressRating: Int
    @Binding var foodInput: String
    @Binding var prioritiesInput: String
    @Binding var mediaInput: String
    @Binding var peopleInput: String
    @Binding var selectedLocations: Set<String>
    @Binding var selectedEvents: Set<String>
    @Binding var selectedPhotos: Set<String>
    @Binding var selectedHealth: Set<String>
    
    private var dateRange: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        let today = Date()
        
        // Calculate how many dates we need based on screen width
        // Assuming we want to fit as many as possible in 3 rows
        let approximateWidth = UIScreen.main.bounds.width - 40
        let columnsPerRow = Int((approximateWidth + DatePickerConstants.spacing) / (DatePickerConstants.circleSize + DatePickerConstants.spacing))
        let totalDates = columnsPerRow * 3
        
        // Calculate the starting date to ensure we end 4 days in the future
        let endDate = 4
        let startDate = endDate - totalDates + 1
        
        // Generate dates from calculated start to 4 days in the future
        for i in startDate...endDate {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private var momentsSummaryText: String {
        let totalMoments = selectedLocations.count + selectedEvents.count + selectedPhotos.count
        if totalMoments == 0 {
            return "No moments selected"
        } else {
            return "\(totalMoments) moment\(totalMoments == 1 ? "" : "s") selected"
        }
    }
    
    private var trackersSummaryText: String {
        let completedCount = [
            moodRating > 0 ? 1 : 0,
            energyRating > 0 ? 1 : 0,
            stressRating > 0 ? 1 : 0,
            !foodInput.isEmpty ? 1 : 0,
            !prioritiesInput.isEmpty ? 1 : 0,
            !mediaInput.isEmpty ? 1 : 0,
            !peopleInput.isEmpty ? 1 : 0
        ].reduce(0, +)
        
        return "\(completedCount) of 7 completed"
    }
    
    private var hasSelectedMoments: Bool {
        !selectedLocations.isEmpty || !selectedEvents.isEmpty || !selectedPhotos.isEmpty || !selectedHealth.isEmpty
    }
    
    private var momentsCountText: String {
        let totalSelected = selectedLocations.count + selectedEvents.count + selectedPhotos.count + selectedHealth.count
        if totalSelected == 0 {
            return "Capture meaningful moments from your day"
        } else {
            return "\(totalSelected) selected."
        }
    }
    
    private var hasTrackerData: Bool {
        moodRating > 0 || energyRating > 0 || stressRating > 0 || 
        !foodInput.isEmpty || !prioritiesInput.isEmpty || !mediaInput.isEmpty || !peopleInput.isEmpty
    }
    
    private var currentDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private var dailyChatTitle: String {
        return "\(currentDayName) Chat"
    }
    
    private var chatInteractionsText: String {
        if chatMessageCount == 0 {
            return ""
        }
        return "\(chatMessageCount) interaction\(chatMessageCount == 1 ? "" : "s")."
    }
    
    private var chatSubtitleWithResume: String {
        let interactionCount = Int.random(in: 1...55)
        return "\(interactionCount) interactions Resume"
    }
    
    private func relativeDateText(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            if days > 0 {
                if days < 7 {
                    return "\(days) day\(days == 1 ? "" : "s") ago"
                } else if days < 14 {
                    return "1 week ago"
                } else if days < 30 {
                    return "\(days / 7) week\(days / 7 == 1 ? "" : "s") ago"
                } else if days < 60 {
                    return "1 month ago"
                } else {
                    return "\(days / 30) month\(days / 30 == 1 ? "" : "s") ago"
                }
            } else {
                let futureDays = abs(days)
                if futureDays < 7 {
                    return "in \(futureDays) day\(futureDays == 1 ? "" : "s")"
                } else if futureDays < 14 {
                    return "in 1 week"
                } else {
                    return "in \(futureDays / 7) week\(futureDays / 7 == 1 ? "" : "s")"
                }
            }
        }
    }
    
    private func navigateToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = newDate
            }
        }
    }
    
    private func navigateToNextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = newDate
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header section with gray background
            VStack(spacing: 0) {
                // Header with profile button
                HStack {
                    Spacer()
                    
                    Menu {
                        Button("Settings") {
                            showingSettings = true
                        }
                        
                        Section("Show in Today") {
                            Button {
                                showDatePickerGrid.toggle()
                            } label: {
                                HStack {
                                    Text("Date Picker Grid")
                                    if showDatePickerGrid {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showDateNavigation.toggle()
                            } label: {
                                HStack {
                                    Text("Date Navigation")
                                    if showDateNavigation {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showChat.toggle()
                            } label: {
                                HStack {
                                    Text("Daily Chat")
                                    if showChat {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showMoments.toggle()
                            } label: {
                                HStack {
                                    Text("Daily Moments")
                                    if showMoments {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showTrackers.toggle()
                            } label: {
                                HStack {
                                    Text("Daily Trackers")
                                    if showTrackers {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showInsights.toggle()
                            } label: {
                                HStack {
                                    Text("Today Insights")
                                    if showInsights {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showBioTooltip.toggle()
                            } label: {
                                HStack {
                                    Text("Bio ToolTip")
                                    if showBioTooltip {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showChatFAB.toggle()
                            } label: {
                                HStack {
                                    Text("Chat FAB")
                                    if showChatFAB {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showEntryFAB.toggle()
                            } label: {
                                HStack {
                                    Text("Entry FAB")
                                    if showEntryFAB {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.clear))
                    }
                    .accessibilityLabel("Profile Menu")
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Content with Daily Activities
            List {
                // Date picker grid at top of scrollable content
                if showDatePickerGrid {
                    DatePickerGrid(
                        dates: dateRange,
                        selectedDate: $selectedDate
                    )
                    .background(Color.clear)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                
                // Spacer divider between Date Picker Grid and Date Navigation
                if showDatePickerGrid && showDateNavigation {
                    Divider()
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                }
                
                // Date navigation section (no section header)
                if showDateNavigation {
                    HStack {
                    // Left arrow
                    Button(action: navigateToPreviousDay) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    // Center content - tappable to open date picker
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        VStack(spacing: 2) {
                            Text(selectedDate, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            
                            Text(relativeDateText(for: selectedDate))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Right arrow
                    Button(action: navigateToNextDay) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 16)
                }
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                }
                
                // Daily Entry section (only shown after entry is created)
                if entryCreated {
                    Section("Daily Entry") {
                        Button(action: {
                            showingEntry = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Morning Reflections and Evening Plans")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("Today I started with my usual morning routine, feeling energized and ready to tackle the day ahead. I spent some time thinking about my work goals and how I want to approach the various projects I have on my plate. The conversation helped me organize my thoughts around what's most important right now.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Daily Chat Section
                if showChat {
                    Section("Daily Chat") {
                        TodayActivityRowWithChatResumeV2(
                            icon: "bubble.left.and.bubble.right.fill",
                            iconColor: .blue,
                            title: dailyChatTitle,
                            subtitle: chatMessageCount > 0 ? chatInteractionsText : "",
                            isCompleted: chatCompleted,
                            showResume: chatCompleted,
                            showDefaultContent: !chatCompleted,
                            action: { showingDailyChat = true },
                            resumeAction: { showingDailyChat = true },
                            beginChatAction: { 
                                openChatInLogMode = false
                                showingDailyChat = true 
                            },
                            logHighlightsAction: { 
                                openChatInLogMode = true
                                showingDailyChat = true
                            }
                        )
                        
                        // View Summary row when chat has been interacted with
                        if chatCompleted {
                            Button(action: {
                                showingPreviewEntry = true
                            }) {
                                HStack(spacing: 12) {
                                    // Icon with colored background
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "44C0FF"))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "doc.text")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundStyle(.white)
                                        )
                                    
                                    // Content
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Summary")
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    Spacer()
                                    
                                    // View with chevron
                                    HStack(spacing: 4) {
                                        Text("View")
                                            .font(.subheadline)
                                            .foregroundStyle(Color(hex: "44C0FF"))
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Daily Moments Section
                if showMoments {
                    Section("Daily Moments") {
                        TodayActivityRowWithMomentsSubtitle(
                            icon: "sparkles",
                            iconColor: .purple,
                            title: "Moments",
                            selectedCount: selectedLocations.count + selectedEvents.count + selectedPhotos.count + selectedHealth.count,
                            isCompleted: hasSelectedMoments,
                            selectedDate: selectedDate,
                            action: { 
                                showingMoments = true
                            }
                        )
                    }
                }
                
                // Daily Trackers Section
                if showTrackers {
                    Section("Daily Trackers") {
                        TodayActivityRowWithCheckbox(
                            icon: "chart.line.uptrend.xyaxis",
                            iconColor: .orange,
                            title: "Trackers",
                            subtitle: hasTrackerData ? "Trackers completed for today" : "Track your mood, energy, and daily activities",
                            isCompleted: hasTrackerData,
                            action: { 
                                showingTrackers = true
                            }
                        )
                    }
                }
                
                // Today Insights Section
                if showInsights {
                    Section("Today Insights") {
                    HStack(spacing: 0) {
                        TodayInsightItem(
                            icon: "cloud.sun",
                            title: "72°F Sunny",
                            detail: "Alpine, Utah",
                            action: { showingWeather = true }
                        )
                        
                        TodayInsightItem(
                            icon: "square.and.pencil",
                            title: "3 entries",
                            detail: "Today",
                            action: { showingEntries = true }
                        )
                        
                        TodayInsightItem(
                            icon: "calendar.badge.clock",
                            title: "2 memories",
                            detail: "On This Day",
                            action: { showingOnThisDay = true }
                        )
                    }
                    .padding(.vertical, 4)
                    }
                }
                
                // Bio ToolTip (no section wrapper)
                if showBioTooltip {
                    TipView(bioTip) { action in
                        if action.id == "fill-bio" {
                            // Handle Fill Bio Now action
                            showingBioView = true
                            bioTip.invalidate(reason: .actionPerformed)
                        } else if action.id == "later" {
                            // Handle Maybe Later action
                            bioTip.invalidate(reason: .actionPerformed)
                        }
                    }
                    .tipBackground(Color.black.opacity(0.05))
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.insetGrouped)
        }
        .sheet(isPresented: $showingDailyChat) {
            DailyChatView(
                selectedDate: selectedDate,
                initialLogMode: openChatInLogMode,
                entryCreated: $entryCreated,
                onChatStarted: {
                    // Mark that user has interacted with chat
                    hasInteractedWithChat = true
                    // Don't automatically show Daily Chat section unless manually enabled
                },
                onMessageCountChanged: { count in
                    chatMessageCount = count
                    // Only mark as completed if there's at least one interaction
                    if count > 0 {
                        chatCompleted = true
                    }
                }
            )
        }
        .sheet(isPresented: $showingMoments) {
            MomentsView(
                selectedLocations: $selectedLocations,
                selectedEvents: $selectedEvents,
                selectedPhotos: $selectedPhotos,
                selectedHealth: $selectedHealth
            )
        }
        .sheet(isPresented: $showingTrackers) {
            TrackerView(
                moodRating: $moodRating,
                energyRating: $energyRating,
                stressRating: $stressRating,
                foodInput: $foodInput,
                prioritiesInput: $prioritiesInput,
                mediaInput: $mediaInput,
                peopleInput: $peopleInput
            )
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            // Post notification for date change
            NotificationCenter.default.post(name: NSNotification.Name("SelectedDateChanged"), object: newValue)
            
            // Reset daily activities state when date changes
            chatCompleted = false
            isGeneratingPreview = false
            summaryGenerated = false
            hasInteractedWithChat = false
            chatMessageCount = 0
            entryCreated = false
            
            // Check if there are existing chat messages for the new date
            let existingMessages = ChatSessionManager.shared.getMessages(for: newValue)
            if !existingMessages.isEmpty {
                hasInteractedWithChat = true
                chatCompleted = true
                // Don't automatically show Daily Chat section unless manually enabled
                chatMessageCount = existingMessages.filter { $0.isUser }.count
            }
            
            // Clear moments data
            selectedLocations.removeAll()
            selectedEvents.removeAll()
            selectedPhotos.removeAll()
            
            // Clear tracker data
            moodRating = 0
            energyRating = 0
            stressRating = 0
            foodInput = ""
            prioritiesInput = ""
            mediaInput = ""
            peopleInput = ""
        }
        .sheet(isPresented: $showingWeather) {
            NavigationStack {
                WeatherView()
            }
        }
        .sheet(isPresented: $showingEntries) {
            NavigationStack {
                EntriesView()
            }
        }
        .sheet(isPresented: $showingOnThisDay) {
            NavigationStack {
                OnThisDayView()
            }
        }
        .sheet(isPresented: $showingPreviewEntry) {
            ChatEntryPreviewView(
                selectedDate: selectedDate,
                entryCreated: $entryCreated
            )
        }
        .sheet(isPresented: $showingEntry) {
            EntryView(journal: nil)
        }
        .sheet(isPresented: $showingBioView) {
            BioEditView()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TriggerDailyChat"))) { _ in
            // Only respond to Daily Chat trigger if this variant supports it
            showingDailyChat = true
        }
        }
    }
    
    private func generateSummary() {
        // Start loading state
        isGeneratingPreview = true
        
        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2.0...4.0)) {
            isGeneratingPreview = false
            summaryGenerated = true
        }
    }
}

// Custom row component with checkbox for Daily Activities
struct TodayActivityRowWithCheckbox: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isCompleted: Bool
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
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary.opacity(0.5))
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom row component with chat resume functionality (V2 with hyperlinks)
struct TodayActivityRowWithChatResumeV2: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let showResume: Bool
    let showDefaultContent: Bool
    let action: () -> Void
    let resumeAction: () -> Void
    let beginChatAction: () -> Void
    let logHighlightsAction: () -> Void
    
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
                    
                    if showResume {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if showDefaultContent {
                        Text("Log details about your day")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                
                if showResume {
                    HStack(spacing: 4) {
                        Text("Resume")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                        
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                } else {
                    HStack(spacing: 4) {
                        Text("Start Chat")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                        
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom row component with chat resume functionality
struct TodayActivityRowWithChatResume: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let showResume: Bool
    let action: () -> Void
    let resumeAction: () -> Void
    
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
                    
                    if showResume {
                        HStack(spacing: 4) {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Button(action: resumeAction) {
                                Text("Resume")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                    } else {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary.opacity(0.5))
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Daily Chat components moved to DailyChatViews.swift

// MARK: - Supporting Views
// Custom row component with moments-specific subtitle formatting
struct TodayActivityRowWithMomentsSubtitle: View {
    let icon: String
    let iconColor: Color
    let title: String
    let selectedCount: Int
    let isCompleted: Bool
    let selectedDate: Date
    let action: () -> Void
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private var dynamicTitle: String {
        return "\(dayOfWeek) Moments"
    }
    
    private var relativeDateText: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            let components = calendar.dateComponents([.day, .weekOfYear, .month, .year], from: selectedDate, to: now)
            
            if let days = components.day, abs(days) < 7 {
                let dayText = abs(days) == 1 ? "Day" : "Days"
                return abs(days) == 2 ? "Two Days Ago" : "\(abs(days)) \(dayText) Ago"
            } else if let weeks = components.weekOfYear, abs(weeks) < 5 {
                let weekText = abs(weeks) == 1 ? "Week" : "Weeks"
                return abs(weeks) == 1 ? "A Week Ago" : "\(abs(weeks)) \(weekText) Ago"
            } else if let months = components.month, abs(months) < 12 {
                let monthText = abs(months) == 1 ? "Month" : "Months"
                return abs(months) == 1 ? "A Month Ago" : "\(abs(months)) \(monthText) Ago"
            } else if let years = components.year {
                let yearText = abs(years) == 1 ? "Year" : "Years"
                return abs(years) == 1 ? "A Year Ago" : "\(abs(years)) \(yearText) Ago"
            }
        }
        
        return dayOfWeek
    }
    
    private var subtitleText: Text {
        if selectedCount == 0 {
            return Text("Select media, places, and events from ")
                .foregroundStyle(.secondary) +
            Text(relativeDateText)
                .foregroundStyle(Color(hex: "44C0FF"))
        } else {
            return Text("\(selectedCount) selected. ")
                .foregroundStyle(.secondary) +
            Text("Select more")
                .foregroundStyle(Color(hex: "44C0FF"))
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                        .font(.system(size: 16, weight: .medium))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(dynamicTitle)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    subtitleText
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Placeholder Views for Today Insights
struct WeatherView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Image(systemName: "cloud.sun")
                .font(.system(size: 80))
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding()
            
            Text("Weather")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Weather information will be displayed here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Weather")
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

struct EntriesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 80))
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding()
            
            Text("Entries")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Journal entries will be displayed here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Entries")
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

struct OnThisDayView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding()
            
            Text("On This Day")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Memories from this day in previous years will be displayed here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .navigationTitle("On This Day")
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

// Today Insight Item Component
struct TodayInsightItem: View {
    let icon: String
    let title: String
    let detail: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(height: 28)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// TodayInsightItem without action for NavigationLink usage
struct TodayInsightItemView: View {
    let icon: String
    let title: String
    let detail: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Color(hex: "44C0FF"))
                .frame(height: 40)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - ChatEntryPreviewView moved to DailyChatViews.swift


#Preview {
    TodayView()
}
