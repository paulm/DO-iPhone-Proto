import SwiftUI

// MARK: - Data Models
struct PromptPack: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let promptCount: Int
    let author: String
    let description: String
}

/// Prompts tab view showing writing prompts gallery and packs
struct PromptsView: View {
    @State private var selectedTab = 0
    @State private var showingSettings = false
    private var experimentsManager = ExperimentsManager.shared
    
    var body: some View {
        Group {
            switch experimentsManager.variant(for: .promptsTab) {
            case .original:
                PromptsTabOriginalView(selectedTab: $selectedTab, showingSettings: $showingSettings)
            default:
                PromptsTabOriginalView(selectedTab: $selectedTab, showingSettings: $showingSettings)
            }
        }
    }
}

/// Original Prompts tab layout - Updated with iOS standard patterns
struct PromptsTabOriginalView: View {
    @Binding var selectedTab: Int
    @Binding var showingSettings: Bool
    @State private var selectedPromptPack: PromptPack?
    @State private var currentPromptIndex = 0
    
    // Track saved packs and answered prompts
    @State private var savedPacks: Set<String> = ["Gratitude", "Childhood Memories"]
    @State private var answeredCounts: [String: Int] = [
        "Gratitude": 2,
        "Friendships Through the Years": 5,
        "Childhood Memories": 0
    ]
    
    // Sample data for prompt packs
    private let promptPacks = [
        PromptPack(
            icon: "heart.text.square",
            title: "Gratitude",
            promptCount: 37,
            author: "Day One Team",
            description: "Spark everyday thankfulness by noticing the large and small blessings that color your life."
        ),
        PromptPack(
            icon: "envelope",
            title: "Friendships Through the Years",
            promptCount: 25,
            author: "Day One Team",
            description: "Explore the bonds that have shaped your life through meaningful friendships."
        ),
        PromptPack(
            icon: "figure.child",
            title: "Childhood Memories",
            promptCount: 42,
            author: "Day One Team",
            description: "Journey back to your earliest experiences and rediscover forgotten moments."
        ),
        PromptPack(
            icon: "face.smiling",
            title: "Firsts in Life",
            promptCount: 30,
            author: "Day One Team",
            description: "Celebrate the milestone moments that marked new chapters in your story."
        ),
        PromptPack(
            icon: "cloud.sun",
            title: "Seasons of Life",
            promptCount: 28,
            author: "Day One Team",
            description: "Reflect on how different seasons have influenced your journey and growth."
        )
    ]
    
    
    // Sample prompts for carousel with Day One Journal colors
    private let todaysPrompts = [
        ("What is my earliest childhood memory?", "Childhood Memories", "figure.child", BrandColors.journalBlue),
        ("What moment changed my perspective?", "Life Lessons", "lightbulb", BrandColors.journalFire),
        ("If I could have dinner with anyone, who would it be and why?", "Imagination", "person.2", BrandColors.journalLavender)
    ]
    
    @ViewBuilder
    private var todaysPromptSection: some View {
        Section {
            VStack(spacing: 0) {
                TabView(selection: $currentPromptIndex) {
                    ForEach(Array(todaysPrompts.enumerated()), id: \.0) { index, prompt in
                        todaysPromptCard(
                            question: prompt.0,
                            backgroundColor: prompt.3
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // Hide default indicators
                .frame(height: 150) // 75% of 200
                
                // Category name (centered below card)
                Text("from \(todaysPrompts[currentPromptIndex].1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                
                // Custom page indicator (centered)
                HStack(spacing: 8) {
                    ForEach(0..<todaysPrompts.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPromptIndex ? Color.gray : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } header: {
            Text("Today's Prompts")
        }
    }
    
    private func todaysPromptCard(question: String, backgroundColor: Color) -> some View {
        Text(question)
            .font(.system(size: 19, weight: .thin, design: .serif)) // Increased from 17 to 19
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .padding(.leading, 6)  // 6pt on each side = 12pt between cards
        .padding(.trailing, 6)
    }
    
    @ViewBuilder
    private var promptPacksSection: some View {
        let savedPacksList = promptPacks.filter { savedPacks.contains($0.title) }
        let unsavedPacksList = promptPacks.filter { !savedPacks.contains($0.title) }
        
        // Show saved packs section if any exist
        if !savedPacksList.isEmpty {
            Section("Saved Packs") {
                ForEach(savedPacksList) { pack in
                    Button(action: {
                        selectedPromptPack = pack
                    }) {
                        promptPackRow(for: pack)
                    }
                }
            }
        }
        
        // Show remaining packs in Prompt Packs section
        Section("Prompt Packs") {
            ForEach(unsavedPacksList) { pack in
                Button(action: {
                    selectedPromptPack = pack
                }) {
                    promptPackRow(for: pack)
                }
            }
        }
    }
    
    private func promptPackRow(for pack: PromptPack) -> some View {
        HStack {
            Image(systemName: pack.icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pack.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                // Show saved status and/or answered count
                if let subtitle = promptPackSubtitle(for: pack) {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func promptPackSubtitle(for pack: PromptPack) -> String? {
        let isSaved = savedPacks.contains(pack.title)
        let answeredCount = answeredCounts[pack.title] ?? 0
        
        var parts: [String] = []
        
        if isSaved {
            parts.append("✓ Saved")
        }
        
        if answeredCount > 0 {
            parts.append("\(answeredCount) Answered")
        }
        
        return parts.isEmpty ? nil : parts.joined(separator: " • ")
    }
    
    var body: some View {
        NavigationStack {
            List {
                todaysPromptSection
                promptPacksSection
            }
            .navigationTitle("Prompts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(item: $selectedPromptPack) { pack in
            PromptPackDetailView(
                packTitle: pack.title,
                packIcon: pack.icon,
                promptCount: pack.promptCount,
                author: pack.author
            )
        }
    }
}


#Preview {
    PromptsView()
}