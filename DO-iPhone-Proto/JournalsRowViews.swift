import SwiftUI

struct FolderRow: View {
    let folder: JournalFolder
    let isExpanded: Bool
    let isEditMode: Bool
    var isSelectMode: Bool = false
    let onToggle: () -> Void
    let onSelectFolder: () -> Void
    var isRenaming: Bool = false
    @Binding var editedName: String
    var onRenameSubmit: (() -> Void)? = nil
    var nameFieldFocused: FocusState<Bool>.Binding
    var onRename: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onReorder: (() -> Void)? = nil
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Folder icon and content - tappable to toggle expand/collapse
                Button(action: onToggle) {
                    HStack(spacing: 16) {
                        // Layered folder icon with chevron
                        ZStack(alignment: .center) {
                            // Back layer 2 (second journal color, only if 2+ journals)
                            if folder.journals.count >= 2 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(folder.journals[1].color)
                                    .frame(width: isExpanded ? 1 : 10, height: 28)
                                    .shadow(color: Color.black.opacity(0.25), radius: 0.5, x: 0, y: 0)
                                    .offset(x: isExpanded ? 14 : 17, y: 0)
                                    .opacity(isExpanded ? 0 : 1)
                                    .animation(.easeInOut(duration: 0.5), value: isExpanded)
                            }

                            // Back layer 1 (first journal color, only if 1+ journals)
                            if folder.journals.count >= 1 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(folder.journals[0].color)
                                    .frame(width: isExpanded ? 1 : 10, height: 32)
                                    .shadow(color: Color.black.opacity(0.25), radius: 0.5, x: 0, y: 0)
                                    .offset(x: isExpanded ? 11 : 14, y: 0)
                                    .opacity(isExpanded ? 0 : 1)
                                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
                            }

                            // Front layer (always shown - NO ANIMATION)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "F0F0F0"))
                                .frame(width: 30, height: 40)
                                .shadow(color: Color.black.opacity(0.25), radius: 0.5, x: 0, y: 0)
                                .animation(nil, value: isExpanded)

                            // Chevron icon (separate layer on top)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.gray)
                                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                        }
                        .frame(width: 33, height: 40)
                        .offset(x: -2, y: 2)

                        // Folder info
                        VStack(alignment: .leading, spacing: 2) {
                            if isRenaming {
                                TextField("Collection Name", text: $editedName)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .focused(nameFieldFocused)
                                    .onSubmit {
                                        onRenameSubmit?()
                                    }
                                    .submitLabel(.done)
                            } else {
                                Text(folder.name)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                            }

                            HStack(spacing: 4) {
                                Text("\(folder.journalCount) journals")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("\(folder.entryCount) entries")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Ellipsis menu - hidden in Select Mode
                if !isSelectMode {
                    Menu {
                        Button {
                            onSelectFolder()
                        } label: {
                            Label("View", systemImage: "square.grid.2x2")
                        }

                        Button {
                            onRename?()
                        } label: {
                            Label("Rename", systemImage: "character.cursor.ibeam")
                        }

                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 0)
            .padding(.bottom, 4)

            // Only show divider when folder is collapsed
            if !isExpanded {
                Divider()
                    .padding(.leading, 0)
            }
        }
        .alert("Delete Collection", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            if folder.journalCount > 0 {
                Text("This collection contains \(folder.journalCount) \(folder.journalCount == 1 ? "journal" : "journals"). All journals will be preserved and moved out of the collection.")
            } else {
                Text("Are you sure you want to delete this collection?")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                onSelectFolder()
            } label: {
                Label("View", systemImage: "square.grid.2x2")
            }
            .tint(Color(hex: "44C0FF"))
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

struct JournalRow: View {
    let journal: Journal
    let isSelected: Bool
    let isEditMode: Bool
    var isSelectMode: Bool = false
    let onSelect: () -> Void
    var onNewEntry: (() -> Void)? = nil
    var onRename: ((String) -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onMoveToCollection: ((String) -> Void)? = nil
    var onRemoveFromCollection: (() -> Void)? = nil
    var onReorder: (() -> Void)? = nil
    var onEnterSelectMode: (() -> Void)? = nil
    var availableCollections: [JournalFolder] = []
    var isInCollection: Bool = false
    @State private var showingEditJournal = false
    @State private var isRenaming = false
    @State private var editedName = ""
    @State private var showingDeleteConfirmation = false
    @FocusState private var isNameFieldFocused: Bool

    // Extracted row content to allow conditional Button wrapper
    @ViewBuilder
    private var rowContent: some View {
        HStack(spacing: 16) {
            // Color square
            RoundedRectangle(cornerRadius: 4)
                .fill(journal.color)
                .frame(width: 30, height: 40)
                .overlay(
                    // Vertical line inset 2pt from left
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 1)
                            .offset(x: 3)
                    }
                )
                .overlay(
                    // Shared or Concealed icon
                    Group {
                        if journal.isShared == true {
                            Text(DayOneIcon.users.rawValue)
                                .font(.custom("DayOneIcons", size: 16))
                                .foregroundStyle(.white)
                        } else if journal.isConcealed == true {
                            Text(DayOneIcon.eye_cross.rawValue)
                                .font(.custom("DayOneIcons", size: 16))
                                .foregroundStyle(.white)
                        }
                    }
                )
                .offset(x: 0, y: 2)

            // Journal info
            VStack(alignment: .leading, spacing: 4) {
                if isRenaming {
                    TextField("Journal Name", text: $editedName)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .focused($isNameFieldFocused)
                        .onSubmit {
                            if !editedName.isEmpty {
                                onRename?(editedName)
                            }
                            isRenaming = false
                        }
                        .submitLabel(.done)
                } else {
                    Text(journal.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                // Show journal count for "All Entries"
                if let journalCount = journal.journalCount {
                    HStack(spacing: 4) {
                        Text("\(journalCount) journals")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let entryCount = journal.entryCount {
                            Text("\(entryCount) entries")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if journal.isShared == true, let memberCount = journal.memberCount {
                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(memberCount) members")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else if let count = journal.entryCount {
                    HStack(spacing: 4) {
                        Text("\(count) entries")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if journal.isShared == true, let memberCount = journal.memberCount {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(memberCount) members")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()
        }
        .contentShape(Rectangle())
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Conditionally wrap content in Button only when NOT in Select Mode
                if isSelectMode {
                    // Select Mode: No Button wrapper - allows native List selection
                    rowContent
                } else {
                    // Normal Mode: Button wrapper for tap handling
                    Button(action: onSelect) {
                        rowContent
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 0)
            .padding(.bottom, 4)

            Divider()
                .padding(.leading, 0)
        }
        // Only show contextMenu and swipeActions when NOT in Select Mode
        .modifier(JournalRowContextModifier(
            isSelectMode: isSelectMode,
            journal: journal,
            onNewEntry: onNewEntry,
            onEditJournal: { showingEditJournal = true },
            onRename: {
                editedName = journal.name
                isRenaming = true
                isNameFieldFocused = true
            },
            onMoveToCollection: onMoveToCollection,
            onRemoveFromCollection: onRemoveFromCollection,
            onReorder: onReorder,
            onEnterSelectMode: onEnterSelectMode,
            onDelete: { showingDeleteConfirmation = true },
            availableCollections: availableCollections,
            isInCollection: isInCollection
        ))
        .alert("Delete Journal", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("Are you sure you want to delete \"\(journal.name)\"? This action cannot be undone.")
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

// MARK: - JournalRow Context Modifier

struct JournalRowContextModifier: ViewModifier {
    let isSelectMode: Bool
    let journal: Journal
    let onNewEntry: (() -> Void)?
    let onEditJournal: () -> Void
    let onRename: () -> Void
    let onMoveToCollection: ((String) -> Void)?
    let onRemoveFromCollection: (() -> Void)?
    let onReorder: (() -> Void)?
    let onEnterSelectMode: (() -> Void)?
    let onDelete: (() -> Void)?
    let availableCollections: [JournalFolder]
    let isInCollection: Bool

    func body(content: Content) -> some View {
        if isSelectMode {
            // Select Mode: No contextMenu or swipeActions
            content
        } else {
            // Normal Mode: Full contextMenu and swipeActions
            content
                .contextMenu {
                    if let newEntry = onNewEntry {
                        Button {
                            newEntry()
                        } label: {
                            Label("New Entry", systemImage: "plus")
                        }
                    }

                    Button {
                        onEditJournal()
                    } label: {
                        Label("Edit Journal", systemImage: "gearshape")
                    }

                    Button {
                        onRename()
                    } label: {
                        Label("Rename", systemImage: "character.cursor.ibeam")
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

                    Button {
                        onEnterSelectMode?()
                    } label: {
                        Label("Select", systemImage: "checkmark.circle")
                    }

                    Divider()

                    if onDelete != nil {
                        Button(role: .destructive) {
                            onDelete?()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // New Entry (journal color)
                    if let newEntry = onNewEntry {
                        Button {
                            newEntry()
                        } label: {
                            Label("New Entry", systemImage: "plus")
                        }
                        .tint(journal.color)
                    }

                    // Edit Journal (gray)
                    Button {
                        onEditJournal()
                    } label: {
                        Label("Edit", systemImage: "gearshape")
                    }
                    .tint(.gray)
                }
        }
    }
}


struct AllEntriesCollectionRow: View {
    let totalJournalCount: Int
    let totalEntryCount: Int
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // All Entries icon and content - tappable to select
                Button(action: onSelect) {
                    HStack(spacing: 16) {
                        // Layered All Entries icon (no chevron)
                        ZStack(alignment: .center) {
                            // Back layer (offset to the right)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "D6D6D6"))
                                .frame(width: 30, height: 32)
                                .shadow(color: Color.black.opacity(0.25), radius: 0.5, x: 0, y: 0)
                                .offset(x: 4, y: 0)

                            // Front layer
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "F0F0F0"))
                                .frame(width: 30, height: 40)
                                .shadow(color: Color.black.opacity(0.25), radius: 0.5, x: 0, y: 0)
                        }
                        .frame(width: 33, height: 40)
                        .offset(x: -2, y: 2)

                        // All Entries info
                        VStack(alignment: .leading, spacing: 2) {
                            Text("All Entries")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            HStack(spacing: 4) {
                                Text("\(totalJournalCount) journals")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("\(totalEntryCount) entries")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // No disclosure toggle for All Entries
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 0)

            // Divider at bottom
            Divider()
                .padding(.leading, 0)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

// MARK: - Trash Collection-Style Rows

struct TrashRow: View {
    let itemCount: Int
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Trash icon and content - tappable to select
                Button(action: onSelect) {
                    HStack(spacing: 16) {
                        // Trash icon
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                            .frame(width: 30)

                        // Trash info
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Trash")
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundStyle(.primary)

                            Text("\(itemCount) items")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // No disclosure toggle for Trash
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 0)

            // Divider at bottom
            Divider()
                .padding(.leading, 0)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

