import SwiftUI

/// Half sheet modal showing journaling AI tools
struct JournalingToolsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Handle indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(.secondary)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Title
            Text("Journaling Tools")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            // Tool buttons grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ToolButton(
                    icon: "sparkles",
                    title: "Title Suggestions",
                    action: {
                        // Title suggestions action
                        dismiss()
                    }
                )
                
                ToolButton(
                    icon: "bubble.left.and.bubble.right",
                    title: "Prompts",
                    action: {
                        // Prompts action
                        dismiss()
                    }
                )
                
                ToolButton(
                    icon: "photo.badge.plus",
                    title: "Generate Image",
                    action: {
                        // Generate image action
                        dismiss()
                    }
                )
                
                ToolButton(
                    icon: "sparkles.square.filled.on.square",
                    title: "Summarize Entry",
                    action: {
                        // Summarize entry action
                        dismiss()
                    }
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.hidden)
    }
}

/// Individual tool button component
struct ToolButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(.vertical, 20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    JournalingToolsView()
}