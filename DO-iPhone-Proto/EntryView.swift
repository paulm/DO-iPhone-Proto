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
    @FocusState private var isTextFieldFocused: Bool
    @State private var isEditMode = false
    @State private var shouldShowAudioOnAppear: Bool
    @State private var showingCompactAudioRecord = false
    @State private var insertedAudioData: AudioRecordView.AudioData?
    
    // Location for the map - Sundance Resort coordinates
    private let entryLocation = CLLocationCoordinate2D(latitude: 40.6006, longitude: -111.5878)
    private let locationName = "Sundance Mountain Resort"
    
    // Default entry content
    private let defaultEntryContent = """
A Perfect Day at Sundance

Today was one of those rare days where everything seemed to align perfectly. I woke up early, around 6:30 AM, to the sound of birds chirping outside my window at the resort. The morning light was just beginning to filter through the trees, casting long shadows across the mountain slopes. I decided to start the day with a hike on the Stewart Falls trail, something I've been meaning to do since arriving here three days ago.

The trail was quiet, with only a few other early risers making their way up the path. The air was crisp and cool, probably around 55 degrees, and I could see my breath forming small clouds as I walked. About halfway up, I stopped at a clearing that offered a stunning view of the valley below. The aspens were just beginning to turn golden, creating patches of warm color against the dark green of the pines. I sat on a large rock and just took it all in, feeling grateful for this moment of solitude in nature.

After the hike, I returned to the resort for breakfast at the Foundry Grill. I ordered their famous blueberry pancakes and a strong cup of coffee. While eating, I struck up a conversation with an older couple from Colorado who were celebrating their 40th wedding anniversary. They shared stories about how they've been coming to Sundance every fall for the past fifteen years, and how this place has become a sacred tradition for them. Their love for each other and for this place was infectious.

The afternoon was spent exploring the art studios scattered around the resort. I was particularly drawn to the pottery workshop, where a local artist was demonstrating wheel throwing techniques. She invited me to try my hand at it, and despite making quite a mess, I managed to create something that vaguely resembled a bowl. There's something meditative about working with clay, feeling it take shape beneath your hands, requiring both strength and gentleness.

As the sun began to set, painting the sky in shades of orange and pink, I found myself back on the deck of my cabin, wrapped in a warm blanket with a cup of herbal tea. The day felt complete in a way that few days do. No urgent emails, no pressing deadlines, just the simple pleasure of being present in a beautiful place. Tomorrow I'm planning to try the zip line tour, but for now, I'm content to watch the stars emerge one by one in the darkening sky, feeling deeply connected to this moment and this place.
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
                    .font(.system(size: 17))
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
            ZStack {
                VStack(spacing: 0) {
                    // Journal info header - only shown in Edit mode
                    if isEditMode {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text(journalName)
                                    .foregroundStyle(journalColor)
                                    .fontWeight(.medium)
                                Text(" · ")
                                    .foregroundStyle(.secondary)
                                Text(locationName)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.white)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    }
                
                // Content area with scrollable embeds and text
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Embeds section with gray background
                        if (hasChatActivity && showEntryChatEmbed) || showGeneratedFromDailyChat {
                            VStack(spacing: 10) {
                                // Chat activity indicator
                                if hasChatActivity && showEntryChatEmbed {
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
                                
                                // Generated from Daily Chat indicator
                                if showGeneratedFromDailyChat {
                                    Button {
                                        showingDailyChat = true
                                    } label: {
                                        HStack(spacing: 10) {
                                            Text("Generated from Daily Chat")
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
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Text content with inline audio embeds
                        VStack(alignment: .leading, spacing: 16) {
                            // Show TextEditor when in edit mode, Text otherwise
                            if isEditMode {
                                TextEditor(text: $entryText)
                                    .modifier(entryTextStyle)
                                    .focused($isTextFieldFocused)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(maxWidth: .infinity, minHeight: 500)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                    .onAppear {
                                        // Force keyboard to appear after a brief delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            isTextFieldFocused = true
                                        }
                                    }
                            } else {
                                // Title
                                Text(getEntryTitle())
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isEditMode = true
                                        }
                                    }
                                    .padding(.bottom, 0)
                                
                                // First paragraph after title
                                Text(getTextBeforeAudioEmbed())
                                    .modifier(entryTextStyle)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isEditMode = true
                                        }
                                    }
                            }
                            
                            // First audio recording embed (with transcription)
                            if showAudioEmbedWithTranscription && !isEditMode {
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
                            if showImageEmbed && !isEditMode {
                                imageEmbed(
                                    imageName: "bike-wide",
                                    caption: "Timeless style on two wheels—vintage charm meets modern café culture",
                                    showCaption: showImageCaption,
                                    onTap: {
                                        showingMediaPage = true
                                    }
                                )
                            }
                            
                            // Hide embeds and complex layout when editing
                            if !isEditMode {
                                // Text between image and second audio
                                Text(getTextBetweenImageAndSecondAudio())
                                    .modifier(entryTextStyle)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isEditMode = true
                                        }
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
                                
                                // Remaining text
                                Text(getTextAfterSecondAudioEmbed())
                                    .modifier(entryTextStyle)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isEditMode = true
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, (hasChatActivity && showEntryChatEmbed) || showGeneratedFromDailyChat ? 28 : 12)
                        .padding(.bottom, 100)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: isEditMode) { _, newValue in
                    if !newValue {
                        // Ensure keyboard is dismissed when exiting edit mode
                        isTextFieldFocused = false
                    }
                }
                .onChange(of: isTextFieldFocused) { _, newValue in
                    if !newValue && isEditMode {
                        // Exit edit mode when keyboard is dismissed
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEditMode = false
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        HStack(spacing: 24) {
                            // Dismiss keyboard
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 16))
                            }
                            
                            Spacer()
                            
                            // Entry Tools (Journaling Tools)
                            Button {
                                showingJournalingTools = true
                            } label: {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16))
                            }
                            
                            // Photo Library
                            Button {
                                // TODO: Open photo picker
                            } label: {
                                Image(systemName: "photo")
                                    .font(.system(size: 16))
                            }
                            
                            // Attachments Menu
                            Menu {
                                Button {
                                    // Tag action
                                } label: {
                                    Label("Tag", systemImage: "tag")
                                }
                                
                                Button {
                                    // Audio action
                                } label: {
                                    Label("Audio", systemImage: "mic")
                                }
                                
                                Button {
                                    // Camera action
                                } label: {
                                    Label("Camera", systemImage: "camera")
                                }
                                
                                Button {
                                    // Photo Library action
                                } label: {
                                    Label("Photo Library", systemImage: "photo")
                                }
                                
                                Button {
                                    // Draw action
                                } label: {
                                    Label("Draw", systemImage: "pencil.tip")
                                }
                                
                                Button {
                                    // Scan to PDF action
                                } label: {
                                    Label("Scan to PDF", systemImage: "doc.text.viewfinder")
                                }
                                
                                Button {
                                    // File action
                                } label: {
                                    Label("File", systemImage: "doc")
                                }
                                
                                Button {
                                    // Template action
                                } label: {
                                    Label("Template", systemImage: "doc.text")
                                }
                                
                                Button {
                                    // Scan Text action
                                } label: {
                                    Label("Scan Text", systemImage: "text.viewfinder")
                                }
                            } label: {
                                Image(systemName: "paperclip")
                                    .font(.system(size: 16))
                            }
                            
                            // Editor Features Menu
                            Menu {
                                Button {
                                    // Body text
                                } label: {
                                    Label("Body", systemImage: "text.alignleft")
                                }
                                
                                Button {
                                    // Title text
                                } label: {
                                    Label("Title", systemImage: "textformat")
                                }
                                
                                Button {
                                    // Subtitle text
                                } label: {
                                    Label("Subtitle", systemImage: "text.badge.minus")
                                }
                                
                                Divider()
                                
                                Button {
                                    // List
                                } label: {
                                    Label("List", systemImage: "list.bullet")
                                }
                                
                                Button {
                                    // Checklist
                                } label: {
                                    Label("Checklist", systemImage: "checklist")
                                }
                                
                                Button {
                                    // Indent
                                } label: {
                                    Label("Indent", systemImage: "increase.indent")
                                }
                                
                                Divider()
                                
                                Button {
                                    // Quote Block
                                } label: {
                                    Label("Quote Block", systemImage: "text.quote")
                                }
                                
                                Button {
                                    // Code Block
                                } label: {
                                    Label("Code Block", systemImage: "curlybraces")
                                }
                                
                                Button {
                                    // Line
                                } label: {
                                    Label("Line", systemImage: "minus")
                                }
                            } label: {
                                Image(systemName: "textformat")
                                    .font(.system(size: 16))
                            }
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                    }
                }
            }
                
                // Bottom info block - only shown in Read mode
                if !isTextFieldFocused {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            // Row 1: Journal metadata
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(journalName)
                                        .foregroundStyle(journalColor)
                                        .fontWeight(.medium)
                                    Text(" · ")
                                        .foregroundStyle(.secondary)
                                    Text(locationName)
                                        .foregroundStyle(.secondary)
                                }
                                .font(.caption)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(.white)
                            
                            Divider()
                            
                            // Row 2: Map view
                            Map(position: .constant(.region(MKCoordinateRegion(
                                center: entryLocation,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )))) {
                                Marker(locationName, coordinate: entryLocation)
                                    .tint(journalColor)
                            }
                            .frame(height: 100)
                            .mapStyle(.standard)
                            .allowsHitTesting(false) // Make map non-interactive
                        }
                        .background(.white)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isTextFieldFocused)
            .onKeyPress(.return, phases: .down) { keyPress in
                if keyPress.modifiers.contains(.command) {
                    isTextFieldFocused.toggle()
                    return .handled
                }
                return .ignored
            }
            .toolbar {
                // Date button on the left
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingEditDate = true
                    } label: {
                        Label {
                            Text(formatFullDate(entryDate))
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .labelStyle(.titleOnly)
                        .foregroundColor(.primary)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .tint(.black.opacity(0.9))
                    }
                }
                
                // Ellipsis menu on the right
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if isEditMode {
                                    isEditMode = false
                                    isTextFieldFocused = false
                                } else {
                                    isEditMode = true
                                }
                            }
                        }) {
                            Label(isEditMode ? "Done Editing" : "Edit", systemImage: isEditMode ? "checkmark.circle" : "pencil")
                        }
                        
                        Button(action: {}) {
                            Label("Tag", systemImage: "tag")
                        }
                        
                        Button(action: {}) {
                            Label("Move to...", systemImage: "folder")
                        }
                        
                        Button(action: {}) {
                            Label("Copy to...", systemImage: "doc.on.doc")
                        }
                        
                        Button(role: .destructive, action: {}) {
                            Label("Move to Trash", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        Button(action: {}) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: {}) {
                            Label("View PDF", systemImage: "doc.text")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis")
                        
                    }
                    .tint(.black.opacity(0.9))
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
            .toolbarBackground(.automatic, for: .navigationBar)
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
}

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
