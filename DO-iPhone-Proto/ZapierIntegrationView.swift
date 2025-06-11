import SwiftUI

struct ZapierIntegrationView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero Section
                VStack(spacing: 24) {
                    // Zapier logo placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.orange.gradient)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("Z")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 16) {
                        Text("Day One + Zapier")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Connect Day One to 6,000+ apps and automate your journaling workflow like never before.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
                
                // Benefits Section
                VStack(spacing: 24) {
                    Text("What You Can Do")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 20) {
                        BenefitRow(
                            icon: "clock.arrow.circlepath",
                            title: "Automatic Triggers",
                            description: "Create journal entries when you complete tasks, receive emails, or hit fitness goals."
                        )
                        
                        BenefitRow(
                            icon: "arrow.triangle.branch",
                            title: "Multi-App Workflows",
                            description: "Combine data from multiple sources like weather, calendar events, and social media into rich journal entries."
                        )
                        
                        BenefitRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Data Enrichment",
                            description: "Automatically add location, weather, mood tracking, and productivity metrics to your entries."
                        )
                        
                        BenefitRow(
                            icon: "bell.badge",
                            title: "Smart Reminders",
                            description: "Get prompted to journal based on your habits, schedules, or important life events."
                        )
                        
                        BenefitRow(
                            icon: "photo.on.rectangle.angled",
                            title: "Content Aggregation",
                            description: "Collect photos from Instagram, tweets, or Spotify listening history into themed journal entries."
                        )
                    }
                }
                .padding(.horizontal)
                
                // Popular Zaps Section
                VStack(spacing: 20) {
                    Text("Popular Automations")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        PopularZapRow(
                            apps: ["Gmail", "Day One"],
                            description: "Create journal entries from important emails"
                        )
                        
                        PopularZapRow(
                            apps: ["Apple Health", "Day One"],
                            description: "Log daily fitness achievements and health metrics"
                        )
                        
                        PopularZapRow(
                            apps: ["Todoist", "Day One"],
                            description: "Journal about completed projects and milestones"
                        )
                        
                        PopularZapRow(
                            apps: ["Instagram", "Day One"],
                            description: "Archive your photos with automatic journal entries"
                        )
                        
                        PopularZapRow(
                            apps: ["Weather", "Day One"],
                            description: "Add weather context to your daily reflections"
                        )
                    }
                }
                .padding(.horizontal)
                
                // CTA Section
                VStack(spacing: 16) {
                    Text("Ready to Automate Your Journaling?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Connect Day One to Zapier and start building powerful automations that capture your life automatically.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        // TODO: Implement Zapier OAuth flow
                    } label: {
                        HStack {
                            Image(systemName: "link")
                            Text("Connect to Zapier")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 40)
                    .accessibilityLabel("Connect Day One to Zapier")
                    
                    Text("Free to start • Premium features available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Zapier")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Supporting Views
struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PopularZapRow: View {
    let apps: [String]
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(apps.indices, id: \.self) { index in
                    Text(apps[index])
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                    
                    if index < apps.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        ZapierIntegrationView()
    }
}