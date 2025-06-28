import SwiftUI

/// Modal sheet for creating new journal entries
struct EntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entryText = "A Quiet Walk That Shifted Everything\n\nThis afternoon I walked a familiar trail near my house.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam mattis, orci eu varius imperdiet, augue risus eleifend ex, eu sollicitudin enim erat maximus est."
    @State private var showingJournalingTools = false
    @State private var showingEnhancedJournalingTools = false
    @State private var showingContentFocusedJournalingTools = false
    @State private var showingEntryChat = false
    @State private var hasChatActivity = true // Simulating that this entry has chat activity
    @State private var entryDate = Date()
    @State private var showingEditDate = false
    @State private var showEntryChatEmbed = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Journal info header
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Sample Journal")
                            .foregroundStyle(.black)
                        Text(" · ")
                            .foregroundStyle(.secondary)
                        Text("Sundance Resort")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.white)
                
                // Content area
                VStack(alignment: .leading, spacing: 16) {
                    // Chat activity indicator
                    if hasChatActivity && showEntryChatEmbed {
                        Button {
                            showingEntryChat = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "message.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.black)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Entry Chat Session")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Text("Discussed themes, emotions, and reflections • 3 messages")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.black.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Combined text editor
                    TextEditor(text: $entryText)
                        .font(.body)
                        .focused($isTextFieldFocused)
                        .scrollContentBackground(.hidden)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                HStack(spacing: 20) {
                                    Button {
                                        // Collapse action
                                        isTextFieldFocused = false
                                    } label: {
                                        Image(systemName: "chevron.down")
                                            .font(.title3)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        showingJournalingTools = true
                                    } label: {
                                        Image(systemName: "sparkles")
                                            .font(.title3)
                                    }
                                    
                                    Button {
                                        showingEnhancedJournalingTools = true
                                    } label: {
                                        Image(systemName: "sparkles")
                                            .font(.title3)
                                            .foregroundStyle(.black)
                                    }
                                    
                                    Button {
                                        showingContentFocusedJournalingTools = true
                                    } label: {
                                        Image(systemName: "sparkles")
                                            .font(.title3)
                                            .foregroundStyle(.purple)
                                    }
                                    
                                    Button {
                                        showingEntryChat = true
                                    } label: {
                                        Image(systemName: "message.circle")
                                            .font(.title3)
                                    }
                                    
                                    Button {
                                        // Attachment action
                                    } label: {
                                        Image(systemName: "paperclip")
                                            .font(.title3)
                                    }
                                    
                                    Button {
                                        // Text formatting action
                                    } label: {
                                        Image(systemName: "textformat")
                                            .font(.title3)
                                    }
                                }
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 20)
                            }
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showingEditDate = true
                    }) {
                        HStack(spacing: 4) {
                            Text(entryDate, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            Text("·")
                                .font(.body)
                                .foregroundStyle(.white)
                            Text(entryDate, format: .dateTime.hour().minute())
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Menu {
                            Button(action: {}) {
                                Label("Tag", systemImage: "tag")
                            }
                            
                            Button(action: {}) {
                                Label("Move to...", systemImage: "folder")
                            }
                            
                            Button(action: {}) {
                                Label("Copy to...", systemImage: "doc.on.doc")
                            }
                            
                            Button(role: .destructive, action: {}) {
                                Label("Move to Trash", systemImage: "trash")
                            }
                            
                            Divider()
                            
                            Button(action: {}) {
                                Label("Entry Info", systemImage: "info.circle")
                            }
                            
                            Divider()
                            
                            Button(action: {}) {
                                Label("Export", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: {}) {
                                Label("View PDF", systemImage: "doc.text")
                            }
                            
                            Button(action: {}) {
                                Label("View \(entryDate, format: .dateTime.month(.abbreviated).day())", systemImage: "calendar")
                            }
                            
                            Divider()
                            
                            Button(action: {
                                showEntryChatEmbed.toggle()
                            }) {
                                Label("Show Entry Chat Embed", systemImage: showEntryChatEmbed ? "checkmark" : "")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .accessibilityLabel("Save journal entry")
                    }
                }
            }
            .toolbarBackground(LinearGradient(colors: [Color(hex: "4EC3FE"), Color(hex: "4EC3FE").opacity(0.8)], startPoint: .top, endPoint: .bottom), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingJournalingTools) {
                JournalingToolsView()
            }
            .sheet(isPresented: $showingEnhancedJournalingTools) {
                EnhancedJournalingToolsView()
            }
            .sheet(isPresented: $showingContentFocusedJournalingTools) {
                ContentFocusedJournalingToolsView()
            }
            .sheet(isPresented: $showingEntryChat) {
                EntryChatView(entryText: entryText, entryTitle: extractTitle(from: entryText))
            }
            .sheet(isPresented: $showingEditDate) {
                EditDateView(selectedDate: $entryDate)
            }
        }
    }
    
    private func extractTitle(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return firstLine.isEmpty ? "Untitled Entry" : firstLine
    }
}

#Preview {
    EntryView()
}