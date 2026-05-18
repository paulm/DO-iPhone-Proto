import SwiftUI

struct JournalBookView: View {
    let journal: Journal
    let isSelected: Bool
    let onSelect: () -> Void
    var onNewEntry: (() -> Void)? = nil
    var onRename: ((String) -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onMoveToCollection: ((String) -> Void)? = nil
    var onRemoveFromCollection: (() -> Void)? = nil
    var onReorder: (() -> Void)? = nil
    var availableCollections: [JournalFolder] = []
    var isInCollection: Bool = false
    @State private var showingEditJournal = false
    @State private var showingDeleteConfirmation = false

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
                    .overlay(
                        // New Entry button (top-right corner)
                        Group {
                            if let onNewEntry = onNewEntry {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            onNewEntry()
                                        }) {
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 24, height: 24)
                                                .overlay(
                                                    Image(systemName: "plus")
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundStyle(journal.color)
                                                )
                                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(6)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    )
                    .shadow(color: journal.color.opacity(0.3), radius: 4, x: 2, y: 4)
                    .offset(x: 0, y: 2)

                // Entry count (and journal count for "All Entries")
                if let journalCount = journal.journalCount {
                    // For "All Entries"
                    HStack(spacing: 4) {
                        Text("\(journalCount) journals")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        if let entryCount = journal.entryCount {
                            Text("\(entryCount)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            if journal.isShared == true, let memberCount = journal.memberCount {
                                Text("•")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text("\(memberCount)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                } else if let count = journal.entryCount {
                    HStack(spacing: 4) {
                        Text("\(count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        if journal.isShared == true, let memberCount = journal.memberCount {
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(memberCount)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            if let newEntry = onNewEntry {
                Button {
                    newEntry()
                } label: {
                    Label("New Entry", systemImage: "plus")
                }
            }

            Button {
                showingEditJournal = true
            } label: {
                Label("Edit Journal", systemImage: "gearshape")
            }

            if let onRename = onRename {
                Button {
                    onRename("")
                } label: {
                    Label("Rename", systemImage: "character.cursor.ibeam")
                }
            }

            if !availableCollections.isEmpty {
                Menu {
                    ForEach(availableCollections, id: \.id) { collection in
                        Button {
                            onMoveToCollection?(collection.id)
                        } label: {
                            Label(collection.name, systemImage: "folder")
                        }
                    }
                } label: {
                    Label("Move to Collection", systemImage: "plus.square.fill")
                }
            }

            if isInCollection {
                Button {
                    onRemoveFromCollection?()
                } label: {
                    Label("Remove from Collection", systemImage: "minus.square.fill")
                }
            }

            Button {
                onReorder?()
            } label: {
                Label("Reorder", systemImage: "arrow.up.arrow.down")
            }

            Divider()

            if let onDelete = onDelete {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .alert("Delete Journal", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("Are you sure you want to delete \"\(journal.name)\"? This action cannot be undone.")
        }
    }
}

// MARK: - Recent Journal Book View (smaller, no entry count)
struct RecentJournalBookView: View {
    let journal: Journal
    let isSelected: Bool
    let onSelect: () -> Void
    var onNewEntry: (() -> Void)? = nil

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                // Book shape
                RoundedRectangle(cornerRadius: 6)
                    .fill(journal.color)
                    .aspectRatio(0.7, contentMode: .fit)
                    .overlay(
                        // Book spine effect
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(journal.color.opacity(0.3))
                                .frame(height: 2)
                                .padding(.horizontal, 6)
                            Spacer()
                        }
                    )
                    .overlay(
                        // Journal title on book cover - smaller font
                        VStack {
                            Spacer()
                            HStack {
                                Text(journal.name)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Spacer()
                            }
                            .padding(.bottom, 6)
                            .padding(.leading, 6)
                        }
                    )
                    .overlay(
                        // Selection indicator
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isSelected ? .blue : .clear, lineWidth: 2)
                    )
                    .overlay(
                        // New Entry button (top-right corner)
                        Group {
                            if let onNewEntry = onNewEntry {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            onNewEntry()
                                        }) {
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 26, height: 26)
                                                .overlay(
                                                    Image(systemName: "plus")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundStyle(journal.color)
                                                )
                                                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 0)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(6)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    )
                    .shadow(color: journal.color.opacity(0.3), radius: 4, x: 0, y: 0)
                // No entry count displayed
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Folder Detail View

struct RecentEntryCard: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Entry content
            VStack(alignment: .leading, spacing: 0) {
                // Combined title and content
                Text("\(entry.title) \(entry.preview)")
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(minHeight: 80)

            // Journal indicator at bottom
            HStack(spacing: 8) {
                Circle()
                    .fill(entry.journalColor)
                    .frame(width: 8, height: 8)

                Text(entry.journalName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Journals Sections Order View
