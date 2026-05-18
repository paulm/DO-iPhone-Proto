import SwiftUI

struct JournalNode: Identifiable, Equatable {
    let id: String
    let journal: Journal

    var name: String { journal.name }
    var color: Color { journal.color }
    var entryCount: Int? { journal.entryCount }
}

// Collection (formerly Folder) node with expandable contents
struct CollectionNode: Identifiable, Equatable {
    let id: String
    var name: String
    var contents: [JournalNode]
    var isExpanded: Bool = false

    var itemCount: Int { contents.count }
    var color: Color { Color(hex: "333B40") }
}

// Display node union type for rendering
enum DisplayNode: Identifiable, Equatable {
    case journal(JournalNode, isNested: Bool = false, parentCollectionId: String? = nil)
    case collection(CollectionNode)
    case dropZone

    var id: String {
        switch self {
        case .journal(let journal, _, _): return journal.id
        case .collection(let collection): return collection.id
        case .dropZone: return "dropZone"
        }
    }
}

// MARK: - Journals Reorder View

struct JournalsReorderView: View {
    // MARK: - Layout Constants
    private enum Layout {
        static let nestedIndentation: CGFloat = 32
        static let rowVerticalPadding: CGFloat = 4
        static let iconSize: CGFloat = 20
        static let rowSpacing: CGFloat = 12
    }

    // MARK: - Haptics
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    @Environment(\.dismiss) private var dismiss

    // Input data
    let journals: [Journal]
    let folders: [JournalFolder]
    @Binding var journalItems: [Journal.MixedJournalItem]
    let journalsPopulation: JournalsPopulation
    @Binding var shouldAddCollectionOnOpen: Bool

    // State management
    @State private var rootItems: [DisplayNode] = []
    @State private var collections: [String: CollectionNode] = [:]

    // Cached computed properties
    @State private var cachedDisplayedItems: [DisplayNode] = []
    @State private var cachedOrderedCollections: [CollectionNode] = []

    // Flash animation state
    @State private var flashingCollectionId: String? = nil
    @State private var flashColor: Color = .blue
    @State private var flashingJournalId: String? = nil
    @State private var flashingJournalColor: Color = .blue

    // Scroll state
    @State private var scrollToId: String? = nil

    // Track newly added collection for auto-rename
    @State private var newlyAddedCollectionId: String? = nil

    let accentColor = Color(hex: "44C0FF")

    // Computed counts for navigation title
    private var totalJournalCount: Int {
        var count = 0
        for item in rootItems {
            switch item {
            case .journal:
                count += 1
            case .collection(let collection):
                count += collection.contents.count
            case .dropZone:
                break
            }
        }
        return count
    }

    private var totalCollectionCount: Int {
        return collections.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    List {
                        ForEach(cachedDisplayedItems) { item in
                        switch item {
                        case .journal(let journalNode, let isNested, let parentCollectionId):
                            JournalReorderRow(
                                journalNode: journalNode,
                                isNested: isNested,
                                parentCollectionId: parentCollectionId,
                                orderedCollections: cachedOrderedCollections,
                                accentColor: accentColor,
                                isFlashing: flashingJournalId == journalNode.id,
                                flashColor: flashingJournalColor,
                                onMoveToCollection: { collectionId in
                                    moveJournalToCollection(journal: journalNode, collectionId: collectionId)
                                },
                                onRemoveFromCollection: {
                                    removeJournalFromCollection(journal: journalNode)
                                },
                                onRename: { newName in
                                    renameJournal(id: journalNode.id, newName: newName)
                                },
                                onEdit: {
                                    // TODO: Implement edit journal action
                                },
                                onPreviewBook: {
                                    // TODO: Implement preview book action
                                },
                                onExport: {
                                    // TODO: Implement export action
                                },
                                onDelete: {
                                    deleteJournal(id: journalNode.id)
                                }
                            )
                        case .collection(let collection):
                            CollectionReorderRow(
                                collection: collection,
                                accentColor: accentColor,
                                isFlashing: flashingCollectionId == collection.id,
                                flashColor: flashColor,
                                onTap: { toggleCollection(id: collection.id) },
                                onRename: { newName in
                                    renameCollection(id: collection.id, newName: newName)
                                    // Clear the auto-rename flag after renaming
                                    if newlyAddedCollectionId == collection.id {
                                        newlyAddedCollectionId = nil
                                    }
                                },
                                onPreviewBook: {
                                    // TODO: Implement preview book action
                                },
                                onExport: {
                                    // TODO: Implement export action
                                },
                                onDelete: {
                                    deleteCollection(id: collection.id)
                                },
                                shouldAutoRename: newlyAddedCollectionId == collection.id
                            )
                        case .dropZone:
                            EmptyView()
                        }
                    }
                        .onMove(perform: moveItem)
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, .constant(.active)) // Always in edit mode
                    .safeAreaInset(edge: .bottom) {
                        Spacer().frame(height: 70)
                    }
                    .onChange(of: scrollToId) { _, newId in
                        if let id = newId {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(id, anchor: .center)
                                }
                                scrollToId = nil
                            }
                        }
                    }
                }

                // Empty state
                if rootItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.5))

                        Text("No Journals Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Text("Tap the + button below to create your first journal")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .navigationTitle("\(totalJournalCount) \(totalJournalCount == 1 ? "Journal" : "Journals"), \(totalCollectionCount) \(totalCollectionCount == 1 ? "Collection" : "Collections")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Top trailing - Done button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        applyChangesAndDismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(accentColor)
                            .fontWeight(.semibold)
                    }
                }

                // Bottom bar - New Collection button
                ToolbarItem(placement: .bottomBar) {
                    Button("New Collection", systemImage: "folder.badge.plus") {
                        addNewCollection()
                    }
                    .labelStyle(.titleAndIcon)
                }

                // Bottom bar - New Journal button
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }

                ToolbarItem(placement: .bottomBar) {
                    Button("New Journal", systemImage: "plus") {
                        addNewJournal()
                    }
                    .labelStyle(.titleAndIcon)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            initializeFromJournals()
            rebuildCache()

            // Add new collection if requested
            if shouldAddCollectionOnOpen {
                addNewCollection()
                shouldAddCollectionOnOpen = false
            }
        }
    }

    // MARK: - Initialization

    private func initializeFromJournals() {
        // Convert existing data to our node structure
        rootItems = []
        collections = [:]

        // Build collections dictionary from folders
        for folder in folders {
            let journalNodes = folder.journals.map { JournalNode(id: $0.id, journal: $0) }
            let collection = CollectionNode(
                id: folder.id,
                name: folder.name,
                contents: journalNodes,
                isExpanded: false
            )
            collections[collection.id] = collection
        }

        // Build root items based on journalItems order
        for item in journalItems {
            if item.isFolder, let folder = item.folder {
                if let collection = collections[folder.id] {
                    rootItems.append(.collection(collection))
                }
            } else if let journal = item.journal {
                let journalNode = JournalNode(id: journal.id, journal: journal)
                rootItems.append(.journal(journalNode, isNested: false))
            }
        }

        // Auto-expand all collections if fewer than 20 journals total
        let totalJournals = rootItems.reduce(0) { count, item in
            switch item {
            case .journal:
                return count + 1
            case .collection(let collection):
                return count + collection.contents.count
            case .dropZone:
                return count
            }
        }

        if totalJournals < 20 {
            for (id, var collection) in collections {
                collection.isExpanded = true
                collections[id] = collection
            }

            // Update rootItems with expanded collections
            rootItems = rootItems.map { item in
                if case .collection(let collection) = item,
                   let updatedCollection = collections[collection.id] {
                    return .collection(updatedCollection)
                }
                return item
            }
        }
    }

    // MARK: - Cache Management

    private func rebuildCache() {
        var result: [DisplayNode] = []
        for item in rootItems {
            result.append(item)
            if case .collection(let collection) = item, collection.isExpanded {
                result.append(contentsOf: collection.contents.map { .journal($0, isNested: true, parentCollectionId: collection.id) })
            }
        }
        cachedDisplayedItems = result

        cachedOrderedCollections = rootItems.compactMap { item in
            if case .collection(let collection) = item {
                return collection
            }
            return nil
        }
    }

    // MARK: - Collection Operations

    func toggleCollection(id: String) {
        selectionFeedback.selectionChanged()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let index = findCollectionIndex(id: id),
               case .collection(var collection) = rootItems[index] {
                collection.isExpanded.toggle()
                updateCollection(collection)
                rebuildCache()
                applyChangesLive()
            }
        }
    }

    func renameCollection(id: String, newName: String) {
        withAnimation {
            if let index = findCollectionIndex(id: id),
               case .collection(var collection) = rootItems[index] {
                collection.name = newName
                updateCollection(collection)
                rootItems[index] = .collection(collection)
                rebuildCache()
                applyChangesLive()
            }
        }
    }

    func renameJournal(id: String, newName: String) {
        withAnimation {
            // Find journal in root items
            if let index = rootItems.firstIndex(where: {
                if case .journal(let node, _, _) = $0, node.id == id {
                    return true
                }
                return false
            }), case .journal(let node, let isNested, let parentCollectionId) = rootItems[index] {
                // Create new journal with updated name
                let updatedJournal = node.journal.withName(newName)
                let updatedNode = JournalNode(id: node.id, journal: updatedJournal)
                rootItems[index] = .journal(updatedNode, isNested: isNested, parentCollectionId: parentCollectionId)
                rebuildCache()
                applyChangesLive()
                return
            }

            // Find journal in collections
            for (collectionId, var collection) in collections {
                if let journalIndex = collection.contents.firstIndex(where: { $0.id == id }) {
                    // Create new journal with updated name
                    let updatedJournal = collection.contents[journalIndex].journal.withName(newName)
                    let updatedNode = JournalNode(id: collection.contents[journalIndex].id, journal: updatedJournal)
                    collection.contents[journalIndex] = updatedNode
                    updateCollection(collection)
                    rebuildCache()
                    applyChangesLive()
                    return
                }
            }
        }
    }

    func deleteJournal(id: String) {
        impactMedium.impactOccurred()
        withAnimation {
            // Find and remove journal from root items
            if let index = rootItems.firstIndex(where: {
                if case .journal(let node, _, _) = $0, node.id == id {
                    return true
                }
                return false
            }) {
                rootItems.remove(at: index)
                rebuildCache()
                applyChangesLive()
                return
            }

            // Find and remove journal from collections
            for (collectionId, var collection) in collections {
                if let journalIndex = collection.contents.firstIndex(where: { $0.id == id }) {
                    collection.contents.remove(at: journalIndex)
                    updateCollection(collection)
                    rebuildCache()
                    applyChangesLive()
                    return
                }
            }
        }
    }

    func deleteCollection(id: String) {
        impactMedium.impactOccurred()
        withAnimation {
            // Find the collection in rootItems
            guard let index = findCollectionIndex(id: id),
                  case .collection(let collection) = rootItems[index] else {
                return
            }

            // Extract journals from the collection
            let journalsToPreserve = collection.contents.map { journalNode in
                DisplayNode.journal(journalNode, isNested: false)
            }

            // Remove the collection from rootItems
            rootItems.remove(at: index)

            // Insert the journals at the position where the collection was
            rootItems.insert(contentsOf: journalsToPreserve, at: index)

            // Remove from collections dictionary
            collections.removeValue(forKey: id)

            rebuildCache()
            applyChangesLive()
        }
    }

    func addNewCollection() {
        impactMedium.impactOccurred()
        let newId = UUID().uuidString
        withAnimation {
            let newName = generateNextCollectionName()

            // Create the collection node (expanded by default so added journals are visible)
            let newCollection = CollectionNode(id: newId, name: newName, contents: [], isExpanded: true)
            collections[newCollection.id] = newCollection
            rootItems.append(.collection(newCollection))

            rebuildCache()
            applyChangesLive()
        }

        // Scroll to the newly created collection
        scrollToId = newId

        // Mark this collection for auto-rename
        newlyAddedCollectionId = newId
    }

    private func generateNextCollectionName() -> String {
        let existingNames = Set(collections.values.map { $0.name })
        var counter = 1

        while existingNames.contains("Collection \(counter)") {
            counter += 1
        }

        return "Collection \(counter)"
    }

    private func incrementSuffix(_ suffix: String) -> String {
        var chars = Array(suffix)
        var index = chars.count - 1

        while index >= 0 {
            if chars[index] < "Z" {
                chars[index] = Character(UnicodeScalar(chars[index].asciiValue! + 1))
                return String(chars)
            } else {
                chars[index] = "A"
                index -= 1
            }
        }

        return "A" + String(chars)
    }

    func addNewJournal() {
        impactMedium.impactOccurred()

        // Generate a unique name for the new journal
        let newName = generateNextJournalName()

        // Create a new journal with a random color from Day One palette
        let colors = [
            Color(hex: "44C0FF"), Color(hex: "FFC107"), Color(hex: "2DCC71"),
            Color(hex: "3398DB"), Color(hex: "6A6DCD"), Color(hex: "607D8B"),
            Color(hex: "C27BD2"), Color(hex: "FF983B"), Color(hex: "E91E63"),
            Color(hex: "16D6D9")
        ]
        let randomColor = colors.randomElement() ?? Color(hex: "44C0FF")

        // Create a new journal with random color
        let newJournal = Journal(
            name: newName,
            color: randomColor,
            entryCount: 0
        )

        // Create node and add to bottom of root items
        let journalNode = JournalNode(id: newJournal.id, journal: newJournal)
        let newId = journalNode.id
        rootItems.append(.journal(journalNode, isNested: false))

        // Rebuild cache and apply changes
        rebuildCache()
        applyChangesLive()

        // Scroll to the newly created journal
        scrollToId = newId
    }

    private func generateNextJournalName() -> String {
        // Collect all existing journal names from rootItems
        var existingNames = Set<String>()
        for item in rootItems {
            switch item {
            case .journal(let journalNode, _, _):
                existingNames.insert(journalNode.name)
            case .collection(let collection):
                for journalNode in collection.contents {
                    existingNames.insert(journalNode.name)
                }
            case .dropZone:
                break
            }
        }

        var counter = 1
        while existingNames.contains("Journal \(counter)") {
            counter += 1
        }

        return "Journal \(counter)"
    }

    // MARK: - Save and Dismiss

    /// Apply current state to journalItems binding in real-time
    private func applyChangesLive() {
        var updatedItems: [Journal.MixedJournalItem] = []

        for item in rootItems {
            switch item {
            case .journal(let journalNode, _, _):
                // Root-level journal - use the journal stored in the node
                updatedItems.append(Journal.MixedJournalItem(journal: journalNode.journal))

            case .collection(let collection):
                // Collection with its journals - rebuild folder with reordered contents
                let reorderedJournals = collection.contents.map { journalNode in
                    journalNode.journal
                }
                let updatedFolder = JournalFolder(
                    id: collection.id,
                    name: collection.name,
                    journals: reorderedJournals
                )
                updatedItems.append(Journal.MixedJournalItem(folder: updatedFolder))

            case .dropZone:
                break
            }
        }

        // Update the binding immediately (live updates)
        journalItems = updatedItems
    }

    func applyChangesAndDismiss() {
        // Apply any final changes
        applyChangesLive()

        // Dismiss the modal
        dismiss()
    }

    func findCollectionIndex(id: String) -> Int? {
        rootItems.firstIndex { item in
            if case .collection(let c) = item, c.id == id {
                return true
            }
            return false
        }
    }

    func updateCollection(_ collection: CollectionNode) {
        collections[collection.id] = collection
        if let index = findCollectionIndex(id: collection.id) {
            rootItems[index] = .collection(collection)
        }
    }

    // MARK: - Journal Movement

    func moveJournalToCollection(journal: JournalNode, collectionId: String) {
        guard var collection = collections[collectionId] else { return }

        withAnimation {
            removeJournalFromSource(journal)
            collection.contents.append(journal)
            updateCollection(collection)
            rebuildCache()
            applyChangesLive()
        }

        // Trigger flash animation on both the collection and the journal with journal's color
        flashingCollectionId = collectionId
        flashingJournalId = journal.id
        flashColor = journal.journal.color
        flashingJournalColor = journal.journal.color
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            flashingCollectionId = nil
            flashingJournalId = nil
        }
    }

    func removeJournalFromCollection(journal: JournalNode) {
        withAnimation {
            var parentCollectionId: String?
            var parentCollectionIndex: Int?

            for (index, item) in rootItems.enumerated() {
                if case .collection(let collection) = item {
                    if collection.contents.contains(where: { $0.id == journal.id }) {
                        parentCollectionId = collection.id
                        parentCollectionIndex = index
                        break
                    }
                }
            }

            guard let collectionId = parentCollectionId,
                  let collectionIndex = parentCollectionIndex,
                  var collection = collections[collectionId] else { return }

            collection.contents.removeAll { $0.id == journal.id }
            updateCollection(collection)

            rootItems.insert(.journal(journal, isNested: false), at: collectionIndex + 1)
            rebuildCache()
            applyChangesLive()
        }
    }

    func removeJournalFromSource(_ journal: JournalNode) {
        if let index = rootItems.firstIndex(where: {
            if case .journal(let j, _, _) = $0, j.id == journal.id { return true }
            return false
        }) {
            rootItems.remove(at: index)
            return
        }

        for (_, var collection) in collections {
            if let index = collection.contents.firstIndex(where: { $0.id == journal.id }) {
                collection.contents.remove(at: index)
                updateCollection(collection)
                return
            }
        }
    }

    // MARK: - Drag & Drop

    func moveItem(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        let movedItem = cachedDisplayedItems[sourceIndex]

        let operation = determineMoveOperation(movedItem: movedItem, sourceIndex: sourceIndex, destination: destination)

        withAnimation {
            switch operation {
            case .collectionMove(let fromRootIndex, let toRootIndex):
                rootItems.move(fromOffsets: IndexSet(integer: fromRootIndex), toOffset: toRootIndex)

            case .sameContextMove(let sourceContext, let fromIndex, let toIndex):
                performSameContextMove(sourceContext: sourceContext, fromIndex: fromIndex, toIndex: toIndex)

            case .crossLevelMove(let journal, _, let toContext, let destination):
                performCrossLevelMove(journal: journal, fromContext: getItemContext(at: sourceIndex), toContext: toContext, destination: destination)

            case .invalid:
                return
            }

            impactLight.impactOccurred()
            rebuildCache()
            applyChangesLive()
        }
    }

    private func determineMoveOperation(movedItem: DisplayNode, sourceIndex: Int, destination: Int) -> MoveOperation {
        if case .dropZone = movedItem { return .invalid }

        if case .collection = movedItem {
            let rootIndex = mapDisplayIndexToRootIndex(sourceIndex)
            let destRootIndex = mapDisplayIndexToRootIndex(destination)
            guard rootIndex >= 0 && rootIndex < rootItems.count else { return .invalid }
            guard destRootIndex >= 0 && destRootIndex <= rootItems.count else { return .invalid }
            return .collectionMove(fromRootIndex: rootIndex, toRootIndex: destRootIndex)
        }

        guard case .journal(let journal, _, _) = movedItem else { return .invalid }

        let sourceContext = getItemContext(at: sourceIndex)
        var destinationContext = getItemContext(at: destination)

        if case .inCollection(let sourceCollectionId) = sourceContext,
           destinationContext != sourceContext {
            if let collectionIndex = cachedDisplayedItems.firstIndex(where: { item in
                if case .collection(let c) = item, c.id == sourceCollectionId { return true }
                return false
            }),
               case .collection(let sourceCollection) = cachedDisplayedItems[collectionIndex] {
                let collectionEndIndex = collectionIndex + sourceCollection.contents.count
                if destination == collectionEndIndex + 1 {
                    destinationContext = .inCollection(sourceCollectionId)
                }
            }
        }

        if sourceContext == destinationContext {
            return .sameContextMove(sourceContext: sourceContext, fromIndex: sourceIndex, toIndex: destination)
        }

        return .crossLevelMove(journal: journal, fromContext: sourceContext, toContext: destinationContext, destination: destination)
    }

    private func performSameContextMove(sourceContext: ItemContext, fromIndex: Int, toIndex: Int) {
        if sourceContext == .root {
            let rootIndex = mapDisplayIndexToRootIndex(fromIndex)
            let destRootIndex = mapDisplayIndexToRootIndex(toIndex)
            guard rootIndex >= 0 && rootIndex < rootItems.count else { return }
            guard destRootIndex >= 0 && destRootIndex <= rootItems.count else { return }
            rootItems.move(fromOffsets: IndexSet(integer: rootIndex), toOffset: destRootIndex)
        } else if case .inCollection(let collectionId) = sourceContext,
                  var collection = collections[collectionId] {
            let collectionStartIndex = cachedDisplayedItems.firstIndex { item in
                if case .collection(let c) = item, c.id == collectionId { return true }
                return false
            }

            if let collectionStart = collectionStartIndex {
                let sourceInCollection = fromIndex - collectionStart - 1
                let destInCollection = toIndex - collectionStart - 1
                guard sourceInCollection >= 0 && sourceInCollection < collection.contents.count else { return }
                guard destInCollection >= 0 && destInCollection <= collection.contents.count else { return }
                collection.contents.move(fromOffsets: IndexSet(integer: sourceInCollection), toOffset: destInCollection)
                updateCollection(collection)
            }
        }
    }

    private func performCrossLevelMove(journal: JournalNode, fromContext: ItemContext, toContext: ItemContext, destination: Int) {
        var calculatedInsertPosition: Int?
        var calculatedCollectionId: String?

        if case .inCollection(let destCollectionId) = toContext,
           let destCollection = collections[destCollectionId] {
            if let collectionStartIndex = cachedDisplayedItems.firstIndex(where: { item in
                if case .collection(let c) = item, c.id == destCollectionId { return true }
                return false
            }) {
                let positionInCollection = destination - collectionStartIndex - 1
                calculatedInsertPosition = max(0, min(positionInCollection, destCollection.contents.count))
                calculatedCollectionId = destCollectionId
            }
        } else {
            calculatedInsertPosition = mapDisplayIndexToRootIndex(destination)
        }

        removeJournalFromSource(journal)

        if let collectionId = calculatedCollectionId,
           let insertPos = calculatedInsertPosition,
           var destCollection = collections[collectionId] {
            let finalInsertPosition = min(insertPos, destCollection.contents.count)
            destCollection.contents.insert(journal, at: finalInsertPosition)
            if !destCollection.isExpanded {
                destCollection.isExpanded = true
            }
            updateCollection(destCollection)
        } else if let insertPos = calculatedInsertPosition {
            let finalInsertPosition = min(insertPos, rootItems.count)
            rootItems.insert(.journal(journal, isNested: false), at: finalInsertPosition)
        }
    }

    func mapDisplayIndexToRootIndex(_ displayIndex: Int) -> Int {
        var rootCount = 0
        var currentDisplayIndex = 0

        for item in rootItems {
            if currentDisplayIndex >= displayIndex {
                return rootCount
            }
            currentDisplayIndex += 1
            if case .collection(let collection) = item, collection.isExpanded {
                currentDisplayIndex += collection.contents.count
            }
            rootCount += 1
        }

        return rootCount
    }

    enum ItemContext: Equatable {
        case root
        case inCollection(String)
    }

    enum MoveOperation {
        case collectionMove(fromRootIndex: Int, toRootIndex: Int)
        case sameContextMove(sourceContext: ItemContext, fromIndex: Int, toIndex: Int)
        case crossLevelMove(journal: JournalNode, fromContext: ItemContext, toContext: ItemContext, destination: Int)
        case invalid
    }

    func getItemContext(at index: Int) -> ItemContext {
        guard index < cachedDisplayedItems.count else { return .root }

        for i in stride(from: index, through: 0, by: -1) {
            if case .collection(let collection) = cachedDisplayedItems[i] {
                if collection.isExpanded && i < index {
                    let collectionEndIndex = i + collection.contents.count
                    if index > i && index <= collectionEndIndex {
                        return .inCollection(collection.id)
                    }
                }
                if i == index {
                    return .root
                }
            }
        }

        return .root
    }
}

// MARK: - Journal Reorder Row

struct JournalReorderRow: View {
    let journalNode: JournalNode
    let isNested: Bool
    let parentCollectionId: String?
    let orderedCollections: [CollectionNode]
    let accentColor: Color
    let isFlashing: Bool
    let flashColor: Color
    let onMoveToCollection: (String) -> Void
    let onRemoveFromCollection: () -> Void
    let onRename: ((String) -> Void)?
    let onEdit: (() -> Void)?
    let onPreviewBook: (() -> Void)?
    let onExport: (() -> Void)?
    let onDelete: (() -> Void)?

    @State private var isRenaming = false
    @State private var editedName = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var showingDeleteConfirmation = false

    // Filter out the current collection from available collections
    private var availableCollections: [CollectionNode] {
        if let parentId = parentCollectionId {
            return orderedCollections.filter { $0.id != parentId }
        }
        return orderedCollections
    }

    private enum Layout {
        static let iconSize: CGFloat = 12
        static let rowSpacing: CGFloat = 8
        static let rowVerticalPadding: CGFloat = 0
        static let nestedIndentation: CGFloat = 32
    }

    var body: some View {
        HStack(spacing: Layout.rowSpacing) {
            // Use smaller circle with journal's color
            Circle()
                .fill(journalNode.color)
                .frame(width: Layout.iconSize, height: Layout.iconSize)

            if isRenaming {
                TextField("Journal Name", text: $editedName)
                    .font(.body)
                    .focused($isNameFieldFocused)
                    .onSubmit {
                        if !editedName.isEmpty {
                            onRename?(editedName)
                        }
                        isRenaming = false
                    }
                    .submitLabel(.done)
                    .onChange(of: isNameFieldFocused) { _, isFocused in
                        if !isFocused && isRenaming {
                            if !editedName.isEmpty {
                                onRename?(editedName)
                            }
                            isRenaming = false
                        }
                    }
            } else {
                Text(journalNode.name)
                    .font(.body)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }

            Spacer()

            // Shared or Concealed icon
            if journalNode.journal.isShared == true {
                Text(DayOneIcon.users.rawValue)
                    .font(.custom("DayOneIcons", size: 14))
                    .foregroundStyle(.secondary)
            } else if journalNode.journal.isConcealed == true {
                Text(DayOneIcon.eye_cross.rawValue)
                    .font(.custom("DayOneIcons", size: 14))
                    .foregroundStyle(.secondary)
            }

            // Ellipsis menu
            Menu {
                // Entry count as first item (static, non-interactive)
                if let count = journalNode.entryCount {
                    Button { } label: {
                        Text("\(count) \(count == 1 ? "Entry" : "Entries")")
                    }
                    .disabled(true)

                    Divider()
                }

                if let onEdit = onEdit {
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit Journal", systemImage: "gearshape")
                    }
                }

                if let onRename = onRename {
                    Button {
                        editedName = journalNode.name
                        isRenaming = true
                        isNameFieldFocused = true
                    } label: {
                        Label("Rename", systemImage: "character.cursor.ibeam")
                    }
                }

                if !availableCollections.isEmpty {
                    Menu {
                        ForEach(availableCollections, id: \.id) { collection in
                            Button {
                                onMoveToCollection(collection.id)
                            } label: {
                                Label(collection.name, systemImage: "folder")
                            }
                        }
                    } label: {
                        Label("Move to Collection", systemImage: "plus.square.fill")
                    }
                }

                if isNested {
                    Button {
                        onRemoveFromCollection()
                    } label: {
                        Label("Remove from Collection", systemImage: "minus.square.fill")
                    }
                }

                Divider()

                if let onExport = onExport {
                    Button {
                        onExport()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }

                if let onPreviewBook = onPreviewBook {
                    Button {
                        onPreviewBook()
                    } label: {
                        Label("Preview Book", systemImage: "book")
                    }
                }

                if let onDelete = onDelete {
                    Divider()

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Layout.rowVerticalPadding)
        .padding(.leading, isNested ? Layout.nestedIndentation : 0)
        .listRowBackground(
            Rectangle()
                .fill(flashColor.opacity(isFlashing ? 0.1 : 0))
                .animation(.easeOut(duration: 0.4), value: isFlashing)
        )
        .onTapGesture(count: 2) {
            editedName = journalNode.name
            isRenaming = true
            isNameFieldFocused = true
        }
        .alert("Delete Journal", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("Are you sure you want to delete \"\(journalNode.name)\"? This action cannot be undone.")
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 24))
    }
}

// MARK: - Collection Reorder Row

struct CollectionReorderRow: View {
    let collection: CollectionNode
    let accentColor: Color
    let isFlashing: Bool
    let flashColor: Color
    let onTap: () -> Void
    let onRename: ((String) -> Void)?
    let onPreviewBook: (() -> Void)?
    let onExport: (() -> Void)?
    let onDelete: (() -> Void)?
    let shouldAutoRename: Bool

    @State private var isRenaming = false
    @State private var editedName = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var showingDeleteConfirmation = false

    private enum Layout {
        static let iconSize: CGFloat = 20
        static let rowSpacing: CGFloat = 8
        static let rowVerticalPadding: CGFloat = 4
    }

    var body: some View {
        HStack(spacing: Layout.rowSpacing) {
            // Use media-library-folder icon like main journals page
            Image("media-library-folder")
                .resizable()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .foregroundStyle(collection.color)

            if isRenaming {
                TextField("Collection Name", text: $editedName)
                    .font(.body)
                    .fontWeight(.semibold)
                    .focused($isNameFieldFocused)
                    .onSubmit {
                        if !editedName.isEmpty {
                            onRename?(editedName)
                        }
                        isRenaming = false
                    }
                    .submitLabel(.done)
                    .onChange(of: isNameFieldFocused) { _, isFocused in
                        if !isFocused && isRenaming {
                            if !editedName.isEmpty {
                                onRename?(editedName)
                            }
                            isRenaming = false
                        }
                    }
            } else {
                Text(collection.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }

            Spacer()

            // Ellipsis menu
            Menu {
                // Journal count as first item (static, non-interactive)
                Button { } label: {
                    Text("\(collection.itemCount) \(collection.itemCount == 1 ? "Journal" : "Journals")")
                }
                .disabled(true)

                Divider()

                if let onRename = onRename {
                    Button {
                        editedName = collection.name
                        isRenaming = true
                        isNameFieldFocused = true
                    } label: {
                        Label("Rename", systemImage: "character.cursor.ibeam")
                    }
                }

                if let onPreviewBook = onPreviewBook {
                    Button {
                        onPreviewBook()
                    } label: {
                        Label("Preview Book", systemImage: "book")
                    }
                }

                if let onExport = onExport {
                    Button {
                        onExport()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }

                if let onDelete = onDelete {
                    Divider()

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(collection.isExpanded ? 90 : 0))
        }
        .padding(.vertical, Layout.rowVerticalPadding)
        .listRowBackground(
            Rectangle()
                .fill(flashColor.opacity(isFlashing ? 0.1 : 0))
                .animation(.easeOut(duration: 0.4), value: isFlashing)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onTapGesture(count: 2) {
            editedName = collection.name
            isRenaming = true
            isNameFieldFocused = true
        }
        .alert("Delete Collection", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            if collection.itemCount > 0 {
                Text("This collection contains \(collection.itemCount) \(collection.itemCount == 1 ? "journal" : "journals"). All journals will be preserved and moved out of the collection.")
            } else {
                Text("Are you sure you want to delete this collection?")
            }
        }
        .onAppear {
            if shouldAutoRename {
                editedName = "" // Clear the name so user can type directly
                isRenaming = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isNameFieldFocused = true
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
}

// MARK: - Create Journal View

