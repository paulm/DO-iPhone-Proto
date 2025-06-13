import SwiftUI

// MARK: - Today Tab Variants

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
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }
    
    private var completedActivitiesCount: Int {
        var count = 0
        if surveyCompleted { count += 1 }
        if !selectedLocations.isEmpty || !selectedEvents.isEmpty || !selectedPhotos.isEmpty { count += 1 }
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

#Preview {
    TodayTabSettingsStyleView()
}