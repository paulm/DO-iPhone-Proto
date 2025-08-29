//
//  DayOneIconExtensions.swift
//  DO-iPhone-Proto
//
//  SwiftUI extensions for using Day One Icons throughout the app
//

import SwiftUI

// MARK: - Image Extension for Day One Icons
extension Image {
    /// Create an Image view directly from a Day One Icon
    init(dayOneIcon: DayOneIcon) {
        if let uiImage = DayOneIconImage.createImage(from: dayOneIcon) {
            self.init(uiImage: uiImage)
        } else {
            self.init(systemName: "questionmark.circle")
        }
    }
}

// MARK: - Day One Icon Mapping
extension DayOneIcon {
    /// Maps common SF Symbols to their Day One Icon equivalents
    static func fromSFSymbol(_ sfSymbol: String) -> DayOneIcon? {
        switch sfSymbol {
        // Navigation
        case "chevron.right": return .chevron_right
        case "chevron.left": return .chevron_left
        case "chevron.up": return .chevron_up
        case "chevron.down": return .chevron_down
        
        // Actions
        case "plus": return .plus
        case "plus.circle": return .plus_circle
        case "plus.circle.fill": return .plus_circle_filled
        case "trash": return .trash
        case "square.and.pencil": return .pen_edit
        case "pencil": return .pen
        case "ellipsis": return .dots_horizontal
        case "gearshape", "gearshape.fill": return .settings
        case "checkmark": return .checkmark
        case "checkmark.circle.fill": return .checkmark_circle_filled
        case "circle": return .checkbox_empty
        case "arrow.up": return .arrow_up
        case "arrow.up.circle.fill": return .arrow_up_circle_filled
        case "arrow.clockwise": return .sync
        case "arrow.triangle.2.circlepath": return .loop
        
        // Media & Content
        case "photo": return .photo
        case "camera": return .camera
        case "mic", "mic.fill": return .microphone
        case "speaker": return .speaker
        case "speaker.slash": return .speaker_mute
        
        // Communication
        case "bubble.left.and.bubble.right", "bubble.left.and.bubble.right.fill": return .message
        case "bubble.left": return .comment
        case "message": return .message
        
        // Location & Time
        case "location", "location.circle": return .map_pin
        case "calendar": return .calendar
        case "calendar.badge.clock": return .calendar_clock
        case "clock": return .clock
        
        // Weather
        case "cloud.sun": return .weather_partly_cloudy
        case "sun.max": return .weather_sunny
        
        // Documents
        case "doc.text": return .document
        case "folder": return .folder
        case "book": return .book
        
        // UI Elements
        case "eye.slash": return .eye_cross
        case "eye": return .eye
        
        // Places icons
        case "figure.skiing.downhill": return .skiing
        case "cart.fill", "cart": return .cart
        case "books.vertical.fill": return .books_filled
        case "cup.and.saucer.fill": return .food
        case "figure.hiking": return .hiking
        
        // Events icons
        case "person.3.fill": return .users_group
        case "cross.case.fill": return .health
        case "fork.knife": return .fork_knife
        case "chart.bar.doc.horizontal.fill": return .stats
        case "figure.yoga": return .yoga
        
        default: return nil
        }
    }
}

// MARK: - View Extension for Day One Icons
extension View {
    /// Modifier to replace SF Symbol with Day One Icon
    func dayOneIcon(_ icon: DayOneIcon, size: CGFloat = 20) -> some View {
        Text(icon.rawValue)
            .dayOneIconFont(size: size)
    }
}

// MARK: - Button Convenience Initializers
extension Button where Label == Image {
    /// Create a button with a Day One Icon
    init(dayOneIcon: DayOneIcon, action: @escaping () -> Void) {
        self.init(action: action) {
            Image(dayOneIcon: dayOneIcon)
        }
    }
}

// Button with label extension removed - Swift Label is not generic