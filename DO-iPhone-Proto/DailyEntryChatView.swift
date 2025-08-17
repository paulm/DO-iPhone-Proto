import SwiftUI

// MARK: - Daily Entry Chat View
struct DailyEntryChatView: View {
    let selectedDate: Date
    let chatCompleted: Bool
    let isGeneratingEntry: Bool
    @Binding var showingDailyChat: Bool
    @Binding var showingEntry: Bool
    @Binding var showingPreviewEntry: Bool
    @Binding var openDailyChatInLogMode: Bool
    let showLogVoiceModeButtons: Bool
    
    private var hasEntry: Bool {
        DailyContentManager.shared.hasEntry(for: selectedDate)
    }
    
    private var hasNewMessages: Bool {
        DailyContentManager.shared.hasNewMessagesSinceEntry(for: selectedDate)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    private var shouldShowEntryButton: Bool {
        // Only show Update Entry button when entry exists and there are new messages
        // Generate Entry is now shown as a full-width cell above
        return hasEntry && hasNewMessages && !isGeneratingEntry
    }
    
    private var entryButtonText: String {
        if hasEntry && hasNewMessages {
            return "Update Entry"
        } else {
            return "Generate Entry"
        }
    }
    
    var body: some View {
        // Wrap in gray rounded rectangle when chat has taken place
        if chatCompleted || hasEntry {
            VStack(spacing: 12) {
                
                // Last chat message preview (only show when chat exists)
                if chatCompleted {
                    VStack(alignment: .leading, spacing: 12) {
                        // Get last AI message
                        let messages = ChatSessionManager.shared.getMessages(for: selectedDate)
                        let lastAIMessage = messages.last(where: { !$0.isUser })
                        
                        if let lastMessage = lastAIMessage {
                            Text(lastMessage.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                
                // Resume Chat button
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
                    .background(Color(hex: "E0DEE5"))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(PlainButtonStyle())
                
                // Entry Row (full width, shown when entry exists OR when chat has happened but no entry)
                if hasEntry {
                    // Show actual entry when it exists
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
                    // Show Generate Entry link when chat exists but no entry
                    Button(action: {
                        if !isGeneratingEntry {
                            // Trigger entry generation
                            NotificationCenter.default.post(
                                name: NSNotification.Name("TriggerEntryGeneration"),
                                object: selectedDate
                            )
                        }
                    }) {
                        if isGeneratingEntry {
                            // Show loading state within the cell
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
                
                // Update Entry button (only shown when entry exists and there are new messages)
                if shouldShowEntryButton {
                    VStack(spacing: 0) {
                        // Divider line above Update Entry button
                        Divider()
                            .padding(.top, 2)
                            .padding(.bottom, 14)
                        
                        Button(action: {
                            // Show preview for update
                            showingPreviewEntry = true
                        }) {
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
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 24))
        } else {
            // No chat yet - show Start Chat button only
            Button(action: {
                showingDailyChat = true
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
}
