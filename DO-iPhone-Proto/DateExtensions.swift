import Foundation

private let dateKeyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

extension Date {
    /// "yyyy-MM-dd" key used to group entries, chats, and content by day.
    var dateKey: String {
        dateKeyFormatter.string(from: self)
    }
}
