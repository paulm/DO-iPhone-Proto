import Foundation

extension Notification.Name {
    /// User-driven trigger to start (or resume) the Daily Chat sheet on Today.
    static let triggerDailyChat = Notification.Name("TriggerDailyChat")

    /// Open the EntryView for the current selected date.
    static let openEntryView = Notification.Name("OpenEntryView")

    /// Begin generating a daily entry from chat content.
    static let triggerEntryGeneration = Notification.Name("TriggerEntryGeneration")

    /// The order of sections on the Today tab changed (via settings).
    static let sectionOrderChanged = Notification.Name("SectionOrderChanged")

    /// Sample/fixture data was re-populated; views should re-pull cached state.
    static let dataPopulationChanged = Notification.Name("DataPopulationChanged")

    /// The currently selected date changed.
    static let selectedDateChanged = Notification.Name("SelectedDateChanged")

    /// A daily summary was generated or cleared.
    static let summaryGeneratedStatusChanged = Notification.Name("SummaryGeneratedStatusChanged")

    /// A daily entry was created (or its existence flipped).
    /// Object payload: the `Date` for which the entry was created.
    static let dailyEntryCreatedStatusChanged = Notification.Name("DailyEntryCreatedStatusChanged")
}
