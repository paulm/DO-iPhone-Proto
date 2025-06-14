# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Day One iOS prototype built with SwiftUI that explores different UI approaches for journaling apps. The key architectural feature is a runtime experiments system that allows switching between different UI variants without rebuilding the app.

## Build Commands

- **Build & Run**: Open `DO-iPhone-Proto.xcodeproj` in Xcode and use Cmd+R to build and run
- **iOS Simulator**: Build for iOS simulator (requires Xcode installed)
- **Physical Device**: Can be deployed to physical iOS devices through Xcode

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

### UI Patterns
- **Variant Architecture**: Each major view has multiple implementation variants
- **Tab Cycling**: Tap active tab to cycle through UI experiments
- **Modal Navigation**: Mix of sheets and push navigation
- **Color Theming**: Custom Color extension with hex support (`Color(hex: "44C0FF")`)

### Data Models
- **Journal**: Identifiable struct with name, color, and entry count
- **AppSection**: Enum defining experiment-capable app sections
- **ExperimentVariant**: Enum defining available UI variants (Original, Apple Settings, Variant 2, Paged)

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