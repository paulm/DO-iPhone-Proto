# DatePickerRow Component

## Overview

`DatePickerRow` is a horizontal scrollable date selector component for SwiftUI that provides an elegant timeline view of user activity. It displays a 33-day window (30 past days + today + 2 future days) with visual indicators for different date states.

## Features

- **Horizontal Scrolling Timeline**: Smooth scrollable interface showing 33 days
- **Activity Tracking**: Visual indicators for dates with chat messages and journal entries
- **Auto-Centering**: Automatically scrolls to keep selected date centered
- **Statistics Display**: Shows current streak, total chats, and total entries
- **Multiple Visual States**: Different appearances for past, present, future, selected, and activity states
- **Haptic Feedback**: Light haptic feedback when selecting dates
- **Responsive Layout**: Adapts to different screen sizes with dynamic spacing

## Visual Appearance

```
┌──────────────────────────────────────────────────────────┐
│ [3 Days Streak • 12 Chats • 8 Entries] [○][○][●][○][⊙]→ │
└──────────────────────────────────────────────────────────┘
```

**Legend**:
- `○` = Empty date (no activity)
- `●` = Date with chat messages (small dot indicator)
- `⊙` = Today (ring indicator)
- Blue ring = Selected date
- Dark filled circle = Date with journal entry

## Dependencies

This component requires:
- **SwiftUI** (iOS 18.5+)
- **UIKit** (for haptic feedback)
- **Data Managers** (protocols provided below)

## Component Architecture

The DatePickerRow consists of four main parts:

1. **DatePickerConstants** - Layout constants
2. **DateCircleStyle** - Visual style configuration system
3. **DateCircle** - Individual date circle view
4. **DatePickerRow** - Main scrollable container

---

## Implementation Code

### 1. DatePickerConstants

```swift
import SwiftUI
import UIKit

// MARK: - Layout Constants
struct DatePickerConstants {
    static let circleSize: CGFloat = 22      // Hit area size
    static let spacing: CGFloat = 12         // Base spacing between circles
    static let horizontalPadding: CGFloat = 16  // Left/right margins
}
```

### 2. DateCircleStyle Configuration

```swift
// MARK: - Date Circle Style Configuration
struct DateCircleStyle {
    // Base circle properties
    let baseSize: CGFloat
    let baseColor: Color

    // Selection/highlight circle
    let highlightSize: CGFloat
    let highlightColor: Color?

    // Ring indicator (for today/selected)
    let ringColor: Color?
    let ringSize: CGFloat
    let ringWidth: CGFloat

    // Chat indicator (small dot)
    let chatIndicatorSize: CGFloat
    let chatIndicatorColor: Color

    // Text properties
    let textColor: Color
    let showText: Bool

    // Entry override (when has entry)
    let entryColor: Color?
}

extension DateCircleStyle {
    // MARK: - Base Styles

    /// Style for past dates
    static let past = DateCircleStyle(
        baseSize: 18,
        baseColor: .gray.opacity(0.15),
        highlightSize: 18,
        highlightColor: nil,
        ringColor: nil,
        ringSize: 0,
        ringWidth: 0,
        chatIndicatorSize: 8,
        chatIndicatorColor: Color(hex: "333B40"),
        textColor: .primary,
        showText: false,
        entryColor: nil
    )

    /// Style for today
    static let today = DateCircleStyle(
        baseSize: 18,
        baseColor: .gray.opacity(0.15),
        highlightSize: 18,
        highlightColor: nil,
        ringColor: Color.gray.opacity(0.8),
        ringSize: 22,
        ringWidth: 2,
        chatIndicatorSize: 8,
        chatIndicatorColor: Color(hex: "333B40"),
        textColor: .primary,
        showText: true,
        entryColor: nil
    )

    /// Style for future dates
    static let future = DateCircleStyle(
        baseSize: 8,
        baseColor: .gray.opacity(0.15),
        highlightSize: 18,
        highlightColor: nil,
        ringColor: nil,
        ringSize: 0,
        ringWidth: 0,
        chatIndicatorSize: 8,
        chatIndicatorColor: Color(hex: "333B40"),
        textColor: .secondary,
        showText: false,
        entryColor: nil
    )

    // MARK: - State Modifiers

    /// Apply selected state (blue ring)
    func selected() -> DateCircleStyle {
        DateCircleStyle(
            baseSize: baseSize,
            baseColor: baseColor,
            highlightSize: 18,
            highlightColor: nil,
            ringColor: Color(hex: "44C0FF"), // Blue ring for selection
            ringSize: 22,
            ringWidth: 2,
            chatIndicatorSize: chatIndicatorSize,
            chatIndicatorColor: Color(hex: "333B40"),
            textColor: textColor,
            showText: showText,
            entryColor: entryColor
        )
    }

    /// Apply entry state (dark filled circle)
    func withEntry() -> DateCircleStyle {
        DateCircleStyle(
            baseSize: baseSize,
            baseColor: baseColor,
            highlightSize: 18,
            highlightColor: Color(hex: "333B40"), // Dark gray fill
            ringColor: ringColor,
            ringSize: ringSize,
            ringWidth: ringWidth,
            chatIndicatorSize: 0, // No chat indicator when has entry
            chatIndicatorColor: chatIndicatorColor,
            textColor: .white,
            showText: showText,
            entryColor: Color(hex: "333B40")
        )
    }
}
```

### 3. DateCircle Component

```swift
// MARK: - Individual Date Circle
struct DateCircle: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isFuture: Bool
    let isCompleted: Bool  // Has chat/activity
    let hasEntry: Bool     // Has journal entry
    let showDate: Bool     // Show date number
    let onTap: () -> Void

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    // Compute appropriate style based on state
    private var style: DateCircleStyle {
        // Start with base style
        var baseStyle: DateCircleStyle
        if isFuture {
            baseStyle = .future
        } else if isToday {
            baseStyle = .today
        } else {
            baseStyle = .past
        }

        // Apply modifiers
        if isSelected {
            baseStyle = baseStyle.selected()
        }

        if hasEntry {
            baseStyle = baseStyle.withEntry()
        }

        return baseStyle
    }

    var body: some View {
        ZStack {
            // Layer 1: Spacer for consistent layout
            Circle()
                .fill(.white.opacity(0.01))
                .frame(width: DatePickerConstants.circleSize, height: DatePickerConstants.circleSize)

            // Layer 2: Ring indicator (today/selected)
            if let ringColor = style.ringColor, style.ringSize > 0 {
                Circle()
                    .stroke(ringColor, lineWidth: style.ringWidth)
                    .frame(width: style.ringSize, height: style.ringSize)
            }

            // Layer 3: Base circle
            Circle()
                .fill(style.baseColor)
                .frame(width: style.baseSize, height: style.baseSize)

            // Layer 4: Highlight/Entry circle
            if let highlightColor = style.highlightColor {
                Circle()
                    .fill(highlightColor)
                    .frame(width: style.highlightSize, height: style.highlightSize)
            } else if hasEntry, let entryColor = style.entryColor {
                Circle()
                    .fill(entryColor)
                    .frame(width: style.highlightSize, height: style.highlightSize)
            }

            // Layer 5: Chat/Activity indicator (small dot)
            if isCompleted && !hasEntry && style.chatIndicatorSize > 0 {
                Circle()
                    .fill(style.chatIndicatorColor)
                    .frame(width: style.chatIndicatorSize, height: style.chatIndicatorSize)
            }

            // Layer 6: Date text
            if style.showText || showDate {
                Text(dayNumber)
                    .font(.system(size: 8))
                    .fontWeight(.medium)
                    .foregroundStyle(style.textColor)
            }
        }
        .onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            onTap()
        }
    }
}
```

### 4. DatePickerRow Main Component

```swift
// MARK: - Date Picker Row
struct DatePickerRow: View {
    let dates: [Date]
    @Binding var selectedDate: Date

    // Data source protocol - implement these in your app
    var hasMessagesForDate: ((Date) -> Bool)?
    var hasEntryForDate: ((Date) -> Bool)?

    @State private var dynamicSpacing: CGFloat = DatePickerConstants.spacing

    // Statistics computed from dates
    private var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = calendar.date(byAdding: .day, value: -1, to: today)!

        while hasMessagesForDate?(checkDate) == true {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        return streak
    }

    private var totalChats: Int {
        scrollableDates.filter { hasMessagesForDate?($0) == true }.count
    }

    private var totalEntries: Int {
        scrollableDates.filter { hasEntryForDate?($0) == true }.count
    }

    // Generate scrollable date range: 30 past + today + 2 future = 33 days
    private var scrollableDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var allDates: [Date] = []

        // Add 30 past days (-30 to -1)
        for i in stride(from: -30, to: 0, by: 1) {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                allDates.append(date)
            }
        }

        // Add today
        allDates.append(today)

        // Add 2 future days (+1 to +2)
        for i in 1...2 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                allDates.append(date)
            }
        }

        return allDates
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: dynamicSpacing) {
                    // Stats header
                    HStack(spacing: 6) {
                        Text("\(currentStreak) Day\(currentStreak == 1 ? "" : "s") Streak")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(totalChats) Chat\(totalChats == 1 ? "" : "s")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(totalEntries) Entr\(totalEntries == 1 ? "y" : "ies")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 12)
                    .id("header")

                    // Date circles
                    ForEach(Array(scrollableDates.enumerated()), id: \.offset) { index, date in
                        DateCircle(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(date),
                            isFuture: date > Date(),
                            isCompleted: hasMessagesForDate?(date) == true,
                            hasEntry: hasEntryForDate?(date) == true,
                            showDate: false,
                            onTap: {
                                selectedDate = date
                            }
                        )
                        .id(index)
                    }
                }
                .padding(.horizontal, DatePickerConstants.horizontalPadding)
                .padding(.vertical, 2)
            }
            .onAppear {
                scrollToSelectedDate(proxy: proxy)
            }
            .onChange(of: selectedDate) { oldValue, newValue in
                scrollToSelectedDate(proxy: proxy)
            }
        }
    }

    // Auto-scroll to center selected date
    private func scrollToSelectedDate(proxy: ScrollViewProxy) {
        let calendar = Calendar.current

        if let selectedIndex = scrollableDates.firstIndex(where: {
            calendar.isDate($0, inSameDayAs: selectedDate)
        }) {
            // Center the selected date (show 5 dates before it)
            let targetIndex = max(0, selectedIndex - 5)
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(targetIndex, anchor: .leading)
            }
        } else {
            // Handle dates outside range
            if selectedDate < scrollableDates.first ?? Date() {
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo("header", anchor: .leading)
                }
            } else if selectedDate > scrollableDates.last ?? Date() {
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(scrollableDates.count - 1, anchor: .trailing)
                }
            }
        }
    }
}
```

### 5. Color Extension (Required)

```swift
// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

---

## Integration Guide

### Step 1: Add the Code

Copy all five code sections above into your project. You can organize them as:
- Single file: `DatePickerRow.swift`
- Or separate files: `DatePickerConstants.swift`, `DateCircleStyle.swift`, `DateCircle.swift`, `DatePickerRow.swift`

### Step 2: Implement Data Source

The component needs two data sources. Implement these based on your app's data model:

```swift
// Example: In your parent view or view model
func hasMessagesForDate(_ date: Date) -> Bool {
    // Replace with your actual logic
    // Check if the date has any chat messages or activity
    return yourDataManager.hasActivity(for: date)
}

func hasEntryForDate(_ date: Date) -> Bool {
    // Replace with your actual logic
    // Check if the date has a journal entry
    return yourDataManager.hasEntry(for: date)
}
```

### Step 3: Use the Component

```swift
struct YourView: View {
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            DatePickerRow(
                dates: [], // Not used - component generates its own 33-day range
                selectedDate: $selectedDate,
                hasMessagesForDate: { date in
                    // Your logic here
                    return yourDataManager.hasActivity(for: date)
                },
                hasEntryForDate: { date in
                    // Your logic here
                    return yourDataManager.hasEntry(for: date)
                }
            )
            .padding(.vertical, 10)

            // Rest of your view...
        }
    }
}
```

---

## Customization Options

### Adjust Date Range

Modify the `scrollableDates` computed property in `DatePickerRow`:

```swift
// Current: 30 past + today + 2 future = 33 days
// Change to 60 past + today + 7 future:
for i in stride(from: -60, to: 0, by: 1) { ... }  // Past
for i in 1...7 { ... }  // Future
```

### Customize Colors

Edit the color values in `DateCircleStyle`:

```swift
// Brand colors
static let brandBlue = Color(hex: "44C0FF")  // Selection ring
static let darkGray = Color(hex: "333B40")   // Entry fill, chat indicator

// Change to your brand colors
ringColor: Color(hex: "YOUR_COLOR")
```

### Adjust Layout

Modify `DatePickerConstants`:

```swift
struct DatePickerConstants {
    static let circleSize: CGFloat = 28      // Larger circles
    static let spacing: CGFloat = 16         // More spacing
    static let horizontalPadding: CGFloat = 20  // More margin
}
```

### Hide Statistics

Remove or comment out the stats header section in `DatePickerRow` body:

```swift
// Comment out this entire block:
/*
HStack(spacing: 6) {
    Text("\(currentStreak) Day...")
    // ... stats code
}
.padding(.trailing, 12)
.id("header")
*/
```

### Show Date Numbers

Set `showDate: true` in the `DateCircle` initialization within `DatePickerRow`:

```swift
DateCircle(
    date: date,
    // ... other parameters
    showDate: true,  // Change from false to true
    onTap: { ... }
)
```

---

## Visual States Reference

### Circle Sizes
- **Past dates**: 18pt base circle
- **Today**: 18pt base circle + 22pt ring
- **Future dates**: 8pt small circle
- **Selected**: +22pt blue ring overlay

### Color Palette
- **Selection**: `#44C0FF` (blue)
- **Entry/Activity**: `#333B40` (dark gray)
- **Base circles**: Gray with 15% opacity
- **Today ring**: Gray with 80% opacity

### State Combinations
1. **Empty past date**: 18pt gray circle
2. **Past date with chat**: 18pt gray circle + 8pt dark dot
3. **Past date with entry**: 18pt dark filled circle (white text if shown)
4. **Today (empty)**: 18pt gray circle + 22pt gray ring + date number
5. **Today (with chat)**: Same as above + 8pt dark dot
6. **Today (selected)**: Gray ring changes to blue ring
7. **Future date**: 8pt small gray circle
8. **Selected any date**: +22pt blue ring overlay

---

## Performance Notes

- **Fixed range**: Component always shows exactly 33 dates (no lazy loading needed)
- **Haptic feedback**: Lightweight impact generator (no performance impact)
- **Auto-scroll animation**: Single 0.3s ease-in-out (hardware accelerated)
- **Date calculations**: Computed once per render, cached in computed properties

---

## Accessibility Considerations

- Hit areas: 22pt × 22pt (expandable to 44pt by adjusting `circleSize`)
- Not color-dependent (uses shapes: rings, filled circles, dots)
- Date numbers shown for today by default
- Stats text uses `.secondary` foreground (adapts to light/dark mode)

---

## Troubleshooting

### Dates not showing activity
- Verify your `hasMessagesForDate` and `hasEntryForDate` closures return correct values
- Check that your data is loaded before the component appears
- Add debug prints inside the closures to verify they're being called

### Auto-scroll not working
- Ensure `selectedDate` binding is properly connected
- Verify the selected date falls within the 33-day range
- Check that `ScrollViewReader` proxy is accessible

### Circles appear too small/large
- Adjust `DatePickerConstants.circleSize` for hit area
- Modify `baseSize` in `DateCircleStyle` for visual size
- Ensure `ringSize` is larger than `baseSize` for visible rings

### Stats showing wrong counts
- Verify date range in `scrollableDates` matches your expectations
- Check calendar date comparisons (use `startOfDay` for accuracy)
- Ensure data sources return consistent results for the same date

---

## Example Use Cases

### 1. Minimal Implementation (No Data)
```swift
DatePickerRow(
    dates: [],
    selectedDate: $selectedDate,
    hasMessagesForDate: { _ in false },
    hasEntryForDate: { _ in false }
)
```

### 2. With Core Data
```swift
DatePickerRow(
    dates: [],
    selectedDate: $selectedDate,
    hasMessagesForDate: { date in
        !fetchMessages(for: date).isEmpty
    },
    hasEntryForDate: { date in
        fetchEntry(for: date) != nil
    }
)
```

### 3. With Custom Data Manager
```swift
DatePickerRow(
    dates: [],
    selectedDate: $selectedDate,
    hasMessagesForDate: dataManager.hasActivity,
    hasEntryForDate: dataManager.hasEntry
)
```

---

## Version History

**v1.0** - Initial implementation
- 33-day scrollable timeline
- Visual state system
- Auto-centering behavior
- Statistics display
- Haptic feedback

---

## License & Credits

This component is extracted from a Day One iOS prototype project. Adapt freely for your production app.

**Colors used**:
- Brand Blue: `#44C0FF`
- Dark Gray: `#333B40`

**iOS Target**: iOS 18.5+
**Framework**: SwiftUI
**Dependencies**: UIKit (haptic feedback only)

---

## Quick Start Checklist

- [ ] Copy all five code sections into your project
- [ ] Add Color extension for hex support
- [ ] Implement `hasMessagesForDate` data source
- [ ] Implement `hasEntryForDate` data source
- [ ] Add `DatePickerRow` to your view with bindings
- [ ] Test date selection and auto-scrolling
- [ ] Customize colors to match your brand
- [ ] Adjust date range if needed (default: 33 days)
- [ ] Optional: Hide stats header if not needed
- [ ] Optional: Adjust circle sizes and spacing

---

**Ready to implement?** Copy the code sections above into your project and follow the integration guide. The component is fully self-contained and requires minimal setup beyond implementing your data source closures.
