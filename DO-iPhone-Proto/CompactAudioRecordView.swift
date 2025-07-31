import SwiftUI

struct CompactAudioRecordView: View {
    @Environment(\.dismiss) private var dismiss
    let journal: Journal?
    let existingAudio: AudioRecordView.AudioData?
    
    @State private var editableTitle: String = ""
    @State private var isRecording = false
    @State private var hasRecorded = false
    @State private var recordingTime: TimeInterval = 0
    @State private var isProcessing = false
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    
    // Timer for recording duration
    @State private var recordingTimer: Timer?
    
    enum Mode {
        case record
        case playback
    }
    
    @State private var mode: Mode
    
    init(journal: Journal? = nil, existingAudio: AudioRecordView.AudioData? = nil) {
        self.journal = journal
        self.existingAudio = existingAudio
        
        if let audio = existingAudio {
            // Existing audio - playback mode
            self._editableTitle = State(initialValue: audio.title)
            self._mode = State(initialValue: .playback)
            self._hasRecorded = State(initialValue: true)
            self._recordingTime = State(initialValue: audio.duration)
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
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Button("Cancel") {
                    recordingTimer?.invalidate()
                    dismiss()
                }
                .foregroundStyle(.primary)
                
                Spacer()
                
                Text(editableTitle)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Button("Save") {
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .disabled(mode == .record && !hasRecorded)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            Divider()
            
            // Main content area
            if mode == .record && !hasRecorded {
                // Recording mode
                VStack(spacing: 20) {
                    // Compact waveform visualization
                    HStack(spacing: 2) {
                        ForEach(0..<40) { index in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(isRecording ? Color.red.opacity(0.3) : Color.black.opacity(0.2))
                                .frame(width: 4, height: isRecording ? CGFloat.random(in: 12...30) : CGFloat.random(in: 10...25))
                                .animation(
                                    isRecording ? 
                                        .easeInOut(duration: 0.2).repeatForever(autoreverses: true).delay(Double(index) * 0.02) : 
                                        .default,
                                    value: isRecording
                                )
                        }
                    }
                    .frame(height: 40)
                    
                    // Recording time
                    Text(formatTime(recordingTime))
                        .font(.title2)
                        .fontWeight(.medium)
                        .monospacedDigit()
                    
                    // Stop recording button
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
                                .foregroundStyle(.primary)
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
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "F8F8F8"))
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

// Custom sheet presentation modifier
struct CompactSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let height: CGFloat
    let content: () -> CompactAudioRecordView
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                self.content()
                    .presentationDetents([.height(height)])
                    .presentationDragIndicator(.hidden)
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
        existingAudio: AudioRecordView.AudioData? = nil
    ) -> some View {
        modifier(CompactSheetModifier(
            isPresented: isPresented,
            height: height,
            content: {
                CompactAudioRecordView(journal: journal, existingAudio: existingAudio)
            }
        ))
    }
}

#Preview("Recording Mode") {
    Color.gray
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            CompactAudioRecordView(journal: Journal(name: "Journal", color: Color(hex: "44C0FF"), entryCount: 22))
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.hidden)
        }
}

#Preview("Playback Mode") {
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
                )
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.hidden)
        }
}