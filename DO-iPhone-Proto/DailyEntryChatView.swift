import SwiftUI

// MARK: - String Extension for Markdown Parsing

private extension String {
    /// Extracts the first H1 heading from Markdown content
    /// Returns the title without the # prefix, or nil if no H1 found
    func extractMarkdownTitle() -> String? {
        let lines = self.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("# ") {
                let title = String(trimmed.dropFirst(2))
                    .trimmingCharacters(in: .whitespaces)
                return title.isEmpty ? nil : title
            }
        }
        return nil
    }
}

// MARK: - Daily Entry Chat View
/// Main view for the Daily Entry Chat section in Today tab
/// Manages three states: no chat, active chat, and entry generated
struct DailyEntryChatView: View {
    // MARK: - Properties
    
    // Date being viewed
    let selectedDate: Date
    
    // Chat state flags
    let chatCompleted: Bool  // True when user has sent at least one message
    let isGeneratingEntry: Bool  // True while AI is generating an entry
    
    // Sheet presentation bindings
    @Binding var showingDailyChat: Bool  // Shows full Daily Chat view
    @Binding var showingEntry: Bool  // Shows Entry view for viewing/editing
    @Binding var entryData: EntryView.EntryData?  // Entry data to pass to EntryView
    @Binding var showingPreviewEntry: Bool  // Shows Chat Entry Preview (summary)
    @Binding var openDailyChatInLogMode: Bool  // Whether to open chat in log mode

    // State for confirmation alert and update process
    @State private var showingUpdateConfirmation = false
    @State private var isUpdatingEntry = false
    
    // MARK: - Computed Properties
    
    /// Check if an entry exists for the selected date
    private var hasEntry: Bool {
        DailyContentManager.shared.hasEntry(for: selectedDate)
    }
    
    /// Check if there are new chat messages since the entry was created
    private var hasNewMessages: Bool {
        DailyContentManager.shared.hasNewMessagesSinceEntry(for: selectedDate)
    }
    
    /// Check if the selected date is today
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    /// Get contextual date string for the button label
    private var chatButtonDateText: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(selectedDate) {
            return "Chat About Today"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Chat About Tomorrow"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Chat About Yesterday"
        } else {
            // Calculate days difference for other dates
            let components = calendar.dateComponents([.day], from: Date(), to: selectedDate)
            let days = components.day ?? 0
            
            if days > 0 {
                // Future dates
                if days == 1 {
                    return "Chat About 1 Day From Now"
                } else if days < 7 {
                    return "Chat About \(days) Days From Now"
                } else if days == 7 {
                    return "Chat About 1 Week From Now"
                } else if days < 14 {
                    return "Chat About \(days) Days From Now"
                } else if days < 30 {
                    let weeks = days / 7
                    return weeks == 1 ? "Chat About 1 Week From Now" : "Chat About \(weeks) Weeks From Now"
                } else if days < 60 {
                    return "Chat About 1 Month From Now"
                } else if days < 365 {
                    let months = days / 30
                    return months == 1 ? "Chat About 1 Month From Now" : "Chat About \(months) Months From Now"
                } else {
                    let years = days / 365
                    return years == 1 ? "Chat About 1 Year From Now" : "Chat About \(years) Years From Now"
                }
            } else {
                // Past dates
                let absDays = abs(days)
                if absDays == 0 {
                    return "Chat About Today"
                } else if absDays == 1 {
                    return "Chat About 1 Day Ago"
                } else if absDays < 7 {
                    return "Chat About \(absDays) Days Ago"
                } else if absDays == 7 {
                    return "Chat About 1 Week Ago"
                } else if absDays < 14 {
                    return "Chat About \(absDays) Days Ago"
                } else if absDays < 30 {
                    let weeks = absDays / 7
                    return weeks == 1 ? "Chat About 1 Week Ago" : "Chat About \(weeks) Weeks Ago"
                } else if absDays < 60 {
                    return "Chat About 1 Month Ago"
                } else if absDays < 365 {
                    let months = absDays / 30
                    return months == 1 ? "Chat About 1 Month Ago" : "Chat About \(months) Months Ago"
                } else {
                    let years = absDays / 365
                    return years == 1 ? "Chat About 1 Year Ago" : "Chat About \(years) Years Ago"
                }
            }
        }
    }
    
    /// Determines if Update Entry button should be shown
    /// Only visible when: entry exists AND new messages added AND not currently generating
    private var shouldShowEntryButton: Bool {
        // Only show Update Entry button when entry exists and there are new messages
        // Generate Entry is now shown as a full-width cell above
        return hasEntry && hasNewMessages && !isGeneratingEntry
    }

    /// Format date to time string for entry data
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    /// Dynamic button text based on current state
    private var entryButtonText: String {
        if hasEntry && hasNewMessages {
            return "Update Entry"
        } else {
            return "Generate Entry"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            // Main conditional: Show different UI based on chat/entry state
            // State 1 & 2: Chat exists OR entry exists - show gray rounded container
            if chatCompleted || hasEntry {
            VStack(spacing: 12) {
                
                // SECTION 1: Last AI Message Preview
                // Shows the most recent AI response from the chat
                // Only visible when chat has messages but helps user remember context
                if chatCompleted {
                    // Fetch all messages for the current date
                    let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                    // Find the last message from AI (not user)
                    let lastAIMessage = messages.last(where: { !$0.isUser })
                    
                    if let lastMessage = lastAIMessage {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(lastMessage.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)  // Truncate to 3 lines for preview
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        // Unique ID forces SwiftUI to refresh when message count changes
                        // This ensures the preview updates after dismissing chat
                        .id("\(selectedDate)-\(messages.count)")
                    }
                }
                
                // SECTION 2: Resume Chat Button
                // Always visible when chat/entry exists - primary action to continue conversation
                Button(action: {
                    showingDailyChat = true
                }) {
                    HStack(spacing: 8) {
                        Image(dayOneIcon: .message)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                        
                        Text("Resume Chat")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "E0DEE5"))  // Light gray background
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(PlainButtonStyle())
                
                // SECTION 3: Entry Display/Generation
                // Shows different content based on whether entry exists
                if hasEntry {
                    // Sub-case A: Entry exists - show preview with metadata
                    VStack(spacing: 0) {
                        // Divider line
                        Divider()
                            .padding(.top, 2)
                            .padding(.bottom, 12)
                        
                        Button(action: {
                            // Set entry data for existing entry first
                            let entryContent = """
# Morning Reflections

Today I started with my usual morning routine, feeling energized and ready for the day ahead. The weather was perfect, with clear blue skies and a gentle breeze. I took some extra time to enjoy my coffee on the balcony, watching the city slowly wake up around me.

I've been thinking a lot about balance lately—how to find more moments of peace in the midst of busy days. This morning felt like a small step in the right direction. Sometimes the best days are the ones where we don't try to do too much, but instead focus on being fully present in each moment.

Later, I went for a walk in the park and noticed how the leaves are just beginning to change colors. Fall has always been my favorite season, and I'm looking forward to the cooler weather ahead. There's something about this time of year that makes me feel reflective and grateful.
"""
                            let data = EntryView.EntryData(
                                title: entryContent.extractMarkdownTitle() ?? "Untitled Entry",
                                content: entryContent,
                                date: selectedDate,
                                time: formatTime(selectedDate)
                            )
                            entryData = data
                            // Small delay to ensure state is propagated
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                showingEntry = true
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 8) {


                                // Entry content
                                VStack(alignment: .leading, spacing: 3) {
                                    // REMOVED: Redundant title display
                                    // Title now only appears in Daily Entry section header

                                    Text("Today I started with my usual morning routine, feeling energized and ready for the day ahead. The weather was perfect...")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                // Metadata row
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
                            .padding(.horizontal, 0)
                            .padding(.bottom, 0)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else if chatCompleted {
                    // Sub-case B: Chat exists but no entry yet - show Generate Entry button
                    Button(action: {
                        if !isGeneratingEntry {
                            // Post notification to TodayView to handle entry generation
                            // This allows for centralized journal selection logic
                            NotificationCenter.default.post(
                                name: NSNotification.Name("TriggerEntryGeneration"),
                                object: selectedDate,
                                userInfo: ["source": "DailyEntryChatView"]
                            )
                        }
                    }) {
                        if isGeneratingEntry {
                            // Loading state: Show progress indicator while generating
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
                            .background(Color.white)
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
                }
                
                // SECTION 4: Update Entry Button
                // Conditionally shown when user has added new messages after creating an entry
                // This allows updating the entry with new chat content
                if shouldShowEntryButton {
                    VStack(spacing: 0) {
                        // Visual separator between entry and update button
                        Divider()
                            .padding(.top, 2)
                            .padding(.bottom, 14)
                        
                        Button(action: {
                            // Show confirmation alert for updating entry
                            showingUpdateConfirmation = true
                        }) {
                            if isUpdatingEntry {
                                // Show loading spinner while updating
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                                    .frame(height: 48)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "44C0FF"))
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                            } else {
                                HStack(spacing: 8) {
                                    Image(dayOneIcon: .loop)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                    
                                    Text(entryButtonText)
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
                        .disabled(isUpdatingEntry)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemGray6))  // Gray container background
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
        } else {
            // State 3: No chat and no entry - show initial "Start Chat" button
            // This is the entry point for users to begin their daily reflection
            Button(action: {
                showingDailyChat = true  // Opens full Daily Chat view
            }) {
                HStack(spacing: 8) {
                    Image(dayOneIcon: .comment)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text(chatButtonDateText)
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
        }
        .alert("Update Journal Entry", isPresented: $showingUpdateConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Update", role: .none) {
                // Start the update process
                isUpdatingEntry = true

                // Simulate update process (replace with actual update logic)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    // Mark entry as updated
                    DailyContentManager.shared.setHasEntry(true, for: selectedDate)

                    // Update the message count to current count
                    let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                    let userMessageCount = messages.filter { $0.isUser }.count
                    DailyContentManager.shared.setEntryMessageCount(userMessageCount, for: selectedDate)

                    // Reset the updating state
                    isUpdatingEntry = false

                    // Post notification to refresh the UI
                    NotificationCenter.default.post(name: NSNotification.Name("DailyEntryUpdatedStatusChanged"), object: selectedDate)

                    // Automatically open the entry after update
                    let entryContent = """
# Morning Reflections

Today started with a beautiful sunrise over the mountains. I took a moment to appreciate the quiet before the day began. The morning light streaming through my window reminded me of how much I value these peaceful moments.
"""
                    let data = EntryView.EntryData(
                        title: entryContent.extractMarkdownTitle() ?? "Untitled Entry",
                        content: entryContent,
                        date: selectedDate,
                        time: formatTime(selectedDate)
                    )
                    entryData = data
                    showingEntry = true
                }
            }
            .tint(Color(hex: "44C0FF"))
        } message: {
            Text("Your update will resummarize parts of the current entry. Do you wish to continue?")
        }
    }
}
