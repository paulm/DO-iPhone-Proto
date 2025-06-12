import SwiftUI

struct TrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var moodRating: Int
    @Binding var energyRating: Int
    @Binding var stressRating: Int
    @Binding var foodInput: String
    @Binding var prioritiesInput: String
    @Binding var mediaInput: String
    @Binding var peopleInput: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Instruction message
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Track your daily metrics and activities")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    
                    // Rating trackers section
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How are you feeling?")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            Text("Rate your mood, energy, and stress levels")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        }
                        
                        VStack(spacing: 0) {
                            TrackerRatingRow(title: "Mood", rating: $moodRating, icon: "face.smiling")
                            
                            Divider().padding(.leading, 60)
                            
                            TrackerRatingRow(title: "Energy", rating: $energyRating, icon: "bolt.fill")
                            
                            Divider().padding(.leading, 60)
                            
                            TrackerRatingRow(title: "Stress", rating: $stressRating, icon: "brain.head.profile")
                        }
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    // Input trackers section
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daily Activities")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            Text("Log what you did, ate, and who you spent time with")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        }
                        
                        VStack(spacing: 0) {
                            TrackerInputRow(title: "Food", text: $foodInput, icon: "fork.knife", placeholder: "What did you eat today?")
                            
                            Divider().padding(.leading, 60)
                            
                            TrackerInputRow(title: "Priorities", text: $prioritiesInput, icon: "target", placeholder: "What were your main priorities?")
                            
                            Divider().padding(.leading, 60)
                            
                            TrackerInputRow(title: "Media", text: $mediaInput, icon: "tv", placeholder: "What did you watch or read?")
                            
                            Divider().padding(.leading, 60)
                            
                            TrackerInputRow(title: "People", text: $peopleInput, icon: "person.2", placeholder: "Who did you spend time with?")
                        }
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Trackers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct TrackerRatingRow: View {
    let title: String
    @Binding var rating: Int
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon and title
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(width: 60, alignment: .leading)
            }
            
            // Rating stars
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        rating = star
                    }) {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundStyle(star <= rating ? .yellow : .gray.opacity(0.4))
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
            
            // Rating text
            Text("\(rating)/5")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct TrackerInputRow: View {
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and title
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                if !text.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            }
            
            // Input field
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct TrackersSummarySection: View {
    let moodRating: Int
    let energyRating: Int
    let stressRating: Int
    let foodInput: String
    let prioritiesInput: String
    let mediaInput: String
    let peopleInput: String
    let onTap: () -> Void
    
    private var completedTrackers: Int {
        var count = 0
        if moodRating > 0 { count += 1 }
        if energyRating > 0 { count += 1 }
        if stressRating > 0 { count += 1 }
        if !foodInput.isEmpty { count += 1 }
        if !prioritiesInput.isEmpty { count += 1 }
        if !mediaInput.isEmpty { count += 1 }
        if !peopleInput.isEmpty { count += 1 }
        return count
    }
    
    private var totalTrackers: Int { 7 }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Progress and completion status
                HStack {
                    if completedTrackers == 0 {
                        Text("Track your day")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(completedTrackers) of \(totalTrackers) completed")
                            .foregroundStyle(.primary)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Quick summary if any trackers completed
                if completedTrackers > 0 {
                    VStack(spacing: 8) {
                        // Ratings summary
                        if moodRating > 0 || energyRating > 0 || stressRating > 0 {
                            HStack(spacing: 16) {
                                if moodRating > 0 {
                                    TrackerSummaryItem(title: "Mood", value: "\(moodRating)/5", icon: "face.smiling")
                                }
                                if energyRating > 0 {
                                    TrackerSummaryItem(title: "Energy", value: "\(energyRating)/5", icon: "bolt.fill")
                                }
                                if stressRating > 0 {
                                    TrackerSummaryItem(title: "Stress", value: "\(stressRating)/5", icon: "brain.head.profile")
                                }
                                Spacer()
                            }
                        }
                        
                        // Activities summary
                        let activities = [foodInput, prioritiesInput, mediaInput, peopleInput].filter { !$0.isEmpty }
                        if !activities.isEmpty {
                            HStack {
                                Text("\(activities.count) activit\(activities.count == 1 ? "y" : "ies") logged")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TrackerSummaryItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    TrackerView(
        moodRating: .constant(4),
        energyRating: .constant(3),
        stressRating: .constant(2),
        foodInput: .constant("Salad for lunch"),
        prioritiesInput: .constant("Finish project"),
        mediaInput: .constant(""),
        peopleInput: .constant("Team meeting with Sarah")
    )
}