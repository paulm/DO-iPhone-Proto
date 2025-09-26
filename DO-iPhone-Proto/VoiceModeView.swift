import SwiftUI

// MARK: - Voice Mode View
struct VoiceModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isMuted = false
    @State private var audioLevel: CGFloat = 0.0
    @State private var isListening = true
    private let monitor = MicLevelMonitor()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "1C1C1E"),
                    Color(hex: "2C2C2E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()

                // New listening animation
                ZStack {
                    ListeningAnimationView(
                        level: $audioLevel,
                        tintColor: UIColor(Color(hex: "44C0FF"))
                    )
                    .frame(width: 260, height: 260)

                    // Center microphone icon - kept perfectly still
//                    Image(systemName: "waveform")
//                        .font(.system(size: 40, weight: .regular))
//                        .foregroundStyle(.white)
                }
                .frame(height: 300)
                
                // Status text
                VStack(spacing: 8) {
                    Text(isListening ? "Listening..." : "Voice Mode")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(isMuted ? "Microphone muted" : "Speak naturally")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Bottom toolbar
                HStack(spacing: 60) {
                    // Close button
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Mute toggle button
                    Button(action: {
                        isMuted.toggle()
                        if isMuted {
                            isListening = false
                        } else {
                            isListening = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isMuted ? Color.red.opacity(0.2) : Color.white.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(isMuted ? .red : .white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Start mic monitoring
            do {
                try monitor.start()
                monitor.onLevel = { level in
                    audioLevel = level
                }
            } catch {
                // Handle error if needed
                print("Failed to start mic monitoring: \(error)")
            }
        }
        .onDisappear {
            monitor.stop()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    VoiceModeView()
}
