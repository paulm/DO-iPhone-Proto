import SwiftUI
import TipKit
import UIKit

// MARK: - Style Options
enum TodayViewStyle: String, CaseIterable {
    case standard = "Standard"
}

/// Today tab view
struct TodayView: View {
    @State private var showingSettings = false
    @State private var showingDatePicker = false
    @State private var showingDailySurvey = false
    @State private var showingTrackers = false
    @State private var selectedDate = Date()
    @State private var surveyCompleted = false

    // Trackers state
    @State private var moodRating = 0
    @State private var energyRating = 0
    @State private var stressRating = 0
    @State private var foodInput = ""
    @State private var dailyIntentionInput = ""
    @State private var prioritiesInput = ""
    @State private var mediaInput = ""
    @State private var peopleInput = ""

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
    @State private var entryData: EntryView.EntryData? = nil
    @State private var isGeneratingEntry = false
    @State private var chatUpdateTrigger = false
    @State private var showingJournalSelectionAlert = false
    @State private var showingJournalPicker = false
    @AppStorage("hasShownFirstTimeJournalAlert") private var hasShownFirstTimeJournalAlert = false
    @AppStorage("selectedJournalForEntries") private var selectedJournalForEntries = "Daily"
    @State private var showingVisitsSheet = false
    @State private var showingMomentsVisitsSheet = false
    @State private var showingEventsSheet = false
    @State private var showingMomentsEventsSheet = false
    @State private var showingMediaSheet = false
    @State private var showingMomentsMediaSheet = false
    @State private var placesData: [Visit] = []
    @State private var eventsData: [(name: String, icon: DayOneIcon, time: String, type: String)] = []
    @State private var selectedMomentsPlaces: Set<String> = []
    @State private var selectedMomentsEvents: Set<String> = []
    @State private var selectedMomentsPhotos: Set<String> = []
    @State private var showingMomentsTrackersSheet = false
    @State private var showingMomentsInputsSheet = false
    @State private var selectedMomentsTrackers: [String: Int] = [:] // tracker name -> rating (1-5)
    @State private var showingBio = false
    @State private var showingChatSettings = false
    @State private var showingChatCalendar = false

    // Show/hide toggles for Daily Activities
    @State private var showDatePickerGrid = false
    @State private var showDatePickerRow = true
    @State private var showDateNavigation = true
    @State private var showMoments = true
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

    // Layout Constants
    private let momentsSectionSpacing: CGFloat = 8

    @AppStorage("showChatFAB") private var showChatFAB = false
    @AppStorage("showEntryFAB") private var showEntryFAB = false
    @AppStorage("showChatInputBox") private var showChatInputBox = false
    @AppStorage("showChatMessage") private var showChatMessage = false
    @AppStorage("showDailyEntryChat") private var showDailyEntryChat = true
    @AppStorage("showLogVoiceModeButtons") private var showLogVoiceModeButtons = false
    @AppStorage("showBioSection") private var showBioSection = false
    @AppStorage("todayViewStyle") private var selectedStyle = TodayViewStyle.standard
    @AppStorage("showWelcomeToTodaySheet") private var showWelcomeToTodaySheet = false

    // Sheet presentation state
    @State private var shouldPresentWelcomeSheet = false

    private var hasMomentsSelected: Bool {
        !selectedMomentsPlaces.isEmpty || !selectedMomentsEvents.isEmpty || !selectedMomentsPhotos.isEmpty
    }

    private var dateRange: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        let today = Date()

        // Calculate how many dates we need based on screen width
        // Account for horizontal padding (16pt on each side)
        let approximateWidth = UIScreen.main.bounds.width - (DatePickerConstants.horizontalPadding * 2)
        let columnsPerRow = Int((approximateWidth + DatePickerConstants.spacing) / (DatePickerConstants.circleSize + DatePickerConstants.spacing))
        let totalDates = columnsPerRow * DatePickerConstants.numberOfRows

        // Calculate the starting date to ensure we end at least 5 days in the future (for Date Picker Row)
        let endDate = 5
        let startDate = endDate - totalDates + 1

        // Generate dates from calculated start to 5 days in the future
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
        return Color(UIColor.secondarySystemGroupedBackground)
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

    // Extract Daily Chat section as computed property
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
                    Text("Daily Chat")
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
                    entryData: $entryData,
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

    // Moments Section - Photos
    @ViewBuilder
    private var momentsPhotosSection: some View {
        Section {
            Button(action: {
                showingMomentsMediaSheet = true
            }) {
                HStack(alignment: .center, spacing: 12) {
                    // Left icon - fixed width
                    Image(dayOneIcon: .photo)
                        .font(.system(size: 20))
                        .foregroundStyle(BrandColors.journalLavender)
                        .frame(width: 32)

                    if selectedMomentsPhotos.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Photos")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            Text("Select notable photos...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("Select from 12")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    } else {
                        // Show photo thumbnails horizontally in a scrollable container
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(Array(selectedMomentsPhotos).sorted(), id: \.self) { photoId in
                                    if let index = Int(photoId.replacingOccurrences(of: "photo_", with: "")) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(photoColors[index % photoColors.count])
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .frame(height: 44)

                        // Right side indicator - fixed
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsPhotos.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .frame(minHeight: 44)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(cellBackgroundColor)
    }

    // Moments Section - Places
    @ViewBuilder
    private var momentsPlacesSection: some View {
        Section {
            Button(action: {
                showingMomentsVisitsSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(dayOneIcon: .map_pin)
                        .font(.system(size: 20))
                        .foregroundStyle(BrandColors.journalAqua)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Places")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if selectedMomentsPlaces.isEmpty {
                            Text("Select notable visits...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(Array(selectedMomentsPlaces).sorted().joined(separator: ", "))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                    }

                    Spacer()

                    if selectedMomentsPlaces.isEmpty {
                        Text("Select from \(placesData.count)")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    } else {
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsPlaces.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(cellBackgroundColor)
    }

    // Moments Section - Events
    @ViewBuilder
    private var momentsEventsSection: some View {
        Section {
            Button(action: {
                showingMomentsEventsSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(dayOneIcon: .calendar)
                        .font(.system(size: 20))
                        .foregroundStyle(BrandColors.journalFire)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Events")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if selectedMomentsEvents.isEmpty {
                            Text("Select notable events...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(Array(selectedMomentsEvents).sorted().joined(separator: ", "))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                    }

                    Spacer()

                    if selectedMomentsEvents.isEmpty {
                        Text("Select from \(eventsData.count)")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    } else {
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsEvents.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(cellBackgroundColor)
    }

    // Moments Section - Trackers
    @ViewBuilder
    private var momentsTrackersSection: some View {
        Section {
            Button(action: {
                showingMomentsTrackersSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20))
                        .foregroundStyle(.orange)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trackers")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if selectedMomentsTrackers.isEmpty {
                            Text("Track mood, energy, and stress...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(selectedMomentsTrackers.sorted(by: { $0.key < $1.key }).map { "\($0.key): \($0.value)" }.joined(separator: ", "))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                    }

                    Spacer()

                    if selectedMomentsTrackers.isEmpty {
                        let hour = Calendar.current.component(.hour, from: Date())
                        let timeOfDay = hour < 12 ? "AM" : "PM"
                        Text("Input \(timeOfDay)")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    } else {
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsTrackers.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(cellBackgroundColor)
    }

    // Moments Section - Inputs
    @ViewBuilder
    private var momentsInputsSection: some View {
        Section {
            Button(action: {
                showingMomentsInputsSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 20))
                        .foregroundStyle(BrandColors.journalGreen)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Inputs")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if hasInputsData {
                            Text(completedInputsList)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        } else {
                            Text("Add text inputs...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if hasInputsData {
                        HStack(spacing: 4) {
                            Text("\(completedInputsCount)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    } else {
                        Text("Log Daily Details")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: momentsSectionSpacing, leading: 16, bottom: momentsSectionSpacing, trailing: 16))
        .listRowBackground(cellBackgroundColor)
    }

    private var hasInputsData: Bool {
        !foodInput.isEmpty || !dailyIntentionInput.isEmpty || !prioritiesInput.isEmpty || !mediaInput.isEmpty || !peopleInput.isEmpty
    }

    private var completedInputsCount: Int {
        var count = 0
        if !foodInput.isEmpty { count += 1 }
        if !dailyIntentionInput.isEmpty { count += 1 }
        if !prioritiesInput.isEmpty { count += 1 }
        if !mediaInput.isEmpty { count += 1 }
        if !peopleInput.isEmpty { count += 1 }
        return count
    }

    private var completedInputsList: String {
        var inputs: [String] = []
        if !foodInput.isEmpty { inputs.append(foodInput) }
        if !dailyIntentionInput.isEmpty { inputs.append(dailyIntentionInput) }
        if !prioritiesInput.isEmpty { inputs.append(prioritiesInput) }
        if !mediaInput.isEmpty { inputs.append(mediaInput) }
        if !peopleInput.isEmpty { inputs.append(peopleInput) }
        return inputs.joined(separator: ", ")
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
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDate = Date()
                        }
                    }) {
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
                    }
                    .buttonStyle(PlainButtonStyle())

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
            ScrollViewReader { proxy in
                List {
                    // Initial scroll anchor
                    Color.clear
                        .frame(height: 0)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .id("scrollAnchor")

                    // Date picker grid at top of scrollable content (off by default for now)
                    if showDatePickerGrid {
                        DatePickerGrid(
                            dates: dateRange,
                            selectedDate: $selectedDate,
                            showingChatCalendar: $showingChatCalendar,
                            showDates: false,
                            showStreak: false
                        )
                        .padding(.horizontal, DatePickerConstants.horizontalPadding)
                        .id(chatUpdateTrigger) // Force refresh when data changes
                        .background(Color.clear)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets()) // Remove default list insets
                        .padding(.bottom, 20)
                    }

                    // Date picker row (single row version)
                    if showDatePickerRow {
                        DatePickerRow(
                            dates: dateRange,
                            selectedDate: $selectedDate
                        )
                        .padding(.horizontal, DatePickerConstants.horizontalPadding)
                        .id(chatUpdateTrigger) // Force refresh when data changes
                        .background(Color.clear)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets()) // Remove default list insets
                        .padding(.bottom, 20)
                    }

                    // Date Navigation section
                    dateNavigationSection
                        .id("dateNavigation")

                // Entries Section - Two buttons side by side (no title)
                entryLinksSection

                // Daily Chat Carousel Section
                if showDailyEntryChat {
                    dailyEntryChatSection
                }

                // Moments Section
                if showMoments {
                    momentsEventsSection
                    momentsPlacesSection
                    momentsPhotosSection
                    momentsTrackersSection
                    momentsInputsSection
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
            .gesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height

                        // Only trigger if horizontal swipe is more significant than vertical
                        if abs(horizontalAmount) > abs(verticalAmount) {
                            if horizontalAmount < 0 {
                                // Swipe left - go to next day
                                navigateToNextDay()
                            } else if horizontalAmount > 0 {
                                // Swipe right - go to previous day
                                navigateToPreviousDay()
                            }
                        }
                    }
            )
            } // ScrollViewReader

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
                    Button("Edit Bio") {
                        showingBio = true
                    }

                    Button("Daily Chat Settings") {
                        showingChatSettings = true
                    }

                    Divider()

                    Button("Settings") {
                        showingSettings = true
                    }

                    // DEBUG: Reset first-time journal alert
                    Button("Reset Journal Selection (Debug)") {
                        hasShownFirstTimeJournalAlert = false
                    }

                    Section("Show in Today") {

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
                            showDatePickerRow.toggle()
                        } label: {
                            HStack {
                                Text("Date Picker Row")
                                if showDatePickerRow {
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
                            showMoments.toggle()
                        } label: {
                            HStack {
                                Text("Moments")
                                if showMoments {
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
                            showWelcomeToTodaySheet.toggle()
                        } label: {
                            HStack {
                                Text("Welcome to Today Sheet")
                                if showWelcomeToTodaySheet {
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

                        Button("Add Places") {
                            addPlacesData()
                        }

                        Button("Add Events") {
                            addEventsData()
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
        .sheet(isPresented: $showingVisitsSheet) {
            VisitsSheetView(visits: $placesData, selectedDate: $selectedDate, onAddPlaces: addPlacesData)
        }
        .sheet(isPresented: $showingMomentsVisitsSheet) {
            VisitsSheetView(visits: $placesData, selectedDate: $selectedDate, onAddPlaces: addPlacesData, isForChat: true, selectedPlacesForChat: $selectedMomentsPlaces)
        }
        .sheet(isPresented: $showingEventsSheet) {
            EventsSheetView(events: $eventsData, onAddEvents: addEventsData)
        }
        .sheet(isPresented: $showingMomentsEventsSheet) {
            EventsSheetView(events: $eventsData, onAddEvents: addEventsData, isForChat: true, selectedEventsForChat: $selectedMomentsEvents)
        }
        .sheet(isPresented: $showingMediaSheet) {
            MediaSheetView()
        }
        .sheet(isPresented: $showingMomentsMediaSheet) {
            MediaSheetView(isForChat: true, selectedPhotosForChat: $selectedMomentsPhotos)
        }
        .sheet(isPresented: $showingMomentsTrackersSheet) {
            MomentsTrackersSheetView(selectedTrackers: $selectedMomentsTrackers)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingMomentsInputsSheet) {
            MomentsInputsSheetView(
                foodInput: $foodInput,
                dailyIntentionInput: $dailyIntentionInput,
                prioritiesInput: $prioritiesInput,
                mediaInput: $mediaInput,
                peopleInput: $peopleInput
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
            selectedMomentsPlaces.removeAll()
            selectedMomentsEvents.removeAll()
            selectedMomentsPhotos.removeAll()
            selectedMomentsTrackers.removeAll()

            // Clear tracker data
            moodRating = 0
            energyRating = 0
            stressRating = 0
            foodInput = ""
            dailyIntentionInput = ""
            prioritiesInput = ""
            mediaInput = ""
            peopleInput = ""

            // Update Moments data based on selected date
            updateMomentsDataForSelectedDate()
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
                BioEditView()
            }
        }
        .sheet(isPresented: $showingChatSettings) {
            DailyChatSettingsView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingChatCalendar) {
            DailyChatCalendarView(selectedDate: $selectedDate)
        }
        .onChange(of: showingPreviewEntry) { oldValue, newValue in
            // When sheet is dismissed, check if summary was generated
            if oldValue == true && newValue == false {
                hasViewedSummary = true
                summaryGenerated = DailyContentManager.shared.hasSummary(for: selectedDate)
            }
        }
        .sheet(isPresented: $showingEntry) {
            if let data = entryData {
                // Opening existing entry - Read mode
                EntryView(journal: nil, entryData: data, startInEditMode: false)
                    .onDisappear {
                        entryData = nil
                    }
            } else {
                // New entry with prompt - Edit mode
                EntryView(journal: nil, prompt: selectedPrompt, startInEditMode: true)
                    .onDisappear {
                        selectedPrompt = nil
                    }
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

            // Update Moments data based on selected date
            updateMomentsDataForSelectedDate()

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
        .onChange(of: hasMomentsSelected) { oldValue, newValue in
            // Show Create Entry FAB when any moments are selected
            if newValue {
                showEntryFAB = true
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

    private func addPlacesData() {
        // Generate random visits for the selected date
        placesData = Visit.generateRandomVisits(for: selectedDate)
    }

    private func addEventsData() {
        // Populate with sample events
        eventsData = [
            (name: "Morning Team Standup", icon: DayOneIcon.calendar, time: "9:00 AM - 9:30 AM", type: "Work"),
            (name: "Dentist Appointment", icon: DayOneIcon.calendar, time: "11:00 AM - 12:00 PM", type: "Health"),
            (name: "Lunch with Sarah", icon: DayOneIcon.calendar, time: "12:30 PM - 1:30 PM", type: "Personal"),
            (name: "Project Review Meeting", icon: DayOneIcon.calendar, time: "2:00 PM - 3:00 PM", type: "Work"),
            (name: "Yoga Class", icon: DayOneIcon.calendar, time: "5:30 PM - 6:30 PM", type: "Wellness")
        ]
    }

    private func updateMomentsDataForSelectedDate() {
        // Only show data for today, clear for all other dates
        if Calendar.current.isDateInToday(selectedDate) {
            // Generate random visits for the selected date
            placesData = Visit.generateRandomVisits(for: selectedDate)

            eventsData = [
                (name: "Morning Team Standup", icon: DayOneIcon.calendar, time: "9:00 AM - 9:30 AM", type: "Work"),
                (name: "Dentist Appointment", icon: DayOneIcon.calendar, time: "11:00 AM - 12:00 PM", type: "Health"),
                (name: "Lunch with Sarah", icon: DayOneIcon.calendar, time: "12:30 PM - 1:30 PM", type: "Personal"),
                (name: "Project Review Meeting", icon: DayOneIcon.calendar, time: "2:00 PM - 3:00 PM", type: "Work"),
                (name: "Yoga Class", icon: DayOneIcon.calendar, time: "5:30 PM - 6:30 PM", type: "Wellness")
            ]
        } else {
            // Clear data for non-today dates (show zero state)
            placesData = []
            eventsData = []
        }
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

#Preview {
    TodayView()
}
