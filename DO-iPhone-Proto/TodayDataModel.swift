import Foundation

// MARK: - Today Data Model
struct TodayDataModel: Codable {
    let dailyData: [DayData]
}

struct DayData: Codable {
    let daysAgo: Int
    let hasChat: Bool
    let hasGeneratedEntry: Bool
    let entryCount: Int
    let onThisDayCount: Int
}

// MARK: - Today Data Manager
class TodayDataManager {
    static let shared = TodayDataManager()
    private var loadedData: TodayDataModel?
    private var dataByDate: [String: DayData] = [:]
    
    private init() {
        loadData()
    }
    
    private func loadData() {
        guard let url = Bundle.main.url(forResource: "DailyData", withExtension: "json") else {
            print("Failed to find DailyData.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            loadedData = try decoder.decode(TodayDataModel.self, from: data)
            
            // Build date lookup dictionary
            let calendar = Calendar.current
            let today = Date()
            
            for dayData in loadedData?.dailyData ?? [] {
                if let date = calendar.date(byAdding: .day, value: -dayData.daysAgo, to: today) {
                    let key = dateKey(for: date)
                    dataByDate[key] = dayData
                }
            }
            
            // Update ChatSessionManager with chat data
            updateChatData()
            // Update DailyContentManager with entry data
            updateEntryData()
            
        } catch {
            print("Failed to load DailyData.json: \(error)")
        }
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func updateChatData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Clear existing sample data first
        ChatSessionManager.shared.clearAllSessions()
        
        for dayData in loadedData?.dailyData ?? [] {
            if dayData.hasChat {
                if let date = calendar.date(byAdding: .day, value: -dayData.daysAgo, to: today) {
                    // Add chat messages for this date
                    let messages = [
                        DailyChatMessage(content: "How's your day?", isUser: false, isLogMode: false),
                        DailyChatMessage(content: generateUserResponse(for: dayData.daysAgo), isUser: true, isLogMode: false)
                    ]
                    ChatSessionManager.shared.saveMessages(messages, for: date)
                }
            }
        }
    }
    
    private func updateEntryData() {
        let calendar = Calendar.current
        let today = Date()
        
        for dayData in loadedData?.dailyData ?? [] {
            if let date = calendar.date(byAdding: .day, value: -dayData.daysAgo, to: today) {
                // Set whether this date has a generated entry
                DailyContentManager.shared.setHasEntry(dayData.hasGeneratedEntry, for: date)
            }
        }
    }
    
    private func generateUserResponse(for daysAgo: Int) -> String {
        let responses = [
            "Had a great day today! Finished some important work.",
            "Today was productive. Got through my todo list.",
            "Relaxing day. Spent time with family.",
            "Busy but fulfilling day at work.",
            "Good day overall. Made progress on my goals.",
            "Challenging day but learned a lot.",
            "Wonderful day! Everything went smoothly.",
            "Quiet day of reflection and planning.",
            "Exciting day with new opportunities.",
            "Normal day, nothing too special.",
            "Great workout and healthy meals today.",
            "Creative day, worked on personal projects.",
            "Social day, caught up with friends.",
            "Focused day of deep work."
        ]
        return responses[daysAgo - 1] // Use daysAgo as index for variety
    }
    
    func getDayData(for date: Date) -> DayData? {
        let key = dateKey(for: date)
        return dataByDate[key]
    }
    
    func getEntryCount(for date: Date) -> Int {
        return getDayData(for: date)?.entryCount ?? 0
    }
    
    func getOnThisDayCount(for date: Date) -> Int {
        return getDayData(for: date)?.onThisDayCount ?? 0
    }
}