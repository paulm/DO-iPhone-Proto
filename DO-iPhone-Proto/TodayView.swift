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
            case .original:
                TodayViewOriginal(
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
                    selectedPhotos: $selectedPhotos
                )
            case .appleSettings:
                TodayTabSettingsStyleView()
            case .v1i1:
                TodayViewV1i1(
                    showingSettings: $showingSettings,
                    showingDatePicker: $showingDatePicker,
                    showingMoments: $showingMoments,
                    selectedDate: $selectedDate,
                    selectedLocations: $selectedLocations,
                    selectedEvents: $selectedEvents,
                    selectedPhotos: $selectedPhotos
                )
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
                    selectedPhotos: $selectedPhotos
                )
            default:
                TodayViewOriginal(
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
                    selectedPhotos: $selectedPhotos
                )
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
                selectedPhotos: $selectedPhotos
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

/// Original Today tab layout
struct TodayViewOriginal: View {
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
        VStack(spacing: 0) {
            // Header with profile button
            HStack {
                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    Circle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.gray)
                        )
                }
                .accessibilityLabel("Settings")
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
            .padding(.top, 24)
            
            // Content sections
            ScrollView {
                VStack(spacing: 24) {
                    // Selected date display
                    Text(selectedDate, style: .date)
                        .font(.headline)
                        .padding(.top, 24)
                    
                    // Daily Survey Section
                    SectionCard(title: "Daily Survey", icon: "list.clipboard") {
                        VStack(alignment: .leading, spacing: 8) {
                            if surveyCompleted {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Completed for today")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Button(surveyCompleted ? "Edit" : "Start") {
                                showingDailySurvey = true
                            }
                            .foregroundStyle(Color(hex: "44C0FF"))
                        }
                    }
                    
                    // Moments Section
                    SectionCard(title: "Moments", icon: "sparkles") {
                        MomentsSummarySection(
                            selectedLocations: selectedLocations,
                            selectedEvents: selectedEvents,
                            selectedPhotos: selectedPhotos,
                            onTap: {
                                showingMoments = true
                            }
                        )
                    }
                    
                    // Trackers Section
                    SectionCard(title: "Trackers", icon: "chart.line.uptrend.xyaxis") {
                        TrackersSummarySection(
                            moodRating: moodRating,
                            energyRating: energyRating,
                            stressRating: stressRating,
                            foodInput: foodInput,
                            prioritiesInput: prioritiesInput,
                            mediaInput: mediaInput,
                            peopleInput: peopleInput,
                            onTap: {
                                showingTrackers = true
                            }
                        )
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
        }
    }
}

/// V1i1 Today tab layout - Copy of Original with Daily Chat section, no Daily Survey or Trackers
struct TodayViewV1i1: View {
    @Binding var showingSettings: Bool
    @Binding var showingDatePicker: Bool
    @Binding var showingMoments: Bool
    @Binding var selectedDate: Date
    @Binding var selectedLocations: Set<String>
    @Binding var selectedEvents: Set<String>
    @Binding var selectedPhotos: Set<String>
    
    @State private var showingDailyChat = false
    @State private var chatStarted = false
    @State private var momentsOpened = false
    
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
    
    private var currentDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private var totalSelectedMoments: Int {
        selectedLocations.count + selectedEvents.count + selectedPhotos.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with profile button
            HStack {
                Text(selectedDate, style: .date)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    Circle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.gray)
                        )
                }
                .accessibilityLabel("Settings")
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
            .padding(.top, 24)
            
            // Content sections
            ScrollView {
                VStack(spacing: 24) {
                    // Daily Chat Section
                    Button(action: {
                        showingDailyChat = true
                    }) {
                        VStack(spacing: 20) {
                            // Blue chat bubble icon
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(Color(hex: "44C0FF"))
                            
                            // Title
                            Text("Daily Chat")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            
                            // Status message
                            if chatStarted {
                                Text("12 messages")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Tap to start your \(currentDayName) chat...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Action button
                            if chatStarted {
                                Button("Generate Entry") {
                                    // TODO: Implement generate entry functionality
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color(hex: "44C0FF"))
                                
                                // Selected locations display
                                if !selectedLocations.isEmpty {
                                    Text(Array(selectedLocations).joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 8)
                                }
                            } else {
                                Button("Start Chat") {
                                    showingDailyChat = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color(hex: "44C0FF"))
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    
                    // Moments Section
                    Button(action: {
                        showingMoments = true
                    }) {
                        VStack(spacing: 20) {
                            // Sparkles icon
                            Image(systemName: "sparkles")
                                .font(.system(size: 50))
                                .foregroundStyle(Color(hex: "44C0FF"))
                            
                            // Title
                            Text("Moments")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            
                            // Status message
                            if momentsOpened {
                                if totalSelectedMoments == 0 {
                                    Text("No moments selected")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("\(totalSelectedMoments) moment\(totalSelectedMoments == 1 ? "" : "s") selected")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text("Capture meaningful moments from your day")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Action button
                            Button("Select Moments") {
                                showingMoments = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(hex: "44C0FF"))
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingDailyChat) {
            DailyChatView(onChatStarted: {
                chatStarted = true
            })
        }
        .sheet(isPresented: $showingMoments) {
            MomentsView(
                selectedLocations: $selectedLocations,
                selectedEvents: $selectedEvents,
                selectedPhotos: $selectedPhotos
            )
            .onAppear {
                momentsOpened = true
            }
        }
    }
}

/// V1i2 Today tab layout - Same header as v1i1 with Daily Activities section
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
    @State private var momentsCompleted = false
    @State private var trackersCompleted = false
    @State private var showingProfileMenu = false
    @State private var isGeneratingPreview = false
    
    // Show/hide toggles for Daily Activities
    @State private var showChat = true
    @State private var showMoments = true
    @State private var showTrackers = false
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
        !selectedLocations.isEmpty || !selectedEvents.isEmpty || !selectedPhotos.isEmpty
    }
    
    private var momentsCountText: String {
        let totalSelected = selectedLocations.count + selectedEvents.count + selectedPhotos.count
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
        let interactionCount = Int.random(in: 1...55)
        return "\(interactionCount) interactions."
    }
    
    private var chatSubtitleWithResume: String {
        let interactionCount = Int.random(in: 1...55)
        return "\(interactionCount) interactions Resume"
    }
    
    var body: some View {
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
                // Generated Journal Entry Preview (separate section)
                Section("Daily Summary") {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                if isGeneratingPreview {
                                    // Loading state
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 8) {
                                            Text("Generating entry...")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.secondary)
                                                .multilineTextAlignment(.leading)
                                            
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            // Placeholder lines with shimmer effect
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(.gray.opacity(0.3))
                                                .frame(height: 16)
                                                .frame(maxWidth: .infinity)
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(.gray.opacity(0.3))
                                                .frame(height: 16)
                                                .frame(maxWidth: .infinity)
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(.gray.opacity(0.3))
                                                .frame(height: 16)
                                                .frame(maxWidth: 0.7 * UIScreen.main.bounds.width)
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(.gray.opacity(0.3))
                                                .frame(height: 16)
                                                .frame(maxWidth: 0.9 * UIScreen.main.bounds.width)
                                        }
                                        
                                        // Show selected locations and events even during loading
                                        if !selectedLocations.isEmpty || !selectedEvents.isEmpty {
                                            VStack(alignment: .leading, spacing: 2) {
                                                if !selectedLocations.isEmpty {
                                                    Text("Locations: ") +
                                                    Text(Array(selectedLocations).joined(separator: ", "))
                                                        .foregroundStyle(.secondary)
                                                }
                                                
                                                if !selectedEvents.isEmpty {
                                                    Text("Events: ") +
                                                    Text(Array(selectedEvents).joined(separator: ", "))
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                            .fontWeight(.medium)
                                        }
                                    }
                                } else {
                                    // Actual content
                                    VStack(alignment: .leading, spacing: 8) {
                                        // Show placeholder if nothing is available
                                        if !chatCompleted && selectedLocations.isEmpty && selectedEvents.isEmpty {
                                            Text("Interact to populate")
                                                .font(.subheadline)
                                                .foregroundStyle(.tertiary)
                                                .multilineTextAlignment(.leading)
                                        } else {
                                            // Chat summary section
                                            if chatCompleted {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Morning Reflections and Evening Plans")
                                                        .font(.subheadline)
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(.primary)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Text("Today I started with my usual morning routine, feeling energized and ready to tackle the day ahead. I spent some time thinking about my work goals and how I want to approach the various projects I have on my plate. The conversation helped me organize my thoughts around what's most important right now. As I look toward the evening, I'm planning to wind down with some reading and prepare for tomorrow's meetings.")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(4)
                                                        .multilineTextAlignment(.leading)
                                                }
                                            }
                                            
                                            // Selected locations and events section
                                            if !selectedLocations.isEmpty || !selectedEvents.isEmpty {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    if !selectedLocations.isEmpty {
                                                        Text("Locations: ") +
                                                        Text(Array(selectedLocations).joined(separator: ", "))
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    
                                                    if !selectedEvents.isEmpty {
                                                        Text("Events: ") +
                                                        Text(Array(selectedEvents).joined(separator: ", "))
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                                .font(.caption)
                                                .foregroundStyle(.primary)
                                                .fontWeight(.medium)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if !isGeneratingPreview && (chatCompleted || !selectedLocations.isEmpty || !selectedEvents.isEmpty) {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                
                // Daily Chat Section
                if showChat {
                    Section("Daily Chat") {
                        TodayActivityRowWithChatResume(
                            icon: "bubble.left.and.bubble.right.fill",
                            iconColor: .blue,
                            title: dailyChatTitle,
                            subtitle: chatCompleted ? chatInteractionsText : "Share details or answer questions via chat to auto compose your daily entry.",
                            isCompleted: chatCompleted,
                            showResume: chatCompleted,
                            action: { showingDailyChat = true },
                            resumeAction: { showingDailyChat = true }
                        )
                    }
                }
                
                // Daily Moments Section
                if showMoments {
                    Section("Daily Moments") {
                        TodayActivityRowWithMomentsSubtitle(
                            icon: "sparkles",
                            iconColor: .purple,
                            title: "Moments",
                            selectedCount: selectedLocations.count + selectedEvents.count + selectedPhotos.count,
                            isCompleted: hasSelectedMoments,
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
            }
            .listStyle(.insetGrouped)
        }
        .sheet(isPresented: $showingDailyChat) {
            DailyChatView(onChatStarted: {
                // Start loading state when chat is first interacted with
                isGeneratingPreview = true
                
                // Simulate AI processing delay
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2.0...4.0)) {
                    isGeneratingPreview = false
                    chatCompleted = true
                }
            })
        }
        .sheet(isPresented: $showingMoments) {
            MomentsView(
                selectedLocations: $selectedLocations,
                selectedEvents: $selectedEvents,
                selectedPhotos: $selectedPhotos
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

// Daily Chat View
struct DailyChatView: View {
    @Environment(\.dismiss) private var dismiss
    let onChatStarted: () -> Void
    
    @State private var chatText = ""
    @State private var isLogDetailsMode = false
    @State private var messages: [DailyChatMessage] = []
    @State private var isThinking = false
    @FocusState private var isTextFieldFocused: Bool
    
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
                    VStack(spacing: 20) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(hex: "44C0FF"))
                        
                        Text("Daily Chat")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 40)
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
                                            isLogDetailsMode ? Color(hex: "44C0FF") : Color.clear,
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
            .navigationTitle("Daily Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Auto-focus text field when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
    }
    
    private func sendMessage() {
        let userMessage = DailyChatMessage(content: chatText, isUser: true)
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
            
            // Simulate AI response after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.5...3.0)) {
                isThinking = false
                let aiResponse = aiResponses.randomElement() ?? aiResponses[0]
                let aiMessage = DailyChatMessage(content: aiResponse, isUser: false)
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(aiMessage)
                }
            }
        }
    }
}

// Daily Chat Message Model
struct DailyChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
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
                    .background(Color(hex: "44C0FF"), in: RoundedRectangle(cornerRadius: 18))
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

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color(hex: "44C0FF"))
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            content
        }
        .padding()
        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct MomentsSummarySection: View {
    let selectedLocations: Set<String>
    let selectedEvents: Set<String>
    let selectedPhotos: Set<String>
    let onTap: () -> Void
    
    private var totalSelectedMoments: Int {
        selectedLocations.count + selectedEvents.count + selectedPhotos.count
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                if totalSelectedMoments == 0 {
                    Text("Select moments")
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(totalSelectedMoments) moment\(totalSelectedMoments == 1 ? "" : "s") selected")
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
    let action: () -> Void
    
    private var subtitleText: Text {
        if selectedCount == 0 {
            return Text("Capture meaningful moments from your day")
                .foregroundStyle(.secondary)
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
                    Text(title)
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


#Preview {
    TodayView()
}