import SwiftUI

// MARK: - Sheet Views

// MARK: - Places Sheet View
struct VisitsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingEntryView = false
    @State private var selectedVisitName: String = ""
    @Binding var visits: [(name: String, icon: DayOneIcon, time: String)]
    @Binding var selectedDate: Date
    let onAddPlaces: () -> Void
    var isForChat: Bool = false
    @Binding var selectedMomentsPlaces: Set<String>

    init(visits: Binding<[(name: String, icon: DayOneIcon, time: String)]>,
         selectedDate: Binding<Date>,
         onAddPlaces: @escaping () -> Void,
         isForChat: Bool = false,
         selectedPlacesForChat: Binding<Set<String>> = .constant([])) {
        self._visits = visits
        self._selectedDate = selectedDate
        self.onAddPlaces = onAddPlaces
        self.isForChat = isForChat
        self._selectedMomentsPlaces = selectedPlacesForChat
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header text
                Text("Select notable visits from this day...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                if visits.isEmpty {
                    // Empty state
                    VStack(spacing: 12) {
                        Spacer()

                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary.opacity(0.5))

                        // Only show this message when viewing today
                        if Calendar.current.isDateInToday(selectedDate) {
                            VStack(spacing: 16) {
                                Text("Places will be added as you visit locations throughout the day")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)

                                // View Yesterday button
                                Button {
                                    onAddPlaces()
                                } label: {
                                    Text("View Yesterday")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color(hex: "44C0FF"))
                                }
                                .padding(.top, 4)

                                // Check Settings button
                                Button {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Text("Check Settings")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color(hex: "44C0FF"))
                                }
                                .padding(.top, 4)
                            }
                        } else {
                            Text("No places visited on this day")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Visits list
                    List {
                    ForEach(visits, id: \.name) { visit in
                        Button(action: {
                            if isForChat {
                                // In chat mode, toggle the selection
                                if selectedMomentsPlaces.contains(visit.name) {
                                    selectedMomentsPlaces.remove(visit.name)
                                } else {
                                    selectedMomentsPlaces.insert(visit.name)
                                }
                            } else {
                                // In regular mode, open entry view
                                selectedVisitName = visit.name
                                showingEntryView = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                // Radio button (chat mode) or Icon (regular mode)
                                if isForChat {
                                    Image(systemName: selectedMomentsPlaces.contains(visit.name) ? "circle.inset.filled" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundStyle(selectedMomentsPlaces.contains(visit.name) ? Color(hex: "44C0FF") : .secondary)
                                        .frame(width: 32, height: 32)
                                } else {
                                    Image(dayOneIcon: visit.icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color(hex: "44C0FF"))
                                        .frame(width: 32, height: 32)
                                }

                                // Visit details
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(visit.name)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .opacity(isForChat ? (selectedMomentsPlaces.contains(visit.name) ? 1.0 : 0.5) : 1.0)

                                    Text(visit.time)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                // Ellipsis menu
                                Menu {
                                    Button(action: {
                                        selectedVisitName = visit.name
                                        showingEntryView = true
                                    }) {
                                        Label("Create Entry", dayOneIcon: .pen_edit)
                                    }

                                    Button(action: {
                                        // Handle select nearby place
                                    }) {
                                        Label("Select Nearby Place", dayOneIcon: .map_pin)
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                // Handle hide action
                            }) {
                                Label("Hide", dayOneIcon: .eye_cross)
                            }
                            .tint(.gray)

                            Button(action: {
                                // Handle edit action
                            }) {
                                Label("Edit", dayOneIcon: .pen)
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("View All") {
                        // TODO: Handle View All action
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Places")
                        .font(.headline)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
        .sheet(isPresented: $showingEntryView) {
            EntryView(
                journal: nil,
                prompt: selectedVisitName + "\n\n",
                startInEditMode: true
            )
        }
    }
}

// MARK: - Events Sheet View
struct EventsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingEntryView = false
    @State private var selectedEventName: String = ""
    @Binding var events: [(name: String, icon: DayOneIcon, time: String, type: String)]
    let onAddEvents: () -> Void
    var isForChat: Bool = false
    @Binding var selectedMomentsEvents: Set<String>

    init(events: Binding<[(name: String, icon: DayOneIcon, time: String, type: String)]>,
         onAddEvents: @escaping () -> Void,
         isForChat: Bool = false,
         selectedEventsForChat: Binding<Set<String>> = .constant([])) {
        self._events = events
        self.onAddEvents = onAddEvents
        self.isForChat = isForChat
        self._selectedMomentsEvents = selectedEventsForChat
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header text
                Text("Select notable events from this day...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                if events.isEmpty {
                    // Empty state
                    VStack(spacing: 12) {
                        Spacer()

                        Image(systemName: "calendar")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary.opacity(0.5))

                        VStack(spacing: 16) {
                            Text("No events on this day")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            // Select Calendars button
                            Button {
                                onAddEvents()
                            } label: {
                                Text("Select Calendars")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                            .padding(.top, 4)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Events list
                    List {
                    ForEach(events, id: \.name) { event in
                        Button(action: {
                            if isForChat {
                                // In chat mode, toggle the selection
                                if selectedMomentsEvents.contains(event.name) {
                                    selectedMomentsEvents.remove(event.name)
                                } else {
                                    selectedMomentsEvents.insert(event.name)
                                }
                            } else {
                                // In regular mode, open entry view
                                selectedEventName = event.name
                                showingEntryView = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                // Radio button (chat mode) or Icon (regular mode)
                                if isForChat {
                                    Image(systemName: selectedMomentsEvents.contains(event.name) ? "circle.inset.filled" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundStyle(selectedMomentsEvents.contains(event.name) ? Color(hex: "44C0FF") : .secondary)
                                        .frame(width: 32, height: 32)
                                } else {
                                    Image(dayOneIcon: event.icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color(hex: "44C0FF"))
                                        .frame(width: 32, height: 32)
                                }

                                // Event details
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.name)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .opacity(isForChat ? (selectedMomentsEvents.contains(event.name) ? 1.0 : 0.5) : 1.0)

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
                                        selectedEventName = event.name
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                // Handle hide action
                            }) {
                                Label("Hide", dayOneIcon: .eye_cross)
                            }
                            .tint(.gray)

                            Button(action: {
                                // Handle edit action
                            }) {
                                Label("Edit", dayOneIcon: .pen)
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Calendars") {
                        // TODO: Handle Calendars action
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Events")
                        .font(.headline)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
        .sheet(isPresented: $showingEntryView) {
            EntryView(
                journal: nil,
                prompt: selectedEventName + "\n\n",
                startInEditMode: true
            )
        }
    }
}

struct MediaSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingEntryView = false
    @State private var selectedImageIndex: Int = 0
    var isForChat: Bool = false
    @Binding var selectedMomentsPhotos: Set<String>

    init(isForChat: Bool = false, selectedPhotosForChat: Binding<Set<String>> = .constant([])) {
        self.isForChat = isForChat
        self._selectedMomentsPhotos = selectedPhotosForChat
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header text
                Text("Select notable photos from this day...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                // Media grid - 3 columns x 4 rows
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(0..<12) { index in
                            let photoId = "photo_\(index)"
                            let isSelected = selectedMomentsPhotos.contains(photoId)

                            Button(action: {
                                if isForChat {
                                    // In chat mode, toggle the selection
                                    if selectedMomentsPhotos.contains(photoId) {
                                        selectedMomentsPhotos.remove(photoId)
                                    } else {
                                        selectedMomentsPhotos.insert(photoId)
                                    }
                                } else {
                                    // In regular mode, open entry view
                                    selectedImageIndex = index
                                    showingEntryView = true
                                }
                            }) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(photoColors[index])
                                    .aspectRatio(1, contentMode: .fit)
                                    .opacity(isForChat ? (isSelected ? 1.0 : 0.5) : 1.0)
                                    .overlay(
                                        ZStack {
                                            if !isForChat {
                                                Image(dayOneIcon: .photo)
                                                    .font(.system(size: 24))
                                                    .foregroundStyle(.white.opacity(0.5))
                                            } else {
                                                // Radio button indicator for chat mode
                                                VStack {
                                                    HStack {
                                                        Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                                                            .font(.system(size: 20))
                                                            .foregroundStyle(isSelected ? Color(hex: "44C0FF") : .white.opacity(0.8))
                                                            .padding(8)
                                                        Spacer()
                                                    }
                                                    Spacer()
                                                }
                                            }
                                        }
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isForChat && isSelected ? Color(hex: "44C0FF") : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Media")
                        .font(.headline)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
        .sheet(isPresented: $showingEntryView) {
            EntryView(
                journal: nil,
                prompt: "Photo memory\n\n",
                startInEditMode: true
            )
        }
    }
}
