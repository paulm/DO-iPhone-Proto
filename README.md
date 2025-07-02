# Day One iPhone Prototype

A modern iOS journaling app prototype built with SwiftUI, featuring AI-powered daily chat, smart entry generation, and dynamic UI experiments.

## Overview

This prototype reimagines the journaling experience with conversational AI interactions, automated entry creation from chat conversations, and a flexible UI system that allows runtime experimentation with different design approaches.

## Key Features

### 💬 Daily Chat & AI Integration
- **Conversational Journaling** - Chat with AI about your day in a natural, conversational format
- **Smart Entry Generation** - Automatically create journal entries from your chat conversations
- **Chat Modes** - Switch between "Chat" mode for conversations and "Log" mode for quick notes
- **Contextual Prompts** - AI asks relevant follow-up questions based on your responses
- **Update Workflow** - Resume chats and update existing entries with new insights

### 📅 Smart Date Management
- **Visual Date Grid** - See your journaling streak and activity at a glance
- **Activity Indicators** - Days with chat interactions show in dark gray, entries marked with visual indicators
- **Streak Tracking** - Automatic calculation of consecutive journaling days
- **Entry Links** - Quick access to daily entries and "On This Day" memories
- **Haptic Feedback** - Smooth date selection with tactile response

### 📝 Intelligent Entry System
- **Auto-Generation** - Create entries from chat conversations with one tap
- **Entry Preview** - Review and edit AI-generated summaries before saving
- **Update Detection** - System tracks when entries need updates based on new chat messages
- **Direct Access** - Jump straight to entries or preview for editing

### 🎯 Floating Action Buttons (FABs)
- **Context-Aware** - FABs change based on daily activity state
- **Start Daily Chat** - Begin a new conversation for the day
- **Resume Chat** - Continue existing conversations
- **View/Update Entry** - Smart button that appears only when relevant
- **Visual States** - Different colors and text indicate current status

### 📊 Data-Driven Experience
- **JSON Configuration** - Daily data populated from centralized source
- **Entry Counts** - Dynamic display of entries per day
- **Memory Integration** - "On This Day" shows historical entries
- **State Persistence** - Chat sessions and entries saved across app launches

### 🧪 UI Experiments System
- **Runtime Switching** - Change UI layouts without restarting
- **Multiple Variants** - Each section has different design approaches
- **Tab Cycling** - Quick variant switching by tapping active tabs
- **Settings Control** - Fine-grained control over each UI element

### 🎨 Modern UI Components
- **TipKit Integration** - Native iOS tooltips for user guidance
- **Bio Management** - Personal profile integration with daily chats
- **Weather Widget** - Optional weather display for context
- **Entry Links** - Smart buttons that show/hide based on content
- **Adaptive Layouts** - Responsive design for different screen sizes

## Technical Architecture

- **SwiftUI & iOS 17+** - Latest Apple frameworks and design patterns
- **@Observable Macro** - Modern state management
- **Singleton Managers** - ChatSessionManager and DailyContentManager for data
- **NotificationCenter** - Cross-view communication for real-time updates
- **JSON Data Store** - Flexible data population system

## User Experience Flow

1. **Start Your Day** - Open the app to see your journaling history
2. **Begin Chat** - Tap "Start Daily Chat" to begin a conversation
3. **Natural Conversation** - Chat about your day, thoughts, and experiences
4. **Generate Entry** - Create a journal entry from your chat with one tap
5. **Review & Edit** - Preview the generated entry and make adjustments
6. **Track Progress** - See your streak and browse past entries

## Smart Features

- **Contextual FABs** - Buttons appear only when actions are available
- **Loading States** - Visual feedback during entry generation
- **Automatic Opening** - Entries open automatically after creation
- **Update Detection** - System knows when entries need refreshing
- **State Tracking** - Differentiates between chat interactions and generated entries

## Getting Started

1. Open `DO-iPhone-Proto.xcodeproj` in Xcode
2. Build and run on iOS Simulator or device
3. Tap "Start Daily Chat" to begin journaling
4. Explore different UI variants in Settings → Experiments

---

*This prototype demonstrates the future of journaling through AI-powered conversations and intelligent entry management.*