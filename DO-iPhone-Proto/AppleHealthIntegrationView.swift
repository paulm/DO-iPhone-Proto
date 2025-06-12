import SwiftUI

struct AppleHealthIntegrationView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero Section
                VStack(spacing: 24) {
                    // Apple Health icon
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.red, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "heart.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.white)
                        )
                        .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 16) {
                        Text("Day One + Apple Health")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Automatically capture your health and fitness journey with rich, data-driven journal entries.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
                
                // Health Data Types Section
                VStack(spacing: 24) {
                    Text("Track Your Wellness Journey")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 20) {
                        HealthDataRow(
                            icon: "figure.walk",
                            title: "Activity & Workouts",
                            description: "Steps, distance, active calories, and workout summaries automatically logged.",
                            color: .green
                        )
                        
                        HealthDataRow(
                            icon: "heart",
                            title: "Heart Health",
                            description: "Heart rate trends, resting heart rate, and cardio fitness insights.",
                            color: .red
                        )
                        
                        HealthDataRow(
                            icon: "bed.double",
                            title: "Sleep Patterns",
                            description: "Sleep duration, quality scores, and bedtime routine tracking.",
                            color: .purple
                        )
                        
                        HealthDataRow(
                            icon: "brain.head.profile",
                            title: "Mindfulness",
                            description: "Meditation sessions, mood tracking, and mental wellness check-ins.",
                            color: .blue
                        )
                        
                        HealthDataRow(
                            icon: "drop",
                            title: "Nutrition & Hydration",
                            description: "Water intake, nutritional highlights, and eating pattern insights.",
                            color: .cyan
                        )
                    }
                }
                .padding(.horizontal)
                
                // Benefits Section
                VStack(spacing: 20) {
                    Text("Why Connect Health Data?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        BenefitCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Discover Patterns",
                            description: "See connections between your activities, mood, and overall wellbeing."
                        )
                        
                        BenefitCard(
                            icon: "target",
                            title: "Celebrate Milestones",
                            description: "Automatically journal when you hit fitness goals and personal records."
                        )
                        
                        BenefitCard(
                            icon: "calendar.badge.clock",
                            title: "Daily Health Summary",
                            description: "Get automated entries with your daily health highlights and achievements."
                        )
                    }
                }
                .padding(.horizontal)
                
                // Privacy Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundStyle(.green)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Data Stays Private")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Text("Health data is processed locally on your device and encrypted in your journal entries.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                // CTA Section
                VStack(spacing: 16) {
                    Text("Start Your Health Journey")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Connect Apple Health to automatically capture your wellness story with rich, meaningful journal entries.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        // TODO: Implement Apple Health authorization
                    } label: {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("Connect Apple Health")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.red, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 40)
                    .accessibilityLabel("Connect to Apple Health")
                    
                    Text("Requires iOS 16+ • Secure & Private")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Apple Health")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Supporting Views
struct HealthDataRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
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

struct BenefitCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        AppleHealthIntegrationView()
    }
}