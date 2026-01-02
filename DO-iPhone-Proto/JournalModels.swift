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
    let isShared: Bool? // Shared with other users
    let isConcealed: Bool? // Concealed/private journal

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Initialize from JournalData
    init(from data: JournalData, entryCount: Int? = nil, journalCount: Int? = nil, isShared: Bool? = nil, isConcealed: Bool? = nil) {
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
        self.isShared = isShared
        self.isConcealed = isConcealed
    }

    // Copy initializer that preserves all properties including ID
    init(
        id: String,
        name: String,
        description: String,
        type: String,
        color: Color,
        iconURL: String,
        settings: JournalSettings,
        features: JournalFeatures,
        appearance: JournalAppearance,
        entryCount: Int?,
        journalCount: Int?,
        isShared: Bool? = nil,
        isConcealed: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.color = color
        self.iconURL = iconURL
        self.settings = settings
        self.features = features
        self.appearance = appearance
        self.entryCount = entryCount
        self.journalCount = journalCount
        self.isShared = isShared
        self.isConcealed = isConcealed
    }

    // Legacy initializer for compatibility
    init(name: String, color: Color, entryCount: Int?, journalCount: Int? = nil, coverImage: String? = nil, isShared: Bool? = nil, isConcealed: Bool? = nil) {
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
            originalCoverImageData: coverImage ?? "",
            croppedCoverImageData: coverImage ?? ""
        )
        self.entryCount = entryCount
        self.journalCount = journalCount
        self.isShared = isShared
        self.isConcealed = isConcealed
    }
}

// MARK: - Journal Extension
extension Journal {
    // Create a copy with a new name (preserves ID and all other properties)
    func withName(_ newName: String) -> Journal {
        return Journal(
            id: self.id,
            name: newName,
            description: self.description,
            type: self.type,
            color: self.color,
            iconURL: self.iconURL,
            settings: self.settings,
            features: self.features,
            appearance: self.appearance,
            entryCount: self.entryCount,
            journalCount: self.journalCount,
            isShared: self.isShared,
            isConcealed: self.isConcealed
        )
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

    // Combined color for folder (always Deep Blue for collections)
    var color: Color {
        Color(hex: "333B40")
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - JournalFolder Extension
extension JournalFolder {
    // Create a copy with a new name (preserves ID and journals)
    func withName(_ newName: String) -> JournalFolder {
        return JournalFolder(
            id: self.id,
            name: newName,
            journals: self.journals
        )
    }

    // Create a copy with updated journals array (preserves ID and name)
    func withJournals(_ journals: [Journal]) -> JournalFolder {
        return JournalFolder(
            id: self.id,
            name: self.name,
            journals: journals
        )
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
    // Sample journals with varying entry counts (2-149)
    // Using only Day One colors from day-one-colors.json
    static var sampleJournals: [Journal] {
        return [
            Journal(name: "Journal", color: Color(hex: "44C0FF"), entryCount: 87), // DayOne Blue
            Journal(name: "Notes", color: Color(hex: "FFC107"), entryCount: 142), // Honey
            Journal(name: "Daily", color: Color(hex: "2DCC71"), entryCount: 63), // Green
            // Work folder journals - different colors
            Journal(name: "Meeting Notes and Important Discussions from Weekly Team Syncs", color: Color(hex: "3398DB"), entryCount: 45), // Blue
            Journal(name: "Product Docs", color: Color(hex: "6A6DCD"), entryCount: 28), // Iris
            Journal(name: "Work Notes", color: Color(hex: "607D8B"), entryCount: 91), // Slate
            // Standalone journals
            Journal(name: "Dreams", color: Color(hex: "C27BD2"), entryCount: 19, coverImage: "bike"), // Lavender
            Journal(name: "Fitness", color: Color(hex: "FF983B"), entryCount: 104), // Fire
            Journal(name: "Smith Family Journal", color: Color(hex: "2DCC71"), entryCount: 34, isShared: true), // Green, Shared
            Journal(name: "Therapy", color: Color(hex: "607D8B"), entryCount: 18, isConcealed: true), // Slate, Concealed
            // Personal folder journals - different colors
            Journal(name: "Personal Reflections and Daily Thoughts on Growth and Self Discovery", color: Color(hex: "E91E63"), entryCount: 56), // Hot Pink
            Journal(name: "Ideas", color: Color(hex: "FFC107"), entryCount: 73), // Honey
            Journal(name: "Gratitude Daily", color: Color(hex: "2DCC71"), entryCount: 38), // Green
            // Standalone journal
            Journal(name: "Movie and TV Show Reviews with Ratings and Recommendations", color: Color(hex: "6A6DCD"), entryCount: 22), // Iris
            // Travel journal
            Journal(name: "Travel", color: Color(hex: "16D6D9"), entryCount: 0), // Aqua
            // Travel folder journals - different colors
            Journal(name: "Park City, Utah 2025-09", color: Color(hex: "16D6D9"), entryCount: 12), // Aqua
            Journal(name: "Maui, Hawaii 2025-07", color: Color(hex: "C27BD2"), entryCount: 9), // Lavender
            Journal(name: "Barcelona, Spain 2025-11", color: Color(hex: "FF983B"), entryCount: 7) // Fire
        ]
    }

    static let allJournals = sampleJournals

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
        return visibleJournals
    }

    // Folders with specific journals
    static var folders: [JournalFolder] {
        let journals = sampleJournals

        // Find journals by name for each folder
        let workJournals = journals.filter { ["Meeting Notes", "Product Docs", "Work Notes"].contains($0.name) }
        let personalJournals = journals.filter { ["Reflections", "Ideas", "Gratitude Daily"].contains($0.name) }
        let travelJournals = journals.filter { ["Park City, Utah 2025-09", "Maui, Hawaii 2025-07", "Barcelona, Spain 2025-11"].contains($0.name) }

        return [
            JournalFolder(
                id: "folder-work",
                name: "Work",
                journals: workJournals
            ),
            JournalFolder(
                id: "folder-personal",
                name: "Personal",
                journals: personalJournals
            ),
            JournalFolder(
                id: "folder-travel",
                name: "Travel",
                journals: travelJournals
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

        // Specific order: Journal, Notes, Work folder, Daily, Dreams, Fitness, Personal folder, Movie Log, Travel folder

        // Add Journal
        if let journal = allUnfoldered.first(where: { $0.name == "Journal" }) {
            items.append(MixedJournalItem(journal: journal))
        }

        // Add Notes
        if let notes = allUnfoldered.first(where: { $0.name == "Notes" }) {
            items.append(MixedJournalItem(journal: notes))
        }

        // Add Work folder
        if let workFolder = allFolders.first(where: { $0.name == "Work" }) {
            items.append(MixedJournalItem(folder: workFolder))
        }

        // Add Daily
        if let daily = allUnfoldered.first(where: { $0.name == "Daily" }) {
            items.append(MixedJournalItem(journal: daily))
        }

        // Add Dreams
        if let dreams = allUnfoldered.first(where: { $0.name == "Dreams" }) {
            items.append(MixedJournalItem(journal: dreams))
        }

        // Add Fitness
        if let fitness = allUnfoldered.first(where: { $0.name == "Fitness" }) {
            items.append(MixedJournalItem(journal: fitness))
        }

        // Add Smith Family Journal (shared)
        if let smithFamily = allUnfoldered.first(where: { $0.name == "Smith Family Journal" }) {
            items.append(MixedJournalItem(journal: smithFamily))
        }

        // Add Therapy (concealed)
        if let therapy = allUnfoldered.first(where: { $0.name == "Therapy" }) {
            items.append(MixedJournalItem(journal: therapy))
        }

        // Add Personal folder
        if let personalFolder = allFolders.first(where: { $0.name == "Personal" }) {
            items.append(MixedJournalItem(folder: personalFolder))
        }

        // Add Movie Log
        if let movieLog = allUnfoldered.first(where: { $0.name == "Movie Log" }) {
            items.append(MixedJournalItem(journal: movieLog))
        }

        // Add Travel folder
        if let travelFolder = allFolders.first(where: { $0.name == "Travel" }) {
            items.append(MixedJournalItem(folder: travelFolder))
        }

        return items
    }
}
