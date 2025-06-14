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
    private var experimentsManager = ExperimentsManager.shared
    
    init(viewModel: JournalSelectionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        // All variants now use the same compact layout
        JournalSelectorOriginalView(viewMode: $viewMode, viewModel: viewModel)
    }
}

/// Original Journal Selector layout
struct JournalSelectorOriginalView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var viewMode: ViewMode
    let viewModel: JournalSelectionViewModel
    
    init(viewMode: Binding<ViewMode>, viewModel: JournalSelectionViewModel) {
        self._viewMode = viewMode
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Combined segmented control and buttons row
                HStack(spacing: 12) {
                    // View mode segmented control
                    Picker("View Mode", selection: $viewMode) {
                        Image(systemName: "line.3.horizontal.decrease").tag(ViewMode.compact)
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                        Image(systemName: "square.grid.3x3").tag(ViewMode.grid)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: .infinity)
                    
                    // Compact Add/Edit buttons
                    HStack(spacing: 8) {
                        Button("+ Add") {
                            // TODO: Add new journal action
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.1))
                        )
                        
                        Button("Edit") {
                            // TODO: Edit journals action
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                Divider()
                    .padding(.bottom, 8)
                
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
                        .padding(.top, 8)
                        
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
                        .padding(.top, 12)
                        
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
                        .padding(.top, 12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
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
        .contextMenu {
            Button(action: {
                // TODO: Edit journal action
            }) {
                Label("Edit Journal", systemImage: "pencil")
            }
            
            Button(action: {
                // TODO: New entry action
            }) {
                Label("New Entry", systemImage: "plus")
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
        .contextMenu {
            Button(action: {
                // TODO: Edit journal action
            }) {
                Label("Edit Journal", systemImage: "pencil")
            }
            
            Button(action: {
                // TODO: New entry action
            }) {
                Label("New Entry", systemImage: "plus")
            }
        }
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
        .contextMenu {
            Button(action: {
                // TODO: Edit journal action
            }) {
                Label("Edit Journal", systemImage: "pencil")
            }
            
            Button(action: {
                // TODO: New entry action
            }) {
                Label("New Entry", systemImage: "plus")
            }
        }
    }
}

#Preview {
    JournalSelectorView(viewModel: JournalSelectionViewModel())
}