import SwiftUI

/// Primary timeline view with navigation and entry creation
struct TimelineView: View {
    @State private var viewModel = RootViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Empty state illustration
                VStack(spacing: 20) {
                    Image(systemName: "calendar")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                    
                    Text("Your Journal Awaits")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Start capturing your memories")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Empty journal state. Your journal awaits. Start capturing your memories.")
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button {
                        // Timeline navigation placeholder
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Timeline")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityLabel("View timeline")
                    
                    Button {
                        viewModel.showingNewEntry = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("New Entry")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.tint, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Create new journal entry")
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("Day One")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.blue.gradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $viewModel.showingNewEntry) {
                EntryView()
            }
        }
    }
}

#Preview {
    TimelineView()
}