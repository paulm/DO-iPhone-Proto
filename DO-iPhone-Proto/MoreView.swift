import SwiftUI

/// More tab view showing settings and additional options
struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "gear")
                            .foregroundStyle(Color(hex: "44C0FF"))
                            .frame(width: 24, height: 24)
                        Text("Settings")
                    }
                    
                    HStack {
                        Image(systemName: "cloud")
                            .foregroundStyle(Color(hex: "44C0FF"))
                            .frame(width: 24, height: 24)
                        Text("Sync & Backup")
                    }
                    
                    HStack {
                        Image(systemName: "lock")
                            .foregroundStyle(Color(hex: "44C0FF"))
                            .frame(width: 24, height: 24)
                        Text("Privacy")
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(Color(hex: "44C0FF"))
                            .frame(width: 24, height: 24)
                        Text("Help & Support")
                    }
                    
                    HStack {
                        Image(systemName: "heart")
                            .foregroundStyle(Color(hex: "44C0FF"))
                            .frame(width: 24, height: 24)
                        Text("Rate Day One")
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(Color(hex: "44C0FF"))
                            .frame(width: 24, height: 24)
                        Text("About")
                    }
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MoreView()
}