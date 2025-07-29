import SwiftUI

struct AudioRecordView: View {
    @Environment(\.dismiss) private var dismiss
    let journal: Journal?
    let existingAudio: AudioData?
    
    @State private var editableTitle: String = ""
    @State private var isEditingTitle = false
    @State private var isRecording = false
    @State private var hasRecorded = false
    @State private var recordingTime: TimeInterval = 0
    @State private var showingTranscription = false
    @State private var transcriptionMode: TranscriptionMode = .voice
    @State private var isProcessing = false
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @FocusState private var isTitleFieldFocused: Bool
    
    // Timer for recording duration
    @State private var recordingTimer: Timer?
    
    enum TranscriptionMode: String, CaseIterable {
        case voice = "Voice"
        case ai = "AI"
    }
    
    enum Mode {
        case record
        case playback
    }
    
    @State private var mode: Mode
    
    // For existing audio
    struct AudioData {
        let title: String
        let duration: TimeInterval
        let recordingDate: Date
        let hasTranscription: Bool
        let transcriptionText: String
    }
    
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
        // For existing audio without transcription, return empty
        if let audio = existingAudio, !audio.hasTranscription {
            return ""
        }
        // Otherwise return processed content
        return """
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
        if let audio = existingAudio {
            // Generate a title based on the audio title
            return audio.title
        }
        return "Tuesday Reflections: Reconnections & Routines"
    }
    
    init(journal: Journal? = nil, existingAudio: AudioData? = nil) {
        self.journal = journal
        self.existingAudio = existingAudio
        
        if let audio = existingAudio {
            // Existing audio - playback mode
            self._editableTitle = State(initialValue: audio.title)
            self._mode = State(initialValue: .playback)
            self._hasRecorded = State(initialValue: true)
            self._recordingTime = State(initialValue: audio.duration)
            self._showingTranscription = State(initialValue: audio.hasTranscription)
            self._isRecording = State(initialValue: false)
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
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Editable Title
                    VStack(alignment: .leading, spacing: 4) {
                        if isEditingTitle {
                            TextField("Audio title", text: $editableTitle)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .focused($isTitleFieldFocused)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    isEditingTitle = false
                                }
                        } else {
                            Text(editableTitle)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .onTapGesture {
                                    isEditingTitle = true
                                    isTitleFieldFocused = true
                                }
                        }
                        
                        Text(existingAudio?.recordingDate ?? Date(), format: .dateTime.weekday(.wide).month(.wide).day().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Audio Player/Recorder
                    if mode == .record && !hasRecorded {
                        // Recording mode
                        VStack(spacing: 0) {
                            VStack(spacing: 16) {
                                // Recording waveform visualization
                                HStack(spacing: 2) {
                                    ForEach(0..<60) { index in
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(isRecording ? Color.red.opacity(0.3) : Color.black.opacity(0.2))
                                            .frame(width: 3, height: isRecording ? CGFloat.random(in: 8...40) : CGFloat.random(in: 12...40))
                                            .animation(
                                                isRecording ? 
                                                    .easeInOut(duration: 0.2).repeatForever(autoreverses: true).delay(Double(index) * 0.02) : 
                                                    .default,
                                                value: isRecording
                                            )
                                    }
                                }
                                .frame(height: 60)
                                .padding(.horizontal)
                                
                                // Recording time
                                VStack(spacing: 8) {
                                    Text(formatTime(recordingTime))
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .monospacedDigit()
                                }
                                .padding(.horizontal)
                                
                                // Stop recording button
                                Button {
                                    stopRecording()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 64, height: 64)
                                        
                                        Image(systemName: "stop.fill")
                                            .font(.title)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding(.bottom, 8)
                                
                                // Processing indicator
                                if isProcessing {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Processing audio...")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "F8F8F8"))
                        }
                    } else {
                        // Playback mode
                        VStack(spacing: 16) {
                            // Waveform visualization
                            HStack(spacing: 2) {
                                ForEach(0..<60) { index in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color.black.opacity(0.2))
                                        .frame(width: 3, height: CGFloat.random(in: 12...40))
                                }
                            }
                            .frame(height: 60)
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
                            HStack(spacing: 40) {
                                Button {
                                    // Skip backward 15 seconds
                                    currentTime = max(0, currentTime - 15)
                                } label: {
                                    Image(systemName: "gobackward.15")
                                        .font(.title2)
                                        .foregroundStyle(.primary)
                                }
                                
                                Button {
                                    isPlaying.toggle()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 64, height: 64)
                                        
                                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                            .font(.title)
                                            .foregroundStyle(.white)
                                            .offset(x: isPlaying ? 0 : 2)
                                    }
                                }
                                
                                Button {
                                    // Skip forward 15 seconds
                                    currentTime = min(recordingTime, currentTime + 15)
                                } label: {
                                    Image(systemName: "goforward.15")
                                        .font(.title2)
                                        .foregroundStyle(.primary)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(.vertical, 16)
                        .background(Color(hex: "F8F8F8"))
                    }
                    
                    // Transcription section
                    if showingTranscription {
                        VStack(alignment: .leading, spacing: 16) {
                            // For new recordings, show segmented control
                            if existingAudio == nil {
                                // Segmented Control
                                Picker("Transcription Mode", selection: $transcriptionMode) {
                                    ForEach(TranscriptionMode.allCases, id: \.self) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                            } else {
                                // For existing audio, show transcription header with menu
                                HStack {
                                    Text("TRANSCRIPTION")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    if existingAudio?.hasTranscription == true {
                                        Menu {
                                            Button {
                                                // Transcribe again action
                                            } label: {
                                                Label("Transcribe again", systemImage: "arrow.clockwise")
                                            }
                                            
                                            Button(role: .destructive) {
                                                // Delete transcription action
                                            } label: {
                                                Label("Delete transcription", systemImage: "trash")
                                            }
                                            
                                            Button {
                                                // Add to entry action
                                            } label: {
                                                Label("Add to Entry", systemImage: "text.append")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis.circle")
                                                .font(.body)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Transcription content
                            if existingAudio?.hasTranscription == true || existingAudio == nil {
                                VStack(alignment: .leading, spacing: 12) {
                                    if transcriptionMode == .ai && existingAudio == nil {
                                        Text(aiTitle)
                                            .font(.headline)
                                            .padding(.horizontal)
                                    }
                                    
                                    Text(transcriptionMode == .voice || existingAudio != nil ? voiceTranscription : aiProcessedContent)
                                        .font(.body)
                                        .lineSpacing(4)
                                        .padding(.horizontal)
                                        .padding(.bottom, 40)
                                        .textSelection(.enabled)
                                }
                            } else {
                                // No transcription state for existing audio
                                VStack(spacing: 16) {
                                    Text("No transcription available")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                    
                                    Button {
                                        // Transcribe audio action
                                    } label: {
                                        Label("Transcribe Audio", systemImage: "waveform")
                                            .font(.body)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.blue)
                                            .foregroundStyle(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle(mode == .record && !hasRecorded ? "Audio Recording" : "Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        // Stop recording if active
                        recordingTimer?.invalidate()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // TODO: Save recording
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!showingTranscription)
                }
            }
        }
        .onAppear {
            startRecording()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                isProcessing = false
                showingTranscription = true
                mode = .playback
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

#Preview("Recording Mode") {
    AudioRecordView(journal: Journal(name: "Journal", color: Color(hex: "44C0FF"), entryCount: 22))
}

#Preview("Playback Mode") {
    AudioRecordView(
        existingAudio: AudioRecordView.AudioData(
            title: "Morning Thoughts",
            duration: 125,
            recordingDate: Date(),
            hasTranscription: true,
            transcriptionText: "Sample transcription text..."
        )
    )
}