import SwiftUI

struct StravaIntegrationView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Strava logo placeholder
            Image(systemName: "figure.run")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            
            // Title and description
            VStack(spacing: 16) {
                Text("Day One + Strava")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Automatically import your Strava activities as journal entries. Never miss capturing your fitness achievements and milestones.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Sign in button
            Button {
                // TODO: Implement Strava OAuth flow
            } label: {
                HStack {
                    Image(systemName: "person.circle")
                    Text("Sign into Strava")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.orange, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            .padding(.horizontal, 40)
            .accessibilityLabel("Sign into Strava to enable auto import")
            
            Spacer()
        }
        .navigationTitle("Strava")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        StravaIntegrationView()
    }
}