# Day One iPhone Prototype

A comprehensive iOS journaling app prototype built with SwiftUI, featuring multiple UI experiments and modern design patterns.

## Overview

This prototype explores various approaches to journaling app design, implementing core Day One features with experimental UI variants that can be toggled during runtime.

## Key Features

### 📱 Core Functionality
- **Multiple Journals** - Organize entries across different journals with custom colors
- **Daily Surveys** - Structured prompts for reflection and tracking
- **Moments Tracking** - Capture and categorize daily highlights (locations, events, photos)
- **Activity Trackers** - Monitor mood, energy, stress, and daily activities
- **Writing Prompts** - Curated prompts organized by category with favorites system

### 🧪 Experiments System
- **Live UI Testing** - Switch between different layouts without app restart
- **Multiple Variants** - Each major section has 2-4 different design approaches
- **Global Controls** - Apply variants across all sections or customize individually

### 🎨 UI Variants

#### Today Tab
- **Original** - Card-based layout with date picker
- **Apple Settings** - Grouped sections with completion tracking

#### Journals Tab  
- **Original** - Gradient header with segmented navigation
- **Apple Settings** - Settings-style grouped sections
- **Variant 2** - Dashboard with search, carousels, and statistics
- **Paged** - Standard iOS navigation with journal list

#### Prompts Tab
- **Original** - Gallery layout with prompt cards
- **Apple Settings** - Categorized prompts with preview sections

#### More Tab
- **Original** - Custom layout with quick actions
- **Apple Settings** - Native iOS settings-style interface

## Architecture

- **SwiftUI** - Modern declarative UI framework
- **@Observable** - State management with shared experiment manager
- **Navigation** - Mix of modal sheets and push navigation patterns
- **Experiments** - Runtime UI variant switching system

## Design Principles

- **Consistency** - Shared components and design tokens
- **Accessibility** - Proper labels and touch targets
- **Performance** - Lazy loading and efficient view updates
- **Flexibility** - Easy to add new variants and experiments

## Getting Started

1. Open `DO-iPhone-Proto.xcodeproj` in Xcode
2. Build and run on iOS simulator or device
3. Navigate to **Settings → Experiments** to try different UI variants
4. Tap active tabs to cycle through variants quickly

## Experiment Controls

- **Settings → Experiments** - Full control panel
- **Global Variants** - Apply "Original" or "Apple Settings" to all sections
- **Individual Controls** - Customize each section independently  
- **Tab Cycling** - Tap the active tab to cycle through available variants

---

*This prototype demonstrates modern iOS development patterns and experimental UI approaches for journaling applications.*