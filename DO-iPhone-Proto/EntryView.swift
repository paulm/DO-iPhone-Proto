import SwiftUI
import MapKit

/// Modal sheet for creating new journal entries
struct EntryView: View {
    @Environment(\.dismiss) private var dismiss
    let journal: Journal?
    
    @State private var entryText = """
A Perfect Day at Sundance

Today was one of those rare days where everything seemed to align perfectly. I woke up early, around 6:30 AM, to the sound of birds chirping outside my window at the resort. The morning light was just beginning to filter through the trees, casting long shadows across the mountain slopes. I decided to start the day with a hike on the Stewart Falls trail, something I've been meaning to do since arriving here three days ago.

The trail was quiet, with only a few other early risers making their way up the path. The air was crisp and cool, probably around 55 degrees, and I could see my breath forming small clouds as I walked. About halfway up, I stopped at a clearing that offered a stunning view of the valley below. The aspens were just beginning to turn golden, creating patches of warm color against the dark green of the pines. I sat on a large rock and just took it all in, feeling grateful for this moment of solitude in nature.

After the hike, I returned to the resort for breakfast at the Foundry Grill. I ordered their famous blueberry pancakes and a strong cup of coffee. While eating, I struck up a conversation with an older couple from Colorado who were celebrating their 40th wedding anniversary. They shared stories about how they've been coming to Sundance every fall for the past fifteen years, and how this place has become a sacred tradition for them. Their love for each other and for this place was infectious.

The afternoon was spent exploring the art studios scattered around the resort. I was particularly drawn to the pottery workshop, where a local artist was demonstrating wheel throwing techniques. She invited me to try my hand at it, and despite making quite a mess, I managed to create something that vaguely resembled a bowl. There's something meditative about working with clay, feeling it take shape beneath your hands, requiring both strength and gentleness.

As the sun began to set, painting the sky in shades of orange and pink, I found myself back on the deck of my cabin, wrapped in a warm blanket with a cup of herbal tea. The day felt complete in a way that few days do. No urgent emails, no pressing deadlines, just the simple pleasure of being present in a beautiful place. Tomorrow I'm planning to try the zip line tour, but for now, I'm content to watch the stars emerge one by one in the darkening sky, feeling deeply connected to this moment and this place.
"""
    @State private var showingJournalingTools = false
    @State private var showingEnhancedJournalingTools = false
    @State private var showingContentFocusedJournalingTools = false
    @State private var showingEntryChat = false
    @State private var showingDailyChat = false
    @State private var hasChatActivity = true // Simulating that this entry has chat activity
    @State private var entryDate = Date()
    @State private var showingEditDate = false
    @State private var showEntryChatEmbed = false
    @State private var showGeneratedFromDailyChat = true
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
    
    // Location for the map - Sundance Resort coordinates
    private let entryLocation = CLLocationCoordinate2D(latitude: 40.6006, longitude: -111.5878)
    
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
    private let locationName = "Sundance Resort"
    private var journalColor: Color {
        journal?.color ?? Color(hex: "4EC3FE")
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
                    if isTextFieldFocused {
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
                        .transition(.move(edge: .top).combined(with: .opacity))
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
                                        showingEntryChat = true
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
                            // First two paragraphs
                            Text(getTextBeforeAudioEmbed())
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    if !isTextFieldFocused {
                                        isTextFieldFocused = true
                                    }
                                }
                            
                            // First audio recording embed (with transcription)
                            if showAudioEmbedWithTranscription {
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
                            
                            // Text between image and second audio
                            Text(getTextBetweenImageAndSecondAudio())
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    if !isTextFieldFocused {
                                        isTextFieldFocused = true
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
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    if !isTextFieldFocused {
                                        isTextFieldFocused = true
                                    }
                                }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, (hasChatActivity && showEntryChatEmbed) || showGeneratedFromDailyChat ? 28 : 12)
                        .padding(.bottom, 100)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .overlay(
                    // Floating text editor for editing mode
                    Group {
                        if isTextFieldFocused {
                            TextEditor(text: $entryText)
                                .font(.body)
                                .focused($isTextFieldFocused)
                                .scrollContentBackground(.hidden)
                                .background(.white)
                                .contentMargins(.horizontal, 14, for: .scrollContent)
                                .contentMargins(.vertical, 16, for: .scrollContent)
                        }
                    }
                )
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        HStack(spacing: 20) {
                            Button {
                                // Collapse action
                                isTextFieldFocused = false
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title3)
                            }
                            
                            Spacer()
                            
                            Button {
                                showingJournalingTools = true
                            } label: {
                                Image(systemName: "sparkles")
                                    .font(.title3)
                            }
                            
                            Button {
                                showingEnhancedJournalingTools = true
                            } label: {
                                Image(systemName: "sparkles")
                                    .font(.title3)
                                    .foregroundStyle(.black)
                            }
                            
                            Button {
                                showingContentFocusedJournalingTools = true
                            } label: {
                                Image(systemName: "sparkles")
                                    .font(.title3)
                                    .foregroundStyle(.purple)
                            }
                            
                            Button {
                                showingEntryChat = true
                            } label: {
                                Image(systemName: "message.circle")
                                    .font(.title3)
                            }
                            
                            Button {
                                // Attachment action
                            } label: {
                                Image(systemName: "paperclip")
                                    .font(.title3)
                            }
                            
                            Button {
                                // Text formatting action
                            } label: {
                                Image(systemName: "textformat")
                                    .font(.title3)
                            }
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 18)
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
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showingEditDate = true
                    }) {
                        HStack(spacing: 4) {
                            Text(entryDate, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            Text("·")
                                .font(.body)
                                .foregroundStyle(.white)
                            Text(entryDate, format: .dateTime.hour().minute())
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Menu {
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
                                Label("Entry Info", systemImage: "info.circle")
                            }
                            
                            Divider()
                            
                            Button(action: {}) {
                                Label("Export", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: {}) {
                                Label("View PDF", systemImage: "doc.text")
                            }
                            
                            Button(action: {}) {
                                Label("View \(entryDate, format: .dateTime.month(.abbreviated).day())", systemImage: "calendar")
                            }
                            
                            Divider()
                            
                            Section("Show") {
                                Button(action: {
                                    showEntryChatEmbed.toggle()
                                }) {
                                    Label("Entry Chat Embed", systemImage: showEntryChatEmbed ? "checkmark" : "")
                                }
                                
                                Button(action: {
                                    showGeneratedFromDailyChat.toggle()
                                }) {
                                    Label("Generated from Daily Chat", systemImage: showGeneratedFromDailyChat ? "checkmark" : "")
                                }
                                
                                Button(action: {
                                    showAudioEmbed.toggle()
                                }) {
                                    Label("Audio Embed", systemImage: showAudioEmbed ? "checkmark" : "")
                                }
                                
                                Button(action: {
                                    showAudioEmbedWithTranscription.toggle()
                                }) {
                                    Label("Audio Embed with Transcription", systemImage: showAudioEmbedWithTranscription ? "checkmark" : "")
                                }
                                
                                Button(action: {
                                    showImageEmbed.toggle()
                                }) {
                                    Label("Image", systemImage: showImageEmbed ? "checkmark" : "")
                                }
                                
                                Button(action: {
                                    showImageCaption.toggle()
                                }) {
                                    Label("Image Caption", systemImage: showImageCaption ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .accessibilityLabel("Save journal entry")
                    }
                }
            }
            .toolbarBackground(journalColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingJournalingTools) {
                JournalingToolsView()
            }
            .sheet(isPresented: $showingEnhancedJournalingTools) {
                EnhancedJournalingToolsView()
            }
            .sheet(isPresented: $showingContentFocusedJournalingTools) {
                ContentFocusedJournalingToolsView()
            }
            .sheet(isPresented: $showingEntryChat) {
                EntryChatView(
                    entryText: entryText,
                    entryDate: entryDate,
                    journal: journal
                )
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
            .sheet(isPresented: $showingAudioPage) {
                AudioRecordView(
                    existingAudio: AudioRecordView.AudioData(
                        title: "Morning Reflections at Stewart Falls",
                        duration: audioDuration,
                        recordingDate: entryDate,
                        hasTranscription: true,
                        transcriptionText: audioTranscriptionText
                    )
                )
            }
            .sheet(isPresented: $showingAudioPage2) {
                AudioRecordView(
                    existingAudio: AudioRecordView.AudioData(
                        title: "Sounds of the Mountain Stream",
                        duration: audioDuration2,
                        recordingDate: entryDate,
                        hasTranscription: false,
                        transcriptionText: ""
                    )
                )
            }
            .sheet(isPresented: $showingMediaPage) {
                MediaDetailView(
                    imageName: "bike-wide",
                    imageDate: entryDate,
                    locationName: locationName,
                    locationCoordinate: entryLocation
                )
            }
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
    
    private func getTextBeforeAudioEmbed() -> String {
        let paragraphs = entryText.components(separatedBy: "\n\n")
        if paragraphs.count >= 2 {
            return paragraphs[0...1].joined(separator: "\n\n")
        }
        return entryText
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
}

#Preview {
    EntryView(journal: nil)
}
