import SwiftUI

@Observable
class DailyContentManager {
    static let shared = DailyContentManager()
    private var dailyEntries: [String: Bool] = [:]
    private var summaries: [String: Bool] = [:]
    private var entryMessageCounts: [String: Int] = [:] // Track message count when entry was created
    private var entryUpdateDates: [String: Date] = [:] // Track when entries were last updated

    private init() {
        // Data will be loaded from JSON via TodayDataManager
    }

    func hasEntry(for date: Date) -> Bool {
        let key = date.dateKey
        return dailyEntries[key] ?? false
    }

    func setHasEntry(_ hasEntry: Bool, for date: Date) {
        let key = date.dateKey
        dailyEntries[key] = hasEntry
    }

    func hasSummary(for date: Date) -> Bool {
        let key = date.dateKey
        return summaries[key] ?? false
    }

    func setHasSummary(_ hasSummary: Bool, for date: Date) {
        let key = date.dateKey
        summaries[key] = hasSummary
    }

    func setEntryMessageCount(_ count: Int, for date: Date) {
        let key = date.dateKey
        entryMessageCounts[key] = count
    }

    func getEntryMessageCount(for date: Date) -> Int {
        let key = date.dateKey
        return entryMessageCounts[key] ?? 0
    }

    func hasNewMessagesSinceEntry(for date: Date) -> Bool {
        let key = date.dateKey
        let entryMessageCount = entryMessageCounts[key] ?? 0
        let currentMessages = ChatSessionManager.shared.getMessages(for: date)
        let currentUserMessageCount = currentMessages.filter { $0.isUser }.count
        return currentUserMessageCount > entryMessageCount
    }

    func setEntryUpdateDate(_ updateDate: Date, for date: Date) {
        let key = date.dateKey
        entryUpdateDates[key] = updateDate
    }

    func getEntryUpdateDate(for date: Date) -> Date? {
        let key = date.dateKey
        return entryUpdateDates[key]
    }
}
