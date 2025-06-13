import SwiftUI

/// Prompts tab view showing writing prompts gallery and packs
struct PromptsView: View {
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @State private var experimentsManager = ExperimentsManager.shared
    
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
        VStack(spacing: 0) {
            // Header with profile button
            HStack {
                Text("Prompts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    Circle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.gray)
                        )
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Gallery/My Prompts tabs
            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    Text("Gallery")
                        .font(.headline)
                        .fontWeight(selectedTab == 0 ? .medium : .regular)
                        .foregroundStyle(selectedTab == 0 ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTab == 0 ? .white : .clear)
                                .shadow(color: selectedTab == 0 ? .black.opacity(0.1) : .clear, radius: 2, x: 0, y: 1)
                        )
                }
                
                Button(action: { selectedTab = 1 }) {
                    Text("My Prompts")
                        .font(.headline)
                        .fontWeight(selectedTab == 1 ? .medium : .regular)
                        .foregroundStyle(selectedTab == 1 ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTab == 1 ? .white : .clear)
                                .shadow(color: selectedTab == 1 ? .black.opacity(0.1) : .clear, radius: 2, x: 0, y: 1)
                        )
                }
            }
            .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            .padding(.top, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Recommended Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommended")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
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
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Prompt Packs Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Prompt Packs")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 1) {
                            PromptPackRow(icon: "envelope", title: "Friendships Through the Years")
                            PromptPackRow(icon: "figure.child", title: "Childhood Memories")
                            PromptPackRow(icon: "face.smiling", title: "Firsts in Life")
                            PromptPackRow(icon: "cloud.sun", title: "Seasons of Life")
                        }
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 24)
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
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text(question)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, 16)
                    .padding(.trailing, 16)
                }
                .frame(width: 280, height: 200)
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