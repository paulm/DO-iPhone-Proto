import SwiftUI

struct SimpleJournalingToolsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPrompts = [
        "How did I feel emotionally while immersed in the quiet and nature?",
        "What specific thoughts or realizations did I have during my walk that shifted my perspective?",
        "Have I noticed similar moments of peace in other walks or activities recently?"
    ]
    
    // State for showing modal sheets
    @State private var showingTitleSuggestions = false
    @State private var showingImageSuggestions = false
    @State private var showingEntryHighlights = false
    
    // Sample prompts pool
    private let promptsPool = [
        "How did I feel emotionally while immersed in the quiet and nature?",
        "What specific thoughts or realizations did I have during my walk that shifted my perspective?",
        "Have I noticed similar moments of peace in other walks or activities recently?",
        "What aspects of today surprised me the most?",
        "How did my interactions with others impact my mood?",
        "What challenges did I face and how did I overcome them?",
        "What am I most grateful for about today?",
        "How did I practice self-care or mindfulness today?",
        "What would I do differently if I could relive today?",
        "What moment from today do I want to remember?",
        "How did I step out of my comfort zone today?",
        "What did I learn about myself today?",
        "What patterns am I noticing in my daily life?",
        "How am I different from who I was a year ago?",
        "What brought me joy today, no matter how small?",
        "What did I do today that aligned with my values?",
        "How did I show kindness to myself or others?",
        "What would my future self thank me for doing today?",
        "What emotions came up unexpectedly today?",
        "How did I handle stress or pressure today?"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Generate Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GENERATE")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // Title button
                                Button(action: {
                                    showingTitleSuggestions = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "text.cursor")
                                            .font(.system(size: 14))
                                        Text("Title")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.leading, 20)
                                
                                // Image button
                                Button(action: {
                                    showingImageSuggestions = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 14))
                                        Text("Image")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Entry Highlights button
                                Button(action: {
                                    showingEntryHighlights = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 14))
                                        Text("Entry Highlights")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(Color(hex: "44C0FF"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.trailing, 20)
                            }
                        }
                    }
                    
                    // Writing Prompts Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WRITING PROMPTS")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(currentPrompts.enumerated()), id: \.offset) { index, prompt in
                                Button(action: {
                                    // Handle prompt selection
                                    dismiss()
                                }) {
                                    Text(prompt)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                            }
                            
                            // Refresh button
                            Button(action: {
                                refreshPrompts()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16))
                                    Text("Get More Prompts")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(Color(hex: "44C0FF"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(UIColor.tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                        }
                    }
                    
                    // Add bottom padding for scrolling
                    Color.clear
                        .frame(height: 20)
                }
                .padding(.top, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Empty toolbar for grab handle
                    Color.clear
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showingTitleSuggestions) {
            TitleSuggestionsView()
        }
        .sheet(isPresented: $showingImageSuggestions) {
            ImageSuggestionsView()
        }
        .sheet(isPresented: $showingEntryHighlights) {
            EntryHighlightsView()
        }
    }
    
    private func refreshPrompts() {
        // Get 3 random prompts that aren't currently shown
        let availablePrompts = promptsPool.filter { !currentPrompts.contains($0) }
        let newPrompts = Array(availablePrompts.shuffled().prefix(3))
        
        withAnimation(.easeInOut(duration: 0.3)) {
            // Add new prompts to the beginning of the list
            currentPrompts.insert(contentsOf: newPrompts, at: 0)
        }
    }
}

#Preview {
    SimpleJournalingToolsView()
}