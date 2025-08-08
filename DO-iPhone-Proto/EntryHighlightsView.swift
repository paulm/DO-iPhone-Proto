import SwiftUI

struct EntryHighlightsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var highlights = """
    🥾 Early morning hike on Stewart Falls trail
    🌅 Moment of solitude watching the sunrise
    👫 Connected with anniversary couple at breakfast
    🏺 Created first pottery piece in workshop
    ⭐ Peaceful evening under the stars
    """
    @State private var isGenerating = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Content area
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key moments from your entry")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        // Highlights text editor
                        TextEditor(text: $highlights)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(minHeight: 200)
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            // Refresh button
                            Button(action: {
                                refreshHighlights()
                            }) {
                                Label("Refresh", systemImage: "arrow.clockwise")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Add to Entry button
                            Button(action: {
                                // Add highlights to entry
                                dismiss()
                            }) {
                                Label("Add to Entry", systemImage: "plus.circle.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "44C0FF"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    if isGenerating {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating new highlights...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Entry Highlights")
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func refreshHighlights() {
        isGenerating = true
        
        // Simulate AI generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                // Alternative highlights
                let alternativeHighlights = [
                    """
                    🌄 Woke early to catch the mountain sunrise
                    ☕ Savored quiet morning coffee on the deck
                    🦌 Spotted deer family on the hiking trail
                    💭 Found clarity during meditation by the stream
                    📝 Journaled insights about personal growth
                    """,
                    """
                    🎨 Discovered hidden talent at pottery workshop
                    🍽️ Shared stories over memorable breakfast
                    🏔️ Conquered challenging trail to the falls
                    📸 Captured perfect golden hour moments
                    🌟 Reflected on gratitude under night sky
                    """,
                    """
                    🚶 Took mindful solo walk through aspens
                    💑 Witnessed love story of anniversary couple
                    🌊 Listened to calming waterfall sounds
                    ✨ Experienced breakthrough moment of clarity
                    🏡 Felt deep connection to mountain resort
                    """
                ]
                
                highlights = alternativeHighlights.randomElement() ?? highlights
                isGenerating = false
            }
        }
    }
}

#Preview {
    EntryHighlightsView()
}