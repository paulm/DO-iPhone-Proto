import SwiftUI
import TipKit

// MARK: - Today Tab Variants

// NOTE: This variant is no longer used but kept for reference
// The Today Tab now only uses the v1i2 variant
struct TodayTabSettingsStyleView: View {
    @State private var showingSettings = false
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
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }
    
    private var completedActivitiesCount: Int {
        var count = 0
        if surveyCompleted { count += 1 }
        if !selectedLocations.isEmpty || !selectedEvents.isEmpty || !selectedPhotos.isEmpty || !selectedHealth.isEmpty { count += 1 }
        if moodRating > 0 || energyRating > 0 || stressRating > 0 || 
           !foodInput.isEmpty || !prioritiesInput.isEmpty || !mediaInput.isEmpty || !peopleInput.isEmpty { count += 1 }
        return count
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Date and Progress Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundStyle(Color(hex: "44C0FF"))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Today")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                
                                Text(todayDateString)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                Circle()
                                    .fill(.gray.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if completedActivitiesCount > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.subheadline)
                                
                                Text("\(completedActivitiesCount) of 3 activities completed")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Daily Activities Section
                Section("Daily Activities") {
                    TodayActivityRow(
                        icon: "list.clipboard.fill",
                        iconColor: .blue,
                        title: "Daily Survey",
                        subtitle: surveyCompleted ? "Completed for today" : "Answer daily questions",
                        isCompleted: surveyCompleted,
                        action: { showingDailySurvey = true }
                    )
                    
                    TodayActivityRow(
                        icon: "sparkles",
                        iconColor: .purple,
                        title: "Moments",
                        subtitle: momentsSummaryText,
                        isCompleted: !selectedLocations.isEmpty || !selectedEvents.isEmpty || !selectedPhotos.isEmpty,
                        action: { showingMoments = true }
                    )
                    
                    TodayActivityRow(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .orange,
                        title: "Trackers",
                        subtitle: trackersSummaryText,
                        isCompleted: moodRating > 0 || energyRating > 0 || stressRating > 0 || 
                                   !foodInput.isEmpty || !prioritiesInput.isEmpty || !mediaInput.isEmpty || !peopleInput.isEmpty,
                        action: { showingTrackers = true }
                    )
                }
                
                // Quick Actions Section
                Section("Quick Actions") {
                    TodayQuickActionRow(
                        icon: "plus.circle.fill",
                        iconColor: .green,
                        title: "New Entry",
                        subtitle: "Start writing for today",
                        action: { /* TODO: New entry action */ }
                    )
                    
                    TodayQuickActionRow(
                        icon: "camera.fill",
                        iconColor: .gray,
                        title: "Add Photo",
                        subtitle: "Capture a moment",
                        action: { /* TODO: Add photo action */ }
                    )
                    
                    TodayQuickActionRow(
                        icon: "mic.fill",
                        iconColor: .red,
                        title: "Voice Note",
                        subtitle: "Record your thoughts",
                        action: { /* TODO: Voice note action */ }
                    )
                }
                
                // Insights Section
                Section("Insights") {
                    TodayInsightRow(
                        icon: "chart.bar.fill",
                        iconColor: .indigo,
                        title: "Weekly Summary",
                        subtitle: "View your week's activity",
                        action: { /* TODO: Weekly summary action */ }
                    )
                    
                    TodayInsightRow(
                        icon: "calendar.circle.fill",
                        iconColor: .teal,
                        title: "On This Day",
                        subtitle: "Memories from previous years",
                        action: { /* TODO: On this day action */ }
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
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
    
    private var momentsSummaryText: String {
        let totalMoments = selectedLocations.count + selectedEvents.count + selectedPhotos.count
        if totalMoments == 0 {
            return "Select highlights from your day"
        } else {
            return "\(totalMoments) moment\(totalMoments == 1 ? "" : "s") selected"
        }
    }
    
    private var trackersSummaryText: String {
        var completedCount = 0
        if moodRating > 0 { completedCount += 1 }
        if energyRating > 0 { completedCount += 1 }
        if stressRating > 0 { completedCount += 1 }
        if !foodInput.isEmpty { completedCount += 1 }
        if !prioritiesInput.isEmpty { completedCount += 1 }
        if !mediaInput.isEmpty { completedCount += 1 }
        if !peopleInput.isEmpty { completedCount += 1 }
        
        if completedCount == 0 {
            return "Track your daily metrics"
        } else {
            return "\(completedCount) of 7 completed"
        }
    }
}

struct TodayActivityRow: View {
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
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TodayQuickActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
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
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TodayInsightRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
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
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Multi-Column Today View
struct TodayViewMultiColumn: View {
    @Binding var showingSettings: Bool
    @Binding var showingDatePicker: Bool
    @Binding var showingDailySurvey: Bool
    @Binding var showingMoments: Bool
    @Binding var showingTrackers: Bool
    @Binding var selectedDate: Date
    @Binding var surveyCompleted: Bool
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
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var showingEntry = false
    @State private var isGeneratingEntry = false
    @State private var showingBioView = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Create an instance of the bio tip
    private let bioTip = BioCompletionTip()
    
    private var dateRange: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        let today = Date()
        
        // Show a month's worth of dates centered around today
        for i in -15...15 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // Multi-column layout for iPad/larger screens
                multiColumnLayout
            } else {
                // Fall back to V1i2 view for compact devices
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
            }
        }
    }
    
    @ViewBuilder
    private var multiColumnLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar with calendar and date navigation
            sidebarContent
                .navigationSplitViewColumnWidth(min: 320, ideal: 380, max: 450)
        } detail: {
            // Detail view with daily activities
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
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
        .sheet(isPresented: $showingEntry) {
            EntryView(journal: nil)
        }
        .sheet(isPresented: $showingBioView) {
            BioEditView()
        }
    }
    
    private var sidebarContent: some View {
        List {
            // Calendar view
            Section {
                DatePicker(
                    "Selected Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
            }
            
            // Recent dates with entries/activity
            Section("Recent Activity") {
                ForEach(recentDatesWithActivity(), id: \.self) { date in
                    Button(action: {
                        selectedDate = date
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(date, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                                    .font(.headline)
                                    .foregroundStyle(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                                
                                if hasActivity(for: date) {
                                    HStack(spacing: 8) {
                                        if hasMessagesForDate(date) {
                                            Label("Chat", systemImage: "bubble.left.fill")
                                                .font(.caption)
                                                .labelStyle(.iconOnly)
                                        }
                                        if hasEntryForDate(date) {
                                            Label("Entry", systemImage: "doc.text.fill")
                                                .font(.caption)
                                                .labelStyle(.iconOnly)
                                        }
                                    }
                                    .foregroundStyle(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white.opacity(0.8) : .secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if Calendar.current.isDateInToday(date) {
                                Text("Today")
                                    .font(.caption)
                                    .foregroundStyle(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white.opacity(0.8) : .secondary)
                            }
                        }
                    }
                    .listRowBackground(
                        Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color(hex: "44C0FF") : Color.clear
                    )
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingSettings = true
                }) {
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        )
                }
            }
        }
    }
    
    private var detailContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Date header
                VStack(spacing: 8) {
                    Text(selectedDate, format: .dateTime.weekday(.wide).month(.wide).day())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(relativeDateText(for: selectedDate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)
                
                // Entry section (shown when entry exists OR is being generated)
                if DailyContentManager.shared.hasEntry(for: selectedDate) || isGeneratingEntry {
                    Section {
                        if isGeneratingEntry {
                            // Loading state
                            HStack {
                                Spacer()
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Generating entry...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 40)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Button(action: {
                                showingEntry = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Daily Entry")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                        
                                        Text("Morning Reflections and Evening Plans")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text("Today I started with my usual morning routine, feeling energized and ready to tackle the day ahead...")
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(3)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Daily Activities Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    // Daily Moments
                    ActivityCard(
                        icon: "sparkles",
                        iconColor: .purple,
                        title: "Moments",
                        subtitle: hasSelectedMoments ? momentsCountText : "Capture meaningful moments",
                        isCompleted: hasSelectedMoments,
                        action: { showingMoments = true }
                    )
                    
                    // Daily Trackers
                    ActivityCard(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .orange,
                        title: "Trackers",
                        subtitle: hasTrackerData ? "Trackers completed" : "Track mood and activities",
                        isCompleted: hasTrackerData,
                        action: { showingTrackers = true }
                    )
                }
                
                // Bio Tip
                TipView(bioTip) { action in
                    if action.id == "fill-bio" {
                        showingBioView = true
                        bioTip.invalidate(reason: .actionPerformed)
                    } else if action.id == "later" {
                        bioTip.invalidate(reason: .actionPerformed)
                    }
                }
                .tipBackground(Color.black.opacity(0.05))
                
                // Entry Links
                let entryCount = DailyDataManager.shared.getEntryCount(for: selectedDate)
                let onThisDayCount = DailyDataManager.shared.getOnThisDayCount(for: selectedDate)
                
                if entryCount > 0 || onThisDayCount > 0 {
                    HStack(spacing: 16) {
                        if entryCount > 0 {
                            Button(action: { /* Show entries */ }) {
                                Label("\(entryCount) \(entryCount == 1 ? "Entry" : "Entries")", systemImage: "doc.text")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "44C0FF").opacity(0.1))
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if onThisDayCount > 0 {
                            Button(action: { /* Show on this day */ }) {
                                Label("\(onThisDayCount) On This Day", systemImage: "calendar.badge.clock")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "44C0FF").opacity(0.1))
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper functions
    private func hasActivity(for date: Date) -> Bool {
        return hasMessagesForDate(date) || hasEntryForDate(date)
    }
    
    private func hasMessagesForDate(_ date: Date) -> Bool {
        let messages = ChatSessionManager.shared.getMessages(for: date)
        return !messages.isEmpty && messages.contains { $0.isUser }
    }
    
    private func hasEntryForDate(_ date: Date) -> Bool {
        return DailyContentManager.shared.hasEntry(for: date)
    }
    
    private func recentDatesWithActivity() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []
        
        // Check last 30 days
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                if hasActivity(for: date) {
                    dates.append(date)
                }
            }
        }
        
        // Always include today
        if !dates.contains(where: { calendar.isDateInToday($0) }) {
            dates.insert(today, at: 0)
        }
        
        return Array(dates.prefix(10)) // Show max 10 recent dates
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
                } else if days < 30 {
                    return "\(days / 7) week\(days / 7 == 1 ? "" : "s") ago"
                } else {
                    return "\(days / 30) month\(days / 30 == 1 ? "" : "s") ago"
                }
            } else {
                let futureDays = abs(days)
                if futureDays < 7 {
                    return "in \(futureDays) day\(futureDays == 1 ? "" : "s")"
                } else {
                    return "in \(futureDays / 7) week\(futureDays / 7 == 1 ? "" : "s")"
                }
            }
        }
    }
    
    private var hasSelectedMoments: Bool {
        !selectedLocations.isEmpty || !selectedEvents.isEmpty || !selectedPhotos.isEmpty || !selectedHealth.isEmpty
    }
    
    private var momentsCountText: String {
        let totalSelected = selectedLocations.count + selectedEvents.count + selectedPhotos.count + selectedHealth.count
        if totalSelected == 0 {
            return "Capture meaningful moments from your day"
        } else {
            return "\(totalSelected) selected"
        }
    }
    
    private var hasTrackerData: Bool {
        moodRating > 0 || energyRating > 0 || stressRating > 0 || 
        !foodInput.isEmpty || !prioritiesInput.isEmpty || !mediaInput.isEmpty || !peopleInput.isEmpty
    }
}

// MARK: - Activity Card Component
struct ActivityCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(iconColor)
                        )
                    
                    Spacer()
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TodayTabSettingsStyleView()
}

#Preview("Multi-Column Today") {
    TodayView()
}