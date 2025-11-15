import SwiftUI

@Observable
class DateManager {
    static let shared = DateManager()

    var selectedDate: Date = Date()

    private init() {}
}
