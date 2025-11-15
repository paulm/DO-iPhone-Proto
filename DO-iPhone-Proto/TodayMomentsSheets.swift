import SwiftUI

// MARK: - Moments Sheet Views

struct MomentsTrackersSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTrackers: [String: Int]

    private let trackers = ["Mood", "Energy", "Stress"]
    private let trackerIcons: [String: String] = [
        "Mood": "face.smiling",
        "Energy": "bolt.fill",
        "Stress": "wind"
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
                        NavigationLink(destination: TrackerDetailView(
                            trackerName: tracker,
                            trackerIcon: trackerIcons[tracker] ?? "circle"
                        )) {
                            HStack(spacing: 12) {
                                // Left column: Icon and label stacked horizontally
                                HStack(alignment: .center, spacing: 8) {
                                    Image(systemName: trackerIcons[tracker] ?? "circle")
                                        .font(.title3)
                                        .foregroundStyle(Color(hex: "44C0FF"))

                                    Text(tracker)
                                        .font(.body)
                                        .fontWeight(.medium)
                                }

                                Spacer()

                                // Right column: Rating circles right-aligned
                                HStack(spacing: 8) {
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
                                                    .frame(width: 40, height: 40)

                                                Text("\(rating)")
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                    .foregroundStyle(selectedTrackers[tracker] == rating ? .white : .primary)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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

// MARK: - Tracker Detail View
struct TrackerDetailView: View {
    let trackerName: String
    let trackerIcon: String

    // Sample data for the past month
    private var sampleData: [(date: Date, value: Int)] {
        let calendar = Calendar.current
        let today = Date()
        var data: [(Date, Int)] = []

        // Generate 30 days of sample data
        for day in (0..<30).reversed() {
            if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                // Random value between 1-5, with some days missing (nil values simulated as 0)
                let hasData = Int.random(in: 0...10) > 2 // 80% chance of having data
                let value = hasData ? Int.random(in: 1...5) : 0
                data.append((date, value))
            }
        }

        return data
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Graph section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Past 30 Days")
                        .font(.headline)
                        .padding(.horizontal, 20)

                    // Simple bar graph
                    TrackerGraphView(data: sampleData, trackerName: trackerName)
                        .frame(height: 60)
                        .padding(.horizontal, 20)
                }

                // Stats section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Statistics")
                        .font(.headline)
                        .padding(.horizontal, 20)

                    HStack(spacing: 16) {
                        StatCard(title: "Average", value: String(format: "%.1f", calculateAverage()))
                        StatCard(title: "Highest", value: "\(calculateMax())")
                        StatCard(title: "Lowest", value: "\(calculateMin())")
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
            .padding(.vertical, 20)
        }
        .navigationTitle(trackerName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func calculateAverage() -> Double {
        let validValues = sampleData.filter { $0.value > 0 }.map { Double($0.value) }
        guard !validValues.isEmpty else { return 0 }
        return validValues.reduce(0, +) / Double(validValues.count)
    }

    private func calculateMax() -> Int {
        return sampleData.map { $0.value }.max() ?? 0
    }

    private func calculateMin() -> Int {
        let validValues = sampleData.filter { $0.value > 0 }.map { $0.value }
        return validValues.min() ?? 0
    }
}

// MARK: - Tracker Graph View
struct TrackerGraphView: View {
    let data: [(date: Date, value: Int)]
    let trackerName: String

    // Color mapping for each value
    private func colorForValue(_ value: Int) -> Color {
        // Stress uses inverted colors (green=1, red=5)
        // Mood and Energy use normal colors (red=1, green=5)
        let isStress = trackerName == "Stress"

        let normalColors: [Color] = [
            Color.red,           // 1
            Color.orange,        // 2
            Color.yellow,        // 3
            Color(hex: "A3D977"), // 4 - light green
            Color.green          // 5
        ]

        let stressColors: [Color] = [
            Color.green,         // 1
            Color(hex: "A3D977"), // 2 - light green
            Color.yellow,        // 3
            Color.orange,        // 4
            Color.red            // 5
        ]

        let colors = isStress ? stressColors : normalColors

        guard value >= 1 && value <= 5 else { return Color.gray }
        return colors[value - 1]
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let validData = data.filter { $0.value > 0 }

            VStack(spacing: 4) {
                ZStack(alignment: .bottom) {
                    // Grid lines - 5 lines for values 1-5
                    VStack(spacing: 0) {
                        ForEach(0..<5) { index in
                            Divider()
                                .opacity(0.2)
                            if index < 4 {
                                Spacer()
                            }
                        }
                    }

                    // Data points - only show for days with data
                    if !validData.isEmpty {
                        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                            if item.value > 0 {
                                let xStep = width / CGFloat(data.count - 1)
                                let x = CGFloat(index) * xStep
                                // Map value (1-5) to y position, aligning exactly with grid lines
                                // Grid has 5 lines for values 1-5, evenly spaced
                                let normalizedValue = CGFloat(item.value - 1) / 4.0
                                let y = (height - 20) - ((height - 20) * normalizedValue)

                                Circle()
                                    .fill(colorForValue(item.value))
                                    .frame(width: 8, height: 8)
                                    .position(x: x, y: y)
                            }
                        }
                    }
                }

                // Date labels at bottom aligned with graph
                HStack(spacing: 0) {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        if index % 5 == 0 { // Show every 5th date to avoid crowding
                            let calendar = Calendar.current
                            let day = calendar.component(.day, from: item.date)

                            Text("\(day)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: width / CGFloat(data.count - 1) * 5, alignment: .leading)
                        }
                    }
                }
                .offset(x: 0, y: 0)
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "44C0FF"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
