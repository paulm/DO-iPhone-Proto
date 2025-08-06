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
            case .appleSettings:
                PromptsTabSettingsStyleView()
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
    
    @ViewBuilder
    private var segmentedControlSection: some View {
        Section {
            Picker("View", selection: $selectedTab) {
                Text("Gallery").tag(0)
                Text("My Prompts").tag(1)
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }
    
    // Sample prompts for carousel
    private let todaysPrompts = [
        ("What is my earliest childhood memory?", "Childhood Memories", "figure.child"),
        ("What moment changed my perspective?", "Life Lessons", "lightbulb"),
        ("If I could have dinner with anyone, who would it be and why?", "Imagination", "person.2")
    ]
    
    @ViewBuilder
    private var todaysPromptSection: some View {
        Section {
            VStack(spacing: 0) {
                TabView {
                    ForEach(todaysPrompts, id: \.0) { prompt in
                        todaysPromptCard(
                            question: prompt.0,
                            category: prompt.1,
                            icon: prompt.2
                        )
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // Hide default indicators
                .frame(height: 150) // 75% of 200
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<todaysPrompts.count, id: \.self) { index in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } header: {
            Text("Today's Prompts")
        }
    }
    
    private func todaysPromptCard(question: String, category: String, icon: String) -> some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: geometry.size.width * 0.1) // 10% spacing on left
                
                VStack(spacing: 12) {
                    Text(question)
                        .font(.system(size: 17, weight: .thin, design: .serif))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Label(category, systemImage: icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                }
                .frame(width: geometry.size.width * 0.8) // 80% width
                .frame(maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                )
                
                Spacer()
                    .frame(width: geometry.size.width * 0.1) // 10% spacing on right
            }
        }
    }
    
    @ViewBuilder
    private var promptPacksSection: some View {
        Section("Prompt Packs") {
            ForEach(promptPacks) { pack in
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
                
                Text("\(pack.promptCount) prompts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    var body: some View {
        NavigationStack {
            List {
                segmentedControlSection
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