import SwiftUI

/// Today tab view
struct TodayView: View {
    @State private var showingSettings = false
    @State private var showingDatePicker = false
    @State private var showingDailySurvey = false
    @State private var showingBio = false
    @State private var showingMoments = false
    @State private var showingTrackers = false
    @State private var selectedDate = Date()
    @State private var surveyCompleted = false
    
    // Trackers state
    @State private var moodRating = 3
    @State private var energyRating = 3
    @State private var stressRating = 3
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
                    
                    // Bio Section
                    SectionCard(title: "Bio", icon: "person.circle") {
                        Button("Update personal information") {
                            showingBio = true
                        }
                        .foregroundStyle(Color(hex: "44C0FF"))
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingDatePicker = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingDailySurvey) {
            DailySurveyView(onCompletion: {
                surveyCompleted = true
            })
        }
        .sheet(isPresented: $showingBio) {
            BioSettingsView()
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


#Preview {
    TodayView()
}