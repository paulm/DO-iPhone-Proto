import UIKit
import SwiftUI
import AVFoundation

// MARK: - ListeningHaloView (Core Animation)

public final class ListeningHaloView: UIView {

    // Public API
    func startAnimating() { configureAnimations() }
    func stopAnimating() { layer.sublayers?.forEach { $0.removeAllAnimations() } }
    func updateLevel(_ x: CGFloat) { level = ema(alpha: 0.05, x: clamp01(x), prev: level) }

    // Layers
    private let ringLayer = CAShapeLayer()
    private let pulseReplicator = CAReplicatorLayer()
    private let pulse = CAShapeLayer()
    private let centerDot = CALayer()

    private var level: CGFloat = 0 { didSet { applyLevel(level) } }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear


        // Simple ring stroke
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = tintColor.withAlphaComponent(0.3).cgColor
        ringLayer.lineCap = .round
        ringLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.addSublayer(ringLayer)

        // Pulses - reduced opacity by half
        pulse.fillColor = tintColor.withAlphaComponent(0.025).cgColor
        pulse.strokeColor = tintColor.withAlphaComponent(0.125).cgColor
        pulse.lineWidth = 1.0
        pulseReplicator.instanceCount = 5
        pulseReplicator.instanceDelay = 1.2
        pulseReplicator.addSublayer(pulse)
        layer.addSublayer(pulseReplicator)

        // Center dot/glow anchor - removed to avoid overlapping with icon
        // centerDot.backgroundColor = UIColor.white.withAlphaComponent(0.95).cgColor
        // centerDot.shadowColor = tintColor.cgColor
        // centerDot.shadowOpacity = 0.8
        // centerDot.shadowOffset = .zero
        // layer.addSublayer(centerDot)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func tintColorDidChange() {
        super.tintColorDidChange()
        ringLayer.strokeColor = tintColor.withAlphaComponent(0.3).cgColor
        pulse.fillColor = tintColor.withAlphaComponent(0.075).cgColor
        pulse.strokeColor = tintColor.withAlphaComponent(0.125).cgColor
        // centerDot.shadowColor = tintColor.cgColor  // Removed centerDot
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let b = bounds
        pulseReplicator.frame = b

        // Geometry
        let size = min(b.width, b.height)
        let ringOuter = size * 0.70 // visual ring diameter

        // Set the ring layer's bounds and position
        ringLayer.bounds = CGRect(x: 0, y: 0, width: ringOuter, height: ringOuter)
        ringLayer.position = CGPoint(x: b.midX, y: b.midY)

        // Create the path in the layer's coordinate space
        let ringPath = UIBezierPath(ovalIn: ringLayer.bounds)
        ringLayer.lineWidth = 1.0
        ringLayer.path = ringPath.cgPath

        // Pulse starts roughly at ring size and grows outward
        pulse.bounds = CGRect(x: 0, y: 0, width: ringOuter, height: ringOuter)
        pulse.position = CGPoint(x: b.midX, y: b.midY)
        pulse.path = UIBezierPath(ovalIn: pulse.bounds).cgPath

        // centerDot.bounds = CGRect(x: 0, y: 0, width: size * 0.06, height: size * 0.06)
        // centerDot.cornerRadius = centerDot.bounds.width / 2
        // centerDot.position = CGPoint(x: b.midX, y: b.midY)
    }

    private func configureAnimations() {
        layer.removeAllAnimations()
        pulse.removeAllAnimations()
        ringLayer.removeAllAnimations()

        let reduceMotion = UIAccessibility.isReduceMotionEnabled || ProcessInfo.processInfo.isLowPowerModeEnabled

        // Breathing ring
        if !reduceMotion {
            let breath = CABasicAnimation(keyPath: "transform.scale")
            breath.fromValue = 0.46
            breath.toValue = 1.04
            breath.duration = 3.2
            breath.autoreverses = true
            breath.repeatCount = .infinity
            breath.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            ringLayer.add(breath, forKey: "breath")
        } else {
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 0.65
            fade.toValue = 1.0
            fade.duration = 1.6
            fade.autoreverses = true
            fade.repeatCount = .infinity
            ringLayer.add(fade, forKey: "fade")
        }

        // Repeating ripples - reduced size by half, starting even smaller
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.05
        scale.toValue = 2.30

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.85
        fade.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 9.8
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)

        if !reduceMotion {
            pulse.add(group, forKey: "pulse")
        }
    }

    private func applyLevel(_ x: CGFloat) {
        // Level drives ring thickness and opacity; small but noticeable
        // centerDot.shadowRadius = 8 + 28 * x  // Removed centerDot
        ringLayer.lineWidth = 2 + 3 * x
        ringLayer.opacity = Float(0.65 + 0.35 * x)
    }

    private func clamp01(_ v: CGFloat) -> CGFloat { max(0, min(1, v)) }
    private func ema(alpha: CGFloat, x: CGFloat, prev: CGFloat) -> CGFloat { alpha*x + (1-alpha)*prev }
}

// MARK: - SwiftUI wrapper

public struct ListeningAnimationView: UIViewRepresentable {
    @Binding var level: CGFloat // 0…1 normalized
    var tintColor: UIColor

    public init(level: Binding<CGFloat>, tintColor: UIColor = UIColor(red: 0.267, green: 0.753, blue: 1.0, alpha: 1.0)) {
        self._level = level
        self.tintColor = tintColor
    }

    public func makeUIView(context: Context) -> ListeningHaloView {
        let v = ListeningHaloView()
        v.tintColor = tintColor
        v.startAnimating()
        return v
    }

    public func updateUIView(_ uiView: ListeningHaloView, context: Context) {
        uiView.updateLevel(level)
        if uiView.tintColor != tintColor {
            uiView.tintColor = tintColor
        }
    }
}

// MARK: - Mock Mic Level Monitor for testing

class MicLevelMonitor {
    var onLevel: ((CGFloat) -> Void)?
    private var timer: Timer?
    private var currentLevel: CGFloat = 0

    func start() throws {
        // Simulate mic levels with a timer - more subtle variations
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            // Simulate varying audio levels
            let randomComponent = CGFloat.random(in: -0.05...0.05)
            let sineWave = sin(Date().timeIntervalSince1970 * 1.5) * 0.2
            self.currentLevel = max(0, min(1, 0.2 + sineWave + randomComponent))
            self.onLevel?(self.currentLevel)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
