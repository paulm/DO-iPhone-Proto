import SwiftUI

struct AudioTranscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    let transcriptionText: String
    let audioDuration: TimeInterval
    let recordingDate: Date
    let hasTranscription: Bool
    let audioTitle: String
    
    @State private var editableTitle: String = ""
    @State private var isEditingTitle = false
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @FocusState private var isTitleFieldFocused: Bool
    
    init(transcriptionText: String, audioDuration: TimeInterval, recordingDate: Date, hasTranscription: Bool, audioTitle: String) {
        self.transcriptionText = transcriptionText
        self.audioDuration = audioDuration
        self.recordingDate = recordingDate
        self.hasTranscription = hasTranscription
        self.audioTitle = audioTitle
        self._editableTitle = State(initialValue: audioTitle)
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
                        
                        Text(recordingDate, format: .dateTime.weekday(.wide).month(.wide).day().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Audio Player
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
                                        .frame(width: geometry.size.width * (currentTime / audioDuration), height: 4)
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
                                
                                Text(formatTime(audioDuration))
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
                                currentTime = min(audioDuration, currentTime + 15)
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
                    
                    // Transcription section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("TRANSCRIPTION")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            if hasTranscription {
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
                        
                        if hasTranscription {
                            Text(transcriptionText)
                                .font(.body)
                                .lineSpacing(4)
                                .padding(.horizontal)
                                .padding(.bottom, 40)
                        } else {
                            // No transcription state
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
            .navigationTitle("Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    AudioTranscriptionView(
        transcriptionText: "Sample transcription text...",
        audioDuration: 125,
        recordingDate: Date(),
        hasTranscription: true,
        audioTitle: "Audio Recording"
    )
}