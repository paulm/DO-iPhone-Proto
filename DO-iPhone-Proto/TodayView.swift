import SwiftUI
import TipKit
import UIKit

// MARK: - Style Options
enum TodayViewStyle: String, CaseIterable {
    case standard = "Standard"
    case transparent = "Transparent"
}

// MARK: - Moments Selection Manager
class MomentsSelectionManager: ObservableObject {
    static let shared = MomentsSelectionManager()
    
    @Published var selectedLocations: Set<String> = []
    @Published var selectedEvents: Set<String> = []
    @Published var selectedPhotos: Set<String> = []
    @Published var selectedHealth: Set<String> = []
    
    var hasSelections: Bool {
        !selectedLocations.isEmpty || !selectedEvents.isEmpty || !selectedPhotos.isEmpty || !selectedHealth.isEmpty
    }
    
    var selectionSummary: String {
        var items: [String] = []
        
        if !selectedLocations.isEmpty {
            items.append(contentsOf: selectedLocations)
        }
        
        if !selectedEvents.isEmpty {
            items.append(contentsOf: selectedEvents)
        }
        
        if !selectedPhotos.isEmpty {
            items.append("\(selectedPhotos.count) Images")
        }
        
        if !selectedHealth.isEmpty {
            items.append(contentsOf: selectedHealth)
        }
        
        return items.joined(separator: ", ")
    }
    
    func clearAll() {
        selectedLocations.removeAll()
        selectedEvents.removeAll()
        selectedPhotos.removeAll()
        selectedHealth.removeAll()
    }
}


// MARK: - Date Picker Components
private struct DatePickerConstants {
    static let circleSize: CGFloat = 18
    static let spacing: CGFloat = 12
    static let numberOfRows: Int = 9  // Control the number of date grid rows
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
    let showDates: Bool
    let showStreak: Bool
    
    @State private var availableWidth: CGFloat = UIScreen.main.bounds.width - 40 // Approximate initial width
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging = false
    @State private var lastSelectedDate: Date?
    
    // Check if a date has chat messages (completed)
    private func hasMessagesForDate(_ date: Date) -> Bool {
        let messages = ChatSessionManager.shared.getMessages(for: date)
        return !messages.isEmpty && messages.contains { $0.isUser }
    }
    
    // Check if a date has an entry created
    private func hasEntryForDate(_ date: Date) -> Bool {
        return DailyContentManager.shared.hasEntry(for: date)
    }
    
    init(dates: [Date], selectedDate: Binding<Date>, showDates: Bool = true, showStreak: Bool = true) {
        self.dates = dates
        self._selectedDate = selectedDate
        self.showDates = showDates
        self.showStreak = showStreak
    }
    
    private func isDateCompleted(_ date: Date) -> Bool {
        return hasMessagesForDate(date)
    }
    
    private var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = calendar.date(byAdding: .day, value: -1, to: today)! // Start with yesterday
        
        // Check consecutive days backwards starting from yesterday
        while isDateCompleted(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        return streak
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
        
        // Force exactly the configured number of rows
        let datesPerRow = (dates.count + DatePickerConstants.numberOfRows - 1) / DatePickerConstants.numberOfRows // Round up division
        
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
            // Streak and Today button
            HStack {
                if showStreak && currentStreak > 0 {
                    Text("\(currentStreak) Day\(currentStreak == 1 ? "" : "s") Streak")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
                
                if showStreak && !Calendar.current.isDateInToday(selectedDate) {
                    Button(action: {
                        selectedDate = Date()
                    }) {
                        Text("Today")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(hex: "44C0FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
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
                            hasEntry: hasEntryForDate(date),
                            showDate: showDates,
                            onTap: {
                                selectedDate = date
                            }
                        )
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        // Store the frame for hit testing during drag
                                    }
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
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    dragLocation = value.location
                    
                    // Find which date circle contains the drag location
                    let row = Int(value.location.y / (DatePickerConstants.circleSize + DatePickerConstants.spacing))
                    let col = Int(value.location.x / (DatePickerConstants.circleSize + DatePickerConstants.spacing))
                    
                    if row >= 0 && row < rows.count && col >= 0 && col < rows[row].count {
                        let date = rows[row][col]
                        
                        // Only provide haptic feedback if we're over a new date
                        if lastSelectedDate == nil || !Calendar.current.isDate(lastSelectedDate!, inSameDayAs: date) {
                            // Haptic feedback when selecting a new date
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            lastSelectedDate = date
                        }
                        
                        // Always update the selected date
                        selectedDate = date
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    lastSelectedDate = nil
                }
        )
    }
}

struct DateCircle: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isFuture: Bool
    let isCompleted: Bool
    let hasEntry: Bool
    let showDate: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var textColor: Color {
        if isSelected || hasEntry {
            return .white
        } else if isCompleted {
            return Color(hex: "333B40") // Dark text for circles with chat
        } else if isToday {
            return .primary // Dark text for today
        } else if isFuture {
            return .secondary
        } else {
            return .primary
        }
    }
    
    var body: some View {
        ZStack {
            // White spacer circle for consistent layout (always 18pt)
            Circle()
                .fill(.white.opacity(0.01)) // Nearly invisible, just for spacing
                .frame(width: DatePickerConstants.circleSize, height: DatePickerConstants.circleSize)

            // Base visible circle - 8pt for future dates, 18pt for past/today
            if isFuture {
                Circle()
                    .fill(.gray.opacity(0.15))
                    .frame(width: 8, height: 8)
            } else {
                Circle()
                    .fill(.gray.opacity(0.15))
                    .frame(width: DatePickerConstants.circleSize, height: DatePickerConstants.circleSize)
            }

            // Layered interaction indicators
            if hasEntry {
                // Full size dark gray circle (18pt) for days with entries
                Circle()
                    .fill(isSelected ? Color(hex: "44C0FF") : Color(hex: "333B40"))
                    .frame(width: DatePickerConstants.circleSize, height: DatePickerConstants.circleSize)
            } else {
                // Selected state - blue circle (only if no entry)
                if isSelected {
                    Circle()
                        .fill(Color(hex: "44C0FF"))
                        .frame(width: DatePickerConstants.circleSize, height: DatePickerConstants.circleSize)
                }

                // Small circle for chat interaction (always on top, even when selected)
                if isCompleted {
                    Circle()
                        .fill(isSelected ? .white : Color(hex: "333B40"))
                        .frame(width: 8, height: 8)
                }
            }

            if showDate || isToday {
                Text(dayNumber)
                    .font(.system(size: 8))
                    .fontWeight(.medium)
                    .foregroundStyle(textColor)
            }
        }
        .onTapGesture {
            // Haptic feedback on tap
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            onTap()
        }
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
    
    // Moments selection manager
    @StateObject private var momentsSelection = MomentsSelectionManager.shared
    
    @State private var showingDailyChat = false
    @State private var chatCompleted = false
    @State private var openChatInLogMode = false
    @State private var openDailyChatInLogMode = false
    @State private var chatMessageCount = 0
    @State private var momentsCompleted = false
    @State private var trackersCompleted = false
    @State private var showingProfileMenu = false
    @State private var isGeneratingPreview = false
    @State private var summaryGenerated = false
    @State private var hasInteractedWithChat = false
    @State private var hasViewedSummary = false
    
    // Today Insights state
    @State private var showingWeather = false
    @State private var showingEntries = false
    @State private var showingOnThisDay = false
    @State private var showingPreviewEntry = false
    @State private var entryCreated = false
    @State private var showingEntry = false
    @State private var isGeneratingEntry = false
    @State private var chatUpdateTrigger = false
    @State private var momentsInitialSection: String? = nil
    @State private var showingJournalSelectionAlert = false
    @State private var showingJournalPicker = false
    @AppStorage("hasShownFirstTimeJournalAlert") private var hasShownFirstTimeJournalAlert = false
    @AppStorage("selectedJournalForEntries") private var selectedJournalForEntries = "Daily"
    @State private var showingVisitsSheet = false
    @State private var showingEventsSheet = false
    @State private var showingMediaSheet = false
    @State private var showingBio = false
    
    // Show/hide toggles for Daily Activities
    @State private var showWeather = false
    @State private var showDatePickerGrid = true
    @State private var showDateNavigation = true
    @State private var showChat = false
    @State private var showMomentsList = true
    @State private var showTrackers = false
    @State private var showInsights = true
    @State private var showPrompts = true
    @State private var showGuides = false
    @State private var selectedPrompt: String? = nil
    
    // Moments visibility toggles
    @State private var showMomentsVisits = true
    @State private var showMomentsEvents = true
    @State private var showMomentsMedia = true
    
    // Daily Entry Chat Context toggles
    @State private var includeBio = true
    @State private var includePreviousChats = true
    @State private var includeJournal = true
    
    // TipKit
    private let journalingTip = JournalingMadeEasyTip()
    
    @AppStorage("showChatFAB") private var showChatFAB = false
    @AppStorage("showEntryFAB") private var showEntryFAB = false
    @AppStorage("showChatInputBox") private var showChatInputBox = false
    @AppStorage("showChatMessage") private var showChatMessage = false
    @AppStorage("showMomentsCarousel") private var showMomentsCarousel = false
    @AppStorage("showDailyEntryChat") private var showDailyEntryChat = true
    @AppStorage("showLogVoiceModeButtons") private var showLogVoiceModeButtons = false
    @AppStorage("showBioSection") private var showBioSection = false
    @AppStorage("todayViewStyle") private var selectedStyle = TodayViewStyle.standard
    @AppStorage("showWelcomeToTodaySheet") private var showWelcomeToTodaySheet = false
    
    // Sheet presentation state
    @State private var shouldPresentWelcomeSheet = false
    
    // Options toggles
    @State private var showGridDates = false
    
    private var dateRange: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        let today = Date()
        
        // Calculate how many dates we need based on screen width
        // Assuming we want to fit as many as possible in the configured number of rows
        let approximateWidth = UIScreen.main.bounds.width - 40
        let columnsPerRow = Int((approximateWidth + DatePickerConstants.spacing) / (DatePickerConstants.circleSize + DatePickerConstants.spacing))
        let totalDates = columnsPerRow * DatePickerConstants.numberOfRows
        
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
    
    private var dailyEntryChatPromptText: String {
        let calendar = Calendar.current
        
        // Get day of week for the selected date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full day name (e.g., "Monday")
        let dayOfWeek = formatter.string(from: selectedDate)
        
        // Check special cases first
        if calendar.isDateInToday(selectedDate) {
            // For today, we could use time-based but keeping it simple
            return "How is your \(dayOfWeek)?"
        }
        
        if calendar.isDateInYesterday(selectedDate) {
            return "How was your \(dayOfWeek)?"
        }
        
        if calendar.isDateInTomorrow(selectedDate) {
            return "What's happening on \(dayOfWeek)?"
        }
        
        // For other dates, calculate the difference
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfSelectedDate = calendar.startOfDay(for: selectedDate)
        
        // This gives us the number of days between dates
        // Positive = future, Negative = past
        let daysDifference = calendar.dateComponents([.day], from: startOfToday, to: startOfSelectedDate).day ?? 0
        
        if daysDifference < 0 {
            // Past dates
            let daysAgo = abs(daysDifference)
            
            if daysAgo <= 7 {
                // Within past week
                return "How was your \(dayOfWeek)?"
            } else {
                // Older than a week
                return "How was this day?"
            }
        } else if daysDifference > 0 {
            // Future dates
            if daysDifference <= 7 {
                // Within next week
                return "What's happening on \(dayOfWeek)?"
            } else {
                // More than a week away
                return "What's happening on this \(dayOfWeek)?"
            }
        } else {
            // Fallback (shouldn't get here)
            return "Tell me about this day."
        }
    }
    
    private var momentsSummaryText: String {
        let totalMoments = momentsSelection.selectedLocations.count + momentsSelection.selectedEvents.count + momentsSelection.selectedPhotos.count
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
        !momentsSelection.selectedLocations.isEmpty || !momentsSelection.selectedEvents.isEmpty || !momentsSelection.selectedPhotos.isEmpty || !momentsSelection.selectedHealth.isEmpty
    }
    
    private var momentsCountText: String {
        let totalSelected = momentsSelection.selectedLocations.count + momentsSelection.selectedEvents.count + momentsSelection.selectedPhotos.count + momentsSelection.selectedHealth.count
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
    
    private var backgroundColor: Color {
        return .white
    }
    
    private var cellBackgroundColor: Color {
        switch selectedStyle {
        case .standard:
            return Color(UIColor.secondarySystemGroupedBackground)
        case .transparent:
            return Color(UIColor.systemGroupedBackground)
        }
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
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            // For all other dates, show the day of the week
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Full weekday name (Monday, Tuesday, etc.)
            return formatter.string(from: date)
        }
    }
    
    private func formattedDateForNavigation(_ date: Date) -> String {
        let calendar = Calendar.current
        
        // Check if it's Today, Yesterday, or Tomorrow
        if calendar.isDateInToday(date) || 
           calendar.isDateInYesterday(date) || 
           calendar.isDateInTomorrow(date) {
            // Show full format with weekday for these special days
            return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
        } else {
            // For all other dates, exclude the weekday but add relative time
            let baseDate = date.formatted(.dateTime.month(.abbreviated).day().year())
            let relativeTime = getRelativeTimeText(for: date)
            return "\(baseDate) (\(relativeTime))"
        }
    }
    
    private func getRelativeTimeText(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
        
        if days > 0 {
            // Past dates
            if days == 1 {
                return "1 day ago"
            } else if days < 7 {
                return "\(days) days ago"
            } else if days == 7 {
                return "1 week ago"
            } else if days < 14 {
                return "\(days) days ago"
            } else if days < 30 {
                let weeks = days / 7
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            } else if days < 60 {
                return "1 month ago"
            } else if days < 365 {
                let months = days / 30
                return months == 1 ? "1 month ago" : "\(months) months ago"
            } else {
                let years = days / 365
                return years == 1 ? "1 year ago" : "\(years) years ago"
            }
        } else if days < 0 {
            // Future dates
            let futureDays = abs(days)
            if futureDays == 1 {
                return "in 1 day"
            } else if futureDays < 7 {
                return "in \(futureDays) days"
            } else if futureDays == 7 {
                return "in 1 week"
            } else if futureDays < 14 {
                return "in \(futureDays) days"
            } else if futureDays < 30 {
                let weeks = futureDays / 7
                return weeks == 1 ? "in 1 week" : "in \(weeks) weeks"
            } else if futureDays < 60 {
                return "in 1 month"
            } else if futureDays < 365 {
                let months = futureDays / 30
                return months == 1 ? "in 1 month" : "in \(months) months"
            } else {
                let years = futureDays / 365
                return years == 1 ? "in 1 year" : "in \(years) years"
            }
        } else {
            return "today"
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
    
    private func generateEntry() {
        // Start generating entry
        isGeneratingEntry = true
        
        // After 1 second, mark entry as created and open it
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isGeneratingEntry = false
            // Mark entry as created
            DailyContentManager.shared.setHasEntry(true, for: selectedDate)
            // Track current message count when entry is created
            let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
            let userMessageCount = messages.filter { $0.isUser }.count
            DailyContentManager.shared.setEntryMessageCount(userMessageCount, for: selectedDate)
            // Update local state
            entryCreated = true
            // Post notification to update FAB
            NotificationCenter.default.post(name: NSNotification.Name("DailyEntryCreatedStatusChanged"), object: selectedDate)
        }
    }
    
    // Extract Daily Entry Chat section as computed property
    @ViewBuilder
    private var dailyEntryChatSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // TipKit tip
                TipView(journalingTip)
                    .tipViewStyle(CustomJournalingTipViewStyle())
                    .padding(.bottom, 8)
                
                // Header content (now part of the section body so it scrolls)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Entry Chat")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "292F33"))
                    // Only show welcome prompt when no chat has taken place
                    if !chatCompleted && !DailyContentManager.shared.hasEntry(for: selectedDate) {
                        Text(dailyEntryChatPromptText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, chatCompleted || DailyContentManager.shared.hasEntry(for: selectedDate) ? 4 : 8)
                
                DailyEntryChatView(
                    selectedDate: selectedDate,
                    chatCompleted: chatCompleted,
                    isGeneratingEntry: isGeneratingEntry,
                    showingDailyChat: $showingDailyChat,
                    showingEntry: $showingEntry,
                    showingPreviewEntry: $showingPreviewEntry,
                    openDailyChatInLogMode: $openDailyChatInLogMode,
                    showLogVoiceModeButtons: showLogVoiceModeButtons
                )
                .id(chatUpdateTrigger) // Force refresh when chat updates
            }
        }
        .animation(nil, value: selectedDate)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(showGuides ? Color.green.opacity(0.2) : cellBackgroundColor)
        .listRowSeparator(.hidden)
    }
    
    // Extract Moments List section as computed property
    @ViewBuilder
    private var momentsListSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // Header content (now part of the section body so it scrolls)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Moments")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "292F33"))
                    Text("Create an entry from a moment ...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                // Moments Types
                VStack(alignment: .leading, spacing: 0) {
                    // Photos row
                    Button(action: {
                        showingMediaSheet = true
                    }) {
                        HStack {
                            Image(dayOneIcon: .photo)
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                                .frame(width: 28)
                            
                            Text("Photos")
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text("5")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(.systemGray3))
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    // Places row
                    Button(action: {
                        showingVisitsSheet = true
                    }) {
                        HStack {
                            Image(dayOneIcon: .map_pin)
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                                .frame(width: 28)
                            
                            Text("Places")
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text("4")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(.systemGray3))
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    // Events row
                    Button(action: {
                        showingEventsSheet = true
                    }) {
                        HStack {
                            Image(dayOneIcon: .calendar)
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                                .frame(width: 28)
                            
                            Text("Events")
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text("3")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(.systemGray3))
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(showGuides ? Color.orange.opacity(0.2) : Color.clear)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    private var entryLinksSection: some View {
        let entryCount = DailyDataManager.shared.getEntryCount(for: selectedDate)
        let onThisDayCount = DailyDataManager.shared.getOnThisDayCount(for: selectedDate)
        
        Group {
            if onThisDayCount > 0 {
                // Show both buttons side by side when there are On This Day entries
                HStack(spacing: 12) {
                    // Entries button
                    Button(action: {
                        if entryCount == 0 {
                            // Open Entry view to create new entry
                            showingEntry = true
                        } else {
                            // Open Entries list
                            showingEntries = true
                        }
                    }) {
                        HStack {
                            Text("\(entryCount) \(entryCount == 1 ? "Entry" : "Entries")")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: entryCount > 0 ? "chevron.right" : "plus")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(entryCount > 0 ? Color.secondary : Color(hex: "44C0FF"))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "F3F1F8"))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // On This Day button
                    Button(action: {
                        showingOnThisDay = true
                    }) {
                        HStack {
                            Text("\(onThisDayCount) On This Day")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "F3F1F8"))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                // Show full-width Entries button when no On This Day entries
                Button(action: {
                    if entryCount == 0 {
                        // Open Entry view to create new entry
                        showingEntry = true
                    } else {
                        // Open Entries list
                        showingEntries = true
                    }
                }) {
                    HStack {
                        Text("\(entryCount) \(entryCount == 1 ? "Entry" : "Entries")")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: entryCount > 0 ? "chevron.right" : "plus")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(entryCount > 0 ? Color.secondary : Color(hex: "44C0FF"))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "F3F1F8"))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 12)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(showGuides ? Color.blue.opacity(0.2) : Color.clear)
        .listRowSeparator(.hidden)
    }
    
    // Extract Date Navigation section as computed property
    @ViewBuilder
    private var dateNavigationSection: some View {
        if showDateNavigation {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        // Row 1: "Today" or relative date
                        Text(relativeDateText(for: selectedDate))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "292F33")) // Day One Deep Blue
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Row 2: Full date - show weekday only for Today/Yesterday/Tomorrow
                        Text(formattedDateForNavigation(selectedDate))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    // Arrow navigation buttons
                    HStack(spacing: 12) {
                        // Previous day button
                        Button(action: {
                            if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedDate = previousDay
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(.systemGray2))
                                .frame(width: 48, height: 48)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Next day button
                        Button(action: {
                            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedDate = nextDay
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(.systemGray2))
                                .frame(width: 48, height: 48)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 0)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(showGuides ? Color.red.opacity(0.2) : cellBackgroundColor)
            .listRowSeparator(.hidden)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
            // Main content
            List {
                
                // Date picker grid at top of scrollable content (off by default for now)
                if showDatePickerGrid {
                    DatePickerGrid(
                        dates: dateRange,
                        selectedDate: $selectedDate,
                        showDates: showGridDates,
                        showStreak: false
                    )
                    .id(chatUpdateTrigger) // Force refresh when data changes
                    .background(Color.clear)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.bottom, 20)
                }
                
                // Date Navigation section
                dateNavigationSection
                
                // Entries Section - Two buttons side by side (no title)
                entryLinksSection
                
                // Daily Chat Carousel Section
                if showDailyEntryChat {
                    dailyEntryChatSection
                }
                
                // Moments Carousel Section
                if showMomentsCarousel {
                    Section {
                        MomentsCarouselView(
                            showingMoments: $showingMoments,
                            momentsInitialSection: $momentsInitialSection
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                        .padding(.horizontal, -20)
                    }
                }
                
                // Moments List Section
                if showMomentsList {
                    momentsListSection
                }
                
                // Trackers Section
                if showTrackers {
                    Section {
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
                    .listRowBackground(cellBackgroundColor)
                }
                
                // Bio Section
                if showBioSection {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            // Header content (title and subtitle outside the rounded rect)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bio")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(hex: "292F33"))
                                Text("Personal information and health data")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            // Bio button in rounded rectangle
                            VStack(alignment: .leading, spacing: 0) {
                                Button(action: {
                                    showingBio = true
                                }) {
                                    HStack {
                                        Image(systemName: "person.text.rectangle")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.primary)
                                            .frame(width: 28)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("View & Edit Bio")
                                                .font(.system(size: 16))
                                                .foregroundStyle(.primary)
                                            
                                            Text("Manage your personal profile")
                                                .font(.system(size: 13))
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Color(.systemGray3))
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                
                // Extra space at bottom to allow scrolling content above bottom elements
                Color.clear
                    .frame(height: 200)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(backgroundColor)
            .ignoresSafeArea(edges: .bottom)
            .offset(y: showDatePickerGrid ? -230 : 0)
            .padding(.bottom, showDatePickerGrid ? -230 : 0)
            
                // Chat elements at bottom
                VStack {
                    Spacer()
                    VStack(spacing: 12) {  // Increased spacing from 8pt to 18pt (10pt more)
                        // Chat Message Bubble
                        if showChatMessage && !chatCompleted {
                            ChatMessageBubbleView(dayOfWeek: currentDayName)
                                .id(selectedDate) // Force recreation when date changes
                        }
                        
                        // Chat Input Box
                        if showChatInputBox {
                            ChatInputBoxView {
                                showingDailyChat = true
                                openChatInLogMode = false
                            }
                        }
                    }
                    .padding(.bottom, 16) // Fixed 16pt from bottom
                }
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showingDatePicker = true
                } label: {
                    Image(dayOneIcon: .calendar)
                }

                Menu {
                    Button("Settings") {
                        showingSettings = true
                    }
                    
                    // DEBUG: Reset first-time journal alert
                    Button("Reset Journal Selection (Debug)") {
                        hasShownFirstTimeJournalAlert = false
                    }
                    
                    Section("Show in Today") {
                        
                        Button {
                            showWelcomeToTodaySheet.toggle()
                        } label: {
                            HStack {
                                Text("Welcome to Today Sheet")
                                if showWelcomeToTodaySheet {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showDatePickerGrid.toggle()
                        } label: {
                            HStack {
                                Text("Date Picker Grid")
                                if showDatePickerGrid {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showDateNavigation.toggle()
                        } label: {
                            HStack {
                                Text("Date Navigation")
                                if showDateNavigation {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showMomentsCarousel.toggle()
                        } label: {
                            HStack {
                                Text("Moments Carousel")
                                if showMomentsCarousel {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showMomentsList.toggle()
                        } label: {
                            HStack {
                                Text("Moments List")
                                if showMomentsList {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showTrackers.toggle()
                        } label: {
                            HStack {
                                Text("Trackers")
                                if showTrackers {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showGuides.toggle()
                        } label: {
                            HStack {
                                Text("Guides")
                                if showGuides {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showInsights.toggle()
                        } label: {
                            HStack {
                                Text("Entry Links")
                                if showInsights {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        
                        Button {
                            showDailyEntryChat.toggle()
                        } label: {
                            HStack {
                                Text("Daily Entry Chat")
                                if showDailyEntryChat {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        
                        Button {
                            showLogVoiceModeButtons.toggle()
                        } label: {
                            HStack {
                                Text("Log and Voice Mode Buttons")
                                if showLogVoiceModeButtons {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showBioSection.toggle()
                        } label: {
                            HStack {
                                Text("Bio")
                                if showBioSection {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                    }
                    
                    Section("Show HUD") {
                        Button {
                            showChatFAB.toggle()
                        } label: {
                            HStack {
                                Text("Chat FAB")
                                if showChatFAB {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showEntryFAB.toggle()
                        } label: {
                            HStack {
                                Text("Entry FAB")
                                if showEntryFAB {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showChatInputBox.toggle()
                        } label: {
                            HStack {
                                Text("Chat Input Box")
                                if showChatInputBox {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                        
                        Button {
                            showChatMessage.toggle()
                        } label: {
                            HStack {
                                Text("Chat Message")
                                if showChatMessage {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }
                    }
                    
                    Section("Options") {
                        Button {
                            showGridDates.toggle()
                        } label: {
                            HStack {
                                Text("Grid Dates")
                                if showGridDates {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }

                    }
                    
                    Section("Style") {
                        ForEach(TodayViewStyle.allCases, id: \.self) { style in
                            Button {
                                selectedStyle = style
                            } label: {
                                HStack {
                                    Text(style.rawValue)
                                    if selectedStyle == style {
                                        Image(dayOneIcon: .checkmark)
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("Populate Data") {
                        Button("New") {
                            populateNewUserData()
                        }
                        
                        Button("Past 2 Weeks") {
                            populatePast2WeeksData()
                        }
                        
                        Button("2 Months") {
                            populate2MonthsData()
                        }
                    }
                } label: {
                    // Profile avatar button
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("PM")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .background(
            KeyboardHandler(
                onLeftArrow: { navigateToPreviousDay() },
                onRightArrow: { navigateToNextDay() }
            )
            .frame(width: 0, height: 0)
        )
        } // End NavigationStack
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                DatePicker("Select Date", selection: Binding(
                    get: { selectedDate },
                    set: { newDate in
                        selectedDate = newDate
                        // Dismiss the sheet when a date is selected
                        showingDatePicker = false
                    }
                ), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .navigationTitle("Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Today") {
                                selectedDate = Date()
                                showingDatePicker = false
                            }
                            .disabled(Calendar.current.isDateInToday(selectedDate))
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingDatePicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingDailyChat, onDismiss: {
            // Refresh carousel state when sheet is dismissed
            DispatchQueue.main.async {
                // Update entry created state
                entryCreated = DailyContentManager.shared.hasEntry(for: selectedDate)
                
                // Check if there are messages to show the last AI response
                let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                if !messages.isEmpty && messages.contains(where: { $0.isUser }) {
                    chatCompleted = true
                    chatMessageCount = messages.filter { $0.isUser }.count
                    hasInteractedWithChat = true
                } else {
                    chatCompleted = false
                    chatMessageCount = 0
                    hasInteractedWithChat = false
                }
                
                // Force view refresh
                chatUpdateTrigger.toggle()
            }
        }) {
            DailyChatView(
                selectedDate: selectedDate,
                initialLogMode: openDailyChatInLogMode,
                entryCreated: $entryCreated,
                onChatStarted: {
                    // Mark that user has interacted with chat
                    hasInteractedWithChat = true
                    // Don't automatically show Daily Chat section unless manually enabled
                    // Reset the log mode flag
                    openDailyChatInLogMode = false
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
                selectedLocations: $momentsSelection.selectedLocations,
                selectedEvents: $momentsSelection.selectedEvents,
                selectedPhotos: $momentsSelection.selectedPhotos,
                selectedHealth: $momentsSelection.selectedHealth,
                initialSection: momentsInitialSection
            )
            .onDisappear {
                // Reset the initial section when sheet is dismissed
                momentsInitialSection = nil
            }
        }
        .sheet(isPresented: $showingVisitsSheet) {
            VisitsSheetView()
        }
        .sheet(isPresented: $showingEventsSheet) {
            EventsSheetView()
        }
        .sheet(isPresented: $showingMediaSheet) {
            MediaSheetView()
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
            hasViewedSummary = false
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
            
            // Check if summary and entry exist for the new date
            summaryGenerated = DailyContentManager.shared.hasSummary(for: newValue)
            entryCreated = DailyContentManager.shared.hasEntry(for: newValue)
            
            // Clear moments data
            momentsSelection.selectedLocations.removeAll()
            momentsSelection.selectedEvents.removeAll()
            momentsSelection.selectedPhotos.removeAll()
            momentsSelection.selectedHealth.removeAll()
            
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
        .sheet(isPresented: $showingBio) {
            NavigationStack {
                BioSettingsView()
            }
        }
        .onChange(of: showingPreviewEntry) { oldValue, newValue in
            // When sheet is dismissed, check if summary was generated
            if oldValue == true && newValue == false {
                hasViewedSummary = true
                summaryGenerated = DailyContentManager.shared.hasSummary(for: selectedDate)
            }
        }
        .sheet(isPresented: $showingEntry) {
            EntryView(journal: nil, prompt: selectedPrompt)
                .onDisappear {
                    // Clear the selected prompt after the sheet is dismissed
                    selectedPrompt = nil
                }
        }
        .confirmationDialog(
            "Choose Journal for Entries", 
            isPresented: $showingJournalSelectionAlert,
            titleVisibility: .visible
        ) {
            Button("Create \"Daily\" Journal") {
                selectedJournalForEntries = "Daily"
                hasShownFirstTimeJournalAlert = true
                generateEntry()
            }
            
            Button("Select Existing Journal") {
                hasShownFirstTimeJournalAlert = true
                showingJournalPicker = true
            }
            
            Button("Cancel", role: .cancel) {
                // Reset generating state if cancelled
                isGeneratingEntry = false
            }
        } message: {
            Text("A new \"Daily\" journal will be created for your entries. You can also choose to use one of your existing journals.")
        }
        .sheet(isPresented: $showingJournalPicker) {
            JournalSelectionView(
                selectedJournal: $selectedJournalForEntries,
                onSelection: {
                    showingJournalPicker = false
                    generateEntry()
                }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TriggerDailyChat"))) { _ in
            // Only respond to Daily Chat trigger if this variant supports it
            showingDailyChat = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SummaryGeneratedStatusChanged"))) { notification in
            // Update summaryGenerated state when notification is received
            if let date = notification.object as? Date,
               Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                // Force a UI update
                DispatchQueue.main.async {
                    summaryGenerated = DailyContentManager.shared.hasSummary(for: selectedDate)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DailyEntryCreatedStatusChanged"))) { notification in
            // Update entryCreated state when notification is received
            if let date = notification.object as? Date,
               Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                // Force a UI update
                entryCreated = DailyContentManager.shared.hasEntry(for: selectedDate)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TriggerEntryGeneration"))) { notification in
            // Handle entry generation trigger
            if let date = notification.object as? Date,
               Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                // Check if this is the first time
                if !hasShownFirstTimeJournalAlert {
                    // Show the journal selection alert
                    showingJournalSelectionAlert = true
                } else {
                    // Proceed with entry generation
                    generateEntry()
                }
            }
        }
        .onAppear {
            // Check if summary and entry exist for current date on appear
            summaryGenerated = DailyContentManager.shared.hasSummary(for: selectedDate)
            entryCreated = DailyContentManager.shared.hasEntry(for: selectedDate)
            
            // Show Welcome to Today sheet if enabled
            if showWelcomeToTodaySheet {
                shouldPresentWelcomeSheet = true
            }
        }
        .sheet(isPresented: $shouldPresentWelcomeSheet) {
            WelcomeToTodaySheet()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ChatMessagesUpdated"))) { _ in
            // Force view update when chat messages change
            DispatchQueue.main.async {
                chatUpdateTrigger.toggle()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DailyEntryUpdatedStatusChanged"))) { notification in
            // Force view update when entry is updated
            if let date = notification.object as? Date,
               Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                DispatchQueue.main.async {
                    chatUpdateTrigger.toggle()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DataPopulationChanged"))) { _ in
            // Force UI update when data is re-populated
            DispatchQueue.main.async {
                // Update current date state
                updateCurrentDateState()
                // Force view refresh
                chatUpdateTrigger.toggle()
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
    
    private func formatRelativeDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let days = components.day, days > 0 {
            if days == 1 {
                return "yesterday"
            } else {
                return "\(days) days ago"
            }
        } else if let hours = components.hour, hours > 0 {
            if hours == 1 {
                return "1 hour ago"
            } else {
                return "\(hours) hours ago"
            }
        } else if let minutes = components.minute, minutes > 0 {
            if minutes == 1 {
                return "1 minute ago"
            } else {
                return "\(minutes) minutes ago"
            }
        } else {
            return "just now"
        }
    }
    
    // MARK: - Data Population Methods
    
    private func populateNewUserData() {
        // Clear all existing data for a brand new user experience
        ChatSessionManager.shared.clearAllSessions()
        
        // Clear all daily content entries
        let calendar = Calendar.current
        let today = Date()
        
        // Clear data for the past 2 months to ensure clean state
        for dayOffset in -60...4 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                DailyContentManager.shared.setHasEntry(false, for: date)
                DailyContentManager.shared.setHasSummary(false, for: date)
                DailyContentManager.shared.setEntryMessageCount(0, for: date)
            }
        }
        
        // Reset current state
        chatCompleted = false
        entryCreated = false
        hasInteractedWithChat = false
        chatMessageCount = 0
        
        // Post notification to update UI
        NotificationCenter.default.post(name: NSNotification.Name("DataPopulationChanged"), object: nil)
    }
    
    private func populatePast2WeeksData() {
        // This recreates the current default behavior - past 2 weeks of data
        ChatSessionManager.shared.clearAllSessions()
        
        let calendar = Calendar.current
        let today = Date()
        
        // Clear all data first
        for dayOffset in -60...4 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                DailyContentManager.shared.setHasEntry(false, for: date)
                DailyContentManager.shared.setHasSummary(false, for: date)
                DailyContentManager.shared.setEntryMessageCount(0, for: date)
            }
        }
        
        // Populate past 2 weeks with various states
        let dayConfigs = [
            (1, true, true),    // Yesterday: chat + entry
            (2, true, false),   // 2 days ago: chat only
            (3, true, true),    // 3 days ago: chat + entry
            (4, false, false),  // 4 days ago: no activity
            (5, true, false),   // 5 days ago: chat only
            (6, true, true),    // 6 days ago: chat + entry
            (7, false, false),  // 7 days ago: no activity
            (8, true, true),    // 8 days ago: chat + entry
            (9, false, false),  // 9 days ago: no activity
            (10, true, false),  // 10 days ago: chat only
            (11, false, false), // 11 days ago: no activity
            (12, true, true),   // 12 days ago: chat + entry
            (13, false, false), // 13 days ago: no activity
            (14, true, false)   // 14 days ago: chat only
        ]
        
        for (daysAgo, hasChat, hasEntry) in dayConfigs {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                if hasChat {
                    // Add chat messages
                    let messages = [
                        DailyChatMessage(content: "How's your day?", isUser: false, isLogMode: false),
                        DailyChatMessage(content: generateSampleResponse(for: daysAgo), isUser: true, isLogMode: false)
                    ]
                    ChatSessionManager.shared.saveMessages(messages, for: date)
                    
                    if hasEntry {
                        DailyContentManager.shared.setHasEntry(true, for: date)
                        DailyContentManager.shared.setEntryMessageCount(1, for: date)
                    }
                }
            }
        }
        
        // Update current date state if needed
        updateCurrentDateState()
        
        // Post notification to update UI
        NotificationCenter.default.post(name: NSNotification.Name("DataPopulationChanged"), object: nil)
    }
    
    private func populate2MonthsData() {
        // Populate 2 months of consecutive usage
        ChatSessionManager.shared.clearAllSessions()
        
        let calendar = Calendar.current
        let today = Date()
        
        // Clear all data first
        for dayOffset in -60...4 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                DailyContentManager.shared.setHasEntry(false, for: date)
                DailyContentManager.shared.setHasSummary(false, for: date)
                DailyContentManager.shared.setEntryMessageCount(0, for: date)
            }
        }
        
        // Populate 2 months (60 days) with realistic usage pattern
        for daysAgo in 1...60 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                // Create a realistic usage pattern:
                // - 80% chance of chat interaction
                // - 60% chance of entry creation if chat exists
                // - Skip some days for realism (10% skip rate)
                
                let skipDay = Int.random(in: 1...10) == 1
                
                if !skipDay {
                    let hasChat = Int.random(in: 1...10) <= 8 // 80% chance
                    
                    if hasChat {
                        // Add chat messages with varying lengths
                        let messageCount = Int.random(in: 1...5)
                        var messages: [DailyChatMessage] = []
                        
                        messages.append(DailyChatMessage(content: "How's your day?", isUser: false, isLogMode: false))
                        messages.append(DailyChatMessage(content: generateSampleResponse(for: daysAgo), isUser: true, isLogMode: false))
                        
                        // Add additional messages for variety
                        for i in 1..<messageCount {
                            if i % 2 == 0 {
                                messages.append(DailyChatMessage(content: generateFollowUpQuestion(for: i), isUser: false, isLogMode: false))
                            } else {
                                messages.append(DailyChatMessage(content: generateFollowUpResponse(for: daysAgo, index: i), isUser: true, isLogMode: false))
                            }
                        }
                        
                        ChatSessionManager.shared.saveMessages(messages, for: date)
                        
                        // 60% chance of entry creation
                        let hasEntry = Int.random(in: 1...10) <= 6
                        if hasEntry {
                            DailyContentManager.shared.setHasEntry(true, for: date)
                            DailyContentManager.shared.setEntryMessageCount(messages.filter { $0.isUser }.count, for: date)
                        }
                    }
                }
            }
        }
        
        // Update current date state if needed
        updateCurrentDateState()
        
        // Post notification to update UI
        NotificationCenter.default.post(name: NSNotification.Name("DataPopulationChanged"), object: nil)
    }
    
    private func generateSampleResponse(for daysAgo: Int) -> String {
        let responses = [
            "Had a great day today! Finished some important work and feeling accomplished.",
            "Today was productive. Got through my todo list and even had time for a walk.",
            "Relaxing day. Spent quality time with family and recharged.",
            "Busy but fulfilling day at work. Made progress on the big project.",
            "Good day overall. Made progress on my personal goals.",
            "Challenging day but learned a lot. Tomorrow will be better.",
            "Wonderful day! Everything went smoothly and feeling grateful.",
            "Quiet day of reflection and planning for the week ahead.",
            "Exciting day with new opportunities presenting themselves.",
            "Normal day, nothing too special but content with the progress.",
            "Great workout and healthy meals today. Feeling energized.",
            "Creative day, worked on personal projects and feeling inspired.",
            "Social day, caught up with friends over coffee.",
            "Focused day of deep work. Got a lot done.",
            "Mixed day with ups and downs, but ending on a positive note."
        ]
        return responses[min(daysAgo % responses.count, responses.count - 1)]
    }
    
    private func generateFollowUpQuestion(for index: Int) -> String {
        let questions = [
            "What was the highlight of your day?",
            "How are you feeling about tomorrow?",
            "Did anything unexpected happen?",
            "What are you grateful for today?",
            "Any challenges you overcame?"
        ]
        return questions[index % questions.count]
    }
    
    private func generateFollowUpResponse(for daysAgo: Int, index: Int) -> String {
        let responses = [
            "The highlight was definitely completing that presentation I've been working on.",
            "Looking forward to tomorrow! Have some exciting meetings planned.",
            "Actually yes, ran into an old friend at the coffee shop. It was nice catching up.",
            "Grateful for my health and the support of my family.",
            "Yes, finally figured out that bug that's been bothering me for days!"
        ]
        return responses[(daysAgo + index) % responses.count]
    }
    
    private func updateCurrentDateState() {
        // Check if there are existing chat messages for the current date
        let existingMessages = ChatSessionManager.shared.getMessages(for: selectedDate)
        if !existingMessages.isEmpty {
            hasInteractedWithChat = true
            chatCompleted = true
            chatMessageCount = existingMessages.filter { $0.isUser }.count
        }
        
        // Check if entry exists for current date
        entryCreated = DailyContentManager.shared.hasEntry(for: selectedDate)
        summaryGenerated = DailyContentManager.shared.hasSummary(for: selectedDate)
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
                    Image(dayOneIcon: .checkmark_circle_filled)
                        .foregroundStyle(.green)
                        .font(.title3)
                } else {
                    Image(dayOneIcon: .checkbox_empty)
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
                    Image(dayOneIcon: .checkmark_circle_filled)
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
                    Image(dayOneIcon: .checkmark_circle_filled)
                        .foregroundStyle(.green)
                        .font(.title3)
                } else {
                    Image(dayOneIcon: .checkbox_empty)
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
                
                Image(dayOneIcon: isCompleted ? .checkmark_circle_filled : .checkbox_empty)
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
            Image(dayOneIcon: .weather_partly_cloudy)
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
            Image(dayOneIcon: .pen_edit)
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
            Image(dayOneIcon: .calendar_clock)
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

// Chat Message Bubble View
struct ChatMessageBubbleView: View {
    let dayOfWeek: String
    @State private var animateIn = false
    
    var body: some View {
        HStack {
            Text("How's your \(dayOfWeek)?")
                .font(.body)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Spacer()
        }
        .padding(.horizontal, 16)
        .offset(y: animateIn ? 0 : 40)
        .opacity(animateIn ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                animateIn = true
            }
        }
        .onDisappear {
            animateIn = false
        }
    }
}

// Chat Input Box View
struct ChatInputBoxView: View {
    let action: () -> Void
    @State private var showCursor = true
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                HStack(spacing: 0) {
                    // Blinking cursor
                    Rectangle()
                        .fill(Color(hex: "44C0FF"))
                        .frame(width: 2, height: 24)
                        .opacity(showCursor ? 1 : 0)
                    
                    Text("Chat about your day...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(dayOneIcon: .microphone)
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                
                Image(dayOneIcon: .arrow_up_circle_filled)
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "44C0FF"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                showCursor.toggle()
            }
        }
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


// MARK: - Moments Carousel View
struct MomentsCarouselView: View {
    @Binding var showingMoments: Bool
    @Binding var momentsInitialSection: String?
    @StateObject private var momentsSelection = MomentsSelectionManager.shared
    
    struct MomentCategory {
        let title: String
        let icon: String
        let count: Int
        let color: Color
    }
    
    let categories = [
        MomentCategory(title: "Visits", icon: "location.fill", count: 5, color: Color(hex: "44C0FF")),
        MomentCategory(title: "Media", icon: "photo.fill", count: 12, color: Color(hex: "44C0FF")),
        MomentCategory(title: "Events", icon: "calendar", count: 3, color: Color(hex: "44C0FF")),
        MomentCategory(title: "Health", icon: "heart.fill", count: 8, color: Color(hex: "44C0FF"))
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Summary item (shown when there are selections)
                if momentsSelection.hasSelections {
                    Text(momentsSelection.selectionSummary)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .padding(12)
                        .frame(width: 163, height: 84) // 2/3 of 244 = ~163
                        .background(Color(hex: "F3F1F8"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.leading, 20)
                }
                
                // Regular category items
                ForEach(Array(categories.enumerated()), id: \.element.title) { index, category in
                    Button(action: {
                        momentsInitialSection = category.title
                        showingMoments = true
                    }) {
                        VStack(spacing: 0) {
                            // Icon
                            Image(systemName: category.icon)
                                .font(.system(size: 28))
                                .foregroundStyle(category.color)
                                .frame(maxHeight: .infinity)
                            
                            // Count label with menu for Visits
                            if category.title == "Visits" {
                                HStack(spacing: 4) {
                                    Text("\(category.count) \(category.title)")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                    
                                    Menu {
                                        Button("Home - 6:00 AM") {
                                            // TODO: Open new entry for Home visit
                                        }
                                        Button("Starbucks - 8:15 AM") {
                                            // TODO: Open new entry for Starbucks visit
                                        }
                                        Button("Office - 9:30 AM") {
                                            // TODO: Open new entry for Office visit
                                        }
                                        Button("Gym - 12:30 PM") {
                                            // TODO: Open new entry for Gym visit
                                        }
                                        Button("Park - 5:30 PM") {
                                            // TODO: Open new entry for Park visit
                                        }
                                    } label: {
                                        Image(dayOneIcon: .dots_horizontal)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }
                                    .onTapGesture {
                                        // Prevent button tap when menu is tapped
                                    }
                                }
                                .padding(.bottom, 8)
                            } else {
                                Text("\(category.count) \(category.title)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 8)
                            }
                        }
                        .frame(width: 116, height: 84)
                        .background(Color(hex: "F3F1F8"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, index == 0 && !momentsSelection.hasSelections ? 20 : 0)
                    .padding(.trailing, 0)
                }
                
                // Settings button
                Button(action: {
                    // TODO: Open moments settings
                }) {
                    Image(dayOneIcon: .settings)
                        .font(.system(size: 24))
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .frame(width: 60, height: 84)
                        .background(Color(hex: "F3F1F8"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 20)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Entry Links Carousel View
struct EntryLinksCarouselView: View {
    let selectedDate: Date
    @Binding var showingEntries: Bool
    @Binding var showingOnThisDay: Bool
    
    var body: some View {
        let entryCount = DailyDataManager.shared.getEntryCount(for: selectedDate)
        let onThisDayCount = DailyDataManager.shared.getOnThisDayCount(for: selectedDate)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Entries button (shown first if > 0)
                if entryCount > 0 {
                    Button(action: { 
                        showingEntries = true
                    }) {
                        Text("\(entryCount) \(entryCount == 1 ? "Entry" : "Entries")")
                            .font(.system(size: 13))
                            .fontWeight(.regular)
                            .foregroundStyle(Color.primary.opacity(0.8))
                            .frame(height: 38)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "F3F1F8"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 20)
                }
                
                // On This Day button (shown second if > 0)
                if onThisDayCount > 0 {
                    Button(action: { 
                        showingOnThisDay = true
                    }) {
                        Text("\(onThisDayCount) On This Day")
                            .font(.system(size: 13))
                            .fontWeight(.regular)
                            .foregroundStyle(Color.primary.opacity(0.8))
                            .frame(height: 38)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "F3F1F8"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, entryCount == 0 ? 20 : 0)
                    .padding(.trailing, 20)
                }
            }
            .padding(.top, 12) // Add padding above buttons
        }
    }
}

// MARK: - Places Sheet View
struct VisitsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingEntryView = false
    @State private var selectedVisitName: String = ""
    
    // Sample visits data matching MomentsView
    private let visits = [
        (name: "Sundance Mountain Resort", icon: DayOneIcon.skiing, time: "3 hours"),
        (name: "Whole Foods Market", icon: DayOneIcon.cart, time: "45 min"),
        (name: "Park City Library", icon: DayOneIcon.books_filled, time: "1 hour"),
        (name: "Starbucks Coffee", icon: DayOneIcon.food, time: "30 min"),
        (name: "Silver Lake Trail", icon: DayOneIcon.hiking, time: "2 hours")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header text
                Text("Create an entry from any visit")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                // Visits list
                List {
                    ForEach(visits, id: \.name) { visit in
                        Button(action: {
                            selectedVisitName = visit.name
                            showingEntryView = true
                        }) {
                            HStack(spacing: 12) {
                                // Icon
                                Image(dayOneIcon: visit.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .frame(width: 32, height: 32)
                                
                                // Visit details
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(visit.name)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    
                                    Text(visit.time)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                // Ellipsis menu
                                Menu {
                                    Button(action: {
                                        selectedVisitName = visit.name
                                        showingEntryView = true
                                    }) {
                                        Label("Create Entry", dayOneIcon: .pen_edit)
                                    }
                                    
                                    Button(action: {
                                        // Handle select nearby place
                                    }) {
                                        Label("Select Nearby Place", dayOneIcon: .map_pin)
                                    }
                                    
                                    Button(action: {
                                        // Handle hide
                                    }) {
                                        Label("Hide", dayOneIcon: .eye_cross)
                                    }
                                } label: {
                                    Image(dayOneIcon: .dots_horizontal)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .menuStyle(.borderlessButton)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                // Handle hide action
                            }) {
                                Label("Hide", dayOneIcon: .eye_cross)
                            }
                            .tint(.gray)
                            
                            Button(action: {
                                // Handle edit action
                            }) {
                                Label("Edit", dayOneIcon: .pen)
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("View All") {
                        // TODO: Handle View All action
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Places")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
        .sheet(isPresented: $showingEntryView) {
            EntryView(
                journal: nil,
                prompt: selectedVisitName + "\n\n",
                startInEditMode: true
            )
        }
    }
}

// MARK: - Events Sheet View
struct EventsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingEntryView = false
    @State private var selectedEventName: String = ""
    
    // Sample events data
    private let events = [
        (name: "Morning Team Standup", icon: DayOneIcon.users_group, time: "9:00 AM - 9:30 AM", type: "Work"),
        (name: "Dentist Appointment", icon: DayOneIcon.health, time: "11:00 AM - 12:00 PM", type: "Health"),
        (name: "Lunch with Sarah", icon: DayOneIcon.fork_knife, time: "12:30 PM - 1:30 PM", type: "Personal"),
        (name: "Project Review Meeting", icon: DayOneIcon.stats, time: "2:00 PM - 3:00 PM", type: "Work"),
        (name: "Yoga Class", icon: DayOneIcon.yoga, time: "5:30 PM - 6:30 PM", type: "Wellness")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header text
                Text("Create an entry from any event")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                // Events list
                List {
                    ForEach(events, id: \.name) { event in
                        Button(action: {
                            selectedEventName = event.name
                            showingEntryView = true
                        }) {
                            HStack(spacing: 12) {
                                // Icon
                                Image(dayOneIcon: event.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .frame(width: 32, height: 32)
                                
                                // Event details
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.name)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    
                                    HStack(spacing: 4) {
                                        Text(event.time)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        Text("·")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        Text(event.type)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // Ellipsis menu
                                Menu {
                                    Button(action: {
                                        selectedEventName = event.name
                                        showingEntryView = true
                                    }) {
                                        Label("Create Entry", dayOneIcon: .pen_edit)
                                    }
                                    
                                    Button(action: {
                                        // Handle edit event
                                    }) {
                                        Label("Edit Event", dayOneIcon: .pen)
                                    }
                                    
                                    Button(action: {
                                        // Handle hide
                                    }) {
                                        Label("Hide", dayOneIcon: .eye_cross)
                                    }
                                } label: {
                                    Image(dayOneIcon: .dots_horizontal)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .menuStyle(.borderlessButton)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                // Handle hide action
                            }) {
                                Label("Hide", dayOneIcon: .eye_cross)
                            }
                            .tint(.gray)
                            
                            Button(action: {
                                // Handle edit action
                            }) {
                                Label("Edit", dayOneIcon: .pen)
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Calendars") {
                        // TODO: Handle Calendars action
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Events")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
        .sheet(isPresented: $showingEntryView) {
            EntryView(
                journal: nil,
                prompt: selectedEventName + "\n\n",
                startInEditMode: true
            )
        }
    }
}

struct MediaSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingEntryView = false
    @State private var selectedImageIndex: Int = 0
    
    // Placeholder colors for the media grid
    private let mediaColors: [Color] = [
        Color(hex: "44C0FF").opacity(0.3),
        Color(hex: "FF6B6B").opacity(0.3),
        Color(hex: "4ECDC4").opacity(0.3),
        Color(hex: "FFD93D").opacity(0.3),
        Color(hex: "6BCF7F").opacity(0.3),
        Color(hex: "A8E6CF").opacity(0.3),
        Color(hex: "FF8B94").opacity(0.3),
        Color(hex: "C1E1DC").opacity(0.3),
        Color(hex: "FFB6C1").opacity(0.3),
        Color(hex: "B4A7D6").opacity(0.3),
        Color(hex: "FFE4B5").opacity(0.3),
        Color(hex: "E0BBE4").opacity(0.3)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header text
                Text("Tap any photo to create an entry")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                // Media grid - 4 columns x 3 rows
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                    ForEach(0..<12) { index in
                        Button(action: {
                            selectedImageIndex = index
                            showingEntryView = true
                        }) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(mediaColors[index])
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(
                                    Image(dayOneIcon: .photo)
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white.opacity(0.5))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Media")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
        .sheet(isPresented: $showingEntryView) {
            EntryView(
                journal: nil,
                prompt: "Photo memory\n\n",
                startInEditMode: true
            )
        }
    }
}

// MARK: - Keyboard Handling
struct KeyboardHandler: UIViewRepresentable {
    let onLeftArrow: () -> Void
    let onRightArrow: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = KeyboardView()
        view.onLeftArrow = onLeftArrow
        view.onRightArrow = onRightArrow
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    class KeyboardView: UIView {
        var onLeftArrow: (() -> Void)?
        var onRightArrow: (() -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        private func setup() {
            backgroundColor = .clear
            isUserInteractionEnabled = true
        }
        
        override var canBecomeFirstResponder: Bool { true }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            if window != nil {
                DispatchQueue.main.async {
                    self.becomeFirstResponder()
                }
            }
        }
        
        @objc private func leftArrowPressed() {
            onLeftArrow?()
        }
        
        @objc private func rightArrowPressed() {
            onRightArrow?()
        }
        
        override var keyCommands: [UIKeyCommand]? {
            return [
                UIKeyCommand(
                    input: UIKeyCommand.inputLeftArrow,
                    modifierFlags: [],
                    action: #selector(leftArrowPressed)
                ),
                UIKeyCommand(
                    input: UIKeyCommand.inputRightArrow,
                    modifierFlags: [],
                    action: #selector(rightArrowPressed)
                )
            ]
        }
    }
}

// MARK: - Journal Selection View
struct JournalSelectionView: View {
    @Binding var selectedJournal: String
    let onSelection: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    // Sample journals
    private let journals = [
        "Daily",
        "Personal",
        "Work",
        "Travel",
        "Gratitude",
        "Dreams",
        "Fitness"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(journals, id: \.self) { journal in
                    Button(action: {
                        selectedJournal = journal
                        onSelection()
                    }) {
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.green)
                                .frame(width: 28, height: 28)
                            
                            Text(journal)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if selectedJournal == journal {
                                Image(dayOneIcon: .checkmark)
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TodayView()
}
