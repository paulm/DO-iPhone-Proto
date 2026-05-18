import SwiftUI
import TipKit

extension TodayView {

    // MARK: - Supporting Computed Properties

    var currentEntryTitle: String {
        guard DailyContentManager.shared.hasEntry(for: selectedDate) else {
            return "Daily Entry"
        }

        // Get sample entry content that varies by date
        let entryContent = getSampleEntryContent(for: selectedDate)

        // Extract title from Markdown H1 or use first line
        if let h1Title = entryContent.extractMarkdownTitle() {
            return h1Title
        }

        // Fallback: use first non-empty line
        let firstLine = entryContent.components(separatedBy: .newlines)
            .first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) ?? ""

        return firstLine.isEmpty ? "Untitled Entry" : firstLine
    }

    var currentDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }

    var dailyChatTitle: String {
        return "\(currentDayName) Chat"
    }

    var chatInteractionsText: String {
        if chatMessageCount == 0 {
            return ""
        }
        return "\(chatMessageCount) interaction\(chatMessageCount == 1 ? "" : "s")."
    }

    // MARK: - Daily Chat Section

    // Daily Chat section - collapsible
    @ViewBuilder
    var dailyChatSection: some View {
        // Header
        Section {
            HStack(spacing: 12) {
                // Title
                Text("Daily Chat")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "292F33"))

                Spacer()

                // Primary action button when collapsed
                if !dailyChatExpanded {
                    Button(action: {
                        openDailyChatIfEnabled()
                    }) {
                        Text(chatCompleted ? "Resume Chat" : (Calendar.current.isDateInToday(selectedDate) ? "Chat About Today" : "Start Chat"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(chatCompleted ? Color.primary : Color.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(chatCompleted ? Color(hex: "E0DEE5") : Color(hex: "44C0FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Toggle arrow - always on the far right
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dailyChatExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(dailyChatExpanded ? 90 : 0))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if dailyChatExpanded {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // TipKit tip
                    TipView(journalingTip)
                        .tipViewStyle(CustomJournalingTipViewStyle())
                        .padding(.bottom, 8)

                    // Welcome prompt - only show when no chat has taken place
                    if !chatCompleted && !DailyContentManager.shared.hasEntry(for: selectedDate) {
                        Text(dailyEntryChatPromptText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)
                    }

                    // Chat interface wrapped in gray rounded rectangle
                    VStack(spacing: 12) {
                        // Last AI message preview
                        if chatCompleted {
                            let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                            let lastAIMessage = messages.last(where: { !$0.isUser })

                            if let lastMessage = lastAIMessage {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(lastMessage.content)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .id("\(selectedDate)-\(messages.count)")
                            }
                        }

                        // Resume Chat or Start Chat button
                        Button(action: {
                            openDailyChatIfEnabled()
                        }) {
                            HStack(spacing: 8) {
                                Image(dayOneIcon: chatCompleted ? .message : .comment)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(chatCompleted ? Color.primary : Color.white)

                                Text(chatCompleted ? "Resume Chat" : (Calendar.current.isDateInToday(selectedDate) ? "Chat About Today" : "Start Chat"))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(chatCompleted ? Color.primary : Color.white)
                            }
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(chatCompleted ? Color(hex: "E0DEE5") : Color(hex: "44C0FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            .animation(nil, value: selectedDate)
            .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
            .listRowBackground(showGuides ? Color.green.opacity(0.2) : cellBackgroundColor)
            .listRowSeparator(.hidden)
        }
    }

    // MARK: - Daily Entry Section

    // Daily Entry section - collapsible
    @ViewBuilder
    var dailyEntrySection: some View {
        // Header
        Section {
            HStack(alignment: .top, spacing: 12) {
                // Dynamic title based on entry state
                let hasEntry = DailyContentManager.shared.hasEntry(for: selectedDate)

                if dailyEntryExpanded {
                    // EXPANDED STATE: Multi-line title with wrapping
                    Text(hasEntry ? currentEntryTitle : "Daily Entry")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "292F33"))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    // COLLAPSED STATE: Single-line title with ellipsis
                    Text(hasEntry ? currentEntryTitle : "Daily Entry")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "292F33"))
                        .lineLimit(1)
                }

                Spacer()

                // Contextual buttons when collapsed
                if !dailyEntryExpanded {
                    let hasNewMessages = DailyContentManager.shared.hasNewMessagesSinceEntry(for: selectedDate)

                    // Show only ONE button based on priority: Update Entry > View Entry > Generate Entry
                    if hasEntry && hasNewMessages && !isGeneratingEntry {
                        // Priority 1: Update Entry (when entry exists and there are new messages)
                        Button(action: {
                            NotificationCenter.default.post(
                                name: .triggerEntryGeneration,
                                object: selectedDate
                            )
                        }) {
                            Text("Update Entry")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else if hasEntry {
                        // Priority 2: View Entry (when entry exists but no new messages)
                        Button(action: {
                            let entryContent = getSampleEntryContent(for: selectedDate)
                            let data = EntryView.EntryData(
                                title: entryContent.extractMarkdownTitle() ?? "Untitled Entry",
                                content: entryContent,
                                date: selectedDate,
                                time: formatTime(selectedDate)
                            )
                            entryData = data
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                showingEntry = true
                            }
                        }) {
                            Text("View Entry")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(hex: "44C0FF"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "44C0FF").opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else if chatCompleted {
                        // Priority 3: Generate Entry (when chat exists but no entry)
                        Button(action: {
                            if !isGeneratingEntry {
                                NotificationCenter.default.post(
                                    name: .triggerEntryGeneration,
                                    object: selectedDate
                                )
                            }
                        }) {
                            Text("Generate Entry")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isGeneratingEntry)
                    }
                    // else: No buttons shown when no chat and no entry
                }

                // Toggle arrow - always on the far right
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dailyEntryExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: todayToggleIconSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "44C0FF"), Color(hex: "F3F1F8"))
                        .rotationEffect(.degrees(dailyEntryExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: dailyEntryExpanded)
                }
                .buttonStyle(PlainButtonStyle())
                .animation(nil, value: dailyEntryExpanded)
            }
            .padding(.horizontal, 16)
            .listRowInsets(EdgeInsets(top: todayInterSectionSpacing, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }

        // Content
        if dailyEntryExpanded {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // Entry display or generate button (no gray wrapper)
                    if DailyContentManager.shared.hasEntry(for: selectedDate) {
                        // Entry exists - show preview
                        Button(action: {
                            let entryContent = getSampleEntryContent(for: selectedDate)
                            let data = EntryView.EntryData(
                                title: entryContent.extractMarkdownTitle() ?? "Untitled Entry",
                                content: entryContent,
                                date: selectedDate,
                                time: formatTime(selectedDate)
                            )
                            entryData = data
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                showingEntry = true
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                // REMOVED: Redundant title display
                                // Title now only appears in section header

                                Text("Today I started with my usual morning routine, feeling energized and ready for the day ahead. The weather was perfect...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)

                                HStack(spacing: 4) {
                                    Text("Daily")
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color(hex: "44C0FF"))

                                    Text("•")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)

                                    Text("Salt Lake City, Utah")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)

                                    Text("•")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)

                                    Text("Partly Cloudy 63° - 82°")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Update Entry button if there are new messages
                        if DailyContentManager.shared.hasNewMessagesSinceEntry(for: selectedDate) && !isGeneratingEntry {
                            Button(action: {
                                // Post notification to trigger entry generation
                                NotificationCenter.default.post(
                                    name: .triggerEntryGeneration,
                                    object: selectedDate
                                )
                            }) {
                                HStack(spacing: 8) {
                                    Image(dayOneIcon: .loop)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)

                                    Text("Update Entry")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else if chatCompleted {
                        // Chat exists but no entry - show Generate Entry button
                        Button(action: {
                            if !isGeneratingEntry {
                                NotificationCenter.default.post(
                                    name: .triggerEntryGeneration,
                                    object: selectedDate
                                )
                            }
                        }) {
                            if isGeneratingEntry {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)

                                    Text("Generating...")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            } else {
                                HStack(spacing: 8) {
                                    Image(dayOneIcon: .document)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)

                                    Text("Generate Entry")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "44C0FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isGeneratingEntry)
                    } else {
                        // No chat and no entry - show placeholder
                        Text("Start a chat to generate an entry")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 24)
                    }
                }
            }
            .animation(nil, value: selectedDate)
            .listRowInsets(EdgeInsets(top: todaySectionSpacing, leading: 16, bottom: todaySectionSpacing, trailing: 16))
            .listRowBackground(showGuides ? Color.blue.opacity(0.2) : cellBackgroundColor)
            .listRowSeparator(.hidden)
        }
    }
}
