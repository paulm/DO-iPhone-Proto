import SwiftUI

struct PromptPackDetailView: View {
    let packTitle: String
    let packIcon: String
    let promptCount: Int
    let author: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPrompt: String?
    
    // Sample prompts for Gratitude pack based on screenshot
    private let prompts = [
        "What am I grateful for today?",
        "What small things happened today that I am grateful for?",
        "What simple pleasures do I cherish most?",
        "What are today's highlights so far?"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header section
                    VStack(spacing: 12) {
                        // Icon
                        Image(systemName: packIcon)
                            .font(.system(size: 40))
                            .foregroundStyle(.gray)
                            .padding(.top, 24)
                        
                        // Title
                        Text(packTitle)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                        
                        // Metadata
                        HStack(spacing: 12) {
                            Text("\(promptCount) prompts")
                                .foregroundStyle(.gray)
                            
                            Text("•")
                                .foregroundStyle(.gray)
                            
                            Text("By \(author)")
                                .foregroundStyle(.gray)
                        }
                        .font(.caption)
                        
                        // My Prompts button
                        Button(action: {
                            // TODO: Add to My Prompts functionality
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                Text("My Prompts")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "44C0FF"))
                            .clipShape(Capsule())
                        }
                        .padding(.vertical, 8)
                        
                        // Description
                        Text("Spark everyday thankfulness by noticing the large and small blessings that color your life.")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    
                    // Prompts list
                    VStack(spacing: 20) {
                        ForEach(prompts, id: \.self) { prompt in
                            PromptDetailCard(
                                prompt: prompt,
                                isSelected: selectedPrompt == prompt,
                                onTap: {
                                    selectedPrompt = prompt
                                }
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .background(.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // TODO: Share functionality
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

struct PromptDetailCard: View {
    let prompt: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(prompt)
                .font(.system(size: 17, weight: .thin, design: .serif))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color(hex: "44C0FF") : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PromptPackDetailView(
        packTitle: "Gratitude",
        packIcon: "heart.text.square",
        promptCount: 37,
        author: "Day One Team"
    )
}
