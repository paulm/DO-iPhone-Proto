import SwiftUI
import UIKit

// MARK: - Gold Celebration View (Half-sheet modal with #F0B805 gold)

struct GoldCelebrationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Animation phases
    @State private var badgeAppeared = false
    @State private var headlineAppeared = false
    @State private var ringPulse = false
    @State private var shimmerPhase: CGFloat = -1
    @State private var confettiVisible = false
    @State private var coinSpin: Double = 0

    // Confetti particles
    @State private var particles: [CParticle] = []
    @State private var lastTick: Date?

    // #F0B805-based gold palette
    private let gold      = Color(hex: "F0B805")
    private let lightGold = Color(hex: "F8D44A")
    private let paleGold  = Color(hex: "FDE98E")
    private let deepGold  = Color(hex: "C49604")
    private let darkGold  = Color(hex: "8A6A03")

    var body: some View {
        ZStack {
            // Confetti layer
            if confettiVisible && !reduceMotion {
                SwiftUI.TimelineView(.animation) { timeline in
                    Canvas { ctx, size in
                        for p in particles {
                            let fade = max(0, 1.0 - p.age / p.lifetime)
                            guard fade > 0 else { continue }
                            ctx.opacity = fade * p.opacity
                            var t = CGAffineTransform(translationX: p.x, y: p.y)
                            t = t.rotated(by: p.rotation)
                            t = t.scaledBy(x: p.scale, y: p.scale)

                            let path: Path
                            if p.isCircle {
                                path = Path(ellipseIn: CGRect(x: -4, y: -4, width: 8, height: 8))
                            } else {
                                path = Path(roundedRect: CGRect(x: -3, y: -6, width: 6, height: 12), cornerRadius: 1.5)
                            }
                            ctx.fill(path.applying(t), with: .color(p.color))
                        }
                    }
                    .allowsHitTesting(false)
                    .onChange(of: timeline.date) { _, now in
                        guard let last = lastTick else { lastTick = now; return }
                        let dt = min(now.timeIntervalSince(last), 0.05)
                        lastTick = now
                        particles = particles.compactMap { p in
                            var p = p
                            p.age += dt
                            guard p.age < p.lifetime else { return nil }
                            p.x += p.vx * CGFloat(dt)
                            p.y += p.vy * CGFloat(dt)
                            p.vy += 280 * CGFloat(dt)
                            p.vx *= (1 - 0.45 * CGFloat(dt))
                            p.rotation += p.rotVel * dt
                            return p
                        }
                    }
                }
            }

            // Main content
            VStack(spacing: 0) {
                Spacer()

                // Badge with pulsing rings
                ZStack {
                    // Pulsing rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(gold.opacity(0.25), lineWidth: 1.5)
                            .frame(width: 180 + CGFloat(i) * 20, height: 180 + CGFloat(i) * 20)
                            .scaleEffect(ringPulse ? 1.3 : 0.9)
                            .opacity(ringPulse ? 0 : 0.5)
                            .animation(
                                .easeOut(duration: 1.6)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.2),
                                value: ringPulse
                            )
                    }

                    // Gold badge
                    Image("do-gold-badge")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [paleGold, gold, deepGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 150)
                        .overlay(
                            // Shimmer sweep
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: max(0, shimmerPhase - 0.2)),
                                    .init(color: paleGold.opacity(0.8), location: shimmerPhase),
                                    .init(color: .clear, location: min(1, shimmerPhase + 0.2))
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .blendMode(.plusLighter)
                            .mask(
                                Image("do-gold-badge")
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                            )
                        )
                        .shadow(color: gold.opacity(0.35), radius: 20, x: 0, y: 8)
                        .scaleEffect(badgeAppeared ? 1.0 : 0.2)
                        .opacity(badgeAppeared ? 1 : 0)
                        .rotation3DEffect(
                            .degrees(coinSpin),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.4
                        )
                        .animation(
                            reduceMotion
                                ? .easeOut(duration: 0.25)
                                : .spring(response: 0.55, dampingFraction: 0.62),
                            value: badgeAppeared
                        )
                }
                .padding(.bottom, 28)

                // Headline
                Text("Welcome to Gold")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [darkGold, deepGold, darkGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(headlineAppeared ? 1 : 0.85)
                    .opacity(headlineAppeared ? 1 : 0)
                    .animation(
                        reduceMotion
                            ? .easeOut(duration: 0.2)
                            : .spring(response: 0.45, dampingFraction: 0.72).delay(0.3),
                        value: headlineAppeared
                    )

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                Color.white

                // Subtle radial glow centered on badge area
                RadialGradient(
                    colors: [
                        gold.opacity(0.12),
                        paleGold.opacity(0.06),
                        Color.white
                    ],
                    center: UnitPoint(x: 0.5, y: 0.38),
                    startRadius: 0,
                    endRadius: 350
                )
            }
            .ignoresSafeArea()
        )
        .onAppear { startAnimation() }
    }

    // MARK: - Animation Sequence

    private func startAnimation() {
        // Haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        // Badge + coin spin (immediate)
        badgeAppeared = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if !reduceMotion {
            withAnimation(.easeOut(duration: 0.9)) {
                coinSpin = 720
            }
        }

        // Rings
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            ringPulse = true
        }

        // Shimmer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.4
            }
        }

        // Headline
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            headlineAppeared = true
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }

        // Confetti
        if !reduceMotion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                emitConfetti(count: 70)
                confettiVisible = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                emitConfetti(count: 40)
            }
        }

        // Auto-dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            dismiss()
        }
    }

    // MARK: - Confetti Emitter

    private func emitConfetti(count: Int) {
        let colors: [Color] = [gold, lightGold, paleGold, deepGold, darkGold, Color(hex: "44C0FF")]
        let screenWidth = UIScreen.main.bounds.width
        let cx = screenWidth / 2
        let cy: CGFloat = 80

        let burst = (0..<count).map { _ -> CParticle in
            let angle = Double.random(in: 0 ..< .pi * 2)
            let speed = CGFloat.random(in: 200...520)
            return CParticle(
                x: cx + .random(in: -15...15),
                y: cy,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed - .random(in: 80...180),
                rotation: .random(in: 0 ..< .pi * 2),
                rotVel: .random(in: -5...5),
                scale: .random(in: 0.5...1.4),
                opacity: .random(in: 0.7...1.0),
                color: colors.randomElement()!,
                lifetime: .random(in: 1.8...2.8),
                age: 0,
                isCircle: Bool.random()
            )
        }
        particles.append(contentsOf: burst)
    }
}

// MARK: - Particle Model

private struct CParticle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var rotation: Double
    var rotVel: Double
    var scale: CGFloat
    var opacity: Double
    var color: Color
    var lifetime: Double
    var age: Double
    var isCircle: Bool
}

// MARK: - Preview

#Preview("Gold Celebration") {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            GoldCelebrationView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
}
