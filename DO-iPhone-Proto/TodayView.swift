import SwiftUI
import TipKit
import UIKit

// MARK: - Constants
/// Size for toggle disclosure icons (arrow-right-circle)

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
    let journalingTip = JournalingMadeEasyTip()

    // Layout Constants
    let momentsSectionSpacing: CGFloat = 8
    let todaySectionSpacing: CGFloat = 16
    let todayInterSectionSpacing: CGFloat = 24 // Spacing between major sections

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

    var hasMomentsSelected: Bool {
        !selectedMomentsPlaces.isEmpty || !selectedMomentsEvents.isEmpty || !selectedMomentsPhotos.isEmpty
    }

    var dateRange: [Date] {
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


    // Helper function to check AI features before opening daily chat
    func openDailyChatIfEnabled() {
        if dailyChatEnabled {
            showingDailyChat = true
        } else {
            showingEnableAIModal = true
        }
    }

    var trackersSummaryText: String {
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

    var hasTrackerData: Bool {
        moodRating > 0 || energyRating > 0 || stressRating > 0 ||
        !foodInput.isEmpty || !prioritiesInput.isEmpty || !mediaInput.isEmpty || !peopleInput.isEmpty
    }

    // MARK: - Moments Collapsed State Helpers

    // Generate realistic moment counts based on date (allows zeros)


    var backgroundColor: Color {
        return .white
    }

    var cellBackgroundColor: Color {
        return Color(UIColor.secondarySystemGroupedBackground)
    }





    // Helper method for formatting time


    @ViewBuilder
    var entryLinksSection: some View {
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
    var dateNavigationSection: some View {
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
    var goldSection: some View {
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
    var bioSection: some View {
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


    // Helper method to render sections in custom order
    @ViewBuilder
    func sectionView(for sectionId: String) -> some View {
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

}


#Preview {
    TodayView()
}
