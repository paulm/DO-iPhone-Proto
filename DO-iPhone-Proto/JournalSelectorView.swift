import SwiftUI

struct JournalSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: JournalSelectionViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Journal list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Journal.allJournals) { journal in
                            JournalRow(
                                journal: journal,
                                isSelected: journal.id == viewModel.selectedJournal.id,
                                onSelect: {
                                    viewModel.selectJournal(journal)
                                    dismiss()
                                }
                            )
                        }
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
    let journal: Journal
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Color square
                RoundedRectangle(cornerRadius: 6)
                    .fill(journal.color)
                    .frame(width: 32, height: 32)
                
                // Journal info
                VStack(alignment: .leading, spacing: 2) {
                    Text(journal.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    if let count = journal.entryCount {
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
    JournalSelectorView(viewModel: JournalSelectionViewModel())
}