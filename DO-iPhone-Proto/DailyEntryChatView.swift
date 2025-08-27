import SwiftUI

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
    @Binding var showingPreviewEntry: Bool  // Shows Chat Entry Preview (summary)
    @Binding var openDailyChatInLogMode: Bool  // Whether to open chat in log mode
    
    // UI configuration
    let showLogVoiceModeButtons: Bool
    
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
    
    /// Determines if Update Entry button should be shown
    /// Only visible when: entry exists AND new messages added AND not currently generating
    private var shouldShowEntryButton: Bool {
        // Only show Update Entry button when entry exists and there are new messages
        // Generate Entry is now shown as a full-width cell above
        return hasEntry && hasNewMessages && !isGeneratingEntry
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
                        Image(systemName: "bubble.left.and.bubble.right")
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
                            showingEntry = true
                        }) {
                            VStack(alignment: .leading, spacing: 8) {

                                
                                // Entry content
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Morning Reflections")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                    
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
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text")
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
                                    Image(systemName: "arrow.triangle.2.circlepath")
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
                    Image(systemName: "bubble.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("Chat About Today")
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
                }
            }
            .tint(Color(hex: "44C0FF"))
        } message: {
            Text("Your update will resummarize parts of the current entry. Do you wish to continue?")
        }
    }
}
