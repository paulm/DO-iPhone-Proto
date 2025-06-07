import SwiftUI

/// Prompts tab view showing writing prompts
struct PromptsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "quote.bubble")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                    
                    Text("Writing Prompts")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Inspiration for your next entry")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                
                Spacer()
            }
            .navigationTitle("Prompts")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    PromptsView()
}