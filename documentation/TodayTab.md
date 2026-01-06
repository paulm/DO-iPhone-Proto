# Today Tab Documentation

## Date Picker Grid

The Date Picker Row is a horizontal scrollable date selector component that provides a timeline view of the user's journaling activity. Despite being called "Date Picker Row" in the code, this section documents its grid-like behavior and visual presentation.

### Overview

**File**: `TodayDatePicker.swift` (lines 480-708)
**Component**: `DatePickerRow`
**Container**: Horizontal ScrollView with auto-scroll behavior

### Purpose

The Date Picker Row serves as a compact, always-visible date navigation control that:
- Displays journaling activity across a 33-day window
- Provides quick access to past and future dates
- Shows at-a-glance statistics (streak, chats, entries)
- Auto-centers on the selected date for optimal viewing

### Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│ [Stats Header] [○][○][●][○][○][⊙][○][○][○]...              │
└─────────────────────────────────────────────────────────────┘
```

**Components** (left to right):
1. **Stats Header** (fixed, scrolls with content)
   - Streak counter
   - Chat count
   - Entry count
   - "View All" button
2. **Date Circles** (scrollable timeline)
   - 30 past days
   - Today (index 30)
   - 2 future days

### Date Range

**Total Dates**: 33 days
**Past**: 30 days before today (indices 0-29)
**Present**: Today (index 30)
**Future**: 2 days after today (indices 31-32)

Generated dynamically using `scrollableDates` computed property (lines 576-599).

### Visual States

Each date circle can display multiple visual states simultaneously:

#### Base States
- **Past Date**: 18pt gray circle (`baseSize: 18`, `baseColor: .gray.opacity(0.15)`)
- **Today**: 18pt gray circle with 22pt gray ring (`ringSize: 22`, `ringWidth: 2`)
- **Future Date**: 8pt small gray circle (`baseSize: 8`)

#### Activity States
- **Has Chat**: 8pt dark indicator dot (`chatIndicatorSize: 8`, color: `#333B40`)
- **Has Entry**: 18pt dark filled circle with white text (`entryColor: #333B40`)
- **Selected**: 22pt blue ring overlay (`ringColor: #44C0FF`)

#### Visual Hierarchy
1. Base circle (gray, size varies by date type)
2. Ring indicator (gray for today, blue for selected)
3. Activity indicator (dot for chat, filled for entry)
4. Date number (8pt font, only shown for today by default)

### Stats Header

**Location**: Left-aligned, scrolls with content
**Format**: `[Streak] • [Chats] • [Entries] • [View All]`

**Metrics** (computed properties):
- `currentStreak` (lines 507-520): Consecutive days with chats, counting backwards from yesterday
- `totalChats` (line 522-524): Count of dates with user chat messages
- `totalEntries` (line 526-528): Count of dates with created entries

**"View All" Button**: Opens full calendar view (`showingChatCalendar = true`)

### Interaction Behavior

#### Tap Gesture
- **Target**: Individual date circles
- **Action**: Select date (`selectedDate = date`)
- **Feedback**: Light haptic impact (`UIImpactFeedbackGenerator(style: .light)`)
- **Side Effect**: Auto-scrolls to center selected date

#### Auto-Scroll Behavior
**Function**: `scrollToSelectedDate(proxy:)` (lines 683-707)

**Trigger Events**:
- Component appears (`.onAppear`)
- Selected date changes (`.onChange(of: selectedDate)`)

**Scroll Logic**:
1. Find selected date index in 33-day range
2. Calculate target: `selectedIndex - 5` (centers date with 5 visible before it)
3. Animate scroll: `.easeInOut(duration: 0.3)`
4. Edge cases:
   - Date before range → scroll to header
   - Date after range → scroll to end
   - Date in range → center with 5-date offset

### Layout Constants

**Source**: `DatePickerConstants` (lines 6-11)

```swift
circleSize: 22          // Hit area size (visual size varies by state)
spacing: 12             // Base spacing (dynamically adjusted)
horizontalPadding: 16   // Left/right margins
```

**Dynamic Spacing**: Calculated at runtime based on available width (lines 489, 545-548)
- Adjusts between 8-20pt to optimize layout
- Ensures consistent appearance across device sizes

### State Management

**Bindings** (passed from parent):
- `selectedDate: Binding<Date>` - Currently selected date
- `showingChatCalendar: Binding<Bool>` - Full calendar modal visibility

**Internal State**:
- `availableWidth: CGFloat` - Container width for layout calculations
- `dynamicSpacing: CGFloat` - Computed spacing between circles
- `lastSelectedDate: Date?` - For drag gesture tracking (unused in current impl)

### Data Integration

**Chat Messages**: `ChatSessionManager.shared.getMessages(for: date)`
- Checks for user messages (`messages.contains { $0.isUser }`)
- Used by `hasMessagesForDate(_ date: Date) -> Bool` (lines 493-496)

**Entries**: `DailyContentManager.shared.hasEntry(for: date)`
- Checks if entry created for date
- Used by `hasEntryForDate(_ date: Date) -> Bool` (lines 499-501)

### Shared Components

**DateCircle** (lines 384-477): Shared with `DatePickerGrid`
- Renders individual date circles
- Handles visual states via `DateCircleStyle` system
- Provides tap interaction and haptic feedback

**DateCircleStyle** (lines 274-382): Configuration struct
- Defines visual properties for each state
- Supports modifier methods (`.selected()`, `.withEntry()`)
- Maintains consistent visual language across components

### Styling System

**Color Palette**:
- Brand Blue: `#44C0FF` (selected ring, "View All" button)
- Dark Gray: `#333B40` (chat indicator, entry fill)
- System Gray: `.gray.opacity(0.15)` (base circles)

**Typography**:
- Stats Text: `.caption` weight `.medium` (secondary foreground)
- Date Numbers: `.system(size: 8)` weight `.medium`

### Performance Considerations

- **Lazy Loading**: Not applicable (fixed 33-date range)
- **Scroll Performance**: Hardware-accelerated ScrollView
- **Haptic Feedback**: Lightweight impact generator
- **Animation**: Single 0.3s easeInOut for scrolling

### Display Toggle

**AppStorage Key**: `"showDatePickerRow"`
**Default**: `true`
**Location**: Settings menu in Today tab toolbar (lines 1896-1904)

**Implementation**:
```swift
@AppStorage("showDatePickerRow") private var showDatePickerRow = true

// Usage in section rendering
if showDatePickerRow {
    DatePickerRow(
        dates: dateRange,
        selectedDate: $selectedDate,
        showingChatCalendar: $showingChatCalendar
    )
}
```

### Related Components

**DatePickerGrid** (lines 20-271): Multi-row grid alternative
- Shows 6 rows of dates
- Non-scrollable, fits on screen
- Stats above grid instead of inline
- Supports drag gesture for quick date selection
- Optional "Today" button for quick navigation

### Design Decisions

1. **33-Day Window**: Balances historical context (30 days) with future planning (2 days)
2. **Stats Position**: Left-aligned to always be visible when scrolling dates
3. **Auto-Center Scroll**: Ensures selected date is always prominently visible
4. **No Drag Selection**: Unlike DatePickerGrid, only supports tap interaction (simpler for horizontal scroll)
5. **Today at Index 30**: Consistent positioning allows predictable scroll behavior

### Accessibility Notes

- Circle hit areas: 22pt × 22pt (meets 44pt minimum when accounting for spacing)
- Semantic color usage (not color-only indicators)
- Date numbers shown for today and when showDate is enabled
- Stats readable with secondary foreground color
- "View All" button provides full calendar alternative

---

**Last Updated**: 2026-01-05
**Component Version**: iOS 26, SwiftUI
