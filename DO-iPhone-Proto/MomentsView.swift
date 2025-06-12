import SwiftUI

// MARK: - Moment Data Models
struct Moment: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let type: MomentType
    let time: String
    
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
}

struct MomentsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocations: Set<String>
    @Binding var selectedEvents: Set<String>
    @Binding var selectedPhotos: Set<String>
    @State private var selectedMoments: Set<Moment> = []
    
    private let allMoments: [Moment] = [
        // Locations (chronological order)
        Moment(title: "Home", type: .location, time: "6:00 AM"),
        Moment(title: "Starbucks", type: .location, time: "8:15 AM"),
        Moment(title: "Office", type: .location, time: "9:30 AM"),
        Moment(title: "Gym", type: .location, time: "12:30 PM"),
        Moment(title: "Park", type: .location, time: "5:30 PM"),
        
        // Events (chronological order)
        Moment(title: "Team Meeting", type: .event, time: "10:00 AM"),
        Moment(title: "Lunch with Sarah", type: .event, time: "1:00 PM"),
        Moment(title: "Doctor Appointment", type: .event, time: "3:30 PM"),
        Moment(title: "Yoga Class", type: .event, time: "6:00 PM"),
        
        // Photos (chronological order)
        Moment(title: "Morning Coffee", type: .photo, time: "7:45 AM"),
        Moment(title: "Team Photo", type: .photo, time: "11:30 AM"),
        Moment(title: "Lunch View", type: .photo, time: "1:15 PM"),
        Moment(title: "Sunset Walk", type: .photo, time: "5:45 PM"),
        Moment(title: "Evening Workout", type: .photo, time: "6:30 PM")
    ].sorted { timeToMinutes($0.time) < timeToMinutes($1.time) }
    
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
                    ForEach(allMoments) { moment in
                        MomentRowView(
                            moment: moment,
                            isSelected: selectedMoments.contains(moment),
                            onTap: {
                                if selectedMoments.contains(moment) {
                                    selectedMoments.remove(moment)
                                    removeMomentFromBindings(moment)
                                } else {
                                    selectedMoments.insert(moment)
                                    addMomentToBindings(moment)
                                }
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
        }
    }
    
    private func loadCurrentSelections() {
        selectedMoments = Set(allMoments.filter { moment in
            switch moment.type {
            case .location:
                return selectedLocations.contains(moment.title)
            case .event:
                return selectedEvents.contains(moment.title)
            case .photo:
                return selectedPhotos.contains(moment.title)
            }
        })
    }
    
    private func addMomentToBindings(_ moment: Moment) {
        switch moment.type {
        case .location:
            selectedLocations.insert(moment.title)
        case .event:
            selectedEvents.insert(moment.title)
        case .photo:
            selectedPhotos.insert(moment.title)
        }
    }
    
    private func removeMomentFromBindings(_ moment: Moment) {
        switch moment.type {
        case .location:
            selectedLocations.remove(moment.title)
        case .event:
            selectedEvents.remove(moment.title)
        case .photo:
            selectedPhotos.remove(moment.title)
        }
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