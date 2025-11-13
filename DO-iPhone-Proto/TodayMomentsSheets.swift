import SwiftUI

// MARK: - Moments Sheet Views

struct MomentsTrackersSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTrackers: [String: Int]

    private let trackers = ["Mood", "Energy", "Stress", "Focus"]
    private let trackerIcons: [String: String] = [
        "Mood": "face.smiling",
        "Energy": "bolt.fill",
        "Stress": "wind",
        "Focus": "scope"
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header text
                Text("Select trackers and rate them on a scale of 1-5...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                // Trackers list
                List {
                    ForEach(trackers, id: \.self) { tracker in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .center) {
                                Image(systemName: trackerIcons[tracker] ?? "circle")
                                    .font(.title3)
                                    .foregroundStyle(Color(hex: "44C0FF"))

                                Text(tracker)
                                    .font(.body)
                                    .fontWeight(.medium)
                            }

                            // 1-5 rating circles - centered
                            HStack(spacing: 12) {
                                Spacer()
                                ForEach(1...5, id: \.self) { rating in
                                    Button(action: {
                                        if selectedTrackers[tracker] == rating {
                                            // Deselect if tapping the same rating
                                            selectedTrackers.removeValue(forKey: tracker)
                                        } else {
                                            selectedTrackers[tracker] = rating
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedTrackers[tracker] == rating ? Color(hex: "44C0FF") : Color.gray.opacity(0.2))
                                                .frame(width: 44, height: 44)

                                            Text("\(rating)")
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundStyle(selectedTrackers[tracker] == rating ? .white : .primary)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                Spacer()
                            }
                            .padding(.bottom, 4)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Trackers")
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
}

// MARK: - Moments Inputs Sheet View
struct MomentsInputsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var foodInput: String
    @Binding var dailyIntentionInput: String
    @Binding var prioritiesInput: String
    @Binding var mediaInput: String
    @Binding var peopleInput: String

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header text
                Text("Log what you did, ate, and who you spent time with")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                // Inputs list
                List {
                    TrackerInputRow(
                        title: "Food",
                        text: $foodInput,
                        icon: "fork.knife",
                        placeholder: "What did you eat today?",
                        suggestions: ["Coffee", "Eggs", "Salad", "Sandwich", "Smoothie"]
                    )

                    TrackerInputRow(
                        title: "Daily Intention",
                        text: $dailyIntentionInput,
                        icon: "target",
                        placeholder: "What's one intention for today?",
                        suggestions: ["Mindfulness", "Connection", "Focus"]
                    )

                    TrackerInputRow(
                        title: "Priorities",
                        text: $prioritiesInput,
                        icon: "checklist",
                        placeholder: "What are your main priorities?",
                        suggestions: ["Work", "Family", "Learning"]
                    )

                    TrackerInputRow(
                        title: "Media",
                        text: $mediaInput,
                        icon: "tv",
                        placeholder: "What did you consume?",
                        suggestions: ["Instagram", "Movie: ", "Show: ", "Podcast: "]
                    )

                    TrackerInputRow(
                        title: "People",
                        text: $peopleInput,
                        icon: "person.2",
                        placeholder: "Who did you spend time with?",
                        suggestions: ["Murphy Randle", "Hoss", "Paul Smart", "Reggie"]
                    )
                }
                .listStyle(.plain)
            }
            .navigationTitle("Inputs")
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
}
