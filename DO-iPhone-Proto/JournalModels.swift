import SwiftUI

// MARK: - Journal Data Models

struct JournalSettings: Codable, Equatable {
    let hidden: Bool
    let conceal: Bool
    let sortMode: String
    let sortOrder: String
    let addLocationToNewEntries: Bool
}

struct JournalFeatures: Codable, Equatable {
    let shouldBeIncludedInAllEntries: Bool
    let shouldBeIncludedInOnThisDay: Bool
    let shouldBeIncludedInStreaks: Bool
    let shouldBeIncludedInTodayView: Bool
}

struct JournalAppearance: Codable, Equatable {
    let templateID: String
    let presetID: String
    let originalCoverImageData: String
    let croppedCoverImageData: String
}

struct JournalData: Codable {
    let id: String
    let name: String
    let description: String
    let type: String
    let colorHex: String
    let iconURL: String
    let settings: JournalSettings
    let features: JournalFeatures
    let appearance: JournalAppearance
}

struct JournalsContainer: Codable {
    let journals: [JournalData]
}

// MARK: - Updated Journal Model
struct Journal: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String
    let type: String
    let color: Color
    let iconURL: String
    let settings: JournalSettings
    let features: JournalFeatures
    let appearance: JournalAppearance
    let entryCount: Int?
    let journalCount: Int? // For "All Entries" - number of journals included

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Initialize from JournalData
    init(from data: JournalData, entryCount: Int? = nil, journalCount: Int? = nil) {
        self.id = data.id
        self.name = data.name
        self.description = data.description
        self.type = data.type
        self.color = Color(hex: data.colorHex)
        self.iconURL = data.iconURL
        self.settings = data.settings
        self.features = data.features
        self.appearance = data.appearance
        self.entryCount = entryCount
        self.journalCount = journalCount
    }

    // Legacy initializer for compatibility
    init(name: String, color: Color, entryCount: Int?, journalCount: Int? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.description = ""
        self.type = "personal"
        self.color = color
        self.iconURL = ""
        self.settings = JournalSettings(
            hidden: false,
            conceal: false,
            sortMode: "entryDate",
            sortOrder: "descending",
            addLocationToNewEntries: true
        )
        self.features = JournalFeatures(
            shouldBeIncludedInAllEntries: true,
            shouldBeIncludedInOnThisDay: true,
            shouldBeIncludedInStreaks: true,
            shouldBeIncludedInTodayView: true
        )
        self.appearance = JournalAppearance(
            templateID: "template-default",
            presetID: "preset-default",
            originalCoverImageData: "",
            croppedCoverImageData: ""
        )
        self.entryCount = entryCount
        self.journalCount = journalCount
    }
}

// MARK: - Journal Loader
class JournalLoader {
    static let shared = JournalLoader()
    
    private init() {}
    
    func loadJournals() -> [Journal] {
        // Try to load from file in project directory first (for development)
        let fileURL = URL(fileURLWithPath: "/Users/paulmayne/Projects/DO-iPhone-Proto/DO-iPhone-Proto/journals.json")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let container = try JSONDecoder().decode(JournalsContainer.self, from: data)
                
                // Convert JournalData to Journal with mock entry counts
                let mockEntryCounts = [238, 22, 9, 4, 12, 19, nil, 45, 33, 8]
                return container.journals.enumerated().map { index, journalData in
                    Journal(from: journalData, entryCount: index < mockEntryCounts.count ? mockEntryCounts[index] : nil)
                }
            } catch {
                print("Error loading journals from JSON: \(error)")
            }
        }
        
        // Try Bundle as fallback
        if let url = Bundle.main.url(forResource: "journals", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let container = try JSONDecoder().decode(JournalsContainer.self, from: data)
                
                // Convert JournalData to Journal with mock entry counts
                let mockEntryCounts = [238, 22, 9, 4, 12, 19, nil, 45, 33, 8]
                return container.journals.enumerated().map { index, journalData in
                    Journal(from: journalData, entryCount: index < mockEntryCounts.count ? mockEntryCounts[index] : nil)
                }
            } catch {
                print("Error loading journals from JSON: \(error)")
            }
        }
        
        // Fallback to hardcoded journals if JSON loading fails
        return [
            Journal(name: "All Entries", color: .gray, entryCount: 238),
            Journal(name: "Journal", color: Color(hex: "44C0FF"), entryCount: 22),
            Journal(name: "Travel", color: .blue, entryCount: 9),
            Journal(name: "Family Memories", color: .green, entryCount: 4),
            Journal(name: "WCEU", color: Color(red: 0.7, green: 0.8, blue: 0.2), entryCount: 12),
            Journal(name: "Notes", color: .orange, entryCount: 19),
            Journal(name: "Prompts", color: Color(red: 1.0, green: 0.6, blue: 0.2), entryCount: nil)
        ]
    }
}

// MARK: - Folder Model
struct JournalFolder: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let journals: [Journal]

    var entryCount: Int {
        journals.compactMap { $0.entryCount }.reduce(0, +)
    }

    var journalCount: Int {
        journals.count
    }

    // Combined color for folder (uses first journal's color)
    var color: Color {
        journals.first?.color ?? .gray
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Journal Item Protocol
protocol JournalItem: Identifiable {
    var id: String { get }
    var name: String { get }
    var color: Color { get }
}

extension Journal: JournalItem {}
extension JournalFolder: JournalItem {}

// MARK: - Journal Extension
extension Journal {
    static let allJournals = JournalLoader.shared.loadJournals()

    // Filter journals based on their features
    static var visibleJournals: [Journal] {
        allJournals.filter { !$0.settings.hidden }
    }

    static var todayViewJournals: [Journal] {
        allJournals.filter { $0.features.shouldBeIncludedInTodayView && !$0.settings.hidden }
    }

    static var onThisDayJournals: [Journal] {
        allJournals.filter { $0.features.shouldBeIncludedInOnThisDay && !$0.settings.hidden }
    }

    // All Entries journal (always shown at top)
    // This is a special journal that aggregates all entries from all journals
    static var allEntriesJournal: Journal? {
        // Try to find a journal named "All Entries"
        if let allEntries = allJournals.first(where: { $0.name == "All Entries" }) {
            return allEntries
        }
        // If not found, create a synthetic "All Entries" journal
        let totalEntryCount = visibleJournals.compactMap { $0.entryCount }.reduce(0, +)
        let totalJournalCount = visibleJournals.count
        // Use deep blue color
        return Journal(
            name: "All Entries",
            color: Color(hex: "333B40"),
            entryCount: totalEntryCount,
            journalCount: totalJournalCount
        )
    }

    // Journals excluding All Entries
    static var journalsExcludingAllEntries: [Journal] {
        guard let allEntries = allEntriesJournal else { return visibleJournals }
        return visibleJournals.filter { $0.id != allEntries.id }
    }

    // Example folders with journals (excluding All Entries)
    static var folders: [JournalFolder] {
        let journals = journalsExcludingAllEntries
        guard journals.count >= 5 else { return [] }

        return [
            JournalFolder(
                id: "folder-work",
                name: "Work",
                journals: Array(journals.prefix(2))
            ),
            JournalFolder(
                id: "folder-personal",
                name: "Personal",
                journals: Array(journals.dropFirst(2).prefix(3))
            )
        ]
    }

    // Journals not in any folder (excluding All Entries)
    static var unfolderedJournals: [Journal] {
        let folderedJournalIDs = Set(folders.flatMap { $0.journals.map { $0.id } })
        return journalsExcludingAllEntries.filter { !folderedJournalIDs.contains($0.id) }
    }

    // Wrapper for mixed journal items
    struct MixedJournalItem: Identifiable {
        let id: String
        let isFolder: Bool
        let journal: Journal?
        let folder: JournalFolder?

        init(journal: Journal) {
            self.id = journal.id
            self.isFolder = false
            self.journal = journal
            self.folder = nil
        }

        init(folder: JournalFolder) {
            self.id = folder.id
            self.isFolder = true
            self.journal = nil
            self.folder = folder
        }
    }

    // Mixed list of folders and unfoldered journals (for display)
    static var mixedJournalItems: [MixedJournalItem] {
        var items: [MixedJournalItem] = []

        let allFolders = folders
        let allUnfoldered = unfolderedJournals

        // Mix folders and journals based on their original indices
        var folderIndex = 0
        var journalIndex = 0

        // Simple interleaving: folder, journal, journal, folder, journal, etc.
        // Insert first folder at position 0
        if folderIndex < allFolders.count {
            items.append(MixedJournalItem(folder: allFolders[folderIndex]))
            folderIndex += 1
        }

        // Add some journals
        while journalIndex < min(2, allUnfoldered.count) {
            items.append(MixedJournalItem(journal: allUnfoldered[journalIndex]))
            journalIndex += 1
        }

        // Add second folder
        if folderIndex < allFolders.count {
            items.append(MixedJournalItem(folder: allFolders[folderIndex]))
            folderIndex += 1
        }

        // Add remaining journals
        while journalIndex < allUnfoldered.count {
            items.append(MixedJournalItem(journal: allUnfoldered[journalIndex]))
            journalIndex += 1
        }

        // Add any remaining folders
        while folderIndex < allFolders.count {
            items.append(MixedJournalItem(folder: allFolders[folderIndex]))
            folderIndex += 1
        }

        return items
    }
}
