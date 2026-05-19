# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Day One iOS prototype built with SwiftUI that explores different UI approaches for journaling apps.

**Key Features:**
- AI-powered conversational journaling with chat interface
- Modern SwiftUI architecture targeting iOS 18.5+
- TipKit integration for user guidance

**Development Guidelines:**
- Build all functionality using SwiftUI patterns
- Follow Apple Human Interface Guidelines for iOS
- Use SF Symbols for consistent iconography
- Target iOS 18.5+ with modern Swift features
- Use `@Observable` macro for state management
- Leverage Swift concurrency (async/await) where applicable


## Build Commands

- **Build & Run**: Open `DO-iPhone-Proto.xcodeproj` in Xcode and use Cmd+R to build and run
- **iOS Simulator**: Build for iOS simulator (requires Xcode installed)
- **Physical Device**: Can be deployed to physical iOS devices through Xcode
- **Clean Build**: In Xcode, use Product → Clean Build Folder (Shift+Cmd+K)
- **Run Tests**: No test targets currently configured

## Architecture

### Core Components
- **MainTabView.swift**: Root tab navigation with 4 main sections (Today, Journals, Prompts, More)
- **DO_iPhone_ProtoApp.swift**: App entry point
- **RootViewModel.swift**: Root-level state management

### State Management
- Uses SwiftUI's `@Observable` macro for reactive state management
- **RootViewModel**: Root-level UI state (modals, sheets)
- **JournalSelectionViewModel**: Journal selection and theming state
- **ChatSessionManager**: Chat message persistence and state
- **DailyContentManager**: Entry and summary tracking

### UI Patterns
- **Modal Navigation**: Mix of sheets and push navigation
- **Color Theming**: Custom Color extension with hex support (`Color(hex: "44C0FF")`)

### Data Models
- **Journal**: Full-featured journal with settings, features, and appearance
- **DailyChatMessage**: Chat message with user flag and log mode support
- **DayData**: Daily activity data loaded from JSON

## Layout Architecture

Four-tab structure with iOS 26 modern patterns. Each tab picks its primary container based on what it needs:

| Tab | Primary File | Container | Reason |
|---|---|---|---|
| Today | `TodayView.swift` | `List` (.plain) | Reorderable sections, custom backgrounds |
| Journals | `JournalsTab.swift` | Mixed: `List` + `LazyVGrid` | Multiple view modes (icons, grid) |
| Prompts | `PromptsView.swift` | `List` | Simple section structure |
| More | `MoreView.swift` | `ScrollView` + `VStack` | Fixed cards |

For detailed per-tab specs (content organization, sub-sections, state tracking), see:
- `docs/JournalsTab.md` and `docs/requirements-journals-list-and-edit-modal.md`
- `documentation/TodayTab.md` and `documentation/DatePickerGrid.md`

### Cross-tab patterns

- Every tab wrapped in `NavigationStack`.
- Brand color `Color(hex: "44C0FF")`; SF Pro typography.
- Toolbar profile avatar menu top-right; settings via sheet modal.
- Manager state (`ChatSessionManager`, `DailyContentManager`, `DateManager`) is `@Observable`; views read it directly and SwiftUI invalidates on mutation. Notification names are typed via `Notification+App.swift` extensions.

### List vs LazyVStack

Use `List` when you need swipe actions (`.swipeActions()` is List-only) or maximum performance for large datasets. Use `LazyVStack`/`LazyVGrid` for custom layouts or horizontal scrolling. Current footprint:

- **List**: Today sections, Journals icons mode, Prompts
- **LazyVGrid**: Journals grid (books) mode
- **ScrollView + VStack**: More tab, all horizontal sections

### iOS 26 List pattern (canonical example)

```swift
List {
    ForEach(journals) { journal in
        JournalRow(journal: journal)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button("New") { }.tint(journal.color)
                Button("Select") { }.tint(.blue)
                Button("Edit") { }.tint(.gray)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
}
.listStyle(.plain)
.scrollContentBackground(.hidden)
```

## Key Files Structure

```
DO-iPhone-Proto/
├── DO_iPhone_ProtoApp.swift        # App entry point
├── MainTabView.swift               # Root tab navigation
├── RootViewModel.swift             # Root state management
├── JournalSelectionViewModel.swift # Journal selection logic
├── ColorExtension.swift            # Custom color utilities
├── BrandColors.swift               # Day One brand palette
├── TodayView.swift                 # Today tab
├── Today*.swift                    # Today tab supporting views and models
├── JournalsView.swift              # Journals tab
├── JournalsTab.swift               # Journals tab content
├── PromptsView.swift               # Prompts tab
├── PromptsTabVariants.swift        # Prompts tab variant layouts
├── MoreView.swift                  # More tab
├── ChatSessionManager.swift        # Chat persistence (referenced from many files)
├── DailyContentManager.swift       # Entry/summary tracking
├── DateManager.swift               # Current-date singleton
└── *.json                          # journals.json, DailyData.json, day-one-colors.json
```

## AI Chat Features

The app includes an AI-powered journaling chat system:
- **Chat Modes**: Toggle between "Chat" (conversational) and "Log" (quick notes) modes
- **Entry Generation**: Creates journal entries from chat conversations
- **Resume Functionality**: Continue existing chats with context
- **Update Detection**: Detects new messages after entry creation and prompts for updates
- **Floating Action Button**: Context-aware FAB changes state based on chat/entry status

### Chat Implementation Details
- **ChatSessionManager**: Singleton managing chat persistence and state
- **DailyContentManager**: Tracks entries and summaries per date
- **Message Model**: `DailyChatMessage` with user flag and chat mode
- **Entry Workflow**: Chat → Generate Summary → Create Entry → Track Updates

## Data Sources

- **DailyData.json**: Provides daily activity data (steps, water, calories, etc.)
- **journals.json**: Journal configuration and sample data
- Data is loaded on app launch by respective managers (`@Observable` singletons; views read state directly and SwiftUI invalidates on mutation)
- A handful of typed NotificationCenter names remain for cross-view triggers (see `Notification+App.swift`): `.triggerDailyChat`, `.openEntryView`, `.triggerEntryGeneration`, `.sectionOrderChanged`, `.dataPopulationChanged`, `.selectedDateChanged`, `.summaryGeneratedStatusChanged`, `.dailyEntryCreatedStatusChanged`

## Common Development Tasks

### Running the App
1. Open `DO-iPhone-Proto.xcodeproj` in Xcode
2. Select target device (Simulator or physical device)
3. Press Cmd+R or click the Run button
4. For debugging: Use Xcode's debug console and breakpoints
5. For headless build, run, test, simulator, and UI-automation tasks, use the `flowdeck` skill. The project is preconfigured (`flowdeck config get`) so bare commands work: `flowdeck build`, `flowdeck run`, `flowdeck test`. The skill also covers UI automation (`flowdeck ui simulator session/tap/swipe/...`) so Claude can visually verify changes in the simulator without round-tripping through Xcode.

### Modifying Chat Features
- Chat messages stored in `ChatSessionManager.messages`
- Entry generation logic in chat view's `generateEntry()` method
- FAB states determined by checking `hasChat`, `hasEntry`, and `hasNewMessages`
- Update detection compares message counts before/after entry creation

## iOS 26 Standards and Patterns

### Liquid Glass Design System
iOS 26 introduces the Liquid Glass design language with:
- Fluid, translucent aesthetic for all interface elements
- Glassy appearance for tab bars, toolbars, and navigation containers
- Elements that reflect content around them
- Automatic visual enhancement when compiled with iOS 26 SDK

### Key iOS 26 UI Patterns

#### 1. Confirmation Actions and Toolbars
```swift
.toolbar {
    ToolbarItem(placement: .confirmationAction) {
        Button("Done", systemImage: "checkmark") { }
        // Gets automatic glassProminent style in iOS 26
    }
}
```

#### 2. Sheet Presentations
iOS 26 sheets use Liquid Glass backgrounds and float above the interface:
```swift
.sheet(isPresented: $showingSheet) {
    ContentView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
}
```
- Partial height sheets don't touch screen edges
- Background interaction allows touching content behind half sheets
- When expanded to `.large`, background becomes opaque

#### 3. Symbol-Based Design
iOS 26 emphasizes moving from text-based to symbol-based toolbar items:
```swift
// iOS 26 recommended
Button("Action", systemImage: "symbol.name") { }
    .labelStyle(.titleAndIcon)
```

#### 4. Tinting with Liquid Glass
```swift
.tint(.blue) // Gets automatic Liquid Glass treatment
```

#### 5. Navigation Components
- NavigationStack with inline title display mode
- ToolbarItemGroup for grouping related items
- Standard placements: `.confirmationAction`, `.cancellationAction`

### Important iOS 26 Notes
- Always refer to this as "iOS 26" not "iOS 16"
- Liquid Glass effects are automatic when using standard components
- Symbol-based buttons are preferred over text-only buttons
- Use `.presentationBackgroundInteraction(.enabled(upThrough: .medium))` for half sheets
