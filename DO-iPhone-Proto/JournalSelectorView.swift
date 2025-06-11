import SwiftUI

struct JournalSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Journal list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        // All Entries
                        JournalRow(
                            color: .gray,
                            title: "All Entries",
                            entryCount: 238,
                            isSelected: false
                        )
                        
                        // Journal (Selected)
                        JournalRow(
                            color: Color(hex: "44C0FF"),
                            title: "Journal",
                            entryCount: 22,
                            isSelected: true
                        )
                        
                        // Travel
                        JournalRow(
                            color: .blue,
                            title: "Travel",
                            entryCount: 9,
                            isSelected: false
                        )
                        
                        // Family Memories
                        JournalRow(
                            color: .green,
                            title: "Family Memories",
                            entryCount: 4,
                            isSelected: false
                        )
                        
                        // WCEU
                        JournalRow(
                            color: Color(red: 0.7, green: 0.8, blue: 0.2),
                            title: "WCEU",
                            entryCount: 12,
                            isSelected: false
                        )
                        
                        // Notes
                        JournalRow(
                            color: .orange,
                            title: "Notes",
                            entryCount: 19,
                            isSelected: false
                        )
                        
                        // Prompts
                        JournalRow(
                            color: Color(red: 1.0, green: 0.6, blue: 0.2),
                            title: "Prompts",
                            entryCount: nil,
                            isSelected: false
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Journals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("+ Add") {
                        // TODO: Add new journal action
                    }
                    .foregroundStyle(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button("Edit") {
                            // TODO: Edit journals action
                        }
                        .foregroundStyle(.primary)
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
    }
}

struct JournalRow: View {
    let color: Color
    let title: String
    let entryCount: Int?
    let isSelected: Bool
    
    var body: some View {
        Button(action: {
            // TODO: Select journal action
        }) {
            HStack(spacing: 16) {
                // Color square
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: 32, height: 32)
                
                // Journal info
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    if let count = entryCount {
                        Text("\(count) entries")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .gray.opacity(0.15) : .clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    JournalSelectorView()
}