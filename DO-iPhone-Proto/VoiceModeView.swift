import SwiftUI

// MARK: - Voice Mode View
struct VoiceModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isMuted = false
    @State private var audioLevel: CGFloat = 0.3
    @State private var isListening = true
    
    // Animation states for the audio visualizer
    @State private var animationAmount1: CGFloat = 1.0
    @State private var animationAmount2: CGFloat = 1.0
    @State private var animationAmount3: CGFloat = 1.0
    
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
                
                // Center animated graphic
                ZStack {
                    // Outer ring - largest, slowest animation
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "44C0FF").opacity(0.3),
                                    Color(hex: "44C0FF").opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 250, height: 250)
                        .scaleEffect(animationAmount3)
                        .opacity(2 - animationAmount3)
                    
                    // Middle ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "44C0FF").opacity(0.5),
                                    Color(hex: "44C0FF").opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(animationAmount2)
                        .opacity(2 - animationAmount2)
                    
                    // Inner ring - fastest animation
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "44C0FF").opacity(0.7),
                                    Color(hex: "44C0FF").opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animationAmount1)
                        .opacity(2 - animationAmount1)
                    
                    // Center icon/indicator
                    ZStack {
                        // Glowing background
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "44C0FF").opacity(0.3),
                                        Color(hex: "44C0FF").opacity(0.1)
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 10)
                        
                        // Main icon
                        Image(dayOneIcon: .audio_wave)
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "44C0FF"),
                                        Color(hex: "66D4FF")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(isListening ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isListening)
                    }
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
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start the ripple animations with different speeds
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
            animationAmount1 = 1.5
        }
        
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false)) {
            animationAmount2 = 1.6
        }
        
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: false)) {
            animationAmount3 = 1.7
        }
    }
}

#Preview {
    VoiceModeView()
}