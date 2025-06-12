import SwiftUI

// MARK: - Moment Data Models
enum MomentType: String, CaseIterable {
    case location = "location"
    case event = "calendar"
    case photo = "photo"
    
    var icon: String {
        switch self {
        case .location: return "location.fill"
        case .event: return "calendar"
        case .photo: return "photo.fill"
        }
    }
}

struct Moment: Identifiable, Hashable {
    let title: String
    let type: MomentType
    let time: String
    
    // Use content-based ID for stable identification
    var id: String {
        "\(type.rawValue)-\(title)-\(time)"
    }
    
    // Implement Hashable based on content, not UUID
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(type)
        hasher.combine(time)
    }
    
    static func == (lhs: Moment, rhs: Moment) -> Bool {
        lhs.title == rhs.title && lhs.type == rhs.type && lhs.time == rhs.time
    }
}

struct MomentsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocations: Set<String>
    @Binding var selectedEvents: Set<String>
    @Binding var selectedPhotos: Set<String>
    @State private var selectedMoments: Set<Moment> = []
    
    private static let allMomentsData: [(String, MomentType, String)] = [
        // Locations (chronological order)
        ("Home", .location, "6:00 AM"),
        ("Starbucks", .location, "8:15 AM"),
        ("Office", .location, "9:30 AM"),
        ("Gym", .location, "12:30 PM"),
        ("Park", .location, "5:30 PM"),
        
        // Events (chronological order)
        ("Team Meeting", .event, "10:00 AM"),
        ("Lunch with Sarah", .event, "1:00 PM"),
        ("Doctor Appointment", .event, "3:30 PM"),
        ("Yoga Class", .event, "6:00 PM"),
        
        // Photos (chronological order)
        ("Morning Coffee", .photo, "7:45 AM"),
        ("Team Photo", .photo, "11:30 AM"),
        ("Lunch View", .photo, "1:15 PM"),
        ("Sunset Walk", .photo, "5:45 PM"),
        ("Evening Workout", .photo, "6:30 PM")
    ]
    
    private static let staticMoments: [Moment] = {
        return allMomentsData.map { (title, type, time) in
            Moment(title: title, type: type, time: time)
        }.sorted { timeToMinutes($0.time) < timeToMinutes($1.time) }
    }()
    
    private var allMoments: [Moment] { Self.staticMoments }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Instruction message
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select the highlights from your day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                List {
                    ForEach(allMoments, id: \.id) { moment in
                        MomentRowView(
                            moment: moment,
                            isSelected: isMomentSelected(moment),
                            onTap: {
                                toggleMomentSelection(moment)
                            }
                        )
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Moments")
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
            .onAppear {
                loadCurrentSelections()
            }
            .onChange(of: selectedLocations) { _, _ in
                loadCurrentSelections()
            }
            .onChange(of: selectedEvents) { _, _ in
                loadCurrentSelections()
            }
            .onChange(of: selectedPhotos) { _, _ in
                loadCurrentSelections()
            }
        }
    }
    
    private func isMomentSelected(_ moment: Moment) -> Bool {
        switch moment.type {
        case .location:
            return selectedLocations.contains(moment.title)
        case .event:
            return selectedEvents.contains(moment.title)
        case .photo:
            return selectedPhotos.contains(moment.title)
        }
    }
    
    private func toggleMomentSelection(_ moment: Moment) {
        switch moment.type {
        case .location:
            if selectedLocations.contains(moment.title) {
                selectedLocations.remove(moment.title)
            } else {
                selectedLocations.insert(moment.title)
            }
        case .event:
            if selectedEvents.contains(moment.title) {
                selectedEvents.remove(moment.title)
            } else {
                selectedEvents.insert(moment.title)
            }
        case .photo:
            if selectedPhotos.contains(moment.title) {
                selectedPhotos.remove(moment.title)
            } else {
                selectedPhotos.insert(moment.title)
            }
        }
    }
    
    private func loadCurrentSelections() {
        selectedMoments = Set(allMoments.filter { moment in
            isMomentSelected(moment)
        })
    }
}

struct MomentRowView: View {
    let moment: Moment
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon and Time (left side)
                HStack(spacing: 6) {
                    Image(systemName: moment.type.icon)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .frame(width: 16, height: 16)
                    
                    Text(moment.time)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .fixedSize()
                }
                
                Spacer()
                
                // Moment name (right-aligned)
                Text(moment.title)
                    .font(.subheadline)
                    .foregroundStyle(isSelected ? .white : .primary)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.trailing)
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color(hex: "44C0FF") : .clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

// Helper function to convert time string to minutes for sorting
private func timeToMinutes(_ timeString: String) -> Int {
    let components = timeString.replacingOccurrences(of: " AM", with: "").replacingOccurrences(of: " PM", with: "").split(separator: ":")
    guard components.count == 2,
          let hours = Int(components[0]),
          let minutes = Int(components[1]) else {
        return 0
    }
    
    let isPM = timeString.contains("PM")
    let adjustedHours = isPM && hours != 12 ? hours + 12 : (hours == 12 && !isPM ? 0 : hours)
    
    return adjustedHours * 60 + minutes
}

#Preview {
    MomentsView(
        selectedLocations: .constant(Set(["Home", "Office"])),
        selectedEvents: .constant(Set(["Team Meeting"])),
        selectedPhotos: .constant(Set())
    )
}