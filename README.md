# Day One iPhone Prototype

A SwiftUI prototype for Day One that explores AI-driven journaling, smart entry generation from chat, an in-app support chat, and several live UI prototypes used to evaluate alternative layouts before committing.

## Overview

The app is an iOS 26 SwiftUI prototype targeting iPhone. It pairs a polished journaling surface with throwaway UI variants that can be cycled at runtime so design directions can be compared against each other on real data, not in isolated mockups.

## Key Features

### Daily Chat & AI Integration
- **Conversational Journaling** — Chat with the AI about the day in natural language.
- **Smart Entry Generation** — Turn a chat into a journal entry with a single tap; an entry preview is shown before saving.
- **Chat / Log Modes** — Switch between conversational chat and a quick-note log mode.
- **Resume + Update Workflow** — Resume an existing daily chat and surface any new messages that should update the saved entry.

### Today Tab
- Sectioned scroll with date strip, Daily Entry, Daily Chat, Moments, Trackers, Inputs.
- Section ordering and per-section visibility persisted via `@AppStorage`.
- Horizontal swipe on the page navigates between days.

### Journals Tab
- Multiple view modes for browsing journals (list, icon grid, books grid).
- Per-row swipe actions for new entry / select / edit.

### Prompts Tab
- Curated prompts with a journal scope filter.

### More Tab
- Quick-Start capture options, On This Day, Daily Prompt, and recent entries.

### Settings → Support
- In-app help chat with a personalized welcome message that references account context.
- Trending issues as tap-to-send suggestions.
- After two user messages the chat offers to hand the conversation off to a human, clearing the chat and confirming the email it will continue at.
- Browse Guides list with the same top-level categories used by the Day One support guides repo.

## Live UI prototypes (DEBUG only)

Three tabs currently render through a prototype dispatcher that swaps in alternative layouts. A small floating bar at the bottom cycles between variants via left/right chevrons; the bar is compiled out of release builds.

| Tab     | Variants                                                                                                                   | File                          |
|---------|----------------------------------------------------------------------------------------------------------------------------|-------------------------------|
| Today   | A Sectioned scroll · B Hero CTA + chips · C Timeline · D Dashboard grid · E Chat-led · F Calendar workspace · G Story pager | `TodayViewPrototype.swift`    |
| More    | A Stacked cards · B Tabs · C Dashboard grid · D Hero + rows · E Action-led list · F Toolbar + workspace · G Magazine        | `MoreView.swift`              |
| Prompts | A List (current) · B Featured + Grid · C Daily ritual                                                                       | `PromptsView.swift`           |

Selection is stored in `@AppStorage("<tab>PrototypeVariant")`. The shared switcher lives in `PrototypeSwitcher.swift`.

When a variant wins it is folded into the production view and the rest (plus the switcher dispatch) are deleted.

## Technical Architecture

- **SwiftUI on iOS 26** — built against the iOS 26 SDK, using Liquid Glass defaults, the iOS 26 `Tab` API (including the separated `.search` role), and SF Symbols throughout.
- **`@Observable` state managers** — `ChatSessionManager`, `DailyContentManager`, and `DateManager` are `@Observable` singletons that views read directly; SwiftUI invalidates on mutation. A handful of typed `NotificationCenter` names in `Notification+App.swift` remain for cross-view triggers.
- **Day One icon font** — custom SF-Symbol-style icon set used via `Image(dayOneIcon:)`.
- **JSON-backed data** — `journals.json`, `DailyData.json`, and `day-one-colors.json` are loaded on launch.

## Repository conventions

- Project guidance lives in `AGENTS.md`; `CLAUDE.md` is a one-line include of it so the same content is picked up by tools that look for either filename.
- MCP config for the project (context7, cupertino) is versioned at `.mcp.json` so tooling is consistent across machines.
- Day One org repos (`DO-*`, `DayOne-*`) prefer HTTPS over SSH for git operations.

## Getting Started

1. Open `DO-iPhone-Proto.xcodeproj` in Xcode.
2. Build and run on an iOS 26 simulator or device (Cmd+R).
3. Optional headless workflow: with [Flowdeck](https://flowdeck.studio) installed, `flowdeck build` / `flowdeck run` / `flowdeck ui simulator session start` work without arguments — the project is preconfigured.
4. In a DEBUG build, use the floating bar at the bottom of the Today, More, or Prompts tabs to cycle layout variants.

---

*This prototype is a sandbox for design and AI-product exploration. Code under the `*Prototype*` and `Variant` names is intentionally throwaway and will be deleted as decisions land.*
