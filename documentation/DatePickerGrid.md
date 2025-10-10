# Date Picker Grid Documentation

## Overview

The Date Picker Grid is a visual calendar component in the Today tab that displays a scrollable grid of date circles, allowing users to quickly navigate between dates and see activity status at a glance.

**Location**: TodayView.swift (lines 56-475)
**Toggle State**: `@State private var showDatePickerGrid = true`

---

## Core Logic

### Date Range Generation

**Code Reference**: TodayView.swift:575-598

The grid dynamically calculates which dates to display based on:
- Screen width (accounting for 16pt horizontal padding on each side)
- Number of columns that fit per row
- Fixed number of rows (6 rows by default)
- Ending point: 4 days in the future

**Algorithm**:
```
1. Calculate available width: Screen width - (16pt × 2)
2. Determine columns per row: width / (circle size + spacing)
3. Calculate total dates needed: columns × 6 rows
4. Work backward from 4 days in future to determine start date
5. Generate date array from start to +4 days from today
```

**Example**: On iPhone with ~340pt available width:
- Columns per row: ~10
- Total dates: 60 (10 × 6)
- Date range: -55 days to +4 days from today

---

## Grid Layout System

### Adaptive Column Calculation

**Code Reference**: DatePickerGrid:119-144

The grid uses a smart layout algorithm to optimize spacing:

**Column Range**: 7-14 columns (minimum to maximum)
**Spacing Range**: 8-20pt (optimal range for readability)

**Algorithm**:
1. Tries column counts from 14 down to 7
2. For each count, calculates required spacing
3. Selects first configuration where spacing falls in 8-20pt range
4. Updates `dynamicSpacing` state to match optimal spacing

**Row Distribution**:
- Fixed 6 rows (configurable via `DatePickerConstants.numberOfRows`)
- Dates evenly distributed across rows
- Uses ceiling division to handle remainders

### Layout Constants

**Code Reference**: DatePickerConstants:56-61

```swift
circleSize: 22pt          // Hit area for each date
spacing: 12pt             // Base spacing (adjusted dynamically to 8-20pt)
numberOfRows: 6           // Number of grid rows
horizontalPadding: 16pt   // Margin on left/right edges
```

---

## Visual Treatment

### Circle Layer Stack

Each date circle is composed of 6 layers (rendered bottom to top):

**Code Reference**: DateCircle:423-475

1. **Spacer Layer** (22pt diameter)
   - Invisible circle (`white.opacity(0.01)`)
   - Provides consistent hit area for all date states

2. **Ring Layer** (22pt diameter, 2pt stroke)
   - Shown for: Today (gray) or Selected (blue #44C0FF)
   - Stroke color varies by state

3. **Base Circle** (variable diameter)
   - Past/Today: 18pt diameter
   - Future: 8pt diameter
   - Fill: `gray.opacity(0.15)`

4. **Highlight/Entry Circle** (18pt diameter)
   - Shown when date has entry: Dark gray #333B40 filled
   - Shown when selected: Blue ring instead of fill

5. **Chat Indicator** (8pt diameter)
   - Small dot in center when date has chat messages
   - Color: #333B40
   - Hidden if date has entry

6. **Date Text** (8pt font)
   - Shows day number (1-31)
   - Medium weight
   - Optional (toggled via "Grid Dates" setting)
   - Color: `.primary` or `.white` (if has entry)

---

## Date States & Styling

### State Priority System

**Code Reference**: DateCircle:398-421

States are applied in this order:
1. Base style (Past/Today/Future)
2. Selected modifier
3. Entry modifier (highest priority)

### Visual Specifications Table

| State | Circle Size | Fill Color | Ring | Chat Indicator | Text Color | Notes |
|-------|-------------|------------|------|----------------|------------|-------|
| **Past** | 18pt | Gray 15% | None | 8pt dot if has chat | Primary | Default for dates before today |
| **Today** | 18pt | Gray 15% | Gray ring (22pt, 2pt) | 8pt dot if has chat | Primary | Always shows date number |
| **Future** | 8pt | Gray 15% | None | None | Secondary | Smaller to de-emphasize |
| **Selected** | Base size | Base color | Blue ring (#44C0FF, 22pt, 2pt) | Inherited | Inherited | Blue ring replaces any existing ring |
| **Has Entry** | 18pt | Dark gray #333B40 | Inherited ring | Hidden | White | Highest priority visual |
| **Has Chat** | Base size | Base color | Inherited ring | 8pt dot #333B40 | Inherited | Hidden if has entry |

### Style Definitions

**Code Reference**: DateCircleStyle:298-380

**Past Style**:
```swift
baseSize: 18pt
baseColor: gray.opacity(0.15)
ringColor: nil
chatIndicatorSize: 8pt
textColor: .primary
showText: false  // Hidden by default
```

**Today Style**:
```swift
baseSize: 18pt
baseColor: gray.opacity(0.15)
ringColor: gray.opacity(0.8)
ringSize: 22pt
ringWidth: 2pt
chatIndicatorSize: 8pt
textColor: .primary
showText: true  // Always visible
```

**Future Style**:
```swift
baseSize: 8pt  // Smaller
baseColor: gray.opacity(0.15)
ringColor: nil
chatIndicatorSize: 8pt
textColor: .secondary
showText: false
```

---

## Interaction Patterns

### Tap Interaction

**Code Reference**: DateCircle:469-473

- Single tap selects the date
- Triggers light haptic feedback
- Updates `selectedDate` binding
- Updates entire Today view content

### Drag Interaction

**Code Reference**: DatePickerGrid:238-267

**Behavior**:
- Drag anywhere on grid to scrub through dates
- Continuous selection as drag moves across circles
- Light haptic feedback on each new date (debounced)
- No haptic if dragging over same date repeatedly

**Algorithm**:
1. Calculate row/column from drag location
2. Map to date in grid array
3. Check if different from last selected
4. Trigger haptic only if new date
5. Update selection

---

## Additional UI Elements

### Streak Badge

**Code Reference**: DatePickerGrid:104-117, 168-177

**Display Logic**:
- Shows "X Day Streak" or "X Days Streak"
- Counts consecutive days backwards from yesterday
- Only counts days with chat messages (user messages)
- Hidden if streak is 0
- Styled: Gray background, rounded pill

**Algorithm**:
```
1. Start from yesterday (not today)
2. Check if date has completed chat
3. If yes: increment streak, check previous day
4. If no: break and return streak count
```

### Today Button

**Code Reference**: DatePickerGrid:181-195

**Display Logic**:
- Only shown when viewing a non-today date
- Tapping navigates back to today
- Styled: Blue background (#44C0FF), white text, rounded pill

**Purpose**: Quick return to current date from past/future dates

---

## Integration & Data Sources

### Chat Status Detection

**Code Reference**: DatePickerGrid:83-86

```swift
ChatSessionManager.shared.getMessages(for: date)
  .filter { $0.isUser }  // Only user messages count
  .isEmpty == false
```

### Entry Status Detection

**Code Reference**: DatePickerGrid:89-91

```swift
DailyContentManager.shared.hasEntry(for: date)
```

### Real-time Updates

**Code Reference**: TodayView.swift:1213

The grid uses `.id(chatUpdateTrigger)` to force refresh when:
- Chat messages are added/updated
- Entries are created
- Any daily content changes

---

## Settings & Toggles

**Accessible via**: Today tab → Top-right menu

### Date Picker Grid Toggle
- **Setting**: `showDatePickerGrid`
- **Default**: `true`
- **Effect**: Shows/hides entire grid component
- **Code**: TodayView.swift:1205-1219

### Grid Dates Toggle
- **Setting**: `showGridDates`
- **Default**: `false`
- **Effect**: Shows/hides day numbers on all circles (except Today, which always shows)
- **Code**: TodayView.swift:1563-1571

---

## Performance Considerations

### Dynamic Width Calculation

**Code Reference**: DatePickerGrid:227-237

Uses `GeometryReader` with `PreferenceKey` to:
1. Measure available width
2. Update state only if change is significant (>1pt)
3. Recalculate optimal columns and spacing
4. Prevent unnecessary re-renders

### Gesture Debouncing

The drag gesture only triggers haptic feedback when moving to a new date, preventing excessive haptic events during continuous dragging.

---

## Color Palette

```swift
Blue (Selected/Today Button): #44C0FF
Dark Gray (Entry/Chat): #333B40
Gray Base: gray.opacity(0.15)
Gray Ring (Today): gray.opacity(0.8)
White (Entry Text): .white
Primary Text: .primary
Secondary Text: .secondary
```

---

## File Structure

```
TodayView.swift
├── DatePickerConstants (lines 56-61)
│   └── Layout constants
├── DatePickerGrid (lines 70-269)
│   ├── State management
│   ├── Data detection methods
│   ├── Layout calculations
│   ├── Streak calculation
│   └── Gesture handling
├── DateCircleStyle (lines 272-380)
│   ├── Base styles (past, today, future)
│   ├── Modifier methods (selected, withEntry)
│   └── Visual specifications
└── DateCircle (lines 382-475)
    ├── Style computation
    └── Layer rendering
```

---

## Future Enhancements

Potential improvements documented in codebase:
- Accessibility labels for VoiceOver
- Keyboard navigation support
- Custom streak rules (e.g., entry-based streaks)
- Animation for state transitions
- Support for marking dates with multiple indicators
