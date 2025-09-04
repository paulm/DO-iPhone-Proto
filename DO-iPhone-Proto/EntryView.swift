import SwiftUI
import MapKit

/// Modal sheet for creating new journal entries
struct EntryView: View {
    @Environment(\.dismiss) private var dismiss
    let journal: Journal?
    let entryData: EntryData?
    let prompt: String?
    
    // Entry data structure
    struct EntryData {
        let title: String
        let content: String
        let date: Date
        let time: String
    }
    
    @State private var entryText: String
    @State private var showingJournalingTools = false
    @State private var showingDailyChat = false
    @State private var hasChatActivity = true // Simulating that this entry has chat activity
    @State private var entryDate: Date
    @State private var showingEditDate = false
    @State private var showEntryChatEmbed = false
    @State private var showGeneratedFromDailyChat = false
    @State private var isPlayingAudio = false
    @State private var audioDuration: TimeInterval = 125 // 2:05 duration
    @State private var currentPlayTime: TimeInterval = 0
    @State private var showingTranscription = false
    @State private var isPlayingAudio2 = false
    @State private var audioDuration2: TimeInterval = 87 // 1:27 duration
    @State private var showingAudioPage = false
    @State private var showingAudioPage2 = false
    @State private var selectedAudioHasTranscription = true
    @State private var showAudioEmbed = false
    @State private var showAudioEmbedWithTranscription = false
    @State private var showImageEmbed = false
    @State private var showImageCaption = false
    @State private var showingMediaPage = false
    @State private var isEditMode = false
    @State private var shouldShowAudioOnAppear: Bool
    @State private var showingCompactAudioRecord = false
    @State private var insertedAudioData: AudioRecordView.AudioData?
    @State private var useLatoFont = false
    @FocusState private var textEditorFocused: Bool
    
    // Location for the map - Sundance Resort coordinates
    private let entryLocation = CLLocationCoordinate2D(latitude: 40.6006, longitude: -111.5878)
    private let locationName = "Sundance Mountain Resort"
    
    // Default entry content
    private let defaultEntryContent = """
A Perfect Day at Sundance

Today was one of those rare days where everything seemed to align perfectly. I woke up early, around 6:30 AM, to the sound of birds chirping outside my window at the resort. The morning light was just beginning to filter through the trees, casting long shadows across the mountain slopes. I decided to start the day with a hike on the Stewart Falls trail.

The trail was quiet, with only a few other early risers making their way up the path. The air was crisp and cool, probably around 55 degrees, and I could see my breath forming small clouds as I walked. About halfway up, I stopped at a clearing that offered a stunning view of the valley below. The aspens were just beginning to turn golden, creating patches of warm color against the dark green of the pines. I sat on a large rock and just took it all in, feeling grateful for this moment of solitude in nature.
"""
    
    init(journal: Journal?, entryData: EntryData? = nil, prompt: String? = nil, shouldShowAudioOnAppear: Bool = false, startInEditMode: Bool = false) {
        self.journal = journal
        self.entryData = entryData
        self.prompt = prompt
        self._shouldShowAudioOnAppear = State(initialValue: shouldShowAudioOnAppear)
        self._isEditMode = State(initialValue: startInEditMode)
        
        if let data = entryData {
            // Use provided entry data
            self._entryText = State(initialValue: data.content)
            
            // Parse time string and apply to date
            var finalDate = data.date
            let timeComponents = data.time.components(separatedBy: " ")
            if timeComponents.count >= 2 {
                let timePart = timeComponents[0] // e.g., "6:11"
                let meridiem = timeComponents[1] // e.g., "PM"
                
                let timeSubComponents = timePart.components(separatedBy: ":")
                if timeSubComponents.count == 2,
                   let hour = Int(timeSubComponents[0]),
                   let minute = Int(timeSubComponents[1]) {
                    
                    var adjustedHour = hour
                    if meridiem.hasPrefix("PM") && hour != 12 {
                        adjustedHour += 12
                    } else if meridiem.hasPrefix("AM") && hour == 12 {
                        adjustedHour = 0
                    }
                    
                    let calendar = Calendar.current
                    if let dateWithTime = calendar.date(bySettingHour: adjustedHour, minute: minute, second: 0, of: data.date) {
                        finalDate = dateWithTime
                    }
                }
            }
            
            self._entryDate = State(initialValue: finalDate)
        } else if let prompt = prompt {
            // New entry with prompt
            self._entryText = State(initialValue: prompt + "\n\n")
            self._entryDate = State(initialValue: Date())
        } else {
            // New entry - use defaults with sample content
            self._entryText = State(initialValue: defaultEntryContent)
            self._entryDate = State(initialValue: Date())
        }
    }
    
    // Audio transcription text
    private let audioTranscriptionText = """
So, I'm sitting here at Stewart Falls, and I just... I can't even put into words how beautiful this is. The water is just cascading down, and there's this mist that's catching the morning light. It's creating these tiny rainbows everywhere I look.

I'm about halfway up the trail now, and I had to stop and just take this in. You know, I was thinking on the way up here about how we get so caught up in our daily routines, checking emails, rushing from one thing to the next. But being out here, it's like... it's like time just slows down.

The aspens are incredible right now. They're just starting to turn, and you can see these patches of gold mixed in with the evergreens. I wish I could capture this, but even photos don't do it justice. There's something about being here, feeling the cool air, hearing the water... it's just so peaceful.

I think I'm going to sit here for a while longer before heading back down. This is exactly what I needed.
"""
    private var journalName: String {
        journal?.name ?? "Sample Journal"
    }
    private var journalColor: Color {
        journal?.color ?? Color(hex: "4EC3FE")
    }
    
    // Shared text style for entry content
    private var entryTextStyle: some ViewModifier {
        struct EntryTextModifier: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.9))
                    .lineSpacing(4)
            }
        }
        return EntryTextModifier()
    }
    
    private func audioRecordingEmbed(hasTranscription: Bool, isPlaying: Binding<Bool>, duration: TimeInterval, title: String, transcriptionPreview: String? = nil, onTap: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Play/Pause button
                Button {
                    isPlaying.wrappedValue.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: isPlaying.wrappedValue ? "pause.fill" : "play.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .offset(x: isPlaying.wrappedValue ? 0 : 1)
                    }
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(formatTime(duration))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        if hasTranscription {
                            Text("·")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "text.quote")
                                    .font(.system(size: 10))
                                Text("Transcription")
                                    .font(.caption2)
                            }
                            .foregroundStyle(Color.blue)
                        }
                    }
                }
                
                Spacer()
                
                // Waveform visualization
                HStack(spacing: 2) {
                    ForEach(0..<30) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 2, height: CGFloat.random(in: 8...24))
                    }
                }
                .frame(width: 100)
            }
            .padding(12)
            
            // Transcription preview for embeds with transcription
            if hasTranscription, let preview = transcriptionPreview {
                VStack(alignment: .leading, spacing: 4) {
                    Divider()
                        .padding(.horizontal, -12)
                    
                    Text(preview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
            }
        }
        .background(Color(hex: "F8F8F8"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private func imageEmbed(imageName: String, caption: String? = nil, showCaption: Bool = true, onTap: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            // Caption section similar to audio transcription preview
            if showCaption, let captionText = caption {
                VStack(alignment: .leading, spacing: 4) {
                    Divider()
                        .padding(.horizontal, -12)
                    
                    Text(captionText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
            }
        }
        .background(Color(hex: "F8F8F8"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isEditMode {
                    // Edit mode - Full screen scrollable content
                    ScrollView {
                        VStack(spacing: 0) {
                            // Add top padding for navigation bar (reduced by 16pt for alignment)
                            Color.clear.frame(height: 82)
                            
                            // Metadata row as a separate styled view
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
                            .padding(.bottom, 8) // Reduced from 12 to 8 (4pt closer)
                            
                            // Text editor for entry content
                            TextEditor(text: $entryText)
                                .font(useLatoFont ? Font.custom("Lato-Regular", size: 18) : .system(size: 18))
                                .lineSpacing(4)
                                .foregroundColor(Color(hex: "292F33"))
                                .scrollContentBackground(.hidden)
                                .scrollDisabled(true)  // Disable TextEditor's internal scrolling
                                .focused($textEditorFocused)
                                .padding(.horizontal, 11) // Reduced from 16 to 11 (5pt less)
                                .padding(.bottom, 100) // Space for keyboard
                                .frame(minHeight: UIScreen.main.bounds.height - 200)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        VStack(spacing: 0) {
                                            HStack(spacing: 18) {
                                                // Dismiss keyboard and toggle to Read Mode (left-aligned)
                                                Button {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        textEditorFocused = false
                                                        isEditMode = false
                                                    }
                                                } label: {
                                                    Text(DayOneIcon.chevron_down.rawValue)
                                                        .font(Font.custom("DayOneIcons", size: 18))
                                                        .foregroundColor(.primary)
                                                }
                                                .padding(.leading, 6) // Move left icon in by 10pt
                                                
                                                Spacer()
                                                
                                                // Right-aligned buttons
                                                HStack(spacing: 18) {
                                                    // AI Sparkle menu
                                                    Menu {
                                                        Button {
                                                            // AI Title Suggestions action
                                                        } label: {
                                                            Label("AI Title Suggestions", systemImage: "textformat.abc")
                                                        }
                                                        
                                                        Button {
                                                            // Go Deeper Prompts action
                                                        } label: {
                                                            Label("Go Deeper Prompts", systemImage: "bubble.left.and.bubble.right")
                                                        }
                                                        
                                                        Button {
                                                            // Entry Highlights action
                                                        } label: {
                                                            Label("Entry Highlights", systemImage: "doc.text")
                                                        }
                                                        
                                                        Button {
                                                            // Generate Image action
                                                        } label: {
                                                            Label("Generate Image", systemImage: "photo.badge.plus")
                                                        }
                                                        
                                                        
                                                    } label: {
                                                        Text(DayOneIcon.sparkles.rawValue)
                                                            .font(Font.custom("DayOneIcons", size: 18))
                                                            .foregroundColor(.primary)
                                                    }
                                                    
                                                    // Photo picker button
                                                    Button {
                                                        // Open system photo picker
                                                    } label: {
                                                        Text(DayOneIcon.photo.rawValue)
                                                            .font(Font.custom("DayOneIcons", size: 18))
                                                            .foregroundColor(.primary)
                                                    }
                                                    
                                                    // Paperclip attachment menu
                                                    Menu {
                                                        Button {
                                                            // Audio action
                                                        } label: {
                                                            Label("Audio", systemImage: "waveform")
                                                        }
                                                        
                                                        Button {
                                                            showingCompactAudioRecord = true
                                                        } label: {
                                                            Label("Record", systemImage: "mic")
                                                        }
                                                        
                                                        Button {
                                                            // Record Video action
                                                        } label: {
                                                            Label("Record Video", systemImage: "video")
                                                        }
                                                        
                                                        Button {
                                                            // Draw action
                                                        } label: {
                                                            Label("Draw", systemImage: "pencil.tip")
                                                        }
                                                        
                                                        Button {
                                                            // Chat action
                                                        } label: {
                                                            Label("Chat", systemImage: "bubble.left")
                                                        }
                                                    } label: {
                                                        Text(DayOneIcon.attachment.rawValue)
                                                            .font(Font.custom("DayOneIcons", size: 18))
                                                            .foregroundColor(.primary)
                                                    }
                                                    
                                                    // Text formatting menu
                                                    Menu {
                                                        Button {
                                                            // Bold action
                                                        } label: {
                                                            Label("Bold", systemImage: "bold")
                                                        }
                                                        
                                                        Button {
                                                            // Italic action
                                                        } label: {
                                                            Label("Italic", systemImage: "italic")
                                                        }
                                                        
                                                        Divider()
                                                        
                                                        Button {
                                                            // Header action
                                                        } label: {
                                                            Label("Header", systemImage: "textformat.size.larger")
                                                        }
                                                        
                                                        Button {
                                                            // Subhead action
                                                        } label: {
                                                            Label("Subhead", systemImage: "textformat.size")
                                                        }
                                                        
                                                        Divider()
                                                        
                                                        Button {
                                                            // Quote Block action
                                                        } label: {
                                                            Label("Quote Block", systemImage: "quote.opening")
                                                        }
                                                        
                                                        Button {
                                                            // Code Block action
                                                        } label: {
                                                            Label("Code Block", systemImage: "curlybraces")
                                                        }
                                                    } label: {
                                                        Text(DayOneIcon.text_format.rawValue)
                                                            .font(Font.custom("DayOneIcons", size: 18))
                                                            .foregroundColor(.primary)
                                                    }
                                                }
                                                .padding(.trailing, 16) // Move right icons in by 10pt
                                            }
                                            .padding(.vertical, 0)
                                            
                                            // Add margin below the bar
                                            Color.clear.frame(height: 0)
                                        }
                                    }
                                }
                        }
                    }
                    .ignoresSafeArea(.container, edges: [.top, .bottom])
                } else {
                    // Read mode - scrollable content with embeds
                    ZStack {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                        // Embeds section with gray background - only Entry Chat Session now
                        if hasChatActivity && showEntryChatEmbed {
                            VStack(spacing: 10) {
                                // Chat activity indicator
                                Button {
                                    // Entry chat removed - do nothing
                                } label: {
                                    HStack(spacing: 10) {
                                        Text("Entry Chat Session")
                                            .font(.caption)
                                            .foregroundStyle(.primary.opacity(0.7))
                                        
                                        Spacer()
                                        
                                        Text("3")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "F8F8F8"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Text content with inline audio embeds
                        VStack(alignment: .leading, spacing: 8) {
                            // Journal metadata row - always visible at top
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
                            .padding(.bottom, 8)
                            
                            // Generated from Daily Chat indicator - moved here below metadata
                            if showGeneratedFromDailyChat {
                                Button {
                                    showingDailyChat = true
                                } label: {
                                    HStack(spacing: 10) {
                                        Text("Generated from Daily Chat")
                                            .font(.caption)
                                            .fontWeight(Font.Weight.medium)
                                            .foregroundStyle(.primary.opacity(0.7))
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "F3F1F8"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .padding(.bottom, 8)
                            }
                            
                            // Display full text without any formatting
                            Text(entryText)
                                .font(useLatoFont ? Font.custom("Lato-Regular", size: 18) : .system(size: 18))
                                .lineSpacing(4)
                                .foregroundColor(Color(hex: "292F33"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isEditMode = true
                                        textEditorFocused = true
                                    }
                                }
                                .padding(.bottom, 8)
                            
                            // Show embeds after text with proper spacing
                                // First audio recording embed (with transcription)
                                if showAudioEmbedWithTranscription {
                                if let audioData = insertedAudioData {
                                    // Use inserted audio data
                                    audioRecordingEmbed(
                                        hasTranscription: true,
                                        isPlaying: $isPlayingAudio,
                                        duration: audioData.duration,
                                        title: audioData.title,
                                        transcriptionPreview: String(audioData.transcriptionText.prefix(200)),
                                        onTap: {
                                            selectedAudioHasTranscription = true
                                            showingAudioPage = true
                                        }
                                    )
                                } else {
                                    // Use default audio embed
                                    audioRecordingEmbed(
                                        hasTranscription: true,
                                        isPlaying: $isPlayingAudio,
                                        duration: audioDuration,
                                        title: "Morning Reflections at Stewart Falls",
                                        transcriptionPreview: "So, I'm sitting here at Stewart Falls, and I just... I can't even put into words how beautiful this is. The water is just cascading down, and there's this mist that's catching the morning light. It's creating these tiny rainbows everywhere I look.",
                                        onTap: {
                                            selectedAudioHasTranscription = true
                                            showingAudioPage = true
                                        }
                                    )
                                }
                            }
                            
                            // Image embed
                            if showImageEmbed {
                                imageEmbed(
                                    imageName: "bike-wide",
                                    caption: "Timeless style on two wheels—vintage charm meets modern café culture",
                                    showCaption: showImageCaption,
                                    onTap: {
                                        showingMediaPage = true
                                    }
                                )
                            }
                            
                            
                            // Second audio recording embed (without transcription)
                            if showAudioEmbed {
                                audioRecordingEmbed(
                                    hasTranscription: false,
                                    isPlaying: $isPlayingAudio2,
                                    duration: audioDuration2,
                                    title: "Sounds of the Mountain Stream",
                                    transcriptionPreview: nil,
                                    onTap: {
                                        selectedAudioHasTranscription = false
                                        showingAudioPage2 = true
                                    }
                                )
                            }
                            
                            // Map footer section
                            VStack(alignment: .leading, spacing: 6) {
                                // Journal metadata with weather
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
                                
                                // Map with rounded corners and inset
                                Map(position: .constant(.region(MKCoordinateRegion(
                                    center: entryLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )))) {
                                    Marker(locationName, coordinate: entryLocation)
                                        .tint(journalColor)
                                }
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .mapStyle(.standard)
                                .allowsHitTesting(false)
                            }
                            .padding(.top, 24)
                        }
                        // left and right margins
                        .padding(.horizontal, 16)
                        .padding(.top, hasChatActivity && showEntryChatEmbed ? 28 : 12)
                        .padding(.bottom, 24)
                            }
                        }
                    } // End of ZStack
                }
            } // End of Group
            .background(
                // Hidden button to handle CMD+Enter keyboard shortcut
                Button("Toggle Edit Mode") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isEditMode.toggle()
                        if isEditMode {
                            textEditorFocused = true
                        } else {
                            textEditorFocused = false
                        }
                    }
                }
                .keyboardShortcut(.return, modifiers: .command)
                .hidden()
            )
            .toolbar {
                // Date button on the left
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingEditDate = true
                    } label: {
                        Text(formatFullDate(entryDate))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(journalColor)
                    .controlSize(.regular)
                }
                
                // Ellipsis menu on the right
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isEditMode.toggle()
                                if isEditMode {
                                    textEditorFocused = true
                                } else {
                                    textEditorFocused = false
                                }
                            }
                        }) {
                            Label(isEditMode ? "Done Editing" : "Edit", systemImage: isEditMode ? "checkmark.circle" : "pencil")
                        }
                        
                        Button {
                            // Tag action
                        } label: {
                            Label("Tag", systemImage: "tag")
                        }
                        
                        Button {
                            // Move to action
                        } label: {
                            Label("Move to...", systemImage: "folder")
                        }
                        
                        Button {
                            // Copy to action
                        } label: {
                            Label("Copy to...", systemImage: "doc.on.doc")
                        }
                        
                        Button(role: .destructive) {
                            // Move to trash action
                        } label: {
                            Label("Move to Trash", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        Button {
                            // Export action
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            // View PDF action
                        } label: {
                            Label("View PDF", systemImage: "doc.text")
                        }
                        
                        Divider()
                        
                        // Font Selection Section
                        Menu {
                            Button {
                                useLatoFont = false
                            } label: {
                                HStack {
                                    Text("System")
                                    if !useLatoFont {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button {
                                useLatoFont = true
                            } label: {
                                HStack {
                                    Text("Lato")
                                    if useLatoFont {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            Label("Font", systemImage: "textformat")
                        }
                        
                        Divider()
                        
                        // View Options Section
                        Button {
                            showEntryChatEmbed.toggle()
                        } label: {
                            Label(showEntryChatEmbed ? "Hide Chat Embed" : "Show Chat Embed", 
                                  systemImage: showEntryChatEmbed ? "eye.slash" : "eye")
                        }
                        
                        Button {
                            showGeneratedFromDailyChat.toggle()
                        } label: {
                            Label(showGeneratedFromDailyChat ? "Hide Daily Chat Link" : "Show Daily Chat Link", 
                                  systemImage: showGeneratedFromDailyChat ? "message.badge.slash" : "message.badge")
                        }
                        
                        Button {
                            showAudioEmbedWithTranscription.toggle()
                        } label: {
                            Label(showAudioEmbedWithTranscription ? "Hide Audio with Transcription" : "Show Audio with Transcription", 
                                  systemImage: showAudioEmbedWithTranscription ? "waveform.slash" : "waveform")
                        }
                        
                        Button {
                            showAudioEmbed.toggle()
                        } label: {
                            Label(showAudioEmbed ? "Hide Audio Embed" : "Show Audio Embed", 
                                  systemImage: showAudioEmbed ? "speaker.slash" : "speaker.wave.2")
                        }
                        
                        Button {
                            showImageEmbed.toggle()
                        } label: {
                            Label(showImageEmbed ? "Hide Image Embed" : "Show Image Embed", 
                                  systemImage: showImageEmbed ? "photo.slash" : "photo")
                        }
                        
                        if showImageEmbed {
                            Button {
                                showImageCaption.toggle()
                            } label: {
                                Label(showImageCaption ? "Hide Image Caption" : "Show Image Caption", 
                                      systemImage: showImageCaption ? "text.bubble.slash" : "text.bubble")
                            }
                        }
                        
                        Divider()
                        
                        Button {
                            // Share action
                        } label: {
                            Label("Share Entry", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            // Pin action
                        } label: {
                            Label("Pin Entry", systemImage: "pin")
                        }
                        
                        Button {
                            // Bookmark action
                        } label: {
                            Label("Bookmark", systemImage: "bookmark")
                        }
                        
                        Button {
                            // Activity action
                        } label: {
                            Label("View Activity", systemImage: "clock.arrow.circlepath")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis")
                    }
                    .tint(journalColor)
                }
                
                // Done button
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                            .labelStyle(.titleAndIcon)
                    }
                    .tint(journalColor)
                }
            }
            .toolbarBackground(isEditMode ? .hidden : .automatic, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut(duration: 0.3), value: isEditMode)
            .onAppear {
                if shouldShowAudioOnAppear {
                    // Show audio recording after a short delay to ensure sheet is fully presented
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingCompactAudioRecord = true
                        shouldShowAudioOnAppear = false
                    }
                }
                // Focus text editor if starting in edit mode with slight delay for animation
                if isEditMode {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        textEditorFocused = true
                    }
                }
            }
            .sheet(isPresented: $showingJournalingTools) {
                SimpleJournalingToolsView()
            }
            .sheet(isPresented: $showingEditDate) {
                EditDateView(selectedDate: $entryDate)
            }
            .sheet(isPresented: $showingDailyChat) {
                DailyChatView(
                    selectedDate: entryDate,
                    initialLogMode: false,
                    entryCreated: .constant(true),
                    onChatStarted: {},
                    onMessageCountChanged: { _ in }
                )
            }
            .compactAudioSheet(
                isPresented: $showingAudioPage,
                existingAudio: insertedAudioData ?? AudioRecordView.AudioData(
                    title: "Morning Reflections at Stewart Falls",
                    duration: audioDuration,
                    recordingDate: entryDate,
                    hasTranscription: true,
                    transcriptionText: audioTranscriptionText
                )
            )
            .compactAudioSheet(
                isPresented: $showingAudioPage2,
                existingAudio: AudioRecordView.AudioData(
                    title: "Sounds of the Mountain Stream",
                    duration: audioDuration2,
                    recordingDate: entryDate,
                    hasTranscription: false,
                    transcriptionText: ""
                )
            )
            .sheet(isPresented: $showingMediaPage) {
                MediaDetailView(
                    imageName: "bike-wide",
                    imageDate: entryDate,
                    locationName: locationName,
                    locationCoordinate: entryLocation
                )
            }
            .compactAudioSheet(
                isPresented: $showingCompactAudioRecord,
                journal: journal,
                onInsertTranscription: { transcriptionText, audioData in
                    // Insert the transcription text into the entry
                    if !entryText.isEmpty && !entryText.hasSuffix("\n\n") {
                        entryText += "\n\n"
                    }
                    entryText += transcriptionText
                    
                    // Store the audio data and show the embed
                    insertedAudioData = audioData
                    showAudioEmbedWithTranscription = true
                }
            )
        }
    }
    
    private func extractTitle(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return firstLine.isEmpty ? "Untitled Entry" : firstLine
    }
    
    private func formatTimeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        
        if let days = components.day, days > 14 {
            // More than 2 weeks ago, show the date
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return "on \(formatter.string(from: date))"
        } else if let days = components.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            return "just now"
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func getEntryTitle() -> String {
        let paragraphs = entryText.components(separatedBy: "\n\n")
        if paragraphs.count > 0 {
            return paragraphs[0]
        }
        return ""
    }
    
    private func getTextBeforeAudioEmbed() -> String {
        let paragraphs = entryText.components(separatedBy: "\n\n")
        if paragraphs.count >= 2 {
            // Return the second paragraph (skipping the title)
            return paragraphs[1]
        }
        return ""
    }
    
    private func getTextAfterAudioEmbed() -> String {
        let paragraphs = entryText.components(separatedBy: "\n\n")
        if paragraphs.count > 2 {
            return paragraphs[2...].joined(separator: "\n\n")
        }
        return ""
    }
    
    private func getTextBetweenAudioEmbeds() -> String {
        // This will be empty since we're placing the image here instead
        return ""
    }
    
    private func getTextBetweenImageAndSecondAudio() -> String {
        let paragraphs = entryText.components(separatedBy: "\n\n")
        if paragraphs.count > 2 {
            return paragraphs[2]
        }
        return ""
    }
    
    private func getTextAfterSecondAudioEmbed() -> String {
        let paragraphs = entryText.components(separatedBy: "\n\n")
        if paragraphs.count > 3 {
            return paragraphs[3...].joined(separator: "\n\n")
        }
        return ""
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy · h:mm a"
        return formatter.string(from: date)
    }
} // End of EntryView

#Preview("New Entry") {
    EntryView(journal: nil)
}

#Preview("Existing Entry") {
    EntryView(
        journal: nil,
        entryData: EntryView.EntryData(
            title: "Had a wonderful lunch with Emily today.",
            content: "It's refreshing to step away from the daily grind and catch up with old friends. We talked about her new job, my recent travels, and how much has changed since college. Time flies but good friendships remain constant.",
            date: Date(),
            time: "6:11 PM CDT"
        )
    )
}
