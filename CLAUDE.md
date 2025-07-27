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
