import SwiftUI

// MARK: - Prompts Tab Variants

struct PromptsTabSettingsStyleView: View {
    @State private var selectedPromptPack: String = "Daily Reflection"
    
    var body: some View {
        NavigationStack {
            List {
                // Daily Prompt Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.title2)
                                .foregroundStyle(.yellow)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Today's Prompt")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                
                                Text("Daily inspiration for your journal")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text("What makes me feel most alive?")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .padding(.top, 8)
                        
                        HStack(spacing: 12) {
                            Button("Answer Prompt") {
                                // TODO: Answer prompt action
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Skip") {
                                // TODO: Skip prompt action
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button(action: {
                                // TODO: Shuffle prompt action
                            }) {
                                Image(systemName: "shuffle")
                                    .font(.title3)
                                    .foregroundStyle(.primary)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
                
                // Browse by Category Section
                Section("Browse by Category") {
                    PromptCategoryRow(
                        icon: "sun.max.fill",
                        iconColor: .orange,
                        title: "Daily Reflection",
                        subtitle: "25 prompts • Perfect for daily journaling",
                        isSelected: selectedPromptPack == "Daily Reflection",
                        action: { selectedPromptPack = "Daily Reflection" }
                    )
                    
                    PromptCategoryRow(
                        icon: "heart.fill",
                        iconColor: .red,
                        title: "Gratitude",
                        subtitle: "18 prompts • Focus on appreciation",
                        isSelected: selectedPromptPack == "Gratitude",
                        action: { selectedPromptPack = "Gratitude" }
                    )
                    
                    PromptCategoryRow(
                        icon: "target",
                        iconColor: .blue,
                        title: "Goals & Dreams",
                        subtitle: "22 prompts • Explore your aspirations",
                        isSelected: selectedPromptPack == "Goals & Dreams",
                        action: { selectedPromptPack = "Goals & Dreams" }
                    )
                    
                    PromptCategoryRow(
                        icon: "person.2.fill",
                        iconColor: .green,
                        title: "Relationships",
                        subtitle: "16 prompts • Reflect on connections",
                        isSelected: selectedPromptPack == "Relationships",
                        action: { selectedPromptPack = "Relationships" }
                    )
                    
                    PromptCategoryRow(
                        icon: "brain.head.profile",
                        iconColor: .purple,
                        title: "Self-Discovery",
                        subtitle: "30 prompts • Deep introspection",
                        isSelected: selectedPromptPack == "Self-Discovery",
                        action: { selectedPromptPack = "Self-Discovery" }
                    )
                    
                    PromptCategoryRow(
                        icon: "sparkles",
                        iconColor: .pink,
                        title: "Creativity",
                        subtitle: "20 prompts • Unlock imagination",
                        isSelected: selectedPromptPack == "Creativity",
                        action: { selectedPromptPack = "Creativity" }
                    )
                }
                
                // Tools Section
                Section("Tools") {
                    PromptToolRow(
                        icon: "star.fill",
                        iconColor: .yellow,
                        title: "My Favorites",
                        subtitle: "12 saved prompts",
                        action: { /* TODO: Favorites action */ }
                    )
                    
                    PromptToolRow(
                        icon: "clock.fill",
                        iconColor: .indigo,
                        title: "Recently Used",
                        subtitle: "Last 10 prompts you answered",
                        action: { /* TODO: Recent action */ }
                    )
                    
                    PromptToolRow(
                        icon: "plus.circle.fill",
                        iconColor: .teal,
                        title: "Create Custom Prompt",
                        subtitle: "Write your own prompts",
                        action: { /* TODO: Create action */ }
                    )
                    
                    PromptToolRow(
                        icon: "square.and.arrow.down.fill",
                        iconColor: .gray,
                        title: "Import Prompt Packs",
                        subtitle: "Add new prompt collections",
                        action: { /* TODO: Import action */ }
                    )
                }
                
                // Selected Pack Preview
                if !selectedPromptPack.isEmpty {
                    Section("Preview: \(selectedPromptPack)") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(samplePromptsFor(selectedPromptPack), id: \.self) { prompt in
                                HStack {
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    Text(prompt)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                            }
                            
                            Button("View All \(selectedPromptPack) Prompts") {
                                // TODO: View all action
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "44C0FF"))
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Prompts")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func samplePromptsFor(_ pack: String) -> [String] {
        switch pack {
        case "Daily Reflection":
            return [
                "How did I grow today?",
                "What challenged me most?",
                "What am I most grateful for?"
            ]
        case "Gratitude":
            return [
                "Who made my day better?",
                "What small moment brought me joy?",
                "What am I taking for granted?"
            ]
        case "Goals & Dreams":
            return [
                "What do I want to achieve this year?",
                "What's holding me back from my dreams?",
                "How can I take one step forward today?"
            ]
        case "Relationships":
            return [
                "How did I show love today?",
                "Who do I need to reconnect with?",
                "What relationship needs my attention?"
            ]
        case "Self-Discovery":
            return [
                "What makes me unique?",
                "When do I feel most like myself?",
                "What beliefs am I questioning?"
            ]
        case "Creativity":
            return [
                "What inspired me today?",
                "How can I express myself differently?",
                "What would I create if I had no limits?"
            ]
        default:
            return []
        }
    }
}

struct PromptCategoryRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with colored background
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "44C0FF"))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PromptToolRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with colored background
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PromptsTabSettingsStyleView()
}