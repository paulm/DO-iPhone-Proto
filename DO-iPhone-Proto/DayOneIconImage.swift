//
//  DayOneIconImage.swift
//  DO-iPhone-Proto
//
//  Helper to create images from Day One Icons for use in tab bars
//

import SwiftUI
import UIKit

/// Creates an Image from a Day One Icon that can be used in tab bars
struct DayOneIconImage {
    
    /// Creates a UIImage from a Day One Icon
    static func createImage(from icon: DayOneIcon, size: CGFloat = 24) -> UIImage? {
        let font = UIFont(name: "DayOneIcons", size: size) ?? UIFont.systemFont(ofSize: size)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.label
        ]
        
        let attributedString = NSAttributedString(string: icon.rawValue, attributes: attributes)
        let size = attributedString.size()
        
        // Add padding for better rendering
        let paddedSize = CGSize(width: size.width + 4, height: size.height + 4)
        
        UIGraphicsBeginImageContextWithOptions(paddedSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // Draw the icon centered in the context
        let drawPoint = CGPoint(x: 2, y: 2)
        attributedString.draw(at: drawPoint)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image?.withRenderingMode(.alwaysTemplate)
    }
    
    /// Creates a SwiftUI Image from a Day One Icon
    static func image(from icon: DayOneIcon, size: CGFloat = 24) -> Image {
        if let uiImage = createImage(from: icon, size: size) {
            return Image(uiImage: uiImage)
        } else {
            // Fallback to system image
            return Image(systemName: "questionmark.circle")
        }
    }
}

// Extension to use Day One Icons directly in tab items
extension Label where Title == Text, Icon == Image {
    init(_ title: String, dayOneIcon: DayOneIcon) {
        self.init {
            Text(title)
        } icon: {
            DayOneIconImage.image(from: dayOneIcon)
        }
    }
}