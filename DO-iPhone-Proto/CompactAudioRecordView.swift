import SwiftUI

struct CompactAudioRecordView: View {
    @Environment(\.dismiss) private var dismiss
    let journal: Journal?
    let existingAudio: AudioRecordView.AudioData?
    @Binding var currentDetent: PresentationDetent
    let onInsertTranscription: ((String, AudioRecordView.AudioData) -> Void)?
    
    @State private var editableTitle: String = ""
    @State private var isRecording = false
    @State private var hasRecorded = false
    @State private var recordingTime: TimeInterval = 0
    @State private var isProcessing = false
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var isPaused = false
    @State private var showingTranscription = false
    @State private var transcriptionMode: TranscriptionMode = .voice
    @State private var includeTitle = true
    
    // Timer for recording duration
    @State private var recordingTimer: Timer?
    
    enum Mode {
        case record
        case playback
    }
    
    enum TranscriptionMode: String, CaseIterable {
        case voice = "Voice"
        case ai = "AI"
    }
    
    @State private var mode: Mode
    
    // Transcription data
    private var voiceTranscription: String {
        if let audio = existingAudio, !audio.transcriptionText.isEmpty {
            return audio.transcriptionText
        }
        return """
        So today was really interesting. I went to the coffee shop this morning and ran into Sarah. We hadn't seen each other in months, so we ended up talking for like an hour. She told me about her new job at the tech startup downtown, and it sounds really exciting. They're working on some kind of AI-powered fitness app.
        
        After that, I headed to the gym for my usual workout. I'm finally getting back into a routine after the holidays, which feels good. Did legs today and I can already feel it.
        
        Oh, and I almost forgot - I booked tickets for that concert next month. Can't wait to see them live again. It's been way too long since I've been to a proper show.
        
        The weather was perfect today too. Sunny but not too hot. Made me think about planning a weekend trip somewhere soon. Maybe the coast?
        """
    }
    
    private var aiProcessedContent: String {
        """
        **Coffee Shop Encounter**
        Met Sarah at coffee shop after months apart. She shared exciting news about her new position at a downtown tech startup developing an AI-powered fitness application.
        
        **Fitness Progress**
        Completed leg workout at gym, successfully returning to regular exercise routine post-holidays. Already experiencing muscle engagement from the session.
        
        **Entertainment Plans**
        Secured concert tickets for next month's show. Looking forward to first live music experience in extended period.
        
        **Weather & Travel Thoughts**
        Perfect sunny conditions inspired considerations for upcoming weekend coastal trip.
        """
    }
    
    private var aiTitle: String {
        "Tuesday Reflections: Reconnections & Routines"
    }
    
    init(journal: Journal? = nil, existingAudio: AudioRecordView.AudioData? = nil, currentDetent: Binding<PresentationDetent>, onInsertTranscription: ((String, AudioRecordView.AudioData) -> Void)? = nil) {
        self.journal = journal
        self.existingAudio = existingAudio
        self._currentDetent = currentDetent
        self.onInsertTranscription = onInsertTranscription
        
        if let audio = existingAudio {
            // Existing audio - playback mode
            self._editableTitle = State(initialValue: audio.title)
            self._mode = State(initialValue: .playback)
            self._hasRecorded = State(initialValue: true)
            self._recordingTime = State(initialValue: audio.duration)
            self._isRecording = State(initialValue: false)
            // Show transcription immediately if audio has transcription
            self._showingTranscription = State(initialValue: audio.hasTranscription)
        } else {
            // New recording - record mode
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let dayName = formatter.string(from: Date())
            self._editableTitle = State(initialValue: "Audio from \(dayName)")
            self._mode = State(initialValue: .record)
            self._isRecording = State(initialValue: true)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main content area
                if mode == .record && !hasRecorded {
                    // Recording mode
                    VStack(spacing: 20) {
                    // Compact waveform visualization
                    HStack(spacing: 2) {
                        ForEach(0..<40) { index in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(isRecording && !isPaused ? Color.red.opacity(0.3) : Color.black.opacity(0.2))
                                .frame(width: 4, height: isRecording && !isPaused ? CGFloat.random(in: 12...30) : CGFloat.random(in: 10...25))
                                .animation(
                                    isRecording && !isPaused ? 
                                        .easeInOut(duration: 0.2).repeatForever(autoreverses: true).delay(Double(index) * 0.02) : 
                                        .default,
                                    value: isPaused
                                )
                        }
                    }
                    .frame(height: 40)
                    
                    // Recording time
                    Text(formatTime(recordingTime))
                        .font(.title2)
                        .fontWeight(.medium)
                        .monospacedDigit()
                    
                    // Stop and Pause buttons with custom layout
                    ZStack {
                        // Stop recording button (centered)
                        Button {
                            stopRecording()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: "stop.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        // Pause button (positioned to the right)
                        HStack {
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            Button {
                                isPaused.toggle()
                                if isPaused {
                                    recordingTimer?.invalidate()
                                } else {
                                    startRecording()
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                        .font(.title3)
                                        .foregroundStyle(.gray)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Processing indicator
                    if isProcessing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Processing audio...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "F8F8F8"))
            } else {
                // Playback mode
                VStack(spacing: 16) {
                    // Compact waveform
                    HStack(spacing: 2) {
                        ForEach(0..<40) { index in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.black.opacity(0.2))
                                .frame(width: 4, height: CGFloat.random(in: 10...25))
                        }
                    }
                    .frame(height: 40)
                    .padding(.horizontal)
                    
                    // Time progress
                    VStack(spacing: 8) {
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.black)
                                    .frame(width: geometry.size.width * (currentTime / recordingTime), height: 4)
                            }
                        }
                        .frame(height: 4)
                        
                        // Time labels
                        HStack {
                            Text(formatTime(currentTime))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                            
                            Spacer()
                            
                            Text(formatTime(recordingTime))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Play controls
                    HStack(spacing: 32) {
                        Button {
                            currentTime = max(0, currentTime - 15)
                        } label: {
                            Image(systemName: "gobackward.15")
                                .font(.title3)
                                .foregroundStyle(.black)
                        }
                        
                        Button {
                            isPlaying.toggle()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .offset(x: isPlaying ? 0 : 2)
                            }
                        }
                        
                        Button {
                            currentTime = min(recordingTime, currentTime + 15)
                        } label: {
                            Image(systemName: "goforward.15")
                                .font(.title3)
                                .foregroundStyle(.black)
                        }
                    }
                    
                    // Transcription section
                    if showingTranscription {
                        VStack(alignment: .leading, spacing: 16) {
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Segmented Control for transcription mode
                            Picker("Transcription Mode", selection: $transcriptionMode) {
                                ForEach(TranscriptionMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            
                            // Controls section
                            VStack(spacing: 12) {
                                // Include Title toggle (only show for AI mode)
                                if transcriptionMode == .ai {
                                    Toggle("Include Title", isOn: $includeTitle)
                                        .font(.system(size: 15))
                                        .padding(.horizontal)
                                }
                                
                                // Insert into Entry button
                                Button(action: {
                                    // Prepare the text to insert
                                    let textToInsert: String
                                    if transcriptionMode == .voice {
                                        textToInsert = voiceTranscription
                                    } else {
                                        if includeTitle {
                                            textToInsert = aiTitle + "\n\n" + aiProcessedContent
                                        } else {
                                            textToInsert = aiProcessedContent
                                        }
                                    }
                                    
                                    // Create audio data for the embed
                                    let audioData = AudioRecordView.AudioData(
                                        title: editableTitle,
                                        duration: recordingTime,
                                        recordingDate: Date(),
                                        hasTranscription: true,
                                        transcriptionText: voiceTranscription
                                    )
                                    
                                    // Call the callback if available
                                    onInsertTranscription?(textToInsert, audioData)
                                    
                                    dismiss()
                                }) {
                                    Text("Insert into Entry")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: "44C0FF"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 4)
                            
                            // Transcription content
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    if transcriptionMode == .voice {
                                        Text(voiceTranscription)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                    } else {
                                        // AI processed content with optional title
                                        VStack(alignment: .leading, spacing: 8) {
                                            if includeTitle {
                                                Text(aiTitle)
                                                    .font(.headline)
                                                    .foregroundStyle(.primary)
                                                    .padding(.horizontal)
                                            }
                                            
                                            Text(aiProcessedContent)
                                                .font(.body)
                                                .foregroundStyle(.primary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "F8F8F8"))
                }
            }
            .navigationTitle("\(formatTime(recordingTime)) Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            // Edit action
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            // Share action
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive, action: {
                            recordingTimer?.invalidate()
                            dismiss()
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if mode == .record && !hasRecorded {
                startRecording()
            }
        }
        .onDisappear {
            recordingTimer?.invalidate()
        }
    }
    
    private func startRecording() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
    }
    
    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        isProcessing = true
        hasRecorded = true
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isProcessing = false
                showingTranscription = true
                transcriptionMode = .ai  // Auto-select AI mode
                mode = .playback
                // Expand sheet to full height
                currentDetent = .large
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        if mode == .record && !hasRecorded {
            // Recording mode - show tenths
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            let tenths = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 10)
            return String(format: "%d:%02d.%d", minutes, seconds, tenths)
        } else {
            // Playback mode - no tenths
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// Custom sheet presentation modifier
struct CompactSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let height: CGFloat
    let journal: Journal?
    let existingAudio: AudioRecordView.AudioData?
    let onInsertTranscription: ((String, AudioRecordView.AudioData) -> Void)?
    @State private var currentDetent: PresentationDetent
    
    init(isPresented: Binding<Bool>, height: CGFloat, journal: Journal?, existingAudio: AudioRecordView.AudioData?, onInsertTranscription: ((String, AudioRecordView.AudioData) -> Void)? = nil) {
        self._isPresented = isPresented
        self.height = height
        self.journal = journal
        self.existingAudio = existingAudio
        self.onInsertTranscription = onInsertTranscription
        // Start at full height if existing audio has transcription
        let initialDetent: PresentationDetent = (existingAudio?.hasTranscription == true) ? .large : .height(height)
        self._currentDetent = State(initialValue: initialDetent)
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                CompactAudioRecordView(
                    journal: journal,
                    existingAudio: existingAudio,
                    currentDetent: $currentDetent,
                    onInsertTranscription: onInsertTranscription
                )
                .presentationDetents([.height(height), .large], selection: $currentDetent)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
                .presentationBackgroundInteraction(.disabled)
            }
    }
}

extension View {
    func compactAudioSheet(
        isPresented: Binding<Bool>,
        height: CGFloat = 300,
        journal: Journal? = nil,
        existingAudio: AudioRecordView.AudioData? = nil,
        onInsertTranscription: ((String, AudioRecordView.AudioData) -> Void)? = nil
    ) -> some View {
        modifier(CompactSheetModifier(
            isPresented: isPresented,
            height: height,
            journal: journal,
            existingAudio: existingAudio,
            onInsertTranscription: onInsertTranscription
        ))
    }
}

#Preview("Recording Mode") {
    struct PreviewWrapper: View {
        @State private var detent: PresentationDetent = .height(300)
        
        var body: some View {
            Color.gray
                .ignoresSafeArea()
                .sheet(isPresented: .constant(true)) {
                    CompactAudioRecordView(
                        journal: Journal(name: "Journal", color: Color(hex: "44C0FF"), entryCount: 22),
                        currentDetent: $detent,
                        onInsertTranscription: nil
                    )
                    .presentationDetents([.height(300), .large], selection: $detent)
                    .presentationDragIndicator(.visible)
                }
        }
    }
    
    return PreviewWrapper()
}

#Preview("Playback Mode") {
    struct PreviewWrapper: View {
        @State private var detent: PresentationDetent = .height(300)
        
        var body: some View {
            Color.gray
                .ignoresSafeArea()
                .sheet(isPresented: .constant(true)) {
                    CompactAudioRecordView(
                        existingAudio: AudioRecordView.AudioData(
                            title: "Morning Thoughts",
                            duration: 125,
                            recordingDate: Date(),
                            hasTranscription: true,
                            transcriptionText: "Sample transcription text..."
                        ),
                        currentDetent: $detent,
                        onInsertTranscription: nil
                    )
                    .presentationDetents([.height(300), .large], selection: $detent)
                    .presentationDragIndicator(.visible)
                }
        }
    }
    
    return PreviewWrapper()
}