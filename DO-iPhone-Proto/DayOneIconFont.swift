//
//  DayOneIconFont.swift
//  DO-iPhone-Proto
//
//  Day One custom icon font registration and helpers
//

import SwiftUI
import CoreText

public enum DayOneIconFont {
    private static var didRegister = false
    
    /// Register the Day One Icons font with the system
    /// Note: With the font registered in Info.plist, iOS automatically loads it
    /// This method verifies the font is available
    public static func register() {
        guard !didRegister else { return }
        
        // List all available fonts for debugging
        let fontFamilies = UIFont.familyNames
        for family in fontFamilies {
            if family.lowercased().contains("day") || family.lowercased().contains("icon") {
                print("Found font family: \(family)")
                let fontNames = UIFont.fontNames(forFamilyName: family)
                for fontName in fontNames {
                    print("  Font name: \(fontName)")
                }
            }
        }
        
        // Try different possible font names
        let possibleFontNames = ["DayOneIcons", "DayOne Icons", "DayOneIcons-Regular", "DayOne-Icons"]
        var foundFontName: String?
        
        for fontName in possibleFontNames {
            if UIFont(name: fontName, size: 12) != nil {
                foundFontName = fontName
                print("✅ Found Day One Icons font with name: \(fontName)")
                break
            }
        }
        
        if foundFontName == nil {
            print("⚠️ DayOneIcons font not found - checking bundle...")
            
            // Try to manually register if not already registered
            if let fontURL = Bundle.main.url(forResource: "DayOneIcons", withExtension: "ttf") {
                print("Found font file at: \(fontURL)")
                var error: Unmanaged<CFError>?
                let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
                
                if success {
                    print("✅ Successfully registered font manually")
                } else if let error = error?.takeRetainedValue() {
                    print("❌ Font registration failed: \(error)")
                }
            } else {
                print("❌ Font file not found in bundle")
            }
        }
        
        didRegister = true
    }
}

// MARK: - SwiftUI Extensions

extension Font {
    /// Create a Day One Icons font with the specified size
    static func dayOneIcons(size: CGFloat) -> Font {
        return .custom("DayOneIcons", size: size)
    }
}

extension View {
    /// Apply Day One Icons font to this view
    func dayOneIconFont(size: CGFloat) -> some View {
        self.font(.dayOneIcons(size: size))
    }
}

// MARK: - Image Extension for Icons

extension Image {
    /// Create an Image view from a Day One icon
    init(dayOneIcon: DayOneIcon) {
        // Create a Text view with the icon and convert to Image
        // Note: This is a simplified approach - in production you might want
        // to use a different method or create actual image assets
        self.init(systemName: "questionmark.circle") // Fallback
    }
}

// MARK: - Text Helper

extension Text {
    /// Create a Text view with a Day One icon
    init(dayOneIcon: DayOneIcon) {
        self.init(dayOneIcon.rawValue)
    }
}