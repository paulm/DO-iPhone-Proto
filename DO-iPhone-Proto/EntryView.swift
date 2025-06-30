import SwiftUI
import MapKit

/// Modal sheet for creating new journal entries
struct EntryView: View {
    @Environment(\.dismiss) private var dismiss
    let journal: Journal?
    
    @State private var entryText = """
A Perfect Day at Sundance

Today was one of those rare days where everything seemed to align perfectly. I woke up early, around 6:30 AM, to the sound of birds chirping outside my window at the resort. The morning light was just beginning to filter through the trees, casting long shadows across the mountain slopes. I decided to start the day with a hike on the Stewart Falls trail, something I've been meaning to do since arriving here three days ago.

The trail was quiet, with only a few other early risers making their way up the path. The air was crisp and cool, probably around 55 degrees, and I could see my breath forming small clouds as I walked. About halfway up, I stopped at a clearing that offered a stunning view of the valley below. The aspens were just beginning to turn golden, creating patches of warm color against the dark green of the pines. I sat on a large rock and just took it all in, feeling grateful for this moment of solitude in nature.

After the hike, I returned to the resort for breakfast at the Foundry Grill. I ordered their famous blueberry pancakes and a strong cup of coffee. While eating, I struck up a conversation with an older couple from Colorado who were celebrating their 40th wedding anniversary. They shared stories about how they've been coming to Sundance every fall for the past fifteen years, and how this place has become a sacred tradition for them. Their love for each other and for this place was infectious.

The afternoon was spent exploring the art studios scattered around the resort. I was particularly drawn to the pottery workshop, where a local artist was demonstrating wheel throwing techniques. She invited me to try my hand at it, and despite making quite a mess, I managed to create something that vaguely resembled a bowl. There's something meditative about working with clay, feeling it take shape beneath your hands, requiring both strength and gentleness.

As the sun began to set, painting the sky in shades of orange and pink, I found myself back on the deck of my cabin, wrapped in a warm blanket with a cup of herbal tea. The day felt complete in a way that few days do. No urgent emails, no pressing deadlines, just the simple pleasure of being present in a beautiful place. Tomorrow I'm planning to try the zip line tour, but for now, I'm content to watch the stars emerge one by one in the darkening sky, feeling deeply connected to this moment and this place.
"""
    @State private var showingJournalingTools = false
    @State private var showingEnhancedJournalingTools = false
    @State private var showingContentFocusedJournalingTools = false
    @State private var showingEntryChat = false
    @State private var hasChatActivity = true // Simulating that this entry has chat activity
    @State private var entryDate = Date()
    @State private var showingEditDate = false
    @State private var showEntryChatEmbed = false
    @FocusState private var isTextFieldFocused: Bool
    
    // Location for the map - Sundance Resort coordinates
    private let entryLocation = CLLocationCoordinate2D(latitude: 40.6006, longitude: -111.5878)
    private var journalName: String {
        journal?.name ?? "Sample Journal"
    }
    private let locationName = "Sundance Resort"
    private var journalColor: Color {
        journal?.color ?? Color(hex: "4EC3FE")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Journal info header - only shown in Edit mode
                    if isTextFieldFocused {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text(journalName)
                                    .foregroundStyle(journalColor)
                                    .fontWeight(.medium)
                                Text(" · ")
                                    .foregroundStyle(.secondary)
                                Text(locationName)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.white)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                
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
                        .contentMargins(.horizontal, 14, for: .scrollContent)
                        .contentMargins(.vertical, 16, for: .scrollContent)
                        .allowsHitTesting(true) // Always allow taps
                        .onTapGesture {
                            if !isTextFieldFocused {
                                isTextFieldFocused = true
                            }
                        }
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
                                .padding(.horizontal, 18)
                            }
                        }
                }
                .padding(.horizontal, 0)
                .padding(.top, 0)
            }
                
                // Bottom info block - only shown in Read mode
                if !isTextFieldFocused {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            // Row 1: Journal metadata
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(journalName)
                                        .foregroundStyle(journalColor)
                                        .fontWeight(.medium)
                                    Text(" · ")
                                        .foregroundStyle(.secondary)
                                    Text(locationName)
                                        .foregroundStyle(.secondary)
                                }
                                .font(.caption)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(.white)
                            
                            Divider()
                            
                            // Row 2: Map view
                            Map(position: .constant(.region(MKCoordinateRegion(
                                center: entryLocation,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )))) {
                                Marker(locationName, coordinate: entryLocation)
                                    .tint(journalColor)
                            }
                            .frame(height: 100)
                            .mapStyle(.standard)
                            .allowsHitTesting(false) // Make map non-interactive
                        }
                        .background(.white)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isTextFieldFocused)
            .onKeyPress(.return, phases: .down) { keyPress in
                if keyPress.modifiers.contains(.command) {
                    isTextFieldFocused.toggle()
                    return .handled
                }
                return .ignored
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
            .toolbarBackground(journalColor, for: .navigationBar)
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
    EntryView(journal: nil)
}
