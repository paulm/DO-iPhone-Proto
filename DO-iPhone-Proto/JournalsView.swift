import SwiftUI

/// Journals tab view showing journal collections
struct JournalsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                    
                    Text("Your Journals")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Organize your entries into journals")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                
                Spacer()
            }
            .navigationTitle("Journals")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    JournalsView()
}