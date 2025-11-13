import SwiftUI
import TipKit
import UIKit

// MARK: - Date Picker Components
struct DatePickerConstants {
    static let circleSize: CGFloat = 22
    static let spacing: CGFloat = 12
    static let numberOfRows: Int = 6  // Control the number of date grid rows
    static let horizontalPadding: CGFloat = 16  // Margin on left/right
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DatePickerGrid: View {
    let dates: [Date]
    @Binding var selectedDate: Date
    @Binding var showingChatCalendar: Bool
    let showDates: Bool
    let showStreak: Bool

    @State private var availableWidth: CGFloat = 0
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging = false
    @State private var lastSelectedDate: Date?
    @State private var dynamicSpacing: CGFloat = DatePickerConstants.spacing

    // Check if a date has chat messages (completed)
    private func hasMessagesForDate(_ date: Date) -> Bool {
        let messages = ChatSessionManager.shared.getMessages(for: date)
        return !messages.isEmpty && messages.contains { $0.isUser }
    }

    // Check if a date has an entry created
    private func hasEntryForDate(_ date: Date) -> Bool {
        return DailyContentManager.shared.hasEntry(for: date)
    }

    init(dates: [Date], selectedDate: Binding<Date>, showingChatCalendar: Binding<Bool>, showDates: Bool = true, showStreak: Bool = true) {
        self.dates = dates
        self._selectedDate = selectedDate
        self._showingChatCalendar = showingChatCalendar
        self.showDates = showDates
        self.showStreak = showStreak
    }

    private func isDateCompleted(_ date: Date) -> Bool {
        return hasMessagesForDate(date)
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = calendar.date(byAdding: .day, value: -1, to: today)! // Start with yesterday

        // Check consecutive days backwards starting from yesterday
        while isDateCompleted(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        return streak
    }

    private var totalChats: Int {
        dates.filter { hasMessagesForDate($0) }.count
    }

    private var totalEntries: Int {
        dates.filter { hasEntryForDate($0) }.count
    }

    private var columns: Int {
        guard availableWidth > 0 else { return 10 } // Default to 10 columns if width not yet calculated

        // Calculate optimal number of columns and spacing
        let minColumns = 7  // Minimum columns we want
        let maxColumns = 14 // Maximum columns for readability

        // Try different column counts to find the best fit
        for cols in (minColumns...maxColumns).reversed() {
            let totalCircleWidth = CGFloat(cols) * DatePickerConstants.circleSize
            let totalSpacingWidth = availableWidth - totalCircleWidth
            let spacingBetween = totalSpacingWidth / CGFloat(cols - 1)

            // If spacing is reasonable (between 8 and 20 points), use this column count
            if spacingBetween >= 8 && spacingBetween <= 20 {
                // Update dynamic spacing for this configuration
                DispatchQueue.main.async {
                    self.dynamicSpacing = spacingBetween
                }
                return cols
            }
        }

        // Fallback: use minimum columns with calculated spacing
        return minColumns
    }

    private var rows: [[Date]] {
        var result: [[Date]] = []
        var currentRow: [Date] = []

        // Force exactly the configured number of rows
        let datesPerRow = (dates.count + DatePickerConstants.numberOfRows - 1) / DatePickerConstants.numberOfRows // Round up division

        for (index, date) in dates.enumerated() {
            currentRow.append(date)
            if currentRow.count == datesPerRow || index == dates.count - 1 {
                result.append(currentRow)
                currentRow = []
            }
        }

        return result
    }

    var body: some View {
        VStack(spacing: dynamicSpacing) {
            // Stats row
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

                Text("•")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button(action: {
                    showingChatCalendar = true
                }) {
                    Text("View All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(hex: "44C0FF"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, -14)

            // Streak and Today button
            HStack {
                if showStreak && currentStreak > 0 {
                    Text("\(currentStreak) Day\(currentStreak == 1 ? "" : "s") Streak")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()

                if showStreak && !Calendar.current.isDateInToday(selectedDate) {
                    Button(action: {
                        selectedDate = Date()
                    }) {
                        Text("Today")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(hex: "44C0FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.bottom, 8)

            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: dynamicSpacing) {
                    ForEach(Array(row.enumerated()), id: \.offset) { index, date in
                        DateCircle(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(date),
                            isFuture: date > Date(),
                            isCompleted: isDateCompleted(date),
                            hasEntry: hasEntryForDate(date),
                            showDate: showDates,
                            onTap: {
                                selectedDate = date
                            }
                        )
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        // Store the frame for hit testing during drag
                                    }
                            }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size.width)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { width in
            if width > 0 && abs(availableWidth - width) > 1 { // Only update if there's a significant change
                availableWidth = width
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    dragLocation = value.location

                    // Find which date circle contains the drag location
                    let row = Int(value.location.y / (DatePickerConstants.circleSize + dynamicSpacing))
                    let col = Int(value.location.x / (DatePickerConstants.circleSize + dynamicSpacing))

                    if row >= 0 && row < rows.count && col >= 0 && col < rows[row].count {
                        let date = rows[row][col]

                        // Only provide haptic feedback if we're over a new date
                        if lastSelectedDate == nil || !Calendar.current.isDate(lastSelectedDate!, inSameDayAs: date) {
                            // Haptic feedback when selecting a new date
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            lastSelectedDate = date
                        }

                        // Always update the selected date
                        selectedDate = date
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    lastSelectedDate = nil
                }
        )
    }
}

// MARK: - Date Circle Style Configuration
struct DateCircleStyle {
    // Base circle properties
    let baseSize: CGFloat
    let baseColor: Color

    // Selection/highlight circle
    let highlightSize: CGFloat
    let highlightColor: Color?

    // Ring indicator (for today)
    let ringColor: Color?
    let ringSize: CGFloat
    let ringWidth: CGFloat

    // Chat indicator
    let chatIndicatorSize: CGFloat
    let chatIndicatorColor: Color

    // Text properties
    let textColor: Color
    let showText: Bool

    // Entry override (when has entry, override most other styles)
    let entryColor: Color?
}

extension DateCircleStyle {
    // MARK: - Base Styles
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

    // MARK: - Selected State (modifies base styles)
    func selected() -> DateCircleStyle {
        DateCircleStyle(
            baseSize: baseSize,
            baseColor: baseColor,
            highlightSize: 18,
            highlightColor: nil, // No filled blue circle anymore
            ringColor: Color(hex: "44C0FF"), // Blue ring instead
            ringSize: 22,
            ringWidth: 2,
            chatIndicatorSize: chatIndicatorSize,
            chatIndicatorColor: Color(hex: "333B40"), // Keep original chat color
            textColor: textColor, // Keep original text color
            showText: showText,
            entryColor: entryColor // Keep original entry color
        )
    }

    // MARK: - Entry State (overrides most styling)
    func withEntry() -> DateCircleStyle {
        DateCircleStyle(
            baseSize: baseSize,
            baseColor: baseColor,
            highlightSize: 18,
            highlightColor: Color(hex: "333B40"), // Dark gray for entries
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

struct DateCircle: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isFuture: Bool
    let isCompleted: Bool // Has chat
    let hasEntry: Bool
    let showDate: Bool
    let onTap: () -> Void

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    // Compute the appropriate style based on state
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
            // When selected, always use blue ring (even for today)
            baseStyle = baseStyle.selected()
        }

        if hasEntry {
            baseStyle = baseStyle.withEntry()
        }

        return baseStyle
    }

    var body: some View {
        ZStack {
            // Layer 1: Spacer for consistent layout (18pt)
            Circle()
                .fill(.white.opacity(0.01))
                .frame(width: DatePickerConstants.circleSize, height: DatePickerConstants.circleSize)

            // Layer 2: Ring indicator (e.g., yellow ring for today)
            if let ringColor = style.ringColor, style.ringSize > 0 {
                Circle()
                    .stroke(ringColor, lineWidth: style.ringWidth)
                    .frame(width: style.ringSize, height: style.ringSize)
            }

            // Layer 3: Base circle
            Circle()
                .fill(style.baseColor)
                .frame(width: style.baseSize, height: style.baseSize)

            // Layer 4: Highlight/Selection circle (blue for selected, dark for entry)
            if let highlightColor = style.highlightColor {
                Circle()
                    .fill(highlightColor)
                    .frame(width: style.highlightSize, height: style.highlightSize)
            } else if hasEntry, let entryColor = style.entryColor {
                // Entry state when not selected
                Circle()
                    .fill(entryColor)
                    .frame(width: style.highlightSize, height: style.highlightSize)
            }

            // Layer 5: Chat indicator (small dot)
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

// MARK: - Date Picker Row (Shows only bottom row from Date Picker Grid)
struct DatePickerRow: View {
    let dates: [Date]
    @Binding var selectedDate: Date

    @State private var availableWidth: CGFloat = 0
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging = false
    @State private var lastSelectedDate: Date?
    @State private var dynamicSpacing: CGFloat = DatePickerConstants.spacing

    // Check if a date has chat messages (completed)
    private func hasMessagesForDate(_ date: Date) -> Bool {
        let messages = ChatSessionManager.shared.getMessages(for: date)
        return !messages.isEmpty && messages.contains { $0.isUser }
    }

    // Check if a date has an entry created
    private func hasEntryForDate(_ date: Date) -> Bool {
        return DailyContentManager.shared.hasEntry(for: date)
    }

    private func isDateCompleted(_ date: Date) -> Bool {
        return hasMessagesForDate(date)
    }

    private var columns: Int {
        guard availableWidth > 0 else { return 10 } // Default to 10 columns if width not yet calculated

        // Calculate optimal number of columns and spacing
        let minColumns = 7  // Minimum columns we want
        let maxColumns = 14 // Maximum columns for readability

        // Try different column counts to find the best fit
        for cols in (minColumns...maxColumns).reversed() {
            let totalCircleWidth = CGFloat(cols) * DatePickerConstants.circleSize
            let totalSpacingWidth = availableWidth - totalCircleWidth
            let spacingBetween = totalSpacingWidth / CGFloat(cols - 1)

            // If spacing is reasonable (between 8 and 20 points), use this column count
            if spacingBetween >= 8 && spacingBetween <= 20 {
                // Update dynamic spacing for this configuration
                DispatchQueue.main.async {
                    self.dynamicSpacing = spacingBetween
                }
                return cols
            }
        }

        // Fallback: use minimum columns with calculated spacing
        return minColumns
    }

    private var rows: [[Date]] {
        var result: [[Date]] = []
        var currentRow: [Date] = []

        // Force exactly the configured number of rows
        let datesPerRow = (dates.count + DatePickerConstants.numberOfRows - 1) / DatePickerConstants.numberOfRows // Round up division

        for (index, date) in dates.enumerated() {
            currentRow.append(date)
            if currentRow.count == datesPerRow || index == dates.count - 1 {
                result.append(currentRow)
                currentRow = []
            }
        }

        return result
    }

    // Get only the last row (bottom row that contains Today) and adjust to show Today centered
    private var bottomRow: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find today's index in the dates array
        guard let todayIndex = dates.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) else {
            // If today not found, fall back to last row
            let allRows = rows
            return allRows.last ?? []
        }

        // Calculate range: 5 dates before today and 5 dates after today (11 total with today)
        let startIndex = max(0, todayIndex - 5)
        let endIndex = min(dates.count - 1, todayIndex + 5)

        // Extract the range of dates
        return Array(dates[startIndex...endIndex])
    }

    var body: some View {
        HStack(spacing: dynamicSpacing) {
            ForEach(Array(bottomRow.enumerated()), id: \.offset) { index, date in
                DateCircle(
                    date: date,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                    isToday: Calendar.current.isDateInToday(date),
                    isFuture: date > Date(),
                    isCompleted: isDateCompleted(date),
                    hasEntry: hasEntryForDate(date),
                    showDate: false,
                    onTap: {
                        selectedDate = date
                    }
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                // Store the frame for hit testing during drag
                            }
                    }
                )
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size.width)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { width in
            if width > 0 && abs(availableWidth - width) > 1 { // Only update if there's a significant change
                availableWidth = width
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    dragLocation = value.location

                    // Find which date circle contains the drag location
                    let col = Int(value.location.x / (DatePickerConstants.circleSize + dynamicSpacing))

                    if col >= 0 && col < bottomRow.count {
                        let date = bottomRow[col]

                        // Only provide haptic feedback if we're over a new date
                        if lastSelectedDate == nil || !Calendar.current.isDate(lastSelectedDate!, inSameDayAs: date) {
                            // Haptic feedback when selecting a new date
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            lastSelectedDate = date
                        }

                        // Always update the selected date
                        selectedDate = date
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    lastSelectedDate = nil
                }
        )
    }
}
