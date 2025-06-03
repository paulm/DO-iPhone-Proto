import SwiftUI

/// Modal sheet for creating new journal entries
struct EntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entryText = "This afternoon I walked a familiar trail near my house.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam mattis, orci eu varius imperdiet, augue risus eleifend ex, eu sollicitudin enim erat maximus est."
    @State private var entryTitle = ""
    @State private var showingJournalingTools = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with date and journal info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mon, Feb 26, 2024 · 14:23")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    
                    HStack {
                        Text("Sample Journal")
                            .foregroundStyle(.blue)
                        Text(" · ")
                            .foregroundStyle(.white.opacity(0.7))
                        Text("Sundance Resort")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.blue.gradient)
                
                // Content area
                VStack(alignment: .leading, spacing: 16) {
                    // Title field
                    TextField("Entry title", text: $entryTitle, prompt: Text("A Quiet Walk That Shifted Everything"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .textFieldStyle(.plain)
                    
                    // Rich text editor
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
                                        // Photo action
                                    } label: {
                                        Image(systemName: "photo")
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
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .accessibilityLabel("Cancel entry creation")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .accessibilityLabel("Save journal entry")
                }
            }
            .toolbarBackground(.blue.gradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingJournalingTools) {
                JournalingToolsView()
            }
        }
    }
}

#Preview {
    EntryView()
}