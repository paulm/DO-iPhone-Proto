import SwiftUI

/// Content-focused half sheet modal showing journaling AI tools with emphasized content previews
struct ContentFocusedJournalingToolsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ContentFocusedTitleSuggestionsRow()
                    Divider()
                        .padding(.leading, 20)
                    
                    ContentFocusedPromptsRow()
                    Divider()
                        .padding(.leading, 20)
                    
                    ContentFocusedGenerateImageRow()
                    Divider()
                        .padding(.leading, 20)
                    
                    ContentFocusedChatRow()
                    Divider()
                        .padding(.leading, 20)
                    
                    ContentFocusedSummarizeEntryRow()
                }
            }
            .navigationTitle("Journaling Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.height(600)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Content-Focused Tool Rows

struct ContentFocusedTitleSuggestionsRow: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Light, Leaves, and Stillness")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Title Suggestions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button("Add") {
                    // Add action
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "44C0FF"), in: Capsule())
            }
            
            HStack {
                Spacer()
                Button("More Titles...") {
                    // More titles action
                }
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct ContentFocusedPromptsRow: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("How did I feel emotionally with the quiet and nature?")
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text("Writing Prompts")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button("Add") {
                    // Add action
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "44C0FF"), in: Capsule())
            }
            
            HStack {
                Spacer()
                Button("More Prompts...") {
                    // More prompts action
                }
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct ContentFocusedGenerateImageRow: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Sample image thumbnail
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "photo.badge.plus")
                            .foregroundStyle(Color(hex: "44C0FF"))
                            .font(.title2)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mountain trail with stepping stones")
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text("AI Generated Image")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button("Add") {
                    // Add action
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "44C0FF"), in: Capsule())
            }
            
            HStack {
                Spacer()
                Button("More Images...") {
                    // More images action
                }
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct ContentFocusedChatRow: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "message")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Discuss your entry with an AI companion")
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("AI Chat")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            // Open chat view
        }
    }
}

struct ContentFocusedSummarizeEntryRow: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "sparkles.square.filled.on.square")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("A peaceful afternoon walk on a familiar trail brought moments of reflection and connection with nature...")
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(3)
                    
                    Text("Entry Summary")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                Spacer()
                Button("View Full Summary") {
                    // View summary action
                }
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    ContentFocusedJournalingToolsView()
}