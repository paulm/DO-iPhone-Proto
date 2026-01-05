# Requirements: Journal List and Edit/Reorder Modal

## Document Information
- **Component**: Journals Tab - Regular View & Edit/Reorder Modal
- **File**: `JournalsTab.swift`
- **Last Updated**: 2026-01-04
- **Format**: EARS (Easy Approach to Requirements Syntax)

---

## 1. Overview

This document specifies requirements for the Journals List Regular view and its associated Edit/Reorder modal. The Journals List provides multiple viewing modes for journals and collections, while the Edit/Reorder modal allows users to organize, rename, and manage their journal structure.

---

## 2. Journal List Regular - Main View

### 2.1 View Modes

#### REQ-JL-001: View Mode Selection
**WHEN** the user is viewing the Journals tab
**THEN** the system SHALL provide three view modes:
- Compact Mode (list without icons)
- List Mode (icons mode with swipe actions)
- Grid Mode (books mode with 3-column grid)

#### REQ-JL-002: View Mode Persistence
**WHEN** the user switches view modes
**THEN** the system SHALL persist the selected view mode across app sessions

### 2.2 Population Modes

#### REQ-JL-003: Population Mode Options
**WHEN** the user accesses the population menu
**THEN** the system SHALL provide four population options:
- New User (1 journal)
- 3 Journals
- Lots (full sample data)
- 101 Journals

#### REQ-JL-004: Population State Synchronization
**WHEN** the user selects a population mode
**THEN** the system SHALL:
1. Update the `journalsPopulation` state variable
2. Clear existing `journalItems`
3. Populate `journalItems` with appropriate journals for the selected mode
4. Empty trash when "New User" is selected

#### REQ-JL-005: Population Data Source
**WHEN** displaying journals in any population mode
**THEN** the system SHALL use `journalItems` as the data source (not static sample data)
**WHERE** changes made in the edit modal must reflect immediately in the main list

### 2.3 Display Sections

#### REQ-JL-006: Recent Journals Section
**WHEN** the recent journals toggle is enabled
**THEN** the system SHALL display a horizontal scrolling section of recent journals
**WHERE** each journal is 70pt wide with book-style appearance

#### REQ-JL-007: Recent Entries Section
**WHEN** the recent entries toggle is enabled
**THEN** the system SHALL display a horizontal scrolling section of recent entries
**WHERE** each entry card is 108pt wide

#### REQ-JL-008: All Entries Option
**WHEN** there are 2 or more journals
**THEN** the system SHALL display an "All Entries" aggregated journal option

#### REQ-JL-009: Journals Section
**WHEN** displaying the main journals list
**THEN** the system SHALL:
1. Filter journals based on current population setting
2. Display journals in the selected view mode (compact/list/grid)
3. Show collection folders when population is "Lots" or "101 Journals"
4. Hide collection folders when population is "New User" or "3 Journals"

#### REQ-JL-010: Collections Section
**WHEN** collections exist AND population is "Lots" or "101 Journals"
**THEN** the system SHALL display collections either:
- Mixed with journals (default)
- In a separate section (if `useSeparatedCollections` is enabled)

### 2.4 Layout and Spacing

#### REQ-JL-011: Bottom Padding for FAB
**WHEN** scrolling to the bottom of any journal list view
**THEN** the system SHALL provide 70pt of bottom padding
**WHERE** prevents FAB (floating action button) from overlapping content

#### REQ-JL-012: List Mode Layout
**WHEN** List Mode is active
**THEN** the system SHALL use a `List` container with:
- `.plain` style
- `.scrollContentBackground(.hidden)`
- Custom row insets and backgrounds
- Swipe actions for New/Select/Edit

#### REQ-JL-013: Grid Mode Layout
**WHEN** Grid Mode is active
**THEN** the system SHALL use a `LazyVGrid` with:
- 3 columns using `.flexible()` spacing
- 16pt spacing between columns
- 20pt spacing between rows
- Book-shaped cards with 3D effect

#### REQ-JL-014: Compact Mode Layout
**WHEN** Compact Mode is active
**THEN** the system SHALL use a `LazyVStack` with:
- 4pt spacing between items
- Compact rows without icons
- No swipe actions

### 2.5 Actions

#### REQ-JL-015: New Collection Action
**WHEN** the user taps "New Collection" (toolbar or menu)
**THEN** the system SHALL:
1. Set `shouldAddCollectionOnModalOpen` flag to true
2. Open the Edit/Reorder modal
3. NOT add collection directly to main list

#### REQ-JL-016: Edit Button Action
**WHEN** the user taps the "Edit" button
**THEN** the system SHALL:
1. Open the Edit/Reorder modal
2. Pass current journals, folders, and journalItems binding
3. Pass current population setting
4. NOT set the `shouldAddCollectionOnModalOpen` flag

---

## 3. Journal Edit/Reorder Modal

### 3.1 Modal Opening and Display

#### REQ-EM-001: Modal Presentation
**WHEN** the Edit/Reorder modal is opened
**THEN** the system SHALL:
1. Present as a sheet with `.large` presentation detent
2. Display a visible drag indicator
3. Show "Edit" navigation title (inline display mode)
4. Be in edit mode by default (reorder handles visible)

#### REQ-EM-002: Modal Data Initialization
**WHEN** the modal appears
**THEN** the system SHALL:
1. Call `initializeFromJournals()` to build internal node structure
2. Rebuild cache with `rebuildCache()`
3. Check for helper graphics display conditions
4. Check for new collection auto-add flag

### 3.2 Helper Graphics

#### REQ-EM-003: Helper Graphics Display Conditions
**WHEN** the modal appears
**THEN** the system SHALL display helper graphics IF AND ONLY IF:
1. `journalsPopulation == .newUser` (New User mode is active)
2. Helper graphics have not been shown this session

#### REQ-EM-004: Helper Graphics Content
**WHEN** helper graphics are displayed
**THEN** the system SHALL show:
1. Image "journals-new-collection" (163pt wide, leading padding 56pt)
2. Image "journals-new-journal" (118pt wide, trailing padding 56pt)
3. Positioned at bottom of screen as overlay
4. Non-interactive (`.allowsHitTesting(false)`)

#### REQ-EM-005: Helper Graphics Dismissal
**WHEN** the user taps anywhere on the modal
**THEN** the system SHALL hide the helper graphics
**WHERE** graphics do not reappear for the rest of the session

### 3.3 Row Display and Spacing

#### REQ-EM-006: Journal Row Spacing
**WHEN** displaying journal rows
**THEN** the system SHALL use:
- Row spacing (horizontal): 16pt
- Row vertical padding: 4pt
- Icon size: 12pt
- Nested indentation: 32pt

#### REQ-EM-007: Collection Row Spacing
**WHEN** displaying collection rows
**THEN** the system SHALL use:
- Row spacing (horizontal): 16pt
- Row vertical padding: 8pt
- Icon size: 20pt

#### REQ-EM-008: Modal Bottom Padding
**WHEN** scrolling to the bottom of the modal list
**THEN** the system SHALL provide 70pt of bottom padding
**WHERE** prevents toolbar from overlapping content

### 3.4 Button Hit Areas

#### REQ-EM-009: Ellipsis Menu Hit Area
**WHEN** displaying ellipsis menu buttons (journal and collection rows)
**THEN** the system SHALL:
1. Provide minimum 44x44pt tap target
2. Use `.contentShape(Rectangle())` to make entire frame tappable
3. Maintain visual appearance of icon only

#### REQ-EM-010: Folder Action Buttons Hit Area
**WHEN** displaying add/remove collection buttons (journal rows)
**THEN** the system SHALL:
1. Provide minimum 44x44pt tap target for "folder.badge.plus" button
2. Provide minimum 44x44pt tap target for "folder.badge.minus" button
3. Use `.contentShape(Rectangle())` for full frame tappability

### 3.5 New Collection Workflow

#### REQ-EM-011: Add New Collection Trigger
**WHEN** the modal appears WITH `shouldAddCollectionOnOpen == true`
**THEN** the system SHALL:
1. Call `addNewCollection()` after initialization
2. Reset `shouldAddCollectionOnOpen` to false

#### REQ-EM-012: New Collection Creation
**WHEN** adding a new collection
**THEN** the system SHALL:
1. Generate unique ID using `UUID().uuidString`
2. Generate name "Collection N" where N is next available number
3. Create collection with `isExpanded: true` (expanded by default)
4. Add to `collections` dictionary and `rootItems` array
5. Rebuild cache and apply changes live
6. Set `scrollToId` to new collection ID
7. Set `newlyAddedCollectionId` to new collection ID

#### REQ-EM-013: New Collection Scroll Behavior
**WHEN** a new collection is added
**THEN** the system SHALL:
1. Wait 0.5 seconds after creation
2. Scroll to collection with `.center` anchor
3. Use `.easeInOut(duration: 0.3)` animation
4. Clear `scrollToId` after scroll completes

#### REQ-EM-014: New Collection Auto-Rename
**WHEN** a new collection row appears
**IF** `shouldAutoRename == true` (matches `newlyAddedCollectionId`)
**THEN** the system SHALL:
1. Set `editedName` to empty string (not collection name)
2. Set `isRenaming` to true
3. Wait 0.3 seconds (animation delay)
4. Set `isNameFieldFocused` to true (keyboard appears)

#### REQ-EM-015: New Collection Rename Completion
**WHEN** user submits new collection name
**IF** name is not empty
**THEN** the system SHALL:
1. Call `onRename` callback with new name
2. Clear `newlyAddedCollectionId` flag
3. Exit rename mode

**WHEN** user submits with empty name
**THEN** the system SHALL:
1. Keep generated name (e.g., "Collection 1")
2. Exit rename mode without calling `onRename`

### 3.6 Reordering Operations

#### REQ-EM-016: Journal Reordering
**WHEN** user drags a journal to a new position
**THEN** the system SHALL:
1. Determine move operation type (journal move, add to collection, remove from collection)
2. Update `rootItems` array with new order
3. Rebuild cache
4. Apply changes live to `journalItems` binding
5. Trigger haptic feedback (light impact)

#### REQ-EM-017: Collection Reordering
**WHEN** user drags a collection to a new position
**THEN** the system SHALL:
1. Calculate root index positions (source and destination)
2. Move collection in `rootItems` array
3. Rebuild cache
4. Apply changes live to `journalItems` binding
5. Trigger haptic feedback (light impact)

#### REQ-EM-018: Add Journal to Collection
**WHEN** user drags a journal onto a collection
**THEN** the system SHALL:
1. Remove journal from current location
2. Add journal to target collection's contents
3. Update collection in `collections` dictionary
4. Rebuild cache and apply changes
5. Flash animation on both collection and journal (1.2 seconds)
6. Use journal's color for flash animation

#### REQ-EM-019: Remove Journal from Collection
**WHEN** user taps "Remove from Collection" button
**THEN** the system SHALL:
1. Remove journal from collection's contents
2. Insert journal immediately after collection in root items
3. Update collection in `collections` dictionary
4. Rebuild cache and apply changes
5. Trigger haptic feedback (medium impact)

### 3.7 Rename Operations

#### REQ-EM-020: Journal Rename Trigger
**WHEN** user selects "Rename" from journal menu
**THEN** the system SHALL:
1. Set `editedName` to current journal name
2. Set `isRenaming` to true
3. Set `isNameFieldFocused` to true
4. Display TextField in place of journal name

#### REQ-EM-021: Collection Rename Trigger
**WHEN** user selects "Rename" from collection menu
**THEN** the system SHALL:
1. Set `editedName` to current collection name
2. Set `isRenaming` to true
3. Set `isNameFieldFocused` to true
4. Display TextField in place of collection name

#### REQ-EM-022: Rename Submission
**WHEN** user submits rename (Done button or Enter key)
**IF** `editedName` is not empty
**THEN** the system SHALL:
1. Call appropriate rename function (journal or collection)
2. Update item name in data structure
3. Rebuild cache and apply changes live
4. Exit rename mode

#### REQ-EM-023: Rename Focus Loss
**WHEN** rename TextField loses focus
**IF** `isRenaming == true` AND `editedName` is not empty
**THEN** the system SHALL:
1. Call appropriate rename function
2. Update item name
3. Exit rename mode

### 3.8 Delete Operations

#### REQ-EM-024: Journal Delete
**WHEN** user confirms journal deletion
**THEN** the system SHALL:
1. Find journal in root items or collection contents
2. Remove journal from data structure
3. Rebuild cache and apply changes live
4. Trigger haptic feedback (medium impact)
5. Display confirmation alert before deletion

#### REQ-EM-025: Collection Delete
**WHEN** user confirms collection deletion
**THEN** the system SHALL:
1. Extract all journals from collection
2. Insert journals in root items at collection's position
3. Remove collection from data structures
4. Rebuild cache and apply changes live
5. Trigger haptic feedback (medium impact)
6. Display confirmation alert with journal count

#### REQ-EM-026: Delete Confirmation Messages
**WHEN** delete confirmation alert is displayed
**IF** deleting a collection with journals
**THEN** the alert message SHALL state:
"This collection contains N journal(s). All journals will be preserved and moved out of the collection."

**WHEN** deleting an empty collection
**THEN** the alert message SHALL state:
"Are you sure you want to delete this collection?"

### 3.9 Data Synchronization

#### REQ-EM-027: Live Updates
**WHEN** any change is made (reorder, rename, delete, add)
**THEN** the system SHALL immediately call `applyChangesLive()`
**WHERE** updates the `journalItems` binding in real-time

#### REQ-EM-028: Apply Changes Live Implementation
**WHEN** `applyChangesLive()` is called
**THEN** the system SHALL:
1. Create new array of `MixedJournalItem` from `rootItems`
2. Convert root-level journals to journal items
3. Convert collections to folder items with reordered contents
4. Assign to `journalItems` binding
5. Trigger main view re-render

#### REQ-EM-029: Modal Dismissal
**WHEN** user taps "Done" (checkmark button)
**THEN** the system SHALL:
1. Call `applyChangesLive()` (final sync)
2. Dismiss modal
3. Return to main journals list

### 3.10 Toolbar and Navigation

#### REQ-EM-030: Toolbar Layout
**WHEN** modal is displayed
**THEN** the system SHALL show:
1. Top trailing: "Done" button (checkmark icon) in accent color
2. Bottom bar left: "New Collection" button (folder.badge.plus icon)
3. Bottom bar right: "New Journal" button (plus icon)
4. Buttons use `.titleAndIcon` label style

#### REQ-EM-031: New Journal Button
**WHEN** user taps "New Journal" in modal
**THEN** the system SHALL:
1. Generate unique ID and name "Journal N"
2. Create journal node
3. Add to root items
4. Rebuild cache and apply changes
5. Scroll to new journal (center anchor, 0.5s delay)
6. Hide toolbar hints

#### REQ-EM-032: New Collection Button
**WHEN** user taps "New Collection" in modal
**THEN** the system SHALL:
1. Call `addNewCollection()` (same as REQ-EM-012)
2. Hide toolbar hints

---

## 4. Row Component Specifications

### 4.1 JournalReorderRow

#### REQ-JRR-001: Row Structure
**WHEN** displaying a journal row
**THEN** the system SHALL show (left to right):
1. Circle icon (12pt) in journal color
2. Journal name (TextField if renaming, Text otherwise)
3. Spacer
4. Entry count (secondary text)
5. Ellipsis menu button (44x44pt hit area)
6. Folder badge button (add/remove, 44x44pt hit area)

#### REQ-JRR-002: Nested Journal Indentation
**WHEN** journal is nested in a collection
**THEN** the system SHALL:
1. Add 32pt leading padding
2. Display "folder.badge.minus" button
3. Show journal as indented visually

#### REQ-JRR-003: Standalone Journal Actions
**WHEN** journal is NOT nested in a collection
**THEN** the system SHALL:
1. Display "folder.badge.plus" menu button
2. Menu contains list of all collections
3. Tapping collection moves journal to that collection

#### REQ-JRR-004: Journal Menu Actions
**WHEN** user taps ellipsis menu on journal row
**THEN** the system SHALL display options:
1. Rename (pencil icon)
2. Preview Book (book icon)
3. Export (square.and.arrow.up icon)
4. Delete (trash icon, destructive role)

#### REQ-JRR-005: Double-Tap Rename
**WHEN** user double-taps a journal row
**THEN** the system SHALL trigger rename mode

### 4.2 CollectionReorderRow

#### REQ-CRR-001: Row Structure
**WHEN** displaying a collection row
**THEN** the system SHALL show (left to right):
1. Folder icon (20pt) in collection color
2. Collection name (TextField if renaming, Text otherwise)
3. Spacer
4. Journal count (e.g., "5 Journals", secondary text)
5. Ellipsis menu button (44x44pt hit area)
6. Chevron icon (rotates 90° when expanded)

#### REQ-CRR-002: Collection Expansion
**WHEN** collection is expanded (`isExpanded == true`)
**THEN** the system SHALL:
1. Rotate chevron icon 90 degrees
2. Display nested journals below collection row
3. Apply nested indentation to child journals

#### REQ-CRR-003: Collection Menu Actions
**WHEN** user taps ellipsis menu on collection row
**THEN** the system SHALL display options:
1. Rename (pencil icon)
2. Preview Book (book icon)
3. Export (square.and.arrow.up icon)
4. Divider
5. Delete (trash icon, destructive role)

#### REQ-CRR-004: Collection Tap Behavior
**WHEN** user single-taps a collection row
**THEN** the system SHALL toggle expansion state

#### REQ-CRR-005: Collection Double-Tap Rename
**WHEN** user double-taps a collection row
**THEN** the system SHALL trigger rename mode

---

## 5. Visual Feedback and Animations

### 5.1 Haptic Feedback

#### REQ-VF-001: Light Haptic
**WHEN** user performs reorder operation
**THEN** the system SHALL trigger light impact haptic

#### REQ-VF-002: Medium Haptic
**WHEN** user adds new journal, adds new collection, or deletes item
**THEN** the system SHALL trigger medium impact haptic

### 5.2 Flash Animations

#### REQ-VF-003: Journal Added to Collection Flash
**WHEN** journal is moved into a collection
**THEN** the system SHALL:
1. Flash collection background with journal's color at 10% opacity
2. Flash journal background with journal's color at 10% opacity
3. Animation duration: 1.2 seconds
4. Use `.easeOut(duration: 0.4)` animation

### 5.3 Scroll Animations

#### REQ-VF-004: Scroll to New Item
**WHEN** new journal or collection is created
**THEN** the system SHALL:
1. Wait 0.5 seconds for view to render
2. Scroll to item with `.center` anchor
3. Use `.easeInOut(duration: 0.3)` animation
4. Clear scroll ID after completion

---

## 6. Edge Cases and Constraints

### 6.1 Empty States

#### REQ-EC-001: Empty Modal State
**WHEN** modal has no journals or collections
**THEN** the system SHALL display:
1. Book icon (60pt, secondary color at 50% opacity)
2. Title: "No Journals Yet"
3. Subtitle: "Tap the + button below to create your first journal"

### 6.2 Name Generation

#### REQ-EC-002: Collection Name Generation
**WHEN** generating a new collection name
**THEN** the system SHALL:
1. Check all existing collection names
2. Find first available "Collection N" (starting from 1)
3. Use that name

#### REQ-EC-003: Journal Name Generation
**WHEN** generating a new journal name
**THEN** the system SHALL:
1. Check all existing journal names (root and in collections)
2. Find first available "Journal N" (starting from 1)
3. Use that name

### 6.3 Data Integrity

#### REQ-EC-004: Collection Deletion with Journals
**WHEN** deleting a collection that contains journals
**THEN** the system SHALL:
1. Preserve all journals
2. Move journals to root level
3. Insert at position where collection was
4. Maintain journal order from collection

#### REQ-EC-005: Empty Name Prevention
**WHEN** user attempts to save empty name
**THEN** the system SHALL:
1. NOT call rename function
2. Revert to original name
3. Exit rename mode

---

## 7. Technical Constraints

### 7.1 Performance

#### REQ-TC-001: Cache Rebuilding
**WHEN** any structural change occurs
**THEN** the system SHALL rebuild cache immediately
**WHERE** cache contains flattened display items with expanded states

#### REQ-TC-002: Live Updates
**WHEN** changes are applied
**THEN** the system SHALL update binding synchronously
**WHERE** ensures immediate main view updates

### 7.2 State Management

#### REQ-TC-003: Static Session State
**WHEN** tracking session-based flags
**THEN** the system SHALL use static variables
**WHERE** persists across view instance recreation
**EXAMPLES**:
- `hasShownHelperGraphicsThisSession`
- `hasShownHintsForPopulation`

#### REQ-TC-004: Instance State
**WHEN** tracking view-specific state
**THEN** the system SHALL use `@State` variables
**WHERE** resets when view is recreated
**EXAMPLES**:
- `isRenaming`
- `editedName`
- `showingDeleteConfirmation`

---

## 8. Accessibility and Usability

### 8.1 Touch Targets

#### REQ-AU-001: Minimum Touch Target Size
**WHEN** displaying interactive buttons
**THEN** the system SHALL ensure minimum 44x44pt tap target
**WHERE** meets Apple Human Interface Guidelines

#### REQ-AU-002: Button Visual Consistency
**WHEN** enlarging button hit areas
**THEN** the system SHALL maintain original visual icon size
**WHERE** larger hit area is invisible to user

### 8.2 Keyboard Interaction

#### REQ-AU-003: Text Field Submit
**WHEN** user is editing a name
**THEN** the system SHALL:
1. Accept Enter/Return key as submit
2. Use `.submitLabel(.done)` for keyboard
3. Dismiss keyboard on submit

#### REQ-AU-004: Focus Management
**WHEN** entering rename mode programmatically
**THEN** the system SHALL set `@FocusState` variable
**WHERE** causes keyboard to appear automatically

---

## 9. Integration Points

### 9.1 Main View Integration

#### REQ-INT-001: Modal Data Binding
**WHEN** opening modal
**THEN** the system SHALL pass:
1. `journals`: All current journals (extracted from journalItems)
2. `folders`: All current folders (extracted from journalItems)
3. `$journalItems`: Two-way binding to journal items array
4. `journalsPopulation`: Current population setting
5. `$shouldAddCollectionOnModalOpen`: Flag for auto-add collection

#### REQ-INT-002: Population Mode Sync
**WHEN** population mode changes
**THEN** the system SHALL:
1. Update `journalsPopulation` state in main view
2. Call `repopulateJournals()` with new mode
3. Clear and repopulate `journalItems`
4. Main view re-renders with filtered data

### 9.2 Journal Models Integration

#### REQ-INT-003: Journal Model Usage
**WHEN** working with journals
**THEN** the system SHALL use:
1. `Journal` struct for journal data
2. `JournalFolder` struct for collection data
3. `Journal.MixedJournalItem` enum for mixed lists
4. `JournalNode` for modal's internal representation
5. `CollectionNode` for modal's collection representation

---

## 10. Success Criteria

### 10.1 Functional Success

The implementation SHALL be considered successful when:

1. ✅ All three view modes (compact, list, grid) display correctly
2. ✅ All four population modes work correctly
3. ✅ Changes in edit modal sync to main view for ALL population modes
4. ✅ Helper graphics show only for new users, once per session
5. ✅ New collections auto-expand, auto-scroll, and auto-rename
6. ✅ All buttons have 44x44pt minimum hit areas
7. ✅ 70pt bottom padding prevents FAB overlap
8. ✅ Row spacing is 16pt, vertical padding is 4-8pt
9. ✅ Rename, reorder, delete, and add operations work correctly
10. ✅ Haptic feedback and animations work as specified

### 10.2 User Experience Success

The UX SHALL be considered successful when:

1. ✅ User can create collection and immediately name it (no extra taps)
2. ✅ User can easily tap all buttons without precise aim
3. ✅ User can see all journals when scrolling (no FAB obstruction)
4. ✅ User sees immediate feedback for all actions
5. ✅ New users see helpful hints on first use
6. ✅ Changes made in modal immediately visible in main list

---

## Appendix A: Layout Constants Reference

### Main View
- Recent journal width: 70pt
- Recent entry width: 108pt
- Grid columns: 3
- Grid column spacing: 16pt
- Grid row spacing: 20pt
- List bottom padding: 70pt

### Modal - JournalsReorderView
- Nested indentation: 32pt
- Row vertical padding: 8pt
- Icon size: 20pt
- Row spacing: 16pt
- Bottom safe area inset: 70pt

### Modal - JournalReorderRow
- Icon size: 12pt
- Row spacing: 16pt
- Row vertical padding: 4pt
- Nested indentation: 32pt
- Button hit area: 44x44pt

### Modal - CollectionReorderRow
- Icon size: 20pt
- Row spacing: 16pt
- Row vertical padding: 8pt
- Button hit area: 44x44pt

---

## Appendix B: Color Reference

- Accent color: `#44C0FF` (Day One brand blue)
- Secondary text: System secondary
- Flash animation opacity: 10%
- Helper graphics overlay: 40% black

---

## Appendix C: Animation Timing

- Flash animation: 1.2 seconds total, 0.4s easeOut
- Scroll to item delay: 0.5 seconds
- Scroll animation: 0.3s easeInOut
- Auto-rename keyboard delay: 0.3 seconds
- Chevron rotation: Instant with animation wrapper

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-04 | Initial EARS requirements document |

---

*End of Document*
