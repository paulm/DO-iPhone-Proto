//
//  ImageGenerationSupport.swift
//  DO-iPhone-Proto
//
//  Supporting types for Image Generation functionality
//

import SwiftUI
import PhotosUI

// Image item model
struct GeneratedImage: Identifiable {
    let id = UUID()
    var isLoading: Bool
    var image: Image?
}

// Using a class for ImageGenerationView to support @objc methods for UIKit callbacks
final class ImageGenerationViewWrapper: NSObject {
    // Singleton instance for UIKit callbacks
    static let shared = ImageGenerationViewWrapper()

    // Callback for image saving result
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // Handle the result (in a real app, you'd want to show a success or error message)
        if error != nil {
            print("Error saving image: \(String(describing: error))")
            // In a real app: show error alert
        } else {
            print("Image saved successfully")
            // In a real app: show success message
        }
    }
}

// UIActivityViewController wrapper for SwiftUI
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Style selection button
struct StyleButton: View {
    let style: ImageStyle
    let isSelected: Bool
    let action: () -> Void

    // Define accent color
    let accentColor = Color(hex: "44C0FF")

    var body: some View {
        Button(action: action) {
            Text(style.displayName)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? accentColor.opacity(0.2) : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? accentColor : .gray)
        }
        .buttonStyle(.plain)
    }
}

// Image style enum
enum ImageStyle: String, CaseIterable, Hashable {
    case threeD = "3d-model"
    case analogFilm = "analog-film"
    case anime
    case cinematic
    case comicbook
    case craftClay = "craft-clay"
    case digitalArt = "digital-art"
    case enhance
    case fantasyArt = "fantasy-art"
    case isometric
    case lineArt = "line-art"
    case lowpoly
    case neonpunk
    case origami
    case photographic
    case pixelArt = "pixel-art"
    case texture

    var displayName: String {
        switch self {
        case .threeD: return "3D Model"
        case .analogFilm: return "Analog Film"
        case .craftClay: return "Craft Clay"
        case .digitalArt: return "Digital Art"
        case .fantasyArt: return "Fantasy Art"
        case .lineArt: return "Line Art"
        case .pixelArt: return "Pixel Art"
        default: return rawValue.capitalized
        }
    }
}

// Extension to generate gradient images for our simulation
extension UIImage {
    static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
}
