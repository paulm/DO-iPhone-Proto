# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Day One iOS prototype built with SwiftUI that explores different UI approaches for journaling apps. The key architectural feature is a runtime experiments system that allows switching between different UI variants without rebuilding the app.

**Key Features:**
- AI-powered conversational journaling with chat interface
- Runtime UI experimentation framework
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
- **ExperimentsManager.swift**: Global singleton managing UI variant switching across app sections
- **DO_iPhone_ProtoApp.swift**: App entry point
- **RootViewModel.swift**: Root-level state management

### Experiments System
The app uses an `@Observable` ExperimentsManager singleton to control UI variants:
- Each AppSection can have multiple ExperimentVariant options
- Variants can be switched globally or per-section via Settings → Experiments
- Tab re-selection cycles through available variants for that section
- Available variants are defined per section in `ExperimentsManager.availableVariants(for:)`

### State Management
- Uses SwiftUI's `@Observable` macro for reactive state management
- **ExperimentsManager**: Global UI variant state
- **RootViewModel**: Root-level UI state (modals, sheets)
- **JournalSelectionViewModel**: Journal selection and theming state
- **ChatSessionManager**: Chat message persistence and state
- **DailyContentManager**: Entry and summary tracking
- **DailyDataManager**: JSON data loading and caching

### UI Patterns
- **Variant Architecture**: Each major view has multiple implementation variants
- **Tab Cycling**: Tap active tab to cycle through UI experiments
- **Modal Navigation**: Mix of sheets and push navigation
- **Color Theming**: Custom Color extension with hex support (`Color(hex: "44C0FF")`)

### Data Models
- **Journal**: Full-featured journal with settings, features, and appearance
- **DailyChatMessage**: Chat message with user flag and log mode support
- **DayData**: Daily activity data loaded from JSON
- **AppSection**: Enum defining experiment-capable app sections
- **ExperimentVariant**: Enum defining available UI variants (original, appleSettings, v1i2, paged, grid)

## Layout Architecture

### Overview

The app uses a 4-tab structure with iOS 26 modern patterns. Each tab has distinct layout approaches optimized for different content types.

### Tab 1: Today Tab (TimelineView)

**File:** `TodayView.swift`

**Container Structure:** List with `.plain` style
- Uses `ScrollViewReader` for scroll anchoring
- Custom insets and backgrounds per row
- `.scrollContentBackground(.hidden)` for custom background

**Content Organization:**
- **Reorderable Sections**: Customizable order via `SectionItem.allSections`
  1. Date Navigation - Large date display with prev/next buttons
  2. Date Picker Grid - Multi-row calendar (optional)
  3. Date Picker Row - Single horizontal date row (optional)
  4. Entries - Entry count links and "On This Day" navigation
  5. Daily Entry Chat - AI chat interface with TipKit
  6. Moments - Five sections (Events, Places, Photos, Trackers, Inputs)
  7. Bio - Personal information (optional)

**Notable Features:**
- All sections collapsible via `@AppStorage` flags
- Horizontal swipe gestures for date navigation
- FABs positioned 90pt from bottom (above tab bar)
- Keyboard navigation with arrow keys
- Custom `listRowInsets`, `listRowBackground`, `listRowSeparator(.hidden)`

**Performance:**
- `LazyVStack` for date pickers
- Section-based rendering with IDs
- `chatUpdateTrigger` Boolean for forced refreshes

### Tab 2: Journals Tab (JournalsView)

**File:** `JournalsTab.swift`

**View Modes:** Three distinct modes

#### Compact Mode (List Mode)
- **Container:** `LazyVStack` (spacing: 4) in ScrollView
- Compact journal/folder rows without icons
- Collapsible folder support

#### List Mode (Icons Mode)
- **Container:** `List` with `.plain` style
- Larger rows with colored book icons
- **Swipe Actions:** Three-action pattern (New, Select, Edit)
- Drag-to-reorder in edit mode
- `.scrollContentBackground(.hidden)`

#### Grid Mode (Books Mode)
- **Container:** `LazyVGrid` (3 columns)
- `GridItem(.flexible(), spacing: 16)` × 3
- Book-shaped cards with 3D effect
- No folder collapse - flat view

**Content Organization:**
1. **Recent Journals** (optional, collapsible)
   - Horizontal ScrollView, 70pt width per book
2. **Recent Entries** (optional, collapsible)
   - Horizontal ScrollView, 108pt width per card
3. **All Entries** (conditional, 2+ journals only)
4. **Journals Section**
   - Filtered by `JournalsPopulation` setting
   - Header hidden when only 1 journal + no recent sections
5. **Collections Section** (optional)
   - Expandable folders
   - Separated or mixed based on `useSeparatedCollections`
6. **Action Buttons** (New Collection, New Journal)
7. **Trash Row** (different styling per mode)
8. **TipKit Tips** (progressive onboarding)

**Notable Features:**
- Edit mode with `.onMove()` for reordering
- Folder expansion tracked in `expandedFolders: Set<String>`
- Custom sheet positioning (350pt from top)
- Swipe actions only in List mode
- Conditional ScrollView (List mode doesn't use ScrollView wrapper)

**Performance:**
- Lazy containers for efficient rendering
- Filtered lists based on population
- Conditional section rendering
- `.id()` modifiers for view recreation

### Tab 3: Prompts Tab (PromptsView)

**File:** `PromptsView.swift`

**Container Structure:** List (standard SwiftUI List)
- NavigationStack wrapper
- Two main sections with headers

**Content Organization:**

**Section 1: Today's Prompts**
- `TabView` with `.page` style (carousel)
- Height: 150pt
- 3 prompt cards with Day One brand colors
- Serif font (19pt, thin weight)
- Custom page indicator dots
- Category name centered below

**Section 2: Prompt Packs**
- **Saved Packs** (conditional subsection)
- **Prompt Packs** (remaining unsaved)
- Row structure: Icon + Title + Subtitle
- Subtitle shows: "✓ Saved" and/or "X Answered"

**State Tracking:**
- `savedPacks: Set<String>`
- `answeredCounts: [String: Int]`
- `currentPromptIndex` for carousel

**Performance:**
- Simple list structure
- TabView for efficient paging
- Computed filtered lists (not stored state)

### Tab 4: More Tab (MoreView)

**File:** `MoreView.swift`

**Container Structure:** ScrollView with VStack
- VStack spacing: 32pt between sections
- No List container - custom card-based layout

**Content Organization:**

**Three Collapsible Sections:**

1. **Quick Start**
   - Horizontal `ScrollView` with 8 options
   - HStack spacing: 8pt
   - Options: Photos, Audio, Today, Templates, Chat, Video, Draw, Scan Text
   - Each option: 80pt width, icon + text
   - First item: 20pt leading padding

2. **On This Day**
   - Title + date subtitle
   - Empty state message
   - Year buttons (2024, 2023, 2022)
   - Selected year highlighted in blue

3. **Daily Prompt**
   - Card with gray background
   - Centered prompt question
   - "Answer prompt" + Shuffle buttons

**Collapsible Implementation:**
- All sections expandable/collapsible
- Chevron rotates 90° when expanded
- `.easeInOut(duration: 0.2)` animation
- State: `quickStartExpanded`, `onThisDayExpanded`, `dailyPromptExpanded`

**Layout Patterns:**
- Clean card-based design
- No dividers or separators
- Consistent 16pt horizontal padding
- Brand color `Color(hex: "44C0FF")` for actions

### Architecture Summary

#### Container Strategy by Tab

| Tab | Primary Container | Reason |
|-----|------------------|--------|
| Today | List | Dynamic sections, custom backgrounds, reorderable |
| Journals | Mixed | Three view modes require different layouts |
| Prompts | List | Standard sections, simple structure |
| More | ScrollView | Fixed cards, no list features needed |

#### Performance Patterns

**Lazy Loading:**
- **Today:** `LazyVStack` for date pickers
- **Journals:** `LazyVStack` and `LazyVGrid` for journal lists
- **Prompts:** Standard List (small dataset)
- **More:** No lazy loading (minimal content)

**State Management:**
- All tabs use `@State` for local UI state
- Journals uses `@Environment` for `JournalSelectionViewModel`
- Today syncs with `DateManager.shared`

**Refresh Strategies:**
- **Today:** `chatUpdateTrigger` Boolean toggle
- **Journals:** `.id()` modifiers on toggleable views
- **Prompts:** Computed filtered lists
- **More:** Static content (no refresh)

#### Common Patterns Across All Tabs

1. **Navigation:** All wrapped in `NavigationStack`
2. **Toolbar:** Profile avatar menu (PM badge) top-right
3. **Settings:** Sheet modal for app settings
4. **Color:** Brand color `Color(hex: "44C0FF")`
5. **Typography:** SF Pro with semantic sizing

#### List vs LazyVStack Decision Matrix

**Use List when:**
- Need swipe actions (`.swipeActions()` is List-exclusive)
- Maximum performance for large datasets (10x faster)
- Accessibility is priority
- Standard list UI patterns

**Use LazyVStack when:**
- Need custom layouts
- Horizontal scrolling (use `LazyHStack`)
- Complex spacing or backgrounds
- Precise control over every aspect

**Current Usage:**
- **List:** Today (sections), Journals (Icons mode), Prompts
- **LazyVStack:** Journals (Compact mode)
- **LazyVGrid:** Journals (Grid mode)
- **ScrollView:** More tab, horizontal sections

#### iOS 26 List Patterns

```swift
// Journals Icons mode - List with swipe actions
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

**Key Modifiers:**
- `.listStyle(.plain)` - Remove grouped styling
- `.scrollContentBackground(.hidden)` - Custom backgrounds
- `.listRowInsets(EdgeInsets())` - Remove default padding
- `.listRowSeparator(.hidden)` - Custom dividers
- `.swipeActions()` - Native swipe gestures (List-only)

## Key Files Structure

```
DO-iPhone-Proto/
├── MainTabView.swift           # Root tab navigation
├── ExperimentsManager.swift    # UI variant management system
├── RootViewModel.swift         # Root state management
├── JournalSelectionViewModel.swift # Journal selection logic
├── ColorExtension.swift        # Custom color utilities
├── TodayView.swift            # Today tab variants
├── JournalsView.swift         # Journals tab variants  
├── PromptsView.swift          # Prompts tab variants
├── MoreView.swift             # More tab variants
└── *TabVariants.swift         # Variant implementations per section
```

## Development Workflow

1. **Adding New UI Variants**: 
   - Add variant to `ExperimentVariant` enum
   - Update `ExperimentsManager.availableVariants(for:)` for target sections
   - Implement variant logic in respective view files

2. **Adding New Sections**: 
   - Add to `AppSection` enum
   - Define available variants in ExperimentsManager
   - Implement view with variant switching logic

3. **Testing Experiments**: 
   - Use Settings → Experiments for full control
   - Tap active tabs to quickly cycle variants
   - Global variants apply to all compatible sections

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
- Data is loaded on app launch by respective managers
- NotificationCenter broadcasts updates across views

## Common Development Tasks

### Running the App
1. Open `DO-iPhone-Proto.xcodeproj` in Xcode
2. Select target device (Simulator or physical device)
3. Press Cmd+R or click the Run button
4. For debugging: Use Xcode's debug console and breakpoints

### Working with Experiments
- To add a new variant: Update `ExperimentVariant` enum in ExperimentsManager.swift
- To enable variant for a section: Modify `availableVariants(for:)` method
- Default variants set in `ExperimentsManager.init()`
- User can override via Settings → Experiments

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
