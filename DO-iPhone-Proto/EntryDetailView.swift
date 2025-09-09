import SwiftUI
import MapKit

// MARK: - Entry Detail View for iPad Split View
struct EntryDetailView: View {
    let entryData: EntryView.EntryData?
    let journal: Journal?
    
    @State private var isEditMode = false
    @State private var entryText: String = ""
    @State private var showingJournalingTools = false
    @State private var showImageEmbed = false
    @State private var showAudioEmbed = false
    @FocusState private var textEditorFocused: Bool
    
    // Location for the map - Sundance Resort coordinates
    private let entryLocation = CLLocationCoordinate2D(latitude: 40.6006, longitude: -111.5878)
    private let locationName = "Sundance Mountain Resort"
    
    private var journalName: String {
        journal?.name ?? "Personal Journal"
    }
    
    private var journalColor: Color {
        journal?.color ?? Color(hex: "44C0FF")
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: entryData?.date ?? Date())
    }
    
    init(entryData: EntryView.EntryData?, journal: Journal?) {
        self.entryData = entryData
        self.journal = journal
        self._entryText = State(initialValue: entryData?.content ?? "")
    }
    
    var body: some View {
        Group {
            if isEditMode {
                // Edit mode
                editModeView
            } else {
                // Read mode
                readModeView
            }
        }
        .navigationTitle(entryData?.title ?? "Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isEditMode.toggle()
                        if isEditMode {
                            textEditorFocused = true
                        }
                    }
                } label: {
                    Text(isEditMode ? "Done" : "Edit")
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    // MARK: - Read Mode View
    @ViewBuilder
    private var readModeView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with date and metadata
                VStack(alignment: .leading, spacing: 8) {
                    Text(formattedDate)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(journalName)
                            .foregroundStyle(journalColor)
                            .fontWeight(.medium)
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(locationName)
                            .foregroundStyle(.secondary)
                        Text("•")
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "cloud.rain")
                                .font(.system(size: 14))
                            Text("17°C")
                        }
                        .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Main content
                Text(entryText)
                    .font(.system(size: 18))
                    .lineSpacing(4)
                    .foregroundColor(Color(hex: "292F33"))
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Embedded image if enabled
                if showImageEmbed {
                    VStack(spacing: 8) {
                        Image("sample-image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                        
                        Text("Beautiful sunrise at Sundance Mountain Resort")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding()
                }
                
                // Embedded map
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(locationName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Map(coordinateRegion: .constant(
                        MKCoordinateRegion(
                            center: entryLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    ), annotationItems: [entryLocation]) { location in
                        MapMarker(coordinate: location, tint: journalColor)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .disabled(true)
                }
                .padding()
                
                Spacer(minLength: 40)
            }
        }
    }
    
    // MARK: - Edit Mode View
    @ViewBuilder
    private var editModeView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Metadata row
                HStack {
                    Text(journalName)
                        .foregroundStyle(journalColor)
                        .fontWeight(.medium)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(locationName)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "cloud.rain")
                            .font(.system(size: 14))
                        Text("17°C")
                    }
                    .foregroundStyle(.secondary)
                }
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Text editor
                TextEditor(text: $entryText)
                    .font(.system(size: 18))
                    .lineSpacing(4)
                    .foregroundColor(Color(hex: "292F33"))
                    .scrollContentBackground(.hidden)
                    .focused($textEditorFocused)
                    .padding(.horizontal, 11)
                    .frame(minHeight: 400)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack(spacing: 18) {
                    // Dismiss keyboard button
                    Button {
                        textEditorFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 20))
                    }
                    
                    Spacer()
                    
                    // Formatting tools
                    Button {
                        // Bold action
                    } label: {
                        Image(systemName: "bold")
                            .font(.system(size: 18))
                    }
                    
                    Button {
                        // Italic action
                    } label: {
                        Image(systemName: "italic")
                            .font(.system(size: 18))
                    }
                    
                    Button {
                        // List action
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 18))
                    }
                    
                    Button {
                        showImageEmbed.toggle()
                    } label: {
                        Image(systemName: "photo")
                            .font(.system(size: 18))
                    }
                    
                    Button {
                        showAudioEmbed.toggle()
                    } label: {
                        Image(systemName: "mic")
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 12)
            }
        }
    }
}

// Extension to use CLLocationCoordinate2D as annotation item
extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude),\(longitude)"
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(
            entryData: EntryView.EntryData(
                title: "A Perfect Day",
                content: """
                Today was one of those rare days where everything seemed to align perfectly. I woke up early, around 6:30 AM, to the sound of birds chirping outside my window at the resort. The morning light was just beginning to filter through the trees, casting long shadows across the mountain slopes.
                
                The trail was quiet, with only a few other early risers making their way up the path. The air was crisp and cool, probably around 55 degrees, and I could see my breath forming small clouds as I walked.
                """,
                date: Date(),
                time: "6:11 PM CDT"
            ),
            journal: Journal(
                name: "Travel Journal",
                color: Color(hex: "FF6B6B"),
                entryCount: 42
            )
        )
    }
}