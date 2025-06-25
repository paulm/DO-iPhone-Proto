import SwiftUI

// MARK: - Moment Data Models
enum MomentType: String, CaseIterable {
    case visit = "visit"
    case media = "media"
    case event = "event"
    case health = "health"
    
    var icon: String {
        switch self {
        case .visit: return "location.fill"
        case .media: return "photo.fill"
        case .event: return "calendar"
        case .health: return "heart.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .visit: return "Visits"
        case .media: return "Media"
        case .event: return "Events"
        case .health: return "Health"
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
    @Binding var selectedLocations: Set<String>
    @Binding var selectedEvents: Set<String>
    @Binding var selectedPhotos: Set<String>
    @Binding var selectedHealth: Set<String>
    
    init(selectedLocations: Binding<Set<String>>, selectedEvents: Binding<Set<String>>, selectedPhotos: Binding<Set<String>>, selectedHealth: Binding<Set<String>>) {
        self._selectedLocations = selectedLocations
        self._selectedEvents = selectedEvents
        self._selectedPhotos = selectedPhotos
        self._selectedHealth = selectedHealth
    }
    
    private var experimentsManager: ExperimentsManager { ExperimentsManager.shared }
    
    internal static let allMomentsData: [(String, MomentType, String)] = [
        // Visits (chronological order)
        ("Home", .visit, "6:00 AM"),
        ("Starbucks", .visit, "8:15 AM"),
        ("Office", .visit, "9:30 AM"),
        ("Gym", .visit, "12:30 PM"),
        ("Park", .visit, "5:30 PM"),
        
        // Media (chronological order)
        ("Morning Coffee", .media, "7:45 AM"),
        ("Team Photo", .media, "11:30 AM"),
        ("Lunch View", .media, "1:15 PM"),
        ("Sunset Walk", .media, "5:45 PM"),
        ("Evening Workout", .media, "6:30 PM"),
        ("Workout Selfie", .media, "7:00 PM"),
        
        // Events (chronological order)
        ("Team Meeting", .event, "10:00 AM"),
        ("Lunch with Sarah", .event, "1:00 PM"),
        ("Doctor Appointment", .event, "3:30 PM"),
        ("Yoga Class", .event, "6:00 PM"),
        
        // Health (chronological order)
        ("10,000 steps", .health, "6:00 PM"),
        ("8 hours sleep", .health, "6:30 AM"),
        ("30 min workout", .health, "12:30 PM"),
        ("2L water intake", .health, "8:00 PM")
    ]
    
    internal static let staticMoments: [Moment] = {
        return allMomentsData.map { (title, type, time) in
            Moment(title: title, type: type, time: time)
        }.sorted { timeToMinutes($0.time) < timeToMinutes($1.time) }
    }()
    
    private var allMoments: [Moment] { Self.staticMoments }
    
    var body: some View {
        switch experimentsManager.variant(for: .momentsModal) {
        case .grid:
            MomentsViewGrid(
                selectedLocations: $selectedLocations,
                selectedEvents: $selectedEvents,
                selectedPhotos: $selectedPhotos,
                selectedHealth: $selectedHealth
            )
        default:
            MomentsViewOriginal(
                selectedLocations: $selectedLocations,
                selectedEvents: $selectedEvents,
                selectedPhotos: $selectedPhotos,
                selectedHealth: $selectedHealth
            )
        }
    }
    
    private func isMomentSelected(_ moment: Moment) -> Bool {
        switch moment.type {
        case .visit:
            return selectedLocations.contains(moment.title)
        case .event:
            return selectedEvents.contains(moment.title)
        case .media:
            return selectedPhotos.contains(moment.title)
        case .health:
            return selectedHealth.contains(moment.title)
        }
    }
    
    private func toggleMomentSelection(_ moment: Moment) {
        switch moment.type {
        case .visit:
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
        case .media:
            if selectedPhotos.contains(moment.title) {
                selectedPhotos.remove(moment.title)
            } else {
                selectedPhotos.insert(moment.title)
            }
        case .health:
            if selectedHealth.contains(moment.title) {
                selectedHealth.remove(moment.title)
            } else {
                selectedHealth.insert(moment.title)
            }
        }
    }
}

// MARK: - Original List View
struct MomentsViewOriginal: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocations: Set<String>
    @Binding var selectedEvents: Set<String>
    @Binding var selectedPhotos: Set<String>
    @Binding var selectedHealth: Set<String>
    @State private var selectedMoments: Set<Moment> = []
    
    // Section toggles
    @State private var showVisits = true
    @State private var showMedia = true
    @State private var showEvents = true
    @State private var showHealth = true
    @State private var showingFilterMenu = false
    
    private var allMoments: [Moment] { MomentsView.staticMoments }
    
    private var filteredMoments: [Moment] {
        allMoments.filter { moment in
            switch moment.type {
            case .visit: return showVisits
            case .media: return showMedia
            case .event: return showEvents
            case .health: return showHealth
            }
        }
    }
    
    private var visitMoments: [Moment] {
        allMoments.filter { $0.type == .visit }
    }
    
    private var mediaMoments: [Moment] {
        allMoments.filter { $0.type == .media }
    }
    
    private var eventMoments: [Moment] {
        allMoments.filter { $0.type == .event }
    }
    
    private var healthMoments: [Moment] {
        allMoments.filter { $0.type == .health }
    }
    
    private var filterMenu: some View {
        Menu {
            Button {
                showVisits.toggle()
            } label: {
                HStack {
                    Text("Visits")
                    if showVisits {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Button {
                showMedia.toggle()
            } label: {
                HStack {
                    Text("Media")
                    if showMedia {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Button {
                showEvents.toggle()
            } label: {
                HStack {
                    Text("Events")
                    if showEvents {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Button {
                showHealth.toggle()
            } label: {
                HStack {
                    Text("Health")
                    if showHealth {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("Select moments from your day")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            filterMenu
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    private var momentSections: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Visits Section
            if showVisits && !visitMoments.isEmpty {
                MomentSectionView(
                    title: "Visits",
                    moments: visitMoments,
                    isSelected: isMomentSelected,
                    onTap: toggleMomentSelection
                )
            }
            
            // Media Section (Grid)
            if showMedia && !mediaMoments.isEmpty {
                MediaSectionView(
                    moments: mediaMoments,
                    isSelected: isMomentSelected,
                    onTap: toggleMomentSelection
                )
            }
            
            // Events Section
            if showEvents && !eventMoments.isEmpty {
                MomentSectionView(
                    title: "Events",
                    moments: eventMoments,
                    isSelected: isMomentSelected,
                    onTap: toggleMomentSelection
                )
            }
            
            // Health Section
            if showHealth && !healthMoments.isEmpty {
                MomentSectionView(
                    title: "Health",
                    moments: healthMoments,
                    isSelected: isMomentSelected,
                    onTap: toggleMomentSelection
                )
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    momentSections
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
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
            .onChange(of: selectedHealth) { _, _ in
                loadCurrentSelections()
            }
        }
    }
    
    private func isMomentSelected(_ moment: Moment) -> Bool {
        switch moment.type {
        case .visit:
            return selectedLocations.contains(moment.title)
        case .event:
            return selectedEvents.contains(moment.title)
        case .media:
            return selectedPhotos.contains(moment.title)
        case .health:
            return selectedHealth.contains(moment.title)
        }
    }
    
    private func toggleMomentSelection(_ moment: Moment) {
        switch moment.type {
        case .visit:
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
        case .media:
            if selectedPhotos.contains(moment.title) {
                selectedPhotos.remove(moment.title)
            } else {
                selectedPhotos.insert(moment.title)
            }
        case .health:
            if selectedHealth.contains(moment.title) {
                selectedHealth.remove(moment.title)
            } else {
                selectedHealth.insert(moment.title)
            }
        }
    }
    
    private func loadCurrentSelections() {
        selectedMoments = Set(allMoments.filter { moment in
            isMomentSelected(moment)
        })
    }
}

// MARK: - Grid View
struct MomentsViewGrid: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocations: Set<String>
    @Binding var selectedEvents: Set<String>
    @Binding var selectedPhotos: Set<String>
    @Binding var selectedHealth: Set<String>
    @State private var selectedMoments: Set<Moment> = []
    
    // Section toggles
    @State private var showVisits = true
    @State private var showMedia = true
    @State private var showEvents = true
    @State private var showHealth = true
    @State private var showingFilterMenu = false
    
    // Hidden moments
    @State private var hiddenMoments: Set<String> = []
    
    private var allMoments: [Moment] { MomentsView.staticMoments }
    
    private var visitMoments: [Moment] {
        allMoments.filter { $0.type == .visit && !hiddenMoments.contains($0.id) }
    }
    
    private var mediaMoments: [Moment] {
        allMoments.filter { $0.type == .media && !hiddenMoments.contains($0.id) }
    }
    
    private var eventMoments: [Moment] {
        allMoments.filter { $0.type == .event && !hiddenMoments.contains($0.id) }
    }
    
    private var healthMoments: [Moment] {
        allMoments.filter { $0.type == .health && !hiddenMoments.contains($0.id) }
    }
    
    private var filterMenu: some View {
        Menu {
            Button {
                showVisits.toggle()
            } label: {
                HStack {
                    Text("Visits")
                    if showVisits {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Button {
                showMedia.toggle()
            } label: {
                HStack {
                    Text("Media")
                    if showMedia {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Button {
                showEvents.toggle()
            } label: {
                HStack {
                    Text("Events")
                    if showEvents {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Button {
                showHealth.toggle()
            } label: {
                HStack {
                    Text("Health")
                    if showHealth {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Select moments from your day")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            filterMenu
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    private var contentSections: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Visits Section
            if showVisits && !visitMoments.isEmpty {
                MomentSectionView(
                    title: "Visits",
                    moments: visitMoments,
                    isSelected: isMomentSelected,
                    onTap: toggleMomentSelection,
                    onCreateEntry: { moment in
                        // TODO: Create entry for moment
                    },
                    onHide: { moment in
                        hiddenMoments.insert(moment.id)
                    }
                )
            }
            
            // Media Section (Grid)
            if showMedia && !mediaMoments.isEmpty {
                MediaSectionView(
                    moments: mediaMoments,
                    isSelected: isMomentSelected,
                    onTap: toggleMomentSelection
                )
            }
            
            // Events Section
            if showEvents && !eventMoments.isEmpty {
                MomentSectionView(
                    title: "Events",
                    moments: eventMoments,
                    isSelected: isMomentSelected,
                    onTap: toggleMomentSelection,
                    onCreateEntry: { moment in
                        // TODO: Create entry for moment
                    },
                    onHide: { moment in
                        hiddenMoments.insert(moment.id)
                    }
                )
            }
            
            // Health Section
            if showHealth && !healthMoments.isEmpty {
                MomentSectionView(
                    title: "Health",
                    moments: healthMoments,
                    isSelected: isMomentSelected,
                    onTap: toggleMomentSelection,
                    onCreateEntry: { moment in
                        // TODO: Create entry for moment
                    },
                    onHide: { moment in
                        hiddenMoments.insert(moment.id)
                    }
                )
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerView
                    contentSections
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
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
            .onChange(of: selectedHealth) { _, _ in
                loadCurrentSelections()
            }
        }
    }
    
    private func isMomentSelected(_ moment: Moment) -> Bool {
        switch moment.type {
        case .visit:
            return selectedLocations.contains(moment.title)
        case .event:
            return selectedEvents.contains(moment.title)
        case .media:
            return selectedPhotos.contains(moment.title)
        case .health:
            return selectedHealth.contains(moment.title)
        }
    }
    
    private func toggleMomentSelection(_ moment: Moment) {
        switch moment.type {
        case .visit:
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
        case .media:
            if selectedPhotos.contains(moment.title) {
                selectedPhotos.remove(moment.title)
            } else {
                selectedPhotos.insert(moment.title)
            }
        case .health:
            if selectedHealth.contains(moment.title) {
                selectedHealth.remove(moment.title)
            } else {
                selectedHealth.insert(moment.title)
            }
        }
    }
    
    private func loadCurrentSelections() {
        selectedMoments = Set(allMoments.filter { moment in
            isMomentSelected(moment)
        })
    }
}

struct MomentSectionView: View {
    let title: String
    let moments: [Moment]
    let isSelected: (Moment) -> Bool
    let onTap: (Moment) -> Void
    let onCreateEntry: ((Moment) -> Void)?
    let onHide: ((Moment) -> Void)?
    
    init(title: String, moments: [Moment], isSelected: @escaping (Moment) -> Bool, onTap: @escaping (Moment) -> Void, onCreateEntry: ((Moment) -> Void)? = nil, onHide: ((Moment) -> Void)? = nil) {
        self.title = title
        self.moments = moments
        self.isSelected = isSelected
        self.onTap = onTap
        self.onCreateEntry = onCreateEntry
        self.onHide = onHide
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(moments, id: \.id) { moment in
                    MomentRowView(
                        moment: moment,
                        isSelected: isSelected(moment),
                        onTap: { onTap(moment) },
                        onCreateEntry: onCreateEntry != nil ? { onCreateEntry?(moment) } : nil,
                        onHide: onHide != nil ? { onHide?(moment) } : nil
                    )
                    
                    if moment.id != moments.last?.id {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.white.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 20)
    }
}

struct MediaSectionView: View {
    let moments: [Moment]
    let isSelected: (Moment) -> Bool
    let onTap: (Moment) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Media")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(moments, id: \.id) { moment in
                    MediaGridCell(
                        moment: moment,
                        isSelected: isSelected(moment),
                        onTap: { onTap(moment) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 20)
    }
}

struct MediaGridCell: View {
    let moment: Moment
    let isSelected: Bool
    let onTap: () -> Void
    
    private var backgroundImageName: String? {
        // Randomly choose between bike and bike-wide based on moment title hash
        let hash = moment.title.hashValue
        return hash % 2 == 0 ? "bike" : "bike-wide"
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background image
                if let imageName = backgroundImageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(isSelected ? 1.0 : 0.65)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                VStack(spacing: 4) {
                    Spacer()
                    
                    Text(moment.title)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white : .white)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.5), radius: 1)
                    
                    Text(moment.time)
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.9) : .white.opacity(0.8))
                        .shadow(color: .black.opacity(0.5), radius: 1)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white)
                            .font(.caption)
                            .shadow(color: .black.opacity(0.5), radius: 1)
                    }
                }
                .padding(8)
            }
            .frame(height: 100)
            .background(
                isSelected ? Color.white : Color.white.opacity(0.4),
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(
                isSelected ? RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "44C0FF"), lineWidth: 2) : nil
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MomentRowView: View {
    let moment: Moment
    let isSelected: Bool
    let onTap: () -> Void
    let onCreateEntry: (() -> Void)?
    let onHide: (() -> Void)?
    
    init(moment: Moment, isSelected: Bool, onTap: @escaping () -> Void, onCreateEntry: (() -> Void)? = nil, onHide: (() -> Void)? = nil) {
        self.moment = moment
        self.isSelected = isSelected
        self.onTap = onTap
        self.onCreateEntry = onCreateEntry
        self.onHide = onHide
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Main content as button
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // Icon and Time (left side)
                    HStack(spacing: 6) {
                        Image(systemName: moment.type.icon)
                            .font(.caption)
                            .foregroundStyle(isSelected ? Color(hex: "44C0FF") : .secondary)
                            .frame(width: 16, height: 16)
                        
                        Text(moment.time)
                            .font(.caption)
                            .foregroundStyle(isSelected ? Color(hex: "44C0FF") : .secondary)
                            .fixedSize()
                    }
                    
                    Spacer()
                    
                    // Moment name (right-aligned)
                    Text(moment.title)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? .primary : .secondary)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.trailing)
                    
                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(hex: "44C0FF"))
                            .font(.caption)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // 3-dot menu
            Menu {
                Button("Create Entry") {
                    onCreateEntry?()
                }
                
                Button("Hide") {
                    onHide?()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            isSelected ? Color.white : Color.clear,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }
}

struct MomentGridCell: View {
    let moment: Moment
    let isSelected: Bool
    let onTap: () -> Void
    
    private var backgroundImageName: String? {
        if moment.type == .media {
            // Randomly choose between bike and bike-wide based on moment title hash
            let hash = moment.title.hashValue
            return hash % 2 == 0 ? "bike" : "bike-wide"
        }
        return nil
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background for photo items
                if let imageName = backgroundImageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(isSelected ? 1.0 : 0.65)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(spacing: 8) {
                    // Icon
                    Image(systemName: moment.type.icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .frame(width: 24, height: 24)
                    
                    // Moment name
                    Text(moment.title)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Time
                    Text(moment.time)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
                    
                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white)
                            .font(.caption)
                    } else {
                        // Invisible spacer to maintain consistent height
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.clear)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
            }
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? Color(hex: "44C0FF") : .white,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
    MomentsViewOriginal(
        selectedLocations: .constant(Set(["Home", "Office"])),
        selectedEvents: .constant(Set(["Team Meeting"])),
        selectedPhotos: .constant(Set()),
        selectedHealth: .constant(Set(["10,000 steps"]))
    )
}
