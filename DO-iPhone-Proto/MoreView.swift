import SwiftUI

/// More tab view with Quick Start, On This Day, and Daily Prompt
struct MoreView: View {
    @State private var showingSettings = false
    @State private var experimentsManager = ExperimentsManager.shared
    
    var body: some View {
        Group {
            switch experimentsManager.variant(for: .moreTab) {
            case .original:
                MoreTabOriginalView(showingSettings: $showingSettings)
            case .variant1:
                MoreTabSettingsStyleView()
            default:
                MoreTabOriginalView(showingSettings: $showingSettings)
            }
        }
    }
}

/// Original More tab layout
struct MoreTabOriginalView: View {
    @Binding var showingSettings: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Profile section
                    HStack {
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
                    
                    // Quick Start Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Quick Start")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("See more") {
                                // TODO: Show more quick start options
                            }
                            .foregroundStyle(Color(hex: "44C0FF"))
                        }
                        .padding(.horizontal)
                        
                        Text("Instantly create an entry with one of the following:")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        // Quick start options
                        HStack(spacing: 0) {
                            QuickStartOption(icon: "photo.on.rectangle", title: "Photos")
                            QuickStartOption(icon: "mic", title: "Audio")
                            QuickStartOption(icon: "sun.max", title: "Today")
                            QuickStartOption(icon: "doc.text", title: "Templates")
                        }
                        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    // On This Day Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("On This Day")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Jun 12")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("See more") {
                                // TODO: Show more memories
                            }
                            .foregroundStyle(Color(hex: "44C0FF"))
                        }
                        .padding(.horizontal)
                        
                        Text("No past memories yet! Create an entry now, and you'll see it here next year.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        // Year buttons
                        HStack(spacing: 16) {
                            YearButton(year: "2024", isSelected: true)
                            YearButton(year: "2023", isSelected: false)
                            YearButton(year: "2022", isSelected: false)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Daily Prompt Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Daily Prompt")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("See more") {
                                // TODO: Show more prompts
                            }
                            .foregroundStyle(Color(hex: "44C0FF"))
                        }
                        .padding(.horizontal)
                        
                        // Prompt card
                        VStack(spacing: 20) {
                            Text("What makes me feel most alive?")
                                .font(.title3)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 24)
                            
                            HStack {
                                Button(action: {
                                    // TODO: Answer prompt
                                }) {
                                    Text("Answer prompt")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // TODO: Shuffle prompt
                                }) {
                                    Image(systemName: "shuffle")
                                        .font(.title2)
                                        .foregroundStyle(.primary)
                                }
                            }
                            .padding(.bottom, 24)
                        }
                        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarHidden(true)
        }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
    }
}

// MARK: - Supporting Views
struct QuickStartOption: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {
            // TODO: Handle quick start action
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct YearButton: View {
    let year: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {
            // TODO: Select year
        }) {
            Text(year)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? Color(hex: "44C0FF") : .secondary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "44C0FF").opacity(0.1) : .gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MoreView()
}