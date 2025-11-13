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
            List {
                // Instruction message
                Section {
                    Text("Track your daily metrics and activities")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                
                // Rating trackers section
                Section {
                    TrackerRatingRow(title: "Mood", rating: $moodRating, icon: "face.smiling")
                    TrackerRatingRow(title: "Energy", rating: $energyRating, icon: "bolt.fill")
                    TrackerRatingRow(title: "Stress", rating: $stressRating, icon: "brain.head.profile")
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("How are you feeling?")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("Rate your mood, energy, and stress levels")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .textCase(nil)
                    .padding(.bottom, 8)
                }
                
                // Input trackers section
                Section {
                    TrackerInputRow(
                        title: "Food", 
                        text: $foodInput, 
                        icon: "fork.knife", 
                        placeholder: "What did you eat today?",
                        suggestions: ["Salad", "Pizza", "Coffee", "Sandwich", "Pasta", "Sushi", "Smoothie", "Burger"]
                    )
                    
                    TrackerInputRow(
                        title: "Priorities", 
                        text: $prioritiesInput, 
                        icon: "target", 
                        placeholder: "What were your main priorities?",
                        suggestions: ["Work project", "Exercise", "Family time", "Reading", "Meetings", "Planning", "Learning", "Errands"]
                    )
                    
                    TrackerInputRow(
                        title: "Media", 
                        text: $mediaInput, 
                        icon: "tv", 
                        placeholder: "What did you watch or read?",
                        suggestions: ["Netflix", "YouTube", "News", "Podcast", "Book", "Instagram", "Twitter", "Music"]
                    )
                    
                    TrackerInputRow(
                        title: "People", 
                        text: $peopleInput, 
                        icon: "person.2", 
                        placeholder: "Who did you spend time with?",
                        suggestions: ["Family", "Friends", "Colleagues", "Sarah", "Team", "Partner", "Kids", "Parents"]
                    )
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Activities")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("Log what you did, ate, and who you spent time with")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .textCase(nil)
                    .padding(.bottom, 8)
                }
            }
            .listStyle(.insetGrouped)
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
                
                if rating > 0 {
                    Text("\(rating)/5")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Rating circles
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { number in
                    Button(action: {
                        if rating == number {
                            rating = 0 // Deselect if tapping the same circle
                        } else {
                            rating = number // Select this circle
                        }
                    }) {
                        Circle()
                            .fill(number == rating ? Color(hex: "44C0FF") : .gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text("\(number)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(number == rating ? .white : .gray)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct TrackerInputRow: View {
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    let suggestions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            
            // Suggestion bubbles
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: {
                            addSuggestionToText(suggestion)
                        }) {
                            Text(suggestion)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(.gray.opacity(0.1))
                                )
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func addSuggestionToText(_ suggestion: String) {
        if text.isEmpty {
            text = suggestion
        } else {
            // Check if suggestion is already in the text to avoid duplicates
            let currentItems = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if !currentItems.contains(suggestion) {
                text += ", " + suggestion
            }
        }
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
        moodRating: .constant(0),
        energyRating: .constant(0),
        stressRating: .constant(0),
        foodInput: .constant(""),
        prioritiesInput: .constant(""),
        mediaInput: .constant(""),
        peopleInput: .constant("")
    )
}