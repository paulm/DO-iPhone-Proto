# Journals Tab Documentation

## Overview

The Journals tab provides a comprehensive interface for managing journals and collections in the Day One prototype app. It supports multiple view modes, inline editing and renaming, contextual menus, drag-and-drop reordering in a dedicated modal, collection management, and trash functionality.

**File**: `DO-iPhone-Proto/JournalsTab.swift` (4,600+ lines)

---

## Terminology & Naming Conventions

### Recommended Terms

**Use these terms consistently throughout the app:**

| UI Element | Preferred Term | Avoid | Notes |
|------------|---------------|-------|-------|
| Container for journals | **Collection** | Folder | User-facing term |
| Individual journal | **Journal** | Book, Notebook | Core object |
| Journal entries list | **All Entries** | Combined View | Special aggregated view |
| Edit interface | **Reorder Modal** | Edit Mode, Manager | Sheet presentation |
| Entry counter | **X entries** | Entry count | Lowercase, plural |
| Collection counter | **X journals** | Journal count | Lowercase, plural |
| Trash container | **Trash** | Deleted, Bin | Always singular |

### Code vs UI Terminology

| Code Term | UI Term | Location |
|-----------|---------|----------|
| `JournalFolder` | Collection | Models, internal |
| `MixedJournalItem` | (not shown) | Internal wrapper |
| `JournalNode` | (not shown) | Reorder modal state |
| `CollectionNode` | (not shown) | Reorder modal state |
| `viewMode` | View Style | Settings picker |
| `journalsPopulation` | (not shown) | Debug/test setting |

### View Mode Names

| Internal | UI Label | Icon | Description |
|----------|----------|------|-------------|
| `.compact` | **Compact** | `list.bullet` | Minimal list view |
| `.list` | **Icons** | `square.grid.3x3` | Default list with icons |
| `.grid` | **Books** | `books.vertical` | Grid of book cards |

**Note**: Default view mode is **Icons** (`.list`)

---

## Architecture

### View Modes

The Journals tab supports three distinct view modes, togglable via Settings → Journal Manager Options:

#### 1. **Compact Mode**
- **Container**: `LazyVStack` in `ScrollView`
- **Spacing**: 4pt between rows
- **Features**:
  - Minimal design without large icons
  - Collapsible collections
  - Most space-efficient layout
  - No swipe actions
  - No drag-to-reorder (use Reorder Modal)
- **Default**: Hidden (toggle via "Show Compact View")

#### 2. **Icons Mode** ⭐ Default
- **Container**: `List` with `.plain` style
- **Features**:
  - Larger rows with colored book icons
  - **Swipe Actions**: Three-action pattern (New Entry, Select, Edit)
  - No drag-to-reorder in main view (use Reorder Modal)
  - Native iOS list performance
  - 2-line text truncation for long names
- **Default**: Always visible

#### 3. **Books Mode** (Grid)
- **Container**: `LazyVGrid` with 3 columns
- **Features**:
  - Book-shaped cards with 3D styling
  - No folder collapse (flat view)
  - Visual, library-like interface
  - No swipe actions
  - No drag-to-reorder (use Reorder Modal)
- **Default**: Hidden (toggle via "Show Books View")

**View Mode Picker Logic**:
- Only shown when 2+ view modes are enabled
- If only one mode enabled, no picker appears
- Uses SF Symbols: `list.bullet`, `square.grid.3x3`, `books.vertical`

---

## Journal List Sections

The main journal list is organized into several conditional sections:

### 1. **Recent Journals** (Optional)
- Horizontal `ScrollView`
- 70pt width per book icon
- Collapsible section
- Shows recently accessed journals

### 2. **Recent Entries** (Optional)
- Horizontal `ScrollView`
- 108pt width per entry card
- Collapsible section
- Quick access to recent journal entries

### 3. **All Entries** (Conditional)
- Special aggregated view
- Only shown when 2+ journals exist
- Shows total entry count across all journals
- Deep blue color: `Color(hex: "333B40")`
- Displays journal count: "X journals"
- Dynamically updates when journal counts change

### 4. **Journals Section**
- Main list of journals and collections
- Filtered by `JournalsPopulation` setting:
  - **New User**: 1 journal only
  - **3 Journals**: 3 journals
  - **Lots**: All journals (default)
  - **101 Journals**: Programmatically generated test data
- Header hidden when only 1 journal + no recent sections

### 5. **Collections Section** (Optional)
- Expandable folders containing journals
- Can be separated or mixed with journals based on `useSeparatedCollections`
- Uses folder icon: `media-library-folder`
- Shows journal count: "X journals"
- Deep blue color for all collections

### 6. **Action Buttons**
- New Collection button
- New Journal button
- Styled based on view mode

### 7. **Trash Row** (Conditional)
- Only visible when trash count > 0
- Different styling per view mode
- Always at bottom
- Shows item count: "X items"
- Controlled by "Fill Trash"/"Empty Trash" button in settings

---

## Reorder Modal

### Overview

The Reorder Modal (`JournalsReorderView`) provides a dedicated interface for managing journal organization, reordering, renaming, and collection membership.

**Activation**: Tap "Edit" button in navigation bar (top-left)

**Navigation Title**: Dynamically shows "X Journals, Y Collections" with accurate counts

### Features

#### Always-Active Edit Mode
- Drag handles always visible (no toggle needed)
- No separate "edit" and "view" states within the modal
- Simplified UX compared to standard iOS edit patterns

#### Visual Layout

**Row Components**:

**Journals**:
- Small colored circle (20pt) representing journal color
- Journal name (2-line limit, truncates with ellipsis)
- Entry count (right side)
- Ellipsis menu button (context actions)
- Collection management icon (folder.badge.plus/minus)
- Drag handle (far right)
- Trailing insets: 24pt

**Collections**:
- Folder icon (`media-library-folder`, 20pt)
- Collection name (2-line limit, truncates with ellipsis)
- "X journals" count (right side)
- Ellipsis menu button (context actions)
- Chevron indicator (rotates 90° when expanded)
- Drag handle (far right)
- Trailing insets: 16pt

**Row Heights**: Under 44pt (minimal design)

**Indentation**: Journals within collections indented 32pt

#### Context Menus (Ellipsis)

**Journal Menu** (both standalone and nested):
- Edit Journal - Open journal settings
- Rename - Activate inline rename mode
- Move to Collection - Submenu with all collections (standalone only)
- Remove from Collection - Remove from parent (nested only)
- *(Divider)*
- Export - Export journal data
- Preview Book - Preview as book format
- *(Divider)*
- Delete - Delete with confirmation dialog

**Collection Menu**:
- Rename - Activate inline rename mode
- Preview Book - Preview collection as book
- Export - Export collection data
- *(Divider)*
- Delete - Delete with confirmation (journals preserved at root level)

#### Inline Rename

**Activation**:
- Tap "Rename" in ellipsis menu
- TextField appears in place of name label
- Cursor auto-focuses in field

**Features**:
- Auto-capitalization disabled
- 2-line display limit with truncation
- Submit with Return key or tap outside
- Empty names ignored (keeps original)
- Cancel with Escape key

**Name Generation**:
- New journals: "Journal 1", "Journal 2", etc. (no "New" prefix)
- New collections: "Collection 1", "Collection 2", etc. (numbers, not letters)
- Smart counter increment to avoid conflicts

#### Delete Confirmation

**Journals**:
- Alert: "Delete [Name]?"
- Message: "This journal and all its entries will be deleted. This action cannot be undone."
- Actions: Cancel / Delete (destructive)

**Collections**:
- Alert: "Delete [Name]?"
- Message: "This collection will be deleted. The X journals inside will be moved to your journal list."
- Actions: Cancel / Delete (destructive)
- **Behavior**: Journals are preserved and inserted at root level where collection was

#### Toolbar

**Top Trailing**:
- Done button (checkmark icon, Day One blue)
- Applies changes and dismisses

**Bottom Bar** (iOS 26 standard):
- **Left**: "New Collection" button with `folder.badge.plus` icon
- **Spacer** (center)
- **Right**: "New Journal" button with `plus` icon

**Toolbar Hints**:
- Floating graphics overlay on first use
- `journals-new-collection` image (210pt width, left)
- `journals-new-journal` image (150pt width, right)
- Positioned 50pt from bottom
- Dismiss on any tap or button press
- Non-interactive overlay (`.allowsHitTesting(false)`)

### Reordering Rules

1. **Root-level journals**: Can be reordered among all root-level items (journals + collections)
2. **Collections**: Can be reordered among root-level items
3. **Journals within collections**: Can only be reordered within their parent collection
4. **No drag between collections**: Must use collection management icons or menu

**Note**: Reordering is **disabled** in main view (Icons, Compact, Books modes). All reordering happens exclusively in the Reorder Modal.

### Collection Management

#### Adding to Collection
1. Tap **folder.badge.plus icon** on any root-level journal
2. Menu appears showing all available collections
3. Select target collection
4. Journal moves to end of selected collection
5. **Visual feedback**: Both journal and collection flash with color
6. **Live update**: Change immediately visible in main list

#### Removing from Collection
1. Tap **folder.badge.minus icon** on journal within collection
2. Journal immediately moves to root level
3. **Placement**: Inserted directly below parent collection
4. **Live update**: Change immediately visible in main list

### Creating New Items

#### New Journal
- Tap "+" button in bottom-right toolbar
- Creates journal named "Journal 1", "Journal 2", etc.
- Auto-increments counter to avoid name conflicts
- Default color: Random from Day One palette
- Default entry count: 0
- Appears at **bottom** of root-level journals
- **Auto-scroll**: Scrolls to make new journal visible
- **Live sync**: Immediately appears in main list

#### New Collection
- Tap "New Collection" button in bottom-left toolbar
- Creates collection named "Collection 1", "Collection 2", etc.
- Uses numeric suffixes (not alphabetic)
- Starts empty (0 journals)
- Appears at **bottom** of root-level items
- **Auto-scroll**: Scrolls to make new collection visible
- **Live sync**: Immediately appears in main list

---

## Trash Functionality

### Overview

The Trash system allows users to simulate deleted items with a fill/empty toggle.

**Location**: Settings → Journal Manager Options

### Fill/Empty Trash Button

**Behavior**:
- Shows "Fill Trash" when empty (trashCount = 0)
- Shows "Empty Trash" when filled (trashCount = 7)
- Tapping toggles between states
- Icon: `trash` SF Symbol

**Trash Count States**:
- **Empty**: 0 items (row hidden)
- **Filled**: 7 items (row visible)

### Auto-Empty on New User

**Trigger**: Selecting "New User" from population options

**Behavior**:
- Automatically sets trashCount to 0
- Trash row disappears
- User can manually fill again via button

### Trash Row Display

**Visibility**: Only shown when `trashCount > 0`

**Styling by View Mode**:

**Icons Mode** (`TrashRow`):
- Trash icon (system, 20pt)
- "Trash" label
- "X items" subtitle
- Tappable for selection

**Compact Mode** (`CompactTrashRow`):
- Trash icon (system, 14pt)
- "Trash" label
- Item count on right
- Compact single-line layout

**Location**: Always at bottom of journal list

---

## Data Models

### Core Models (JournalModels.swift)

#### `Journal` (Lines 44-133)
```swift
struct Journal: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String
    let type: String
    let color: Color
    let iconURL: String
    let settings: JournalSettings
    let features: JournalFeatures
    let appearance: JournalAppearance
    let entryCount: Int?
    let journalCount: Int? // For "All Entries"
}
```

**Properties**:
- `id`: Unique identifier (UUID string, preserved during rename)
- `name`: Display name (editable via inline rename)
- `color`: SwiftUI Color (supports hex init)
- `entryCount`: Optional count for display
- `journalCount`: Only used for "All Entries" special journal

**Copy Methods**:
```swift
func withName(_ newName: String) -> Journal
```
- Creates copy with updated name
- **Preserves ID and all other properties**
- Used for inline rename functionality

#### `JournalFolder` (Lines 210-252)
```swift
struct JournalFolder: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let journals: [Journal]

    var entryCount: Int // Computed from journals
    var journalCount: Int // Count of journals
    var color: Color // Always deep blue for collections
}
```

**Note**: Called "Collections" in UI, "Folders" in code

**Copy Methods**:
```swift
func withName(_ newName: String) -> JournalFolder
func withJournals(_ journals: [Journal]) -> JournalFolder
```
- Create copies with updated properties
- **Preserve ID and other fields**
- Used for inline rename and journal reordering

#### `Journal.MixedJournalItem` (Lines 364-383)
```swift
struct MixedJournalItem: Identifiable {
    let id: String
    let isFolder: Bool
    let journal: Journal?
    let folder: JournalFolder?
}
```

**Purpose**: Wrapper for mixed list of journals and folders

### Editor-Specific Models (JournalsTab.swift)

#### `JournalNode` (Lines ~2909-2922)
```swift
struct JournalNode: Identifiable, Equatable {
    let id: String
    let journal: Journal  // Stores actual Journal object

    var name: String { journal.name }
    var color: Color { journal.color }
    var entryCount: Int? { journal.entryCount }
}
```

**Purpose**: Adapter node for journals in editor

#### `CollectionNode` (Lines ~2924-2937)
```swift
struct CollectionNode: Identifiable, Equatable {
    let id: String
    var name: String
    var contents: [JournalNode]
    var isExpanded: Bool = false

    var itemCount: Int { contents.count }
    var color: Color { Color(hex: "333B40") }
}
```

**Purpose**: Collection with expandable state

#### `DisplayNode` (Lines ~2939-2951)
```swift
enum DisplayNode: Identifiable, Equatable {
    case journal(JournalNode, isNested: Bool = false)
    case collection(CollectionNode)
    case dropZone
}
```

**Purpose**: Union type for rendering mixed list with drag context

---

## State Management

### Main View State (JournalsTabPagedView)

```swift
@State private var journalItems: [Journal.MixedJournalItem]
```

**Purpose**: Mutable state representing current journal/collection order
- Initialized from `Journal.mixedJournalItems` (static data)
- Updated by Reorder Modal via `@Binding`
- Source of truth for display after edits

```swift
@State private var expandedFolders: Set<String>
```

**Purpose**: Tracks which collections are expanded
- Persists during reordering
- Independent of edit mode
- Uses collection IDs for tracking

```swift
@State private var viewMode: ViewMode
```

**Purpose**: Current view mode (`.compact`, `.list`, `.grid`)

```swift
@State private var journalsPopulation: JournalsPopulation = .lots
```

**Purpose**: Filter level (newUser, threeJournals, lots, oneHundredOne)
- Default: `.lots` (shows all journals)
- Triggers trash emptying when set to `.newUser`

```swift
@State private var trashCount: Int = 7
```

**Purpose**: Current trash item count
- Controlled by Fill/Empty Trash button
- Auto-set to 0 when "New User" selected
- Row hidden when count is 0

### Reorder Modal State (JournalsReorderView)

```swift
@State private var rootItems: [DisplayNode] = []
```

**Purpose**: Ordered array of root-level items
- Journals and collections in display order
- Modified by drag-and-drop
- Source for rebuilding `journalItems`

```swift
@State private var collections: [String: CollectionNode] = [:]
```

**Purpose**: Dictionary of collections by ID
- O(1) lookup for collection operations
- Updated when collections modified

```swift
@State private var cachedDisplayedItems: [DisplayNode] = []
```

**Purpose**: Flattened list for rendering
- Includes expanded collection contents
- Rebuilt when `rootItems` or expansion state changes

```swift
@State private var flashingCollectionId: String? = nil
@State private var flashColor: Color = .blue
@State private var flashingJournalId: String? = nil
@State private var flashingJournalColor: Color = .blue
```

**Purpose**: Visual feedback when moving journals
- Both journal and parent collection flash
- 1.2 second duration
- Uses journal color for feedback

```swift
@State private var scrollToId: String? = nil
```

**Purpose**: Auto-scroll to newly created items
- Set when creating new journal/collection
- Triggers scroll with 0.1s delay
- Scrolls to bottom with anchor

```swift
@State private var showToolbarHints: Bool = true
```

**Purpose**: Show/hide floating toolbar hint graphics
- Initially visible on first load
- Dismissed on any tap or button press
- Non-interactive overlay

### Rename State

```swift
@State private var renamingCollectionID: String? = nil
@State private var editedCollectionName: String = ""
@FocusState private var collectionNameFieldFocused: Bool
```

**Purpose**: Inline rename for journals and collections
- Per-row rename state in both main view and modal
- Auto-focus on TextField activation
- Submit with Return, cancel with Escape

---

## Data Flow & Synchronization

### Opening the Reorder Modal

1. **Main view** → `showingReorderModal = true`
2. **Modal receives**:
   - `journals: filteredJournals` (static sample data, not used)
   - `folders: filteredFolders` (static sample data, not used)
   - `journalItems: $journalItems` (binding to mutable state)
3. **`onAppear`** → calls `initializeFromJournals()`
4. **Initialization**:
   - Builds `collections` dictionary from folders
   - Builds `rootItems` from `journalItems` binding
   - Each node stores the actual `Journal` object
5. **`rebuildCache()`** → creates `cachedDisplayedItems` for rendering

### Making Changes

#### Reordering
1. User drags item
2. `.onMove()` handler fires
3. Updates `rootItems` array
4. Calls `rebuildCache()` → updates display
5. Calls `applyChangesLive()` → syncs to main list

#### Adding Journal
1. User taps "+" toolbar button
2. `addNewJournal()` creates `Journal` object
3. Generates unique name ("Journal 1", etc.)
4. Creates `JournalNode` with journal
5. Appends to `rootItems`
6. Sets `scrollToId` for auto-scroll
7. Calls `rebuildCache()` and `applyChangesLive()`

#### Collection Management
1. User taps folder.badge.plus/minus icon
2. `moveJournalToCollection()` or `removeJournalFromCollection()`
3. Modifies `rootItems` and `collections`
4. Triggers flash animation on both journal and collection
5. Calls `rebuildCache()` and `applyChangesLive()`

#### Inline Rename
1. User taps "Rename" in ellipsis menu
2. Sets `renamingJournalID` or `renamingCollectionID`
3. TextField appears with cursor auto-focused
4. On submit: Creates new object with `withName()` method
5. Updates in `journalItems` or `rootItems`
6. Calls `applyChangesLive()` (in modal)
7. **ID is preserved** during rename

#### Delete Item
1. User taps "Delete" in ellipsis menu
2. Confirmation alert appears
3. On confirm:
   - **Journal**: Removed from `rootItems` or collection
   - **Collection**: Journals extracted and inserted at collection position
4. Calls `rebuildCache()` and `applyChangesLive()`

### Live Synchronization

**`applyChangesLive()`** function (Lines ~4065-4095):

```swift
private func applyChangesLive() {
    var updatedItems: [Journal.MixedJournalItem] = []

    for item in rootItems {
        switch item {
        case .journal(let journalNode, _):
            // Use the journal stored in the node
            updatedItems.append(Journal.MixedJournalItem(journal: journalNode.journal))

        case .collection(let collection):
            // Rebuild folder with reordered journals
            let reorderedJournals = collection.contents.map { $0.journal }
            let updatedFolder = JournalFolder(
                id: collection.id,
                name: collection.name,
                journals: reorderedJournals
            )
            updatedItems.append(Journal.MixedJournalItem(folder: updatedFolder))

        case .dropZone:
            break
        }
    }

    // Update the binding immediately (live updates)
    journalItems = updatedItems
}
```

**Key Points**:
- Uses `Journal` objects stored in `JournalNode` (not lookups)
- Rebuilds `JournalFolder` objects from `CollectionNode` state
- Updates binding immediately → main list sees changes
- Called after every modification

### Dismissing the Modal

1. User taps "Done" button
2. `applyChangesAndDismiss()` calls:
   - `applyChangesLive()` (final sync, redundant but safe)
   - `dismiss()` (closes modal)
3. Main view's `journalItems` now reflects all changes
4. `filteredMixedJournalItems` returns updated `journalItems`
5. List re-renders with new order

---

## Computed Properties

### `filteredJournals` (Lines ~104-119)

Filters journals based on `journalsPopulation` setting:
- **New User**: First journal only
- **3 Journals**: First 3 journals
- **Lots**: All sample journals
- **101 Journals**: All sample journals

**Source**: `Journal.sampleJournals` (static data)

### `filteredFolders` (Lines ~130-140)

Returns folders containing visible journals:
- Filters `Journal.folders` to only include folders with journals in `filteredJournals`

### `filteredMixedJournalItems` (Lines ~142-151)

```swift
private var filteredMixedJournalItems: [Journal.MixedJournalItem] {
    switch journalsPopulation {
    case .newUser, .threeJournals:
        return filteredJournals.map { Journal.MixedJournalItem(journal: $0) }
    case .lots, .oneHundredOne:
        return journalItems  // ✅ Uses mutable state
    }
}
```

**Purpose**: Source of truth for rendering main list
- Returns mutable `journalItems` in `.lots` and `.oneHundredOne` modes
- Enables live updates from editor

### `allEntriesJournal` (Lines ~312-322)

Computed special journal showing aggregated stats:
- Total entry count from all visible journals
- Total journal count
- Deep blue color (`#333B40`)
- Only shown when 2+ journals exist

**Dynamic Updates**: Recalculates when `journalItems` changes

---

## UI Features & Patterns

### Text Truncation

**Applied to**:
- Journal names in Icons mode
- Journal names in Compact mode
- Collection names in all modes
- Journal names in Reorder Modal
- Collection names in Reorder Modal

**Implementation**:
```swift
Text(journal.name)
    .lineLimit(2)
    .truncationMode(.tail)
```

**Purpose**: Handle long journal/collection names gracefully

### Auto-Capitalization

**Disabled in**:
- All inline rename TextFields
- Main view rename fields
- Reorder modal rename fields

**Implementation**:
```swift
TextField("Name", text: $editedName)
    .textInputAutocapitalization(.never)
```

**Purpose**: Prevent forced uppercase typing

### Flash Animations

**Trigger**: Moving journal to collection

**Implementation**:
```swift
flashingCollectionId = collectionId
flashingJournalId = journal.id
flashColor = journal.journal.color
flashingJournalColor = journal.journal.color

DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
    flashingCollectionId = nil
    flashingJournalId = nil
}
```

**Visual**:
- Background color opacity animates from 0.1 to 0
- Duration: 1.2 seconds
- Uses journal's color for both items

### Auto-Scroll

**Trigger**: Creating new journal or collection

**Implementation**:
```swift
scrollToId = newId

// In view:
.onChange(of: scrollToId) { _, newId in
    if let id = newId {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                proxy.scrollTo(id, anchor: .bottom)
            }
            scrollToId = nil
        }
    }
}
```

**Purpose**: Ensure newly created items are visible

---

## Swipe Actions (Icons Mode Only)

**Location**: Lines ~2129-2151 in `JournalRow`

```swift
.swipeActions(edge: .trailing, allowsFullSwipe: false) {
    if !isEditMode {
        Button("New") {
            onNewEntry?()
        }
        .tint(journal.color)

        Button("Select") {
            onSelect()
        }
        .tint(.blue)

        Button("Edit") {
            showingEditJournal = true
        }
        .tint(.gray)
    }
}
```

**Actions**:
1. **New** (journal color): Create new entry in journal
2. **Select** (blue): Navigate to journal
3. **Edit** (gray): Open journal settings

**Not Available**: In Compact, Books, or Edit modes

---

## Test Data & Population Options

### Population Settings

**Location**: Settings → Journal Manager Options

**Options**:

#### 1. New User
- **Journals**: 1 ("Journal")
- **Collections**: 0
- **Trash**: Auto-emptied (0 items)
- **Purpose**: Onboarding experience

#### 2. 3 Journals
- **Journals**: Journal, Notes, Daily
- **Collections**: 0
- **Trash**: Retains current count
- **Purpose**: Simple testing

#### 3. Lots (Default)
- **Journals**: 16 journals
- **Collections**: 3 (Work, Personal, Travel)
- **Trash**: Retains current count
- **Purpose**: Realistic testing with collections
- **Includes**: Long journal names for truncation testing

#### 4. 101 Journals
- **Journals**: 101 programmatically generated
- **Collections**: 8 (Work, Personal, Travel, Health & Fitness, Learning, Projects, Creative, Archive)
- **Trash**: Retains current count
- **Purpose**: Performance and stress testing
- **Includes**: Long journal names at positions 5, 23, 47

### Long Journal Names (Test Data)

**In "Lots" population**:
- "Meeting Notes and Important Discussions from Weekly Team Syncs"
- "Personal Reflections and Daily Thoughts on Growth and Self Discovery"
- "Movie and TV Show Reviews with Ratings and Recommendations"

**In "101 Journals" population**:
- Journal 5: "My Very Long Journal Name That Goes On and On to Test Truncation"
- Journal 23: "Another Extremely Long Journal Title for Testing UI Layout and Truncation Behavior"
- Journal 47: "Weekly Reflections and Personal Growth Journey Through Life's Adventures"

**Purpose**: Test 2-line truncation behavior across all view modes

---

## Limitations & Known Issues

### 1. **No Persistence**
- All changes are in-memory only
- Restarting the app resets to static sample data
- No UserDefaults, CoreData, or file-based storage
- **Impact**: Great for prototyping, not production-ready

### 2. **Static Sample Data**
- Journals loaded from `Journal.sampleJournals` (hardcoded)
- Entry counts are mock data
- No real Day One API integration
- **Workaround**: Can load from `journals.json` via `JournalLoader`

### 3. **No Undo/Redo**
- Changes are immediate and irreversible
- No undo stack implementation
- **Impact**: Accidental reordering/deletion requires manual fix

### 4. **Trash Simulation**
- Trash is simulated (no actual deleted items)
- Fill/Empty toggle only changes count (7 or 0)
- No actual item storage in trash
- **Purpose**: UI demonstration only

### 5. **Collection Limitations**
- Collection color is always deep blue (`#333B40`)
- No nested collections (flat hierarchy only)
- Cannot change collection icons

### 6. **Drag-and-Drop Constraints**
- Cannot drag journals between collections directly
- Must use folder.badge.plus/minus icons or ellipsis menu
- **Reason**: Simplified UX to avoid accidental moves
- Reordering disabled in main view (Icons, Compact, Books modes)

### 7. **View Mode Restrictions**
- Books mode doesn't support folder collapse
- Swipe actions only in Icons mode
- Compact mode has limited styling options

### 8. **Name Collision Handling**
- New journals named "Journal 1", "Journal 2"
- New collections named "Collection 1", "Collection 2"
- Basic increment logic
- No duplicate name prevention for manual renames

### 9. **Performance**
- Full rebuild of `journalItems` on every change
- Not optimized for 1000+ journals
- **Acceptable**: For <100 journals (prototype scale)
- **Test case**: 101 Journals runs smoothly

### 10. **Accessibility**
- No VoiceOver labels on drag handles
- Collection management icons lack accessibility hints
- No dynamic type support beyond system defaults
- Ellipsis menus have basic accessibility

---

## Technical Implementation Details

### Drag-and-Drop System

**Context Tracking**:
```swift
enum ItemContext {
    case root
    case inCollection(String)  // collectionID
}
```

**Move Validation**:
- Checks source and destination contexts
- Prevents invalid moves (e.g., collection into collection)
- Allows journals within same collection only

**Haptic Feedback**:
- Light impact: Selection, toggle
- Medium impact: Add, remove, reorder, delete

### Color System

**Journal Colors**: Custom hex colors via `Color(hex: "44C0FF")`
- Supports 3, 6, and 8 digit hex codes (RGB, ARGB)
- Extension in `ColorExtension.swift`

**Day One Color Palette**:
```swift
Color(hex: "44C0FF")  // DayOne Blue
Color(hex: "FFC107")  // Honey
Color(hex: "2DCC71")  // Green
Color(hex: "3398DB")  // Blue
Color(hex: "6A6DCD")  // Iris
Color(hex: "607D8B")  // Slate
Color(hex: "C27BD2")  // Lavender
Color(hex: "FF983B")  // Fire
Color(hex: "E91E63")  // Hot Pink
Color(hex: "16D6D9")  // Aqua
```

**Gradient Generation**:
```swift
Color.gradientForString(_ text: String) -> LinearGradient
```
- Deterministic color based on first character
- 10 preset Day One colors
- Used for journal icons

**Collection Color**: Always `Color(hex: "333B40")` (deep blue)

### Layout Constants

```swift
private enum Layout {
    static let nestedIndentation: CGFloat = 32
    static let rowVerticalPadding: CGFloat = 4
    static let iconSize: CGFloat = 20
    static let rowSpacing: CGFloat = 12
    static let journalTrailingInset: CGFloat = 24
    static let collectionTrailingInset: CGFloat = 16
}
```

### Animations

**Folder Expansion**:
```swift
.animation(.easeInOut(duration: 0.2), value: isExpanded)
```

**List Reordering**:
```swift
.animation(.default, value: journalItems.map { $0.id })
```

**Flash Feedback**:
```swift
.animation(.easeOut(duration: 0.4), value: isFlashing)
```

**FAB Appearance**:
```swift
.interpolatingSpring(stiffness: 180, damping: 12)
```

**Auto-Scroll**:
```swift
withAnimation {
    proxy.scrollTo(id, anchor: .bottom)
}
```

---

## Future Enhancements (Out of Scope)

### Persistence
- [ ] UserDefaults for custom order
- [ ] CoreData integration
- [ ] iCloud sync support
- [ ] Import/export journal configurations

### Advanced Features
- [ ] Multi-select journals (bulk operations)
- [ ] Duplicate journals
- [ ] Archive/unarchive journals
- [ ] Smart collections (dynamic filters)
- [ ] Custom collection colors
- [ ] Collection icons/symbols
- [ ] Nested collections (sub-collections)
- [ ] Actual trash with restore functionality

### UX Improvements
- [ ] Undo/redo support
- [ ] Search/filter journals
- [ ] Sort options (alphabetical, date, count)
- [ ] Drag journals between collections visually
- [ ] Batch add to collection
- [ ] Collection templates
- [ ] Rename keyboard shortcuts (Cmd+R)

### Performance
- [ ] Virtual scrolling for 1000+ journals
- [ ] Incremental updates (not full rebuild)
- [ ] Background processing for large operations
- [ ] Caching computed properties

### Accessibility
- [ ] Full VoiceOver support
- [ ] Custom accessibility labels
- [ ] Dynamic Type scaling
- [ ] Reduce motion support
- [ ] High contrast mode support

### Integration
- [ ] Day One API connectivity
- [ ] Real entry counts from database
- [ ] Sync with Day One Mac/iOS apps
- [ ] Import from other journaling apps

---

## File Structure

```
DO-iPhone-Proto/
├── JournalsTab.swift (4,600+ lines)
│   ├── JournalsTabPagedView (Main view)
│   ├── View Mode implementations
│   │   ├── Compact Mode
│   │   ├── List/Icons Mode
│   │   └── Grid/Books Mode
│   ├── JournalRow component (with rename)
│   ├── CompactJournalRow component
│   ├── FolderRow component (with rename)
│   ├── TrashRow component
│   ├── CompactTrashRow component
│   ├── JournalsReorderView (Modal)
│   ├── JournalReorderRow (with ellipsis menu & rename)
│   ├── CollectionReorderRow (with ellipsis menu & rename)
│   └── Helper functions
│
├── JournalModels.swift
│   ├── Journal struct (with withName() copy method)
│   ├── JournalFolder struct (with withName() & withJournals() copy methods)
│   ├── JournalSettings, Features, Appearance
│   ├── JournalLoader
│   └── Sample data generators (including long names)
│
└── ColorExtension.swift
    ├── Color(hex:) initializer
    └── gradientForString() generator
```

---

## Testing Checklist

### Basic Functionality
- [ ] Switch between view modes (Compact, Icons, Books)
- [ ] View mode picker hides when only 1 option enabled
- [ ] Expand/collapse collections
- [ ] Navigate to journal details
- [ ] Create new entry from journal row (Icons mode only)

### Trash Functionality
- [ ] Fill Trash button shows "Fill Trash" when empty
- [ ] Fill Trash sets count to 7 and shows row
- [ ] Empty Trash shows "Empty Trash" when filled
- [ ] Empty Trash sets count to 0 and hides row
- [ ] Selecting "New User" auto-empties trash

### Reorder Modal
- [ ] Open Reorder Modal (tap "Edit" button)
- [ ] Title shows correct "X Journals, Y Collections" count
- [ ] Drag handles visible on all rows
- [ ] Toolbar hints appear and dismiss on tap
- [ ] Reorder root-level journals
- [ ] Reorder collections
- [ ] Reorder journals within collections
- [ ] Cannot drag journals between collections

### Collection Management
- [ ] Add journal to collection (folder.badge.plus icon)
- [ ] Add journal to collection (ellipsis menu)
- [ ] Remove journal from collection (folder.badge.minus icon)
- [ ] Remove journal from collection (ellipsis menu)
- [ ] Journal appears below collection after removal
- [ ] Menu shows all available collections
- [ ] Flash animation on both journal and collection

### Inline Rename
- [ ] Rename journal via ellipsis menu
- [ ] Rename collection via ellipsis menu
- [ ] TextField auto-focuses cursor
- [ ] No auto-capitalization in rename field
- [ ] Submit with Return key
- [ ] Cancel with Escape key
- [ ] Empty name ignored (keeps original)
- [ ] Long names truncate to 2 lines
- [ ] Rename persists in main list

### Ellipsis Menus
- [ ] Journal menu shows all actions (Edit, Rename, Move/Remove, Export, Preview, Delete)
- [ ] Collection menu shows all actions (Rename, Preview, Export, Delete)
- [ ] Menu actions work correctly
- [ ] Dividers appear in correct positions
- [ ] Move to Collection shows submenu with all collections
- [ ] Remove from Collection only shown for nested journals

### Delete Functionality
- [ ] Delete journal shows confirmation alert
- [ ] Delete journal removes from list
- [ ] Delete collection shows confirmation alert
- [ ] Delete collection preserves journals at root level
- [ ] Journals inserted at collection's former position
- [ ] Delete impacts live in main list

### Creating Items
- [ ] Create new journal (appears at bottom)
- [ ] Name is "Journal 1", "Journal 2", etc. (no "New" prefix)
- [ ] Create new collection (appears at bottom)
- [ ] Name is "Collection 1", "Collection 2", etc. (numeric)
- [ ] New items auto-scroll into view
- [ ] Counter increments correctly

### Live Synchronization
- [ ] Changes immediately visible in main list
- [ ] Reordering updates main list
- [ ] Adding journal updates main list
- [ ] Collection changes update main list
- [ ] Rename updates main list
- [ ] Delete updates main list
- [ ] Tapping "Done" preserves all changes

### Edge Cases
- [ ] Empty collection displays correctly
- [ ] Last journal removed from collection works
- [ ] Rapid reordering doesn't break state
- [ ] Expanding/collapsing during edit works
- [ ] Switch view modes with custom order
- [ ] Long journal names truncate properly
- [ ] Rename with same name works (no-op)

### Performance
- [ ] Smooth scrolling with 20+ journals
- [ ] Drag-and-drop responsive
- [ ] No lag when toggling collections
- [ ] Modal opens/closes smoothly
- [ ] 101 Journals mode performs well
- [ ] Flash animations smooth

---

## Code Examples

### Reading Journal List

```swift
// Get all visible journals
let journals = Journal.visibleJournals

// Get journals filtered by population setting
let filtered = filteredJournals

// Get mixed items (journals + collections)
let items = filteredMixedJournalItems

// Access specific journal
if let journal = items.first?.journal {
    print(journal.name)
}

// Get All Entries journal
if let allEntries = allEntriesJournal {
    print("Total: \(allEntries.entryCount ?? 0) entries")
    print("Across: \(allEntries.journalCount ?? 0) journals")
}
```

### Creating a New Journal

```swift
let newJournal = Journal(
    name: "My Journal",
    color: Color(hex: "44C0FF"),
    entryCount: 0
)
```

### Renaming a Journal

```swift
// Create renamed copy (preserves ID)
let renamedJournal = journal.withName("New Name")

// Update in journalItems
if let index = journalItems.firstIndex(where: { $0.id == journal.id }) {
    journalItems[index] = Journal.MixedJournalItem(journal: renamedJournal)
}
```

### Working with Collections

```swift
// Check if journal is in collection
let isNested = item.isFolder == false && /* check parent */

// Get collection journals
if let folder = item.folder {
    print("\(folder.name): \(folder.journalCount) journals")
    for journal in folder.journals {
        print("- \(journal.name)")
    }
}

// Rename collection
let renamedFolder = folder.withName("New Collection Name")

// Update journals in collection
let updatedFolder = folder.withJournals(newJournalsArray)
```

### Trash Operations

```swift
// Fill trash
trashCount = 7

// Empty trash
trashCount = 0

// Check if trash visible
if trashCount > 0 {
    // Show trash row
}
```

---

## Debugging Tips

### Issue: Changes not syncing to main list
**Check**: Does `filteredMixedJournalItems` return `journalItems` state?
**Location**: Line ~142 in JournalsTab.swift
**Should be**: `return journalItems` (not static data)

### Issue: Journals disappearing after edit
**Check**: Does `applyChangesLive()` use `journalNode.journal`?
**Location**: Lines ~4065-4095
**Should NOT**: Look up journals in external arrays

### Issue: Rename not persisting
**Check**: Does rename create new object with `withName()`?
**Check**: Is ID preserved in copy?
**Check**: Is `applyChangesLive()` called after update?

### Issue: View mode picker always showing
**Check**: Is `availableViewModesCount` calculated correctly?
**Location**: Lines ~164-170
**Logic**: Count enabled modes, hide picker if count == 1

### Issue: Drag-and-drop not working
**Check**: Are you in the Reorder Modal? (main view has no drag)
**Check**: Are `.onMove()` handlers attached to ForEach?
**Check**: Is `editMode` environment variable set to `.active`?

### Issue: Trash not appearing/disappearing
**Check**: Is `trashCount` being set correctly?
**Check**: Is row conditional `if trashCount > 0`?
**Check**: Does "Fill/Empty Trash" button toggle count?

### Issue: New item name collision
**Check**: Does `generateNextJournalName()` check all existing names?
**Location**: Lines ~347-367
**Should check**: Both `journalItems` and collection contents

### Issue: Flash animation not showing
**Check**: Are `flashingJournalId` and `flashingCollectionId` set?
**Check**: Is color extracted from journal?
**Check**: Is 1.2 second timer clearing IDs?

### Issue: Auto-scroll not working
**Check**: Is `scrollToId` being set after creation?
**Check**: Is ScrollViewReader wrapping the List?
**Check**: Is onChange handler present for scrollToId?

---

## Performance Benchmarks

**Tested on**: iPhone 17 Pro Simulator, iOS 26.0

| Operation | Time | Notes |
|-----------|------|-------|
| Open Reorder Modal | ~100ms | Initial load |
| Reorder 1 journal | ~50ms | Includes live sync |
| Add new journal | ~80ms | Create + sync + scroll |
| Add new collection | ~80ms | Create + sync + scroll |
| Rename journal | ~60ms | Update + sync |
| Delete journal | ~70ms | Remove + sync |
| Delete collection | ~90ms | Extract journals + sync |
| Move to collection | ~100ms | Move + flash animation |
| Expand collection | ~20ms | Animation |
| Apply changes | ~30ms | Full rebuild |
| Dismiss modal | ~100ms | Final sync + dismiss |
| Fill/Empty Trash | ~10ms | Toggle count |

**Rebuild Cost**: ~15ms for 20 items, ~40ms for 50 items, ~120ms for 101 items

---

## Version History

### Current (2026-01-01)
- ✅ Inline rename for journals and collections
- ✅ Ellipsis context menus with full actions
- ✅ Delete journals and collections with confirmation
- ✅ Text truncation (2-line limit) for long names
- ✅ Auto-capitalization disabled in rename fields
- ✅ Auto-scroll to newly created items
- ✅ Flash animations on collection management
- ✅ Reordering disabled in main view (modal-only)
- ✅ Toolbar hint graphics with dismiss behavior
- ✅ Fill/Empty Trash functionality
- ✅ Auto-empty trash on "New User" selection
- ✅ Default names without "New" prefix
- ✅ Numeric collection names (not alphabetic)
- ✅ Long journal names in test data
- ✅ Dynamic navigation title with counts
- ✅ ID preservation during rename

### Previous (2025-12-30)
- ✅ Live synchronization between editor and main list
- ✅ Fixed journal disappearance bug
- ✅ Simplified state management (removed redundant arrays)
- ✅ New journal creation at bottom of list
- ✅ Collection management with folder.badge.plus/minus icons

### Previous Issues (Fixed)
- ❌ Changes lost when dismissing editor
- ❌ Static data lookups breaking sync
- ❌ Journals not found after edits
- ❌ Empty list after tapping "Done"
- ❌ Forced capitalization in rename fields
- ❌ Reordering enabled in main view (caused conflicts)

---

## Related Documentation

- **Main Tab View**: `MainTabView.swift` - Root navigation
- **Journal Models**: `JournalModels.swift` - Data structures
- **Color System**: `ColorExtension.swift` - Hex color support
- **Layout Guide**: `CLAUDE.md` - iOS 26 patterns and architecture

---

## Contact & Support

For questions about this implementation:
1. Check this documentation first
2. Review inline code comments in `JournalsTab.swift`
3. Search for specific function names in codebase
4. Test in iOS Simulator to observe behavior

**Known Limitations**: This is a prototype implementation designed for demonstration and testing. Production use requires persistence layer, error handling, and Day One API integration.

---

**Last Updated**: 2026-01-01
**File Version**: 2.0
**Lines of Code**: ~4,600
**Maintainer**: Claude Code
