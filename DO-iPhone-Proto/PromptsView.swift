import SwiftUI

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

/// Original Prompts tab layout
struct PromptsTabOriginalView: View {
    @Binding var selectedTab: Int
    @Binding var showingSettings: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Top segmented control
                    VStack(spacing: 16) {
                        Picker("Prompts Section", selection: $selectedTab) {
                            Text("Gallery").tag(0)
                            Text("My Prompts").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                    // Recommended Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommended")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        TabView {
                            PromptCard(
                                question: "What is my earliest childhood memory?",
                                category: "Childhood Memories",
                                icon: "figure.child"
                            )
                            
                            PromptCard(
                                question: "What moment changed my perspective?",
                                category: "Life Lessons",
                                icon: "lightbulb"
                            )
                            
                            PromptCard(
                                question: "If I could have dinner with anyone, who would it be and why?",
                                category: "Imagination",
                                icon: "person.2"
                            )
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(height: 280)
                        .padding(.horizontal)
                    }
                    
                    // Prompt Packs Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Prompt Packs")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            PromptPackRow(icon: "envelope", title: "Friendships Through the Years")
                            Divider().padding(.leading, 56)
                            PromptPackRow(icon: "figure.child", title: "Childhood Memories")
                            Divider().padding(.leading, 56)
                            PromptPackRow(icon: "face.smiling", title: "Firsts in Life")
                            Divider().padding(.leading, 56)
                            PromptPackRow(icon: "cloud.sun", title: "Seasons of Life")
                        }
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Prompts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            )
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Supporting Views
struct PromptCard: View {
    let question: String
    let category: String
    let icon: String
    
    var body: some View {
        Button(action: {
            // TODO: Show prompt details
        }) {
            VStack(spacing: 0) {
                // Card content
                VStack {
                    Text(question)
                        .font(.custom("New York", size: 20))
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .padding(.horizontal, 24)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "44C0FF"), Color(hex: "44C0FF").opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                
                // Category label
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(.primary)
                    
                    Text(category)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.white, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PromptPackRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {
            // TODO: Open prompt pack
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PromptsView()
}