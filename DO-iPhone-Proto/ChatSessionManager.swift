import SwiftUI

@Observable
class ChatSessionManager {
    static let shared = ChatSessionManager()
    private var sessions: [String: [DailyChatMessage]] = [:]
    private var summariesGenerated: [String: Bool] = [:]

    private init() {
        // Data will be loaded from JSON via TodayDataManager
    }

    func getMessages(for date: Date = Date()) -> [DailyChatMessage] {
        let key = date.dateKey
        return sessions[key] ?? []
    }

    func saveMessages(_ messages: [DailyChatMessage], for date: Date = Date()) {
        let key = date.dateKey
        sessions[key] = messages
    }

    func clearSession(for date: Date = Date()) {
        let key = date.dateKey
        sessions.removeValue(forKey: key)
        summariesGenerated.removeValue(forKey: key)
    }

    func removeMessage(withId messageId: UUID, for date: Date = Date()) {
        let key = date.dateKey
        if var messages = sessions[key] {
            messages.removeAll { $0.id == messageId }
            sessions[key] = messages
        }
    }

    func toggleIgnoreStatus(withId messageId: UUID, for date: Date = Date()) {
        let key = date.dateKey
        if var messages = sessions[key] {
            if let index = messages.firstIndex(where: { $0.id == messageId }) {
                messages[index].isIgnoredInEntry.toggle()
                sessions[key] = messages
            }
        }
    }

    func isSummaryGenerated(for date: Date = Date()) -> Bool {
        let key = date.dateKey
        return summariesGenerated[key] ?? false
    }

    func setSummaryGenerated(_ generated: Bool, for date: Date = Date()) {
        let key = date.dateKey
        summariesGenerated[key] = generated
    }

    func clearAllSessions() {
        sessions.removeAll()
        summariesGenerated.removeAll()
    }
}

enum ChatMode: String, CaseIterable, Codable {
    case log = "Log"
    case chat = "Chat"
}
