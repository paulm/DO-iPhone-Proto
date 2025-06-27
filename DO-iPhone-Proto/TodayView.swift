import SwiftUI

/// Today tab view
struct TodayView: View {
    @State private var showingSettings = false
    @State private var showingDatePicker = false
    @State private var showingDailySurvey = false
    @State private var showingMoments = false
    @State private var showingTrackers = false
    private var experimentsManager = ExperimentsManager.shared
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
        
        // Past 4 days (from -4 to -1)
        for i in stride(from: -4, through: -1, by: 1) {
            if let date = calendar.date(byAdding: .day, value: i, to: selectedDate) {
                dates.append(date)
            }
        }
        
        // Current day
        dates.append(selectedDate)
        
        // Tomorrow
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            dates.append(tomorrow)
        }
        
        return dates
    }
    
    var body: some View {
        Group {
            switch experimentsManager.variant(for: .todayTab) {
            case .appleSettings:
                TodayTabSettingsStyleView()
            case .v1i2:
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
            default:
                TodayTabSettingsStyleView()
            }
        }
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

/// V1i2 Today tab layout - Enhanced with Daily Activities section
struct TodayViewV1i2: View {
    @Binding var showingSettings: Bool
    @Binding var showingDatePicker: Bool
    @Binding var showingDailySurvey: Bool
    @Binding var showingMoments: Bool
    @Binding var showingTrackers: Bool
    @Binding var selectedDate: Date
    @Binding var surveyCompleted: Bool
    
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
    
    // Show/hide toggles for Daily Activities
    @State private var showChat = true
    @State private var showMoments = false
    @State private var showTrackers = false
    @State private var showInsights = false
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
        
        // Past 4 days (from -4 to -1)
        for i in stride(from: -4, through: -1, by: 1) {
            if let date = calendar.date(byAdding: .day, value: i, to: selectedDate) {
                dates.append(date)
            }
        }
        
        // Current day
        dates.append(selectedDate)
        
        // Tomorrow
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            dates.append(tomorrow)
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
        return "\(chatMessageCount) interaction\(chatMessageCount == 1 ? "" : "s")."
    }
    
    private var chatSubtitleWithResume: String {
        let interactionCount = Int.random(in: 1...55)
        return "\(interactionCount) interactions Resume"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header and date picker section with gray background
            VStack(spacing: 0) {
                // Header with profile button
                HStack {
                    Text(selectedDate, style: .date)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Menu {
                        Button("Settings") {
                            showingSettings = true
                        }
                        
                        Section("Show") {
                            Button {
                                showChat.toggle()
                            } label: {
                                HStack {
                                    Text("Chat")
                                    if showChat {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showMoments.toggle()
                            } label: {
                                HStack {
                                    Text("Moments")
                                    if showMoments {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                showTrackers.toggle()
                            } label: {
                                HStack {
                                    Text("Trackers")
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
                        }
                    } label: {
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.gray)
                            )
                    }
                    .accessibilityLabel("Profile Menu")
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Date picker row
                HStack(spacing: 16) {
                    // Calendar icon
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    .accessibilityLabel("Open date picker")
                    
                    // Date circles
                    HStack(spacing: 12) {
                        ForEach(Array(dateRange.enumerated()), id: \.offset) { index, date in
                            DateCircle(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                isFuture: date > Date(),
                                onTap: {
                                    selectedDate = date
                                }
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Content with Daily Activities
            List {
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
                            subtitle: chatCompleted ? chatInteractionsText : "",
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
                                HStack {
                                    Text("View Summary")
                                        .font(.body)
                                        .foregroundStyle(Color(hex: "44C0FF"))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 12)
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
                    chatCompleted = true
                    showChat = true
                },
                onMessageCountChanged: { count in
                    chatMessageCount = count
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
                showChat = true
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
            EntryView()
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
                        HStack(spacing: 4) {
                            Button(action: logHighlightsAction) {
                                Text("Log Highlights")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text(" or ")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Button(action: beginChatAction) {
                                Text("Begin Chat")
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
                
                if showResume {
                    Button(action: resumeAction) {
                        Text("Resume Chat")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "44C0FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else if isCompleted {
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

// Chat Session Manager
class ChatSessionManager {
    static let shared = ChatSessionManager()
    private var sessions: [String: [DailyChatMessage]] = [:]
    
    private init() {}
    
    private func dateKey(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func getMessages(for date: Date = Date()) -> [DailyChatMessage] {
        let key = dateKey(for: date)
        return sessions[key] ?? []
    }
    
    func saveMessages(_ messages: [DailyChatMessage], for date: Date = Date()) {
        let key = dateKey(for: date)
        sessions[key] = messages
    }
    
    func clearSession(for date: Date = Date()) {
        let key = dateKey(for: date)
        sessions.removeValue(forKey: key)
    }
}

// Daily Chat View
struct DailyChatView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    let initialLogMode: Bool
    @Binding var entryCreated: Bool
    let onChatStarted: () -> Void
    let onMessageCountChanged: (Int) -> Void
    
    @State private var chatText = ""
    @State private var isLogDetailsMode: Bool
    @State private var messages: [DailyChatMessage] = []
    @State private var isThinking = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingPreviewEntry = false
    @State private var showingBioView = false
    
    private let chatSessionManager = ChatSessionManager.shared
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private var userMessageCount: Int {
        messages.filter { $0.isUser }.count
    }
    
    init(selectedDate: Date, initialLogMode: Bool, entryCreated: Binding<Bool>, onChatStarted: @escaping () -> Void, onMessageCountChanged: @escaping (Int) -> Void) {
        self.selectedDate = selectedDate
        self.initialLogMode = initialLogMode
        self._entryCreated = entryCreated
        self.onChatStarted = onChatStarted
        self.onMessageCountChanged = onMessageCountChanged
        self._isLogDetailsMode = State(initialValue: initialLogMode)
        
        // Load existing messages for the selected date
        let existingMessages = ChatSessionManager.shared.getMessages(for: selectedDate)
        self._messages = State(initialValue: existingMessages)
    }
    
    private var placeholderText: String {
        isLogDetailsMode ? "Log any details about this day" : "Chat about your day"
    }
    
    private var showHeaderContent: Bool {
        messages.isEmpty
    }
    
    private let aiResponses = [
        "That sounds like a great way to spend your day! How did that make you feel?",
        "Thanks for sharing that with me. I can tell this was meaningful to you. What was the most memorable part about it?",
        "Interesting! I'd love to hear more about that experience. It sounds like it had quite an impact on your day.",
        "That's wonderful that you took the time to do that. Sometimes the simple moments can be the most rewarding ones, don't you think?"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header content (disappears when user has messages)
                if showHeaderContent {
                    VStack {
                        Spacer()
                        
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(hex: "44C0FF"))
                        
                        Spacer()
                    }
                    .transition(.opacity)
                }
                
                // Chat messages area
                if !messages.isEmpty || isThinking {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    DailyChatBubbleView(message: message)
                                        .id(message.id)
                                }
                                
                                // Thinking indicator
                                if isThinking {
                                    HStack {
                                        ThinkingIndicatorView()
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .id("thinking")
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let lastMessage = messages.last {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: isThinking) { _, newValue in
                            if newValue {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo("thinking", anchor: .bottom)
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                }
                
                // Chat input area
                VStack(spacing: 0) {
                    // Text input field
                    TextField(placeholderText, text: $chatText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .lineLimit(1...6)
                    
                    // Keyboard accessory toolbar
                    HStack {
                        // Chat mode toggle buttons
                        HStack(spacing: 8) {
                            Text("Mode:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 4) {
                                Button(action: {
                                    isLogDetailsMode = false
                                }) {
                                    Text("Chat")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            !isLogDetailsMode ? Color(hex: "44C0FF") : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 16)
                                        )
                                        .foregroundStyle(!isLogDetailsMode ? .white : .secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    isLogDetailsMode = true
                                }) {
                                    Text("Log")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            isLogDetailsMode ? Color(.darkGray) : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 16)
                                        )
                                        .foregroundStyle(isLogDetailsMode ? .white : .secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(2)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18))
                        }
                        
                        Spacer()
                        
                        // Audio and submit buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                // TODO: Audio chat functionality
                            }) {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 32, height: 32)
                                    .background(Color(.systemGray5), in: Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                sendMessage()
                            }) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        chatText.isEmpty ? Color.gray : Color(hex: "44C0FF"),
                                        in: Circle()
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(chatText.isEmpty || isThinking)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Daily Chat")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(selectedDate, style: .date)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        if userMessageCount > 0 {
                            Button(action: {
                                showingPreviewEntry = true
                            }) {
                                Text("View Summary")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            regenerateResponse()
                        }) {
                            Label("Regenerate Response", systemImage: "arrow.clockwise")
                        }
                        
                        Button(action: {
                            showingBioView = true
                        }) {
                            Label("Edit Bio", systemImage: "person.circle")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            clearChat()
                        }) {
                            Label("Clear Chat", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.body)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Set initial log mode
                isLogDetailsMode = initialLogMode
                
                // Auto-insert first AI question if in chat mode and no messages yet
                if !initialLogMode && messages.isEmpty {
                    let initialMessage = DailyChatMessage(content: "How's your \(dayOfWeek)?", isUser: false, isLogMode: false)
                    messages.append(initialMessage)
                    chatSessionManager.saveMessages(messages, for: selectedDate)
                }
                
                // Notify that chat has been started if there are existing messages
                if !messages.isEmpty {
                    onChatStarted()
                    onMessageCountChanged(userMessageCount)
                }
                
                // Auto-focus text field when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
            .onChange(of: messages) { _, newMessages in
                // Save messages whenever they change
                chatSessionManager.saveMessages(newMessages, for: selectedDate)
                // Update message count
                onMessageCountChanged(userMessageCount)
            }
        }
        .sheet(isPresented: $showingPreviewEntry) {
            ChatEntryPreviewView(
                selectedDate: selectedDate,
                entryCreated: $entryCreated
            )
        }
        .sheet(isPresented: $showingBioView) {
            BioEditView()
        }
    }
    
    private func regenerateResponse() {
        // Find the last AI message and regenerate it
        if let lastAIIndex = messages.lastIndex(where: { !$0.isUser && !$0.isLogMode }) {
            // Remove the last AI message
            messages.remove(at: lastAIIndex)
            
            // Show thinking indicator
            isThinking = true
            
            // Generate new response
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.75...1.5)) {
                isThinking = false
                let aiResponse = aiResponses.randomElement() ?? aiResponses[0]
                let aiMessage = DailyChatMessage(content: aiResponse, isUser: false, isLogMode: false)
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(aiMessage)
                }
            }
        }
    }
    
    private func clearChat() {
        messages.removeAll()
        chatSessionManager.clearSession(for: selectedDate)
        onMessageCountChanged(0)
        
        // Re-add initial AI message if in chat mode
        if !isLogDetailsMode {
            let initialMessage = DailyChatMessage(content: "How's your \(dayOfWeek)?", isUser: false, isLogMode: false)
            messages.append(initialMessage)
            chatSessionManager.saveMessages(messages, for: selectedDate)
        }
    }
    
    private func sendMessage() {
        let userMessage = DailyChatMessage(content: chatText, isUser: true, isLogMode: isLogDetailsMode)
        messages.append(userMessage)
        
        chatText = ""
        
        // Trigger onChatStarted callback if this is the first message
        if messages.count == 1 {
            onChatStarted()
        }
        
        // Only show AI response in Chat mode, not in Log details mode
        if !isLogDetailsMode {
            // Show thinking indicator
            isThinking = true
            
            // Simulate AI response after a delay (reduced by half)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.75...1.5)) {
                isThinking = false
                let aiResponse = aiResponses.randomElement() ?? aiResponses[0]
                let aiMessage = DailyChatMessage(content: aiResponse, isUser: false, isLogMode: false)
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(aiMessage)
                }
            }
        }
    }
}

// Daily Chat Message Model
struct DailyChatMessage: Identifiable, Equatable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let isLogMode: Bool
    let timestamp = Date()
}

// Daily Chat Bubble View
struct DailyChatBubbleView: View {
    let message: DailyChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
                
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isLogMode ? Color(.darkGray) : Color(hex: "44C0FF"),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
            } else {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 18))
                
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 16)
    }
}

// Thinking Indicator View
struct ThinkingIndicatorView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0 + 0.3 * sin(animationOffset + Double(index) * 0.5))
                        .animation(
                            Animation.easeInOut(duration: 1.0).repeatForever(),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 18))
        }
        .onAppear {
            animationOffset = 0
            withAnimation {
                animationOffset = .pi * 2
            }
        }
    }
}

// Bio Edit View
struct BioEditView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userBioName") private var userName = ""
    @AppStorage("userBioBio") private var userBio = ""
    @AppStorage("includeInDailyChat") private var includeInDailyChat = true
    
    @State private var editingName = ""
    @State private var editingBio = ""
    @State private var editingInclude = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $editingName)
                        .textFieldStyle(.automatic)
                    
                    VStack(alignment: .leading) {
                        Text("Bio")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $editingBio)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                    }
                }
                
                Section {
                    Toggle("Include in Daily Chat", isOn: $editingInclude)
                }
            }
            .navigationTitle("Bio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userName = editingName
                        userBio = editingBio
                        includeInDailyChat = editingInclude
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                editingName = userName
                editingBio = userBio
                editingInclude = includeInDailyChat
            }
        }
    }
}

// MARK: - Supporting Views
struct DateCircle: View {
    let date: Date
    let isSelected: Bool
    let isFuture: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(isSelected ? Color(hex: "44C0FF") : .gray.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(dayNumber)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(isSelected ? .white : (isFuture ? .secondary : .primary))
                )
                .opacity(isFuture ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


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

// Chat Entry Preview View (Chat Summary)
struct ChatEntryPreviewView: View {
    let selectedDate: Date
    @Binding var entryCreated: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var entryContent: String = ""
    @State private var isCreatingEntry = false
    @State private var showingEntry = false
    @State private var hasNewInteractions = false
    @State private var isLoadingSummary = true
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gray background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoadingSummary {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Color(hex: "44C0FF"))
                        
                        Text("Generating summary...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 0) {
                        // Entry content in white rounded rectangle
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Morning Reflections and Evening Plans")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("Today I started with my usual morning routine, feeling energized and ready to tackle the day ahead. I spent some time thinking about my work goals and how I want to approach the various projects I have on my plate.")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Text("The conversation helped me organize my thoughts around what's most important right now. We discussed my priorities for the week and how to balance work with personal time.")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Text("As I look toward the evening, I'm planning to wind down with some reading and prepare for tomorrow's meetings. It's been a productive day overall, and I'm grateful for the clarity that comes from taking time to reflect.")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding()
                        }
                        
                            Spacer()
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            // Create/Update Entry button
                            Button(action: {
                                if entryCreated {
                                    // Update existing entry
                                    updateEntry()
                                } else {
                                    // Create new entry
                                    createEntry()
                                }
                            }) {
                                HStack {
                                    if isCreatingEntry {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    } else {
                                        Text(entryCreated ? "Update Entry" : "Create Entry")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(isCreatingEntry || (entryCreated && !hasNewInteractions))
                            .opacity((entryCreated && !hasNewInteractions) ? 0.6 : 1.0)
                            
                            // Open button
                            Button(action: {
                                showingEntry = true
                            }) {
                                Text("Open Entry")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(entryCreated ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(entryCreated ? Color(hex: "44C0FF") : Color.gray.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(!entryCreated)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            copyEntryText()
                        }) {
                            Label("Copy Text", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            // TODO: Edit entry
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            deleteEntry()
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Summary generated from chat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEntry) {
            EntryView()
        }
        .onAppear {
            // Show loading state for 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoadingSummary = false
            }
            
            // Check if there are new chat interactions since entry was created
            // This would normally check actual chat data
            if entryCreated {
                // Simulate checking for new interactions
                hasNewInteractions = true
            }
        }
    }
    
    private func createEntry() {
        isCreatingEntry = true
        
        // Simulate entry creation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isCreatingEntry = false
            entryCreated = true
            hasNewInteractions = false
            // Auto-open the entry after creation
            showingEntry = true
        }
    }
    
    private func updateEntry() {
        isCreatingEntry = true
        
        // Simulate entry update
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isCreatingEntry = false
            hasNewInteractions = false
            // Entry remains created
        }
    }
    
    private func copyEntryText() {
        let entryText = """
        Morning Reflections and Evening Plans
        
        Today I started with my usual morning routine, feeling energized and ready to tackle the day ahead. I spent some time thinking about my work goals and how I want to approach the various projects I have on my plate.
        
        The conversation helped me organize my thoughts around what's most important right now. We discussed my priorities for the week and how to balance work with personal time.
        
        As I look toward the evening, I'm planning to wind down with some reading and prepare for tomorrow's meetings. It's been a productive day overall, and I'm grateful for the clarity that comes from taking time to reflect.
        """
        
        UIPasteboard.general.string = entryText
    }
    
    private func deleteEntry() {
        entryCreated = false
        dismiss()
    }
}


#Preview {
    TodayView()
}
