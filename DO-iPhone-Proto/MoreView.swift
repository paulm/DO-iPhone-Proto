import SwiftUI

/// More tab view with Quick Start, On This Day, and Daily Prompt
struct MoreView: View {
    @State private var showingSettings = false

    var body: some View {
        MoreTabOriginalView(showingSettings: $showingSettings)
    }
}

/// Original More tab layout
struct MoreTabOriginalView: View {
    @Binding var showingSettings: Bool
    @State private var quickStartExpanded = true
    @State private var onThisDayExpanded = true
    @State private var dailyPromptExpanded = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Quick Start Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Toggleable header with disclosure arrow
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                quickStartExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text("Quick Start")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(.degrees(quickStartExpanded ? 90 : 0))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)

                        if quickStartExpanded {
                            Text("Instantly create an entry with one of the following:")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)

                            // Quick start options - horizontally scrollable
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    QuickStartOption(icon: "photo.on.rectangle", title: "Photos")
                                        .padding(.leading, 20)
                                    QuickStartOption(icon: "mic", title: "Audio")
                                    QuickStartOption(icon: "sun.max", title: "Today")
                                    QuickStartOption(icon: "doc.text", title: "Templates")
                                    QuickStartOption(icon: "bubble.left", title: "Chat")
                                    QuickStartOption(icon: "video", title: "Video")
                                    QuickStartOption(icon: "pencil.tip", title: "Draw")
                                    QuickStartOption(icon: "text.viewfinder", title: "Scan Text")
                                }
                            }
                            .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                    
                    // On This Day Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Toggleable header with disclosure arrow
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                onThisDayExpanded.toggle()
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("On This Day")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)

                                    Text("Jun 12")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(.degrees(onThisDayExpanded ? 90 : 0))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)

                        if onThisDayExpanded {
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
                    }
                    
                    // Daily Prompt Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Toggleable header with disclosure arrow
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                dailyPromptExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text("Daily Prompt")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(.degrees(dailyPromptExpanded ? 90 : 0))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)

                        if dailyPromptExpanded {
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
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20) // Add top padding for spacing
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("PM")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
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
            .frame(width: 80)
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