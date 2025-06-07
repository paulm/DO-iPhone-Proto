import SwiftUI

/// Enhanced half sheet modal showing journaling AI tools with content previews
struct EnhancedJournalingToolsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    TitleSuggestionsRow()
                    Divider()
                        .padding(.leading, 20)
                    
                    PromptsRow()
                    Divider()
                        .padding(.leading, 20)
                    
                    GenerateImageRow()
                    Divider()
                        .padding(.leading, 20)
                    
                    ChatRow()
                    Divider()
                        .padding(.leading, 20)
                    
                    SummarizeEntryRow()
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

// MARK: - Tool Rows

struct TitleSuggestionsRow: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title Suggestions")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Light, Leaves, and Stillness")
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

struct PromptsRow: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prompts")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("How did I feel emotionally with the quiet and nature?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
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

struct GenerateImageRow: View {
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
                    Text("Generate Image")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("AI generated illustration based on your entry")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
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

struct ChatRow: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "message")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Chat")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("Discuss your entry with an AI companion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
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

struct SummarizeEntryRow: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "sparkles.square.filled.on.square")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Summarize Entry")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("This afternoon I walked a familiar trail near my house. Lorem ipsum dolor sit amet...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
            }
            
            HStack {
                Spacer()
                Button("View Summary") {
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
    EnhancedJournalingToolsView()
}