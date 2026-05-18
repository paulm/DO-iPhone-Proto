import SwiftUI
import TipKit
import UIKit

// MARK: - Constants
/// Size for toggle disclosure icons (arrow-right-circle)
private let todayToggleIconSize: CGFloat = 24

// MARK: - Style Options

/// Today tab view
struct TodayView: View {
    @State var showingSettings = false
    @State var showingSectionsOrder = false
    @State var showingDatePicker = false
    @State var showingTrackers = false
    @State var selectedDate = DateManager.shared.selectedDate

    // Trackers state
    @State var moodRating = 0
    @State var energyRating = 0
    @State var stressRating = 0
    @State var foodInput = ""
    @State var dailyIntentionInput = ""
    @State var prioritiesInput = ""
    @State var mediaInput = ""
    @State var peopleInput = ""

    @State var showingDailyChat = false
    @State var chatCompleted = false
    @State var openChatInLogMode = false
    @State var openDailyChatInLogMode = false
    @State var chatMessageCount = 0
    @State var showingProfileMenu = false
    @State var showingEnableAIModal = false
    @AppStorage("dailyChatEnabled") var dailyChatEnabled = false
    @AppStorage("aiFeaturesEnabled") var aiFeaturesEnabled = false
    @AppStorage("entryAIFeaturesEnabled") var entryAIFeaturesEnabled = false
    @State var summaryGenerated = false
    @State var hasInteractedWithChat = false
    @State var hasViewedSummary = false

    // Today Insights state
    @State var showingWeather = false
    @State var showingEntries = false
    @State var showingOnThisDay = false
    @State var showingPreviewEntry = false
    @State var entryCreated = false
    @State var showingEntry = false
    @State var entryData: EntryView.EntryData? = nil
    @State var isGeneratingEntry = false
    @State var showingJournalSelectionAlert = false
    @State var showingJournalPicker = false
    @AppStorage("hasShownFirstTimeJournalAlert") var hasShownFirstTimeJournalAlert = false
    @AppStorage("selectedJournalForEntries") var selectedJournalForEntries = "Daily"
    @State var showingMomentsSelector = false
    @State var placesData: [Visit] = []
    @State var eventsData: [(name: String, icon: DayOneIcon, time: String, type: String)] = []
    @State var selectedMomentsPlaces: Set<String> = []
    @State var selectedMomentsEvents: Set<String> = []
    @State var selectedMomentsPhotos: Set<String> = []
    @State var showingMomentsTrackersSheet = false
    @State var showingMomentsInputsSheet = false
    @State var selectedMomentsTrackers: [String: Int] = [:] // tracker name -> rating (1-5)
    @State var showingBio = false
    @State var showingChatSettings = false
    @State var showingChatCalendar = false

    // Show/hide toggles for Daily Activities
    @AppStorage("showDatePickerGrid") var showDatePickerGrid = false
    @AppStorage("showDatePickerRow") var showDatePickerRow = true
    @AppStorage("showDateNavigation") var showDateNavigation = true
    @AppStorage("showEntries") var showEntries = true
    @State var showGuides = false
    @State var selectedPrompt: String? = nil

    // Moments visibility toggles

    // Daily Entry Chat Context toggles

    // TipKit
    private let journalingTip = JournalingMadeEasyTip()

    // Layout Constants
    private let momentsSectionSpacing: CGFloat = 8
    private let todaySectionSpacing: CGFloat = 16
    private let todayInterSectionSpacing: CGFloat = 24 // Spacing between major sections

    @AppStorage("showChatFAB") var showChatFAB = false
    @AppStorage("showEntryFAB") var showEntryFAB = false
    @AppStorage("showChatInputBox") var showChatInputBox = false
    @AppStorage("showDailyEntry") var showDailyEntry = true
    @AppStorage("showDailyChat") var showDailyChat = true
    @AppStorage("showMoments") var showMoments = true
    @AppStorage("showTrackers") var showTrackers = true
    @AppStorage("showInputs") var showInputs = true
    @AppStorage("showBioSection") var showBioSection = false
    @AppStorage("showGoldSection") var showGoldSection = true
    @State var showGoldCelebration = false
    @State var showSilverCelebration = false

    // Section expansion states
    @State var dailyEntryExpanded = false
    @State var dailyChatExpanded = false
    @State var momentsExpanded = false
    @State var trackersExpanded = false
    @State var inputsExpanded = false
    @AppStorage("todayViewStyle") var selectedStyle = TodayViewStyle.standard
    @AppStorage("showWelcomeToTodaySheet") var showWelcomeToTodaySheet = false
    @AppStorage("sectionOrder") var sectionOrderData: Data = {
        let encoder = JSONEncoder()
        return (try? encoder.encode(SectionItem.allSections)) ?? Data()
    }()

    // Sheet presentation state
    @State var shouldPresentWelcomeSheet = false
    @State var sectionOrder: [SectionItem] = SectionItem.allSections

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

        // Calculate the starting date to ensure we end at least 2 days in the future (for Date Picker Row)
        let endDate = 2
        let startDate = endDate - totalDates + 1

        // Generate dates from calculated start to 2 days in the future
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

    // Helper function to check AI features before opening daily chat
    private func openDailyChatIfEnabled() {
        if dailyChatEnabled {
            showingDailyChat = true
        } else {
            showingEnableAIModal = true
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

    // MARK: - Moments Collapsed State Helpers

    // Generate realistic moment counts based on date (allows zeros)
    private func momentCount(for date: Date, type: String, maxCount: Int) -> Int {
        guard maxCount > 0 else { return 0 }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        // Create a consistent seed from the date and type (use smaller numbers to avoid overflow)
        let seed = ((components.year ?? 2024) % 100) * 10000 + (components.month ?? 1) * 100 + (components.day ?? 1)

        // Use a simpler hash to avoid overflow
        var hasher = Hasher()
        hasher.combine(seed)
        hasher.combine(type)
        let hashValue = abs(hasher.finalize())

        // Use seed to generate pseudo-random but consistent value
        let value = hashValue % 100

        // Different probability distributions based on value
        // ~20% chance of 0, ~50% chance of 1-2, ~30% chance of 3+
        if value < 20 {
            return 0  // No moments this day
        } else if value < 70 {
            // 1-2 items
            if maxCount == 1 {
                return 1
            } else {
                return 1 + (hashValue % 2)
            }
        } else {
            // 3 to maxCount items
            if maxCount <= 3 {
                return min(maxCount, 3)
            } else {
                let range = maxCount - 2
                return 3 + (hashValue % range)
            }
        }
    }

    private var availablePhotosCount: Int {
        momentCount(for: selectedDate, type: "photos", maxCount: 12)
    }

    private var dynamicPlacesCount: Int {
        momentCount(for: selectedDate, type: "places", maxCount: 6)
    }

    private var dynamicEventsCount: Int {
        momentCount(for: selectedDate, type: "events", maxCount: 5)
    }

    private var momentsCollapsedSummary: String {
        let totalSelected = selectedMomentsPhotos.count + selectedMomentsPlaces.count + selectedMomentsEvents.count
        if totalSelected == 0 {
            return "Select..."
        } else {
            return "\(totalSelected) Selected"
        }
    }

    private var momentsButtonColor: Color {
        let totalSelected = selectedMomentsPhotos.count + selectedMomentsPlaces.count + selectedMomentsEvents.count
        return totalSelected == 0 ? Color(hex: "44C0FF") : Color(hex: "34C759")
    }

    private var hasTrackersData: Bool {
        return !selectedMomentsTrackers.isEmpty
    }

    private var trackerTimeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 12 ? "AM" : "PM"
    }

    private var currentEntryTitle: String {
        guard DailyContentManager.shared.hasEntry(for: selectedDate) else {
            return "Daily Entry"
        }

        // Get sample entry content that varies by date
        let entryContent = getSampleEntryContent(for: selectedDate)

        // Extract title from Markdown H1 or use first line
        if let h1Title = entryContent.extractMarkdownTitle() {
            return h1Title
        }

        // Fallback: use first non-empty line
        let firstLine = entryContent.components(separatedBy: .newlines)
            .first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) ?? ""

        return firstLine.isEmpty ? "Untitled Entry" : firstLine
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
            NotificationCenter.default.post(name: .dailyEntryCreatedStatusChanged, object: selectedDate)
        }
    }

    // Daily Chat section - collapsible
    @ViewBuilder
    private var dailyChatSection: some View {
        // Header
        Section {
            HStack(spacing: 12) {
                // Title
                Text("Daily Chat")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "292F33"))

                Spacer()

                // Primary action button when collapsed
                if !dailyChatExpanded {
                    Button(action: {
                        openDailyChatIfEnabled()
                    }) {
                        Text(chatCompleted ? "Resume Chat" : (Calendar.current.isDateInToday(selectedDate) ? "Chat About Today" : "Start Chat"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(chatCompleted ? Color.primary : Color.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(chatCompleted ? Color(hex: "E0DEE5") : Color(hex: "44C0FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Toggle arrow - always on the far right
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dailyChatExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(dailyChatExpanded ? 90 : 0))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if dailyChatExpanded {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // TipKit tip
                    TipView(journalingTip)
                        .tipViewStyle(CustomJournalingTipViewStyle())
                        .padding(.bottom, 8)

                    // Welcome prompt - only show when no chat has taken place
                    if !chatCompleted && !DailyContentManager.shared.hasEntry(for: selectedDate) {
                        Text(dailyEntryChatPromptText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)
                    }

                    // Chat interface wrapped in gray rounded rectangle
                    VStack(spacing: 12) {
                        // Last AI message preview
                        if chatCompleted {
                            let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                            let lastAIMessage = messages.last(where: { !$0.isUser })

                            if let lastMessage = lastAIMessage {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(lastMessage.content)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .id("\(selectedDate)-\(messages.count)")
                            }
                        }

                        // Resume Chat or Start Chat button
                        Button(action: {
                            openDailyChatIfEnabled()
                        }) {
                            HStack(spacing: 8) {
                                Image(dayOneIcon: chatCompleted ? .message : .comment)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(chatCompleted ? Color.primary : Color.white)

                                Text(chatCompleted ? "Resume Chat" : (Calendar.current.isDateInToday(selectedDate) ? "Chat About Today" : "Start Chat"))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(chatCompleted ? Color.primary : Color.white)
                            }
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(chatCompleted ? Color(hex: "E0DEE5") : Color(hex: "44C0FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            .animation(nil, value: selectedDate)
            .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
            .listRowBackground(showGuides ? Color.green.opacity(0.2) : cellBackgroundColor)
            .listRowSeparator(.hidden)
        }
    }

    // Daily Entry section - collapsible
    @ViewBuilder
    private var dailyEntrySection: some View {
        // Header
        Section {
            HStack(alignment: .top, spacing: 12) {
                // Dynamic title based on entry state
                let hasEntry = DailyContentManager.shared.hasEntry(for: selectedDate)

                if dailyEntryExpanded {
                    // EXPANDED STATE: Multi-line title with wrapping
                    Text(hasEntry ? currentEntryTitle : "Daily Entry")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "292F33"))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    // COLLAPSED STATE: Single-line title with ellipsis
                    Text(hasEntry ? currentEntryTitle : "Daily Entry")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "292F33"))
                        .lineLimit(1)
                }

                Spacer()

                // Contextual buttons when collapsed
                if !dailyEntryExpanded {
                    let hasNewMessages = DailyContentManager.shared.hasNewMessagesSinceEntry(for: selectedDate)

                    // Show only ONE button based on priority: Update Entry > View Entry > Generate Entry
                    if hasEntry && hasNewMessages && !isGeneratingEntry {
                        // Priority 1: Update Entry (when entry exists and there are new messages)
                        Button(action: {
                            NotificationCenter.default.post(
                                name: .triggerEntryGeneration,
                                object: selectedDate
                            )
                        }) {
                            Text("Update Entry")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else if hasEntry {
                        // Priority 2: View Entry (when entry exists but no new messages)
                        Button(action: {
                            let entryContent = getSampleEntryContent(for: selectedDate)
                            let data = EntryView.EntryData(
                                title: entryContent.extractMarkdownTitle() ?? "Untitled Entry",
                                content: entryContent,
                                date: selectedDate,
                                time: formatTime(selectedDate)
                            )
                            entryData = data
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                showingEntry = true
                            }
                        }) {
                            Text("View Entry")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(hex: "44C0FF"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "44C0FF").opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else if chatCompleted {
                        // Priority 3: Generate Entry (when chat exists but no entry)
                        Button(action: {
                            if !isGeneratingEntry {
                                NotificationCenter.default.post(
                                    name: .triggerEntryGeneration,
                                    object: selectedDate
                                )
                            }
                        }) {
                            Text("Generate Entry")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isGeneratingEntry)
                    }
                    // else: No buttons shown when no chat and no entry
                }

                // Toggle arrow - always on the far right
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dailyEntryExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(dailyEntryExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: dailyEntryExpanded)
                }
                .buttonStyle(PlainButtonStyle())
                .animation(nil, value: dailyEntryExpanded)
            }
            .padding(.horizontal, 16)
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if dailyEntryExpanded {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // Entry display or generate button (no gray wrapper)
                    if DailyContentManager.shared.hasEntry(for: selectedDate) {
                        // Entry exists - show preview
                        Button(action: {
                            let entryContent = getSampleEntryContent(for: selectedDate)
                            let data = EntryView.EntryData(
                                title: entryContent.extractMarkdownTitle() ?? "Untitled Entry",
                                content: entryContent,
                                date: selectedDate,
                                time: formatTime(selectedDate)
                            )
                            entryData = data
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                showingEntry = true
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                // REMOVED: Redundant title display
                                // Title now only appears in section header

                                Text("Today I started with my usual morning routine, feeling energized and ready for the day ahead. The weather was perfect...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)

                                HStack(spacing: 4) {
                                    Text("Daily")
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color(hex: "44C0FF"))

                                    Text("•")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)

                                    Text("Salt Lake City, Utah")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)

                                    Text("•")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)

                                    Text("Partly Cloudy 63° - 82°")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Update Entry button if there are new messages
                        if DailyContentManager.shared.hasNewMessagesSinceEntry(for: selectedDate) && !isGeneratingEntry {
                            Button(action: {
                                // Post notification to trigger entry generation
                                NotificationCenter.default.post(
                                    name: .triggerEntryGeneration,
                                    object: selectedDate
                                )
                            }) {
                                HStack(spacing: 8) {
                                    Image(dayOneIcon: .loop)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)

                                    Text("Update Entry")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else if chatCompleted {
                        // Chat exists but no entry - show Generate Entry button
                        Button(action: {
                            if !isGeneratingEntry {
                                NotificationCenter.default.post(
                                    name: .triggerEntryGeneration,
                                    object: selectedDate
                                )
                            }
                        }) {
                            if isGeneratingEntry {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)

                                    Text("Generating...")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            } else {
                                HStack(spacing: 8) {
                                    Image(dayOneIcon: .document)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)

                                    Text("Generate Entry")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isGeneratingEntry)
                    } else {
                        // No chat and no entry - show placeholder
                        Text("Start a chat to generate an entry")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 24)
                    }
                }
            }
            .animation(nil, value: selectedDate)
            .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
            .listRowBackground(showGuides ? Color.blue.opacity(0.2) : cellBackgroundColor)
            .listRowSeparator(.hidden)
        }
    }

    // Helper method for formatting time
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    // Moments Section - Photos
    @ViewBuilder
    private var momentsPhotosSection: some View {
        Section {
            Button(action: {
                showingMomentsSelector = true
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
        .listRowBackground(showGuides ? Color.purple.opacity(0.2) : cellBackgroundColor)
    }

    // Moments Section - Places
    @ViewBuilder
    private var momentsPlacesSection: some View {
        Section {
            Button(action: {
                showingMomentsSelector = true
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
        .listRowBackground(showGuides ? Color.orange.opacity(0.2) : cellBackgroundColor)
    }

    // Moments Section - Events
    @ViewBuilder
    private var momentsEventsSection: some View {
        Section {
            Button(action: {
                showingMomentsSelector = true
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
        .listRowBackground(showGuides ? Color.pink.opacity(0.2) : cellBackgroundColor)
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
        .listRowBackground(showGuides ? Color.cyan.opacity(0.2) : cellBackgroundColor)
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
        .listRowBackground(showGuides ? Color.yellow.opacity(0.2) : cellBackgroundColor)
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
        let entryCount = TodayDataManager.shared.getEntryCount(for: selectedDate)
        let onThisDayCount = TodayDataManager.shared.getOnThisDayCount(for: selectedDate)

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
        .padding(.vertical, 0)
        .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
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
            .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
            .listRowBackground(showGuides ? Color.red.opacity(0.2) : cellBackgroundColor)
            .listRowSeparator(.hidden)
        }
    }

    // MARK: - Gold Upgrade Section
    @ViewBuilder
    private var goldSection: some View {
        Section {
            HStack(spacing: 10) {
                Button(action: {
                    showGoldCelebration = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(hex: "F0B805"))

                        Text("Gold Upgraded")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "FAF0D7"))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    showSilverCelebration = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(hex: "B8C2C9"))

                        Text("Silver Upgraded")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "E8ECF0"))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // Extract Bio section as computed property
    @ViewBuilder
    private var bioSection: some View {
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
        .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // Moments section - collapsible (Events, Places, Photos only)
    @ViewBuilder
    private var momentsCollapsibleSection: some View {
        // Header
        Section {
            HStack(spacing: 12) {
                Text("Moments")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "292F33"))

                Spacer()

                // Collapsed state indicator
                if !momentsExpanded {
                    Button(action: { showingMomentsSelector = true }) {
                        Text(momentsCollapsedSummary)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(momentsButtonColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(momentsButtonColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Toggle arrow - always on the far right
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        momentsExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(momentsExpanded ? 90 : 0))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if momentsExpanded {
            Section {
                HStack(spacing: 4) {
                    MomentOption(
                        icon: .photo,
                        count: availablePhotosCount,
                        title: "Photos",
                        position: .left,
                        onTap: { showingMomentsSelector = true }
                    )

                    MomentOption(
                        icon: .map_pin_filled,
                        count: dynamicPlacesCount,
                        title: "Places",
                        position: .center,
                        onTap: { showingMomentsSelector = true }
                    )

                    MomentOption(
                        icon: .calendar,
                        count: dynamicEventsCount,
                        title: "Events",
                        position: .right,
                        onTap: { showingMomentsSelector = true }
                    )
                }
                //.padding(.vertical, 16)
            }
            //.listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    // Trackers section - collapsible
    @ViewBuilder
    private var trackersCollapsibleSection: some View {
        // Header
        Section {
            HStack(spacing: 12) {
                Text("Trackers")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "292F33"))

                Spacer()

                // Collapsed state indicator
                if !trackersExpanded {
                    if hasTrackersData {
                        // Show count with checkmark
                        HStack(spacing: 4) {
                            Text("\(selectedMomentsTrackers.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "44C0FF").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        // Show "Input AM/PM" prompt
                        Button(action: { }) {  // No action - visual only
                            Text("Input \(trackerTimeOfDay)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(hex: "44C0FF"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "44C0FF").opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // Toggle arrow - always on the far right
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        trackersExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(trackersExpanded ? 90 : 0))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if trackersExpanded {
            momentsTrackersSection
        }
    }

    // Inputs section - collapsible
    @ViewBuilder
    private var inputsCollapsibleSection: some View {
        // Header
        Section {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    inputsExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Inputs")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "292F33"))

                    Spacer()

                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(inputsExpanded ? 90 : 0))
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(PlainButtonStyle())
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if inputsExpanded {
            momentsInputsSection
        }
    }

    // Helper method to render sections in custom order
    @ViewBuilder
    private func sectionView(for sectionId: String) -> some View {
        switch sectionId {
        case "dateNavigation":
            dateNavigationSection
                .id("dateNavigation")
        case "datePickerGrid":
            if showDatePickerGrid {
                DatePickerGrid(
                    dates: dateRange,
                    selectedDate: $selectedDate,
                    showingChatCalendar: $showingChatCalendar,
                    showDates: false,
                    showStreak: false
                )
                .padding(.horizontal, DatePickerConstants.horizontalPadding)
                .background(Color.clear)
                .listRowBackground(showGuides ? Color.indigo.opacity(0.2) : Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.bottom, 20)
            }
        case "datePickerRow":
            if showDatePickerRow {
                DatePickerRow(
                    dates: dateRange,
                    selectedDate: $selectedDate,
                    showingChatCalendar: $showingChatCalendar
                )
                .padding(.vertical, 10)
                .background(Color.clear)
                .listRowBackground(showGuides ? Color.mint.opacity(0.2) : Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        case "entries":
            if showEntries {
                entryLinksSection
            }
        case "dailyEntry":
            if showDailyEntry {
                dailyEntrySection
            }
        case "dailyChat":
            if showDailyChat {
                dailyChatSection
            }
        case "moments":
            if showMoments {
                momentsCollapsibleSection
            }
        case "trackers":
            if showTrackers {
                trackersCollapsibleSection
            }
        case "inputs":
            if showInputs {
                inputsCollapsibleSection
            }
        case "bio":
            if showBioSection {
                bioSection
            }
        case "gold":
            if showGoldSection {
                goldSection
            }
        default:
            EmptyView()
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

                    // Render sections in custom order
                    ForEach(sectionOrder) { section in
                        sectionView(for: section.id)
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
            .environment(\.defaultMinListHeaderHeight, 0)
            .environment(\.defaultMinListRowHeight, 0)
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
                    VStack(spacing: 12) {
                        // Chat Input Box
                        if showChatInputBox {
                            ChatInputBoxView {
                                openDailyChatIfEnabled()
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

                // New ellipsis menu with Edit Bio and Daily Chat Settings
                Menu {
                    Button("Edit Bio") {
                        showingBio = true
                    }

                    Button("Daily Chat Settings") {
                        showingChatSettings = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }

                Menu {
                    Button("Settings") {
                        showingSettings = true
                    }

                    Button("Sort Sections") {
                        showingSectionsOrder = true
                    }

                    Section("Today Sections") {

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
                            showEntries.toggle()
                        } label: {
                            HStack {
                                Text("Entries")
                                if showEntries {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }

                        Button {
                            showDailyEntry.toggle()
                        } label: {
                            HStack {
                                Text("Daily Entry")
                                if showDailyEntry {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
                        }

                        Button {
                            showDailyChat.toggle()
                        } label: {
                            HStack {
                                Text("Daily Chat")
                                if showDailyChat {
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
                            showInputs.toggle()
                        } label: {
                            HStack {
                                Text("Inputs")
                                if showInputs {
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

                    Section("Show") {
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

                    Section("UI Helpers") {
                        Button {
                            showGuides.toggle()
                        } label: {
                            HStack {
                                Text("Show Section Guides")
                                if showGuides {
                                    Image(dayOneIcon: .checkmark)
                                }
                            }
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
        .sheet(isPresented: $showGoldCelebration) {
            GoldCelebrationView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showSilverCelebration) {
            SilverCelebrationView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
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
        .sheet(isPresented: $showingMomentsSelector) {
            MomentsSelectorView(
                selectedDate: selectedDate,
                photosCount: availablePhotosCount,
                places: placesData,
                events: eventsData,
                selectedPhotoIDs: $selectedMomentsPhotos,
                selectedPlaceIDs: $selectedMomentsPlaces,
                selectedEventNames: $selectedMomentsEvents
            )
            .presentationDetents([.large])
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
        .sheet(isPresented: $showingSectionsOrder) {
            TodaySectionsOrderView()
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
            // Sync to shared DateManager
            DateManager.shared.selectedDate = newValue

            // Post notification for date change
            NotificationCenter.default.post(name: .selectedDateChanged, object: newValue)

            // Reset daily activities state when date changes
            chatCompleted = false
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
        .sheet(isPresented: $showingSettings) {
            AppSettingsView()
        }
        .alert("AI Features Privacy", isPresented: $showingEnableAIModal) {
            Button("Cancel", role: .cancel) { }
            Button("I Agree") {
                aiFeaturesEnabled = true
                dailyChatEnabled = true
                entryAIFeaturesEnabled = true
                showingDailyChat = true
            }
        } message: {
            Text("By enabling AI features, you consent to sharing content with our AI partner for processing.\n\n• Our AI partner does not store or train on your data\n• Used solely to generate content within Day One\n• You can disable AI features anytime\n\nThis ensures your privacy while providing AI-powered features to enhance your journaling experience.")
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
                // New entry - check if selected date is today
                let calendar = Calendar.current
                let isToday = calendar.isDateInToday(selectedDate)
                let entryDate = isToday ? Date() : calendar.startOfDay(for: selectedDate)
                let isAllDay = !isToday

                // New entry with prompt - Edit mode
                EntryView(
                    journal: nil,
                    prompt: selectedPrompt,
                    initialDate: entryDate,
                    isAllDay: isAllDay,
                    startInEditMode: true
                )
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
        .onReceive(NotificationCenter.default.publisher(for: .triggerDailyChat)) { _ in
            // Only respond to Daily Chat trigger if this variant supports it
            openDailyChatIfEnabled()
        }
        .onReceive(NotificationCenter.default.publisher(for: .summaryGeneratedStatusChanged)) { notification in
            // Update summaryGenerated state when notification is received
            if let date = notification.object as? Date,
               Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                // Force a UI update
                DispatchQueue.main.async {
                    summaryGenerated = DailyContentManager.shared.hasSummary(for: selectedDate)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dailyEntryCreatedStatusChanged)) { notification in
            // Update entryCreated state when notification is received
            if let date = notification.object as? Date,
               Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                // Force a UI update
                entryCreated = DailyContentManager.shared.hasEntry(for: selectedDate)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .triggerEntryGeneration)) { notification in
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

            // Load section order
            loadSectionOrder()

            // Show Welcome to Today sheet if enabled
            if showWelcomeToTodaySheet {
                shouldPresentWelcomeSheet = true
            }
        }
        .sheet(isPresented: $shouldPresentWelcomeSheet) {
            WelcomeToTodaySheet()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataPopulationChanged)) { _ in
            // Re-pull local cached state when fixtures are re-seeded;
            // @Observable manager state propagates the rest.
            DispatchQueue.main.async {
                updateCurrentDateState()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .sectionOrderChanged)) { _ in
            // Reload section order when it changes
            DispatchQueue.main.async {
                loadSectionOrder()
            }
        }
        .onChange(of: hasMomentsSelected) { oldValue, newValue in
            // Show Create Entry FAB when any moments are selected
            if newValue {
                showEntryFAB = true
            }
        }
    }

    private func loadSectionOrder() {
        let decoder = JSONDecoder()
        if let decodedSections = try? decoder.decode([SectionItem].self, from: sectionOrderData) {
            // Merge with allSections to add any new sections that don't exist yet
            var mergedSections = decodedSections

            // Find sections in allSections that aren't in decodedSections
            let existingIds = Set(decodedSections.map { $0.id })
            let newSections = SectionItem.allSections.filter { !existingIds.contains($0.id) }

            // Add new sections to the end
            mergedSections.append(contentsOf: newSections)

            sectionOrder = mergedSections

            // If we added new sections, save the updated order
            if !newSections.isEmpty {
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(mergedSections) {
                    sectionOrderData = encoded
                }
            }
        } else {
            sectionOrder = SectionItem.allSections
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
