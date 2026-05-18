---
name: xcode-build
description: Build the DO-iPhone-Proto Xcode project for the iOS Simulator and report compile errors. Use when verifying that Swift edits compile, before claiming a UI/Swift task is done, or when the user asks to "build", "check the build", or "does it compile".
---

# xcode-build

Headlessly build the project and surface compile errors. There is no test target, so a successful build is the closest signal of correctness for Swift edits (the user otherwise has to switch to Xcode and Cmd+R).

## Default command

Run from the repo root (`/Users/paulmayne/Repos/DO-iPhone-Proto`):

```bash
xcodebuild \
  -project DO-iPhone-Proto.xcodeproj \
  -scheme DO-iPhone-Proto \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -configuration Debug \
  -quiet \
  build 2>&1
```

If `xcodebuildmcp` is available as an MCP server, prefer its `build_sim` / `build_run_sim` tools — they cache derived data and stream errors more cleanly.

## Output handling

- **Success** (exit 0, `** BUILD SUCCEEDED **` in output): report `Build OK` and the elapsed wall time. Do not paste the full log.
- **Failure**: grep for lines containing `error:` and present them with their `file:line:col` prefix. Cap at the first 20 errors. Include the offending source snippet only if it clarifies the fix.
- **Warnings**: ignore unless the user asks; SwiftUI views generate a lot of noise.

## Destination fallback

If the default destination is unavailable, retry in this order:

1. `'platform=iOS Simulator,name=iPhone 16'`
2. `'platform=iOS Simulator,name=iPhone 15'`
3. `'generic/platform=iOS Simulator'`

To list available simulators: `xcrun simctl list devices available`.

## When to invoke

- After Edit/Write to a `.swift` file when the user is preparing to test in Xcode.
- When the user says "build", "check it builds", "does it compile", or "any errors".
- Before reporting a non-trivial Swift refactor as complete.

## When NOT to invoke

- Documentation, Markdown, or asset-only edits.
- During exploratory reading (no Swift was changed).
- If the user explicitly asks not to build.
