import SwiftUI

// MARK: - More Tab Variants

struct MoreTabSettingsStyleView: View {
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundStyle(.gray)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Profile")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Text("Manage your account and preferences")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 8)
                }
                
                // Quick Actions Section
                Section("Quick Actions") {
                    SettingsRowView(
                        icon: "photo.on.rectangle",
                        iconColor: .blue,
                        title: "Photos",
                        subtitle: "Create entry with photos",
                        action: { /* TODO: Photos action */ }
                    )
                    
                    SettingsRowView(
                        icon: "mic.fill",
                        iconColor: .red,
                        title: "Audio",
                        subtitle: "Record voice entry",
                        action: { /* TODO: Audio action */ }
                    )
                    
                    SettingsRowView(
                        icon: "sun.max.fill",
                        iconColor: .orange,
                        title: "Today",
                        subtitle: "Quick daily entry",
                        action: { /* TODO: Today action */ }
                    )
                    
                    SettingsRowView(
                        icon: "doc.text.fill",
                        iconColor: .green,
                        title: "Templates",
                        subtitle: "Use entry templates",
                        action: { /* TODO: Templates action */ }
                    )
                }
                
                // Discovery Section
                Section("Discovery") {
                    SettingsRowView(
                        icon: "calendar.circle.fill",
                        iconColor: .purple,
                        title: "On This Day",
                        subtitle: "Jun 12 • View past memories",
                        action: { /* TODO: On This Day action */ }
                    )
                    
                    SettingsRowView(
                        icon: "lightbulb.fill",
                        iconColor: .yellow,
                        title: "Daily Prompt",
                        subtitle: "What makes me feel most alive?",
                        action: { /* TODO: Daily Prompt action */ }
                    )
                }
                
                // Tools Section
                Section("Tools") {
                    SettingsRowView(
                        icon: "chart.bar.fill",
                        iconColor: .indigo,
                        title: "Analytics",
                        subtitle: "View writing insights",
                        action: { /* TODO: Analytics action */ }
                    )
                    
                    SettingsRowView(
                        icon: "square.and.arrow.up.fill",
                        iconColor: .teal,
                        title: "Export",
                        subtitle: "Share your entries",
                        action: { /* TODO: Export action */ }
                    )
                    
                    SettingsRowView(
                        icon: "questionmark.circle.fill",
                        iconColor: .gray,
                        title: "Help & Support",
                        subtitle: "Get help with the app",
                        action: { /* TODO: Help action */ }
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct SettingsRowView: View {
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
    MoreTabSettingsStyleView()
}