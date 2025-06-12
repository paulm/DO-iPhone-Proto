import SwiftUI

enum ViewMode: Int, CaseIterable {
    case compact = 0
    case list = 1
    case grid = 2
}

struct JournalSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewMode: ViewMode = .compact
    let viewModel: JournalSelectionViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View mode segmented control
                VStack(spacing: 12) {
                    Picker("View Mode", selection: $viewMode) {
                        Image(systemName: "line.3.horizontal.decrease").tag(ViewMode.compact)
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                        Image(systemName: "square.grid.3x3").tag(ViewMode.grid)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    Divider()
                }
                .padding(.top, 12)
                .background(.white)
                
                // Journal content based on view mode
                ScrollView {
                    switch viewMode {
                    case .compact:
                        LazyVStack(spacing: 4) {
                            ForEach(Journal.allJournals) { journal in
                                CompactJournalRow(
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
                        .padding(.top, 16)
                        
                    case .list:
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
                        
                    case .grid:
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
                            ForEach(Journal.allJournals) { journal in
                                JournalBookView(
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

struct CompactJournalRow: View {
    let journal: Journal
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Small color indicator
                Circle()
                    .fill(journal.color)
                    .frame(width: 12, height: 12)
                
                // Journal name
                Text(journal.name)
                    .font(.body)
                    .fontWeight(isSelected ? .medium : .regular)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Entry count
                if let count = journal.entryCount {
                    Text("\(count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? .gray.opacity(0.1) : .clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
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

struct JournalBookView: View {
    let journal: Journal
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // Book shape
                RoundedRectangle(cornerRadius: 8)
                    .fill(journal.color)
                    .aspectRatio(0.7, contentMode: .fit)
                    .overlay(
                        // Book spine effect
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(journal.color.opacity(0.3))
                                .frame(height: 2)
                                .padding(.horizontal, 8)
                            Spacer()
                        }
                    )
                    .overlay(
                        // Journal title on book cover
                        VStack {
                            Spacer()
                            HStack {
                                Text(journal.name)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                            .padding(.leading, 8)
                        }
                    )
                    .overlay(
                        // Selection indicator
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? .blue : .clear, lineWidth: 3)
                    )
                    .shadow(color: journal.color.opacity(0.3), radius: 4, x: 2, y: 4)
                
                // Entry count only
                if let count = journal.entryCount {
                    Text("\(count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    JournalSelectorView(viewModel: JournalSelectionViewModel())
}