import SwiftUI
import MapKit

struct MomentsSelectorView: View {
    // Constants
    private let toggleIconSize: CGFloat = 24
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    let photosCount: Int
    let places: [Visit]
    let events: [(name: String, icon: DayOneIcon, time: String, type: String)]

    @State private var selectedPhotoIDs: Set<String> = []
    @State private var selectedPlaceIDs: Set<UUID> = []
    @State private var selectedEventNames: Set<String> = []
    @State private var showingEntryView = false
    @State private var selectedItemName: String = ""
    @State private var photosExpanded = true
    @State private var placesExpanded = true
    @State private var eventsExpanded = true

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy"
        return formatter.string(from: selectedDate)
    }

    // Sample photo colors
    private let photoColors: [Color] = [
        Color(red: 0.8, green: 0.6, blue: 0.4),
        Color(red: 0.6, green: 0.7, blue: 0.9),
        Color(red: 0.9, green: 0.7, blue: 0.6),
        Color(red: 0.7, green: 0.8, blue: 0.7),
        Color(red: 0.8, green: 0.7, blue: 0.9),
        Color(red: 0.6, green: 0.8, blue: 0.8),
        Color(red: 0.9, green: 0.8, blue: 0.6),
        Color(red: 0.7, green: 0.7, blue: 0.8),
        Color(red: 0.8, green: 0.8, blue: 0.7),
        Color(red: 0.7, green: 0.8, blue: 0.9),
        Color(red: 0.9, green: 0.7, blue: 0.7),
        Color(red: 0.6, green: 0.9, blue: 0.7)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Photos Section
                    VStack(alignment: .leading, spacing: 0) {
                        // Collapsible header
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                photosExpanded.toggle()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Text("Photos")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(hex: "292F33"))

                                Spacer()

                                // Selection counter
                                Text("\(selectedPhotoIDs.count) / \(photosCount)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Image("arrow-right-circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: toggleIconSize, height: toggleIconSize)
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(.degrees(photosExpanded ? 90 : 0))
                                    .animation(.easeInOut(duration: 0.2), value: photosExpanded)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .animation(nil, value: photosExpanded)

                        if photosExpanded {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Select notable photos from this day...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                    ForEach(0..<photosCount, id: \.self) { index in
                                        let photoId = "photo_\(index)"
                                        let isSelected = selectedPhotoIDs.contains(photoId)

                                        Button(action: {
                                            if selectedPhotoIDs.contains(photoId) {
                                                selectedPhotoIDs.remove(photoId)
                                            } else {
                                                selectedPhotoIDs.insert(photoId)
                                            }
                                        }) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(photoColors[index % photoColors.count])
                                                .aspectRatio(1, contentMode: .fit)
                                                .opacity(isSelected ? 1.0 : 0.5)
                                                .overlay(
                                                    ZStack {
                                                        // Radio button indicator
                                                        VStack {
                                                            HStack {
                                                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                                    .font(.system(size: 20))
                                                                    .foregroundStyle(isSelected ? Color(hex: "44C0FF") : .white.opacity(0.8))
                                                                    .padding(8)
                                                                Spacer()
                                                            }
                                                            Spacer()
                                                        }
                                                    }
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(isSelected ? Color(hex: "44C0FF") : Color.clear, lineWidth: 2)
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        Spacer()
                            .frame(height: 16)
                    }

                    // Places Section
                    if !places.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            // Collapsible header
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    placesExpanded.toggle()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Text("Places")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(hex: "292F33"))

                                    Spacer()

                                    // Selection counter
                                    Text("\(selectedPlaceIDs.count) / \(places.count)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Image("arrow-right-circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: toggleIconSize, height: toggleIconSize)
                                        .foregroundStyle(.secondary)
                                        .rotationEffect(.degrees(placesExpanded ? 90 : 0))
                                        .animation(.easeInOut(duration: 0.2), value: placesExpanded)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .animation(nil, value: placesExpanded)

                            if placesExpanded {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Select notable visits from this day...")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 16)

                                    VStack(spacing: 0) {
                                        ForEach(places) { visit in
                                            VStack(spacing: 0) {
                                                placeRow(for: visit)

                                                if visit.id != places.last?.id {
                                                    Divider()
                                                        .padding(.leading, 20)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Spacer()
                                .frame(height: 16)
                        }
                    }

                    // Events Section
                    if !events.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            // Collapsible header
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    eventsExpanded.toggle()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Text("Events")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(hex: "292F33"))

                                    Spacer()

                                    // Selection counter
                                    Text("\(selectedEventNames.count) / \(events.count)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Image("arrow-right-circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: toggleIconSize, height: toggleIconSize)
                                        .foregroundStyle(.secondary)
                                        .rotationEffect(.degrees(eventsExpanded ? 90 : 0))
                                        .animation(.easeInOut(duration: 0.2), value: eventsExpanded)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .animation(nil, value: eventsExpanded)

                            if eventsExpanded {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Select notable events from this day...")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 16)

                                    VStack(spacing: 0) {
                                        ForEach(events.indices, id: \.self) { index in
                                            let event = events[index]
                                            VStack(spacing: 0) {
                                                eventRow(for: event)

                                                if index != events.count - 1 {
                                                    Divider()
                                                        .padding(.leading, 20)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Spacer()
                                .frame(height: 16)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Moments")
                            .font(.headline)
                        Text(dateString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEntryView) {
            EntryView(
                journal: nil,
                prompt: selectedItemName + "\n\n",
                startInEditMode: true
            )
        }
    }

    @ViewBuilder
    private func placeRow(for visit: Visit) -> some View {
        Button(action: {
            if selectedPlaceIDs.contains(visit.id) {
                selectedPlaceIDs.remove(visit.id)
            } else {
                selectedPlaceIDs.insert(visit.id)
            }
        }) {
            HStack(spacing: 12) {
                // Checkmark circle on left
                Image(systemName: selectedPlaceIDs.contains(visit.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedPlaceIDs.contains(visit.id) ? Color(hex: "44C0FF") : .secondary)
                    .font(.title3)

                // Visit details
                VStack(alignment: .leading, spacing: 2) {
                    switch visit.type {
                    case .city:
                        Text("City: \(visit.name)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    case .home, .work:
                        if let subtitle = visit.subtitle {
                            Text("\(visit.name) (\(subtitle))")
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundStyle(.primary)
                        } else {
                            Text(visit.name)
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundStyle(.primary)
                        }
                    case .place:
                        Text(visit.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }

                    if let location = visit.location {
                        Text("\(location) · \(visit.time) · \(visit.duration)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(visit.time) · \(visit.duration)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Menu button on right
                Menu {
                    Button("Select Nearby Place", systemImage: "location") {}
                    Button("Edit", systemImage: "pencil") {}
                    Button("Delete", systemImage: "trash", role: .destructive) {}
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.secondary)
                        .frame(width: 20, height: 20)
                }
                .onTapGesture {} // Prevent menu from triggering row tap
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .opacity(selectedPlaceIDs.contains(visit.id) ? 1.0 : 0.5)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func eventRow(for event: (name: String, icon: DayOneIcon, time: String, type: String)) -> some View {
        Button(action: {
            if selectedEventNames.contains(event.name) {
                selectedEventNames.remove(event.name)
            } else {
                selectedEventNames.insert(event.name)
            }
        }) {
            HStack(spacing: 12) {
                // Checkmark circle on left
                Image(systemName: selectedEventNames.contains(event.name) ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(selectedEventNames.contains(event.name) ? Color(hex: "44C0FF") : .secondary)
                    .frame(width: 32, height: 32)

                // Event details
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.name)
                        .font(.body)
                        .foregroundStyle(.primary)

                    HStack(spacing: 4) {
                        Text(event.time)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(event.type)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Ellipsis menu
                Menu {
                    Button(action: {
                        selectedItemName = event.name
                        showingEntryView = true
                    }) {
                        Label("Create Entry", dayOneIcon: .pen_edit)
                    }

                    Button(action: {
                        // Handle edit event
                    }) {
                        Label("Edit Event", dayOneIcon: .pen)
                    }

                    Button(action: {
                        // Handle hide
                    }) {
                        Label("Hide", dayOneIcon: .eye_cross)
                    }
                } label: {
                    Image(dayOneIcon: .dots_horizontal)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .opacity(selectedEventNames.contains(event.name) ? 1.0 : 0.5)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MomentsSelectorView(
        selectedDate: Date(),
        photosCount: 12,
        places: Visit.generateRandomVisits(for: Date()),
        events: [
            (name: "Morning Team Standup", icon: .calendar, time: "9:00 AM - 9:30 AM", type: "Work"),
            (name: "Lunch with Sarah", icon: .calendar, time: "12:30 PM - 1:30 PM", type: "Personal"),
            (name: "Dentist Appointment", icon: .calendar, time: "3:00 PM - 4:00 PM", type: "Personal")
        ]
    )
}
