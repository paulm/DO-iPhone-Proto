import SwiftUI

struct CreateCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    let journalItems: [Journal.MixedJournalItem]
    let onCreate: (String, [String]) -> Void

    @State private var collectionName = ""
    @State private var selectedJournalIds: Set<String> = []
    @State private var showJournalsInOtherCollections = false
    @FocusState private var isNameFocused: Bool

    // Separate journals into two categories
    private var journalsNotInCollections: [Journal] {
        journalItems.compactMap { item in
            item.journal
        }
    }

    private var journalsInCollections: [(collection: JournalFolder, journal: Journal)] {
        var result: [(JournalFolder, Journal)] = []
        for item in journalItems {
            if let folder = item.folder {
                for journal in folder.journals {
                    result.append((folder, journal))
                }
            }
        }
        return result
    }

    private var selectedCount: Int {
        selectedJournalIds.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Collection Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Collection Name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)

                            TextField("Collection", text: $collectionName)
                                .font(.system(size: 20, weight: .medium))
                                .focused($isNameFocused)
                                .padding(16)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal, 16)
                        }
                        .padding(.top, 20)

                        // Journals Not in Collections
                        if !journalsNotInCollections.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Available Journals")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 0) {
                                    ForEach(Array(journalsNotInCollections.enumerated()), id: \.element.id) { index, journal in
                                        JournalToggleRow(
                                            journal: journal,
                                            isSelected: selectedJournalIds.contains(journal.id),
                                            onToggle: {
                                                if selectedJournalIds.contains(journal.id) {
                                                    selectedJournalIds.remove(journal.id)
                                                } else {
                                                    selectedJournalIds.insert(journal.id)
                                                }
                                            }
                                        )

                                        if index < journalsNotInCollections.count - 1 {
                                            Divider()
                                                .padding(.leading, 62)
                                        }
                                    }
                                }
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal, 16)
                            }
                        }

                        // Journals in Other Collections (Collapsible)
                        if !journalsInCollections.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: {
                                    withAnimation {
                                        showJournalsInOtherCollections.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text("Journals in Other Collections")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .rotationEffect(.degrees(showJournalsInOtherCollections ? 90 : 0))
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .buttonStyle(.plain)

                                if showJournalsInOtherCollections {
                                    VStack(spacing: 0) {
                                        ForEach(Array(journalsInCollections.enumerated()), id: \.element.journal.id) { index, item in
                                            JournalToggleRow(
                                                journal: item.journal,
                                                collectionName: item.collection.name,
                                                isSelected: selectedJournalIds.contains(item.journal.id),
                                                onToggle: {
                                                    if selectedJournalIds.contains(item.journal.id) {
                                                        selectedJournalIds.remove(item.journal.id)
                                                    } else {
                                                        selectedJournalIds.insert(item.journal.id)
                                                    }
                                                }
                                            )

                                            if index < journalsInCollections.count - 1 {
                                                Divider()
                                                    .padding(.leading, 62)
                                            }
                                        }
                                    }
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal, 16)
                                }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("\(selectedCount) Journal\(selectedCount == 1 ? "" : "s")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onCreate(collectionName, Array(selectedJournalIds))
                    } label: {
                        Text("Create")
                            .foregroundColor(collectionName.isEmpty ? Color.gray.opacity(0.4) : Color(hex: "44C0FF"))
                            .fontWeight(.semibold)
                    }
                    .disabled(collectionName.isEmpty)
                }
            }
            .onAppear {
                // Auto-focus the text field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFocused = true
                }
            }
        }
    }
}

// MARK: - Journal Toggle Row

struct JournalToggleRow: View {
    let journal: Journal
    var collectionName: String? = nil
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
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
                    Text(journal.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let collectionName = collectionName {
                        Text("in \(collectionName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if let count = journal.entryCount {
                        Text("\(count) entries")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Toggle
                Toggle("", isOn: Binding(
                    get: { isSelected },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Picker Sheet

