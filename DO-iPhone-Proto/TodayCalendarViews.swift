import SwiftUI
import UIKit

// MARK: - Calendar Views

struct KeyboardHandler: UIViewRepresentable {
    let onLeftArrow: () -> Void
    let onRightArrow: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = KeyboardView()
        view.onLeftArrow = onLeftArrow
        view.onRightArrow = onRightArrow
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    class KeyboardView: UIView {
        var onLeftArrow: (() -> Void)?
        var onRightArrow: (() -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        private func setup() {
            backgroundColor = .clear
            isUserInteractionEnabled = true
        }

        override var canBecomeFirstResponder: Bool { true }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            if window != nil {
                DispatchQueue.main.async {
                    self.becomeFirstResponder()
                }
            }
        }

        @objc private func leftArrowPressed() {
            onLeftArrow?()
        }

        @objc private func rightArrowPressed() {
            onRightArrow?()
        }

        override var keyCommands: [UIKeyCommand]? {
            return [
                UIKeyCommand(
                    input: UIKeyCommand.inputLeftArrow,
                    modifierFlags: [],
                    action: #selector(leftArrowPressed)
                ),
                UIKeyCommand(
                    input: UIKeyCommand.inputRightArrow,
                    modifierFlags: [],
                    action: #selector(rightArrowPressed)
                )
            ]
        }
    }
}

// MARK: - Journal Selection View
struct JournalSelectionView: View {
    @Binding var selectedJournal: String
    let onSelection: () -> Void
    @Environment(\.dismiss) private var dismiss

    // Sample journals
    private let journals = [
        "Daily",
        "Personal",
        "Work",
        "Travel",
        "Gratitude",
        "Dreams",
        "Fitness"
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(journals, id: \.self) { journal in
                    Button(action: {
                        selectedJournal = journal
                        onSelection()
                    }) {
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.green)
                                .frame(width: 28, height: 28)

                            Text(journal)
                                .foregroundStyle(.primary)

                            Spacer()

                            if selectedJournal == journal {
                                Image(dayOneIcon: .checkmark)
                                    .foregroundStyle(Color(hex: "44C0FF"))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Daily Chat Calendar View
struct DailyChatCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date

    @State private var showingDailyChat = false
    @State private var showingEntry = false
    @State private var entryData: EntryView.EntryData?

    private let calendar = Calendar.current

    // Get all dates with chats, grouped by month
    private var monthsWithChats: [(month: Date, dates: [Date])] {
        var allDates: [Date] = []

        // Look back 2 years
        let today = Date()
        for days in 0..<730 {
            if let date = calendar.date(byAdding: .day, value: -days, to: today) {
                allDates.append(date)
            }
        }

        // Filter dates with chats
        let datesWithChats = allDates.filter { date in
            let messages = ChatSessionManager.shared.getMessages(for: date)
            return !messages.isEmpty && messages.contains { $0.isUser }
        }

        // Group by month
        let groupedByMonth = Dictionary(grouping: datesWithChats) { date in
            calendar.dateComponents([.year, .month], from: date)
        }

        // Convert to array and sort by month (oldest first)
        let months = groupedByMonth.compactMap { components, dates -> (month: Date, dates: [Date])? in
            guard let monthDate = calendar.date(from: components) else { return nil }
            return (monthDate, dates.sorted())
        }
        .sorted { $0.month < $1.month }

        return months
    }

    // Check if a date has chat messages
    private func hasMessagesForDate(_ date: Date) -> Bool {
        let messages = ChatSessionManager.shared.getMessages(for: date)
        return !messages.isEmpty && messages.contains { $0.isUser }
    }

    // Check if a date has an entry
    private func hasEntryForDate(_ date: Date) -> Bool {
        return DailyContentManager.shared.hasEntry(for: date)
    }

    @ViewBuilder
    private func monthView(for monthData: (month: Date, dates: [Date])) -> some View {
        VStack(spacing: 12) {
            // Month header
            Text(monthYearString(from: monthData.month))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)

            // Calendar grid
            calendarGrid(for: monthData.month, dates: monthData.dates)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    ForEach(monthsWithChats, id: \.month) { monthData in
                        monthView(for: monthData)
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Daily Chat Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                    .labelStyle(.titleAndIcon)
                    .tint(Color(hex: "44C0FF"))
                }
            }
            .sheet(isPresented: $showingDailyChat) {
                DailyChatView(
                    selectedDate: selectedDate,
                    initialLogMode: false,
                    entryCreated: .constant(false),
                    onChatStarted: {},
                    onMessageCountChanged: { _ in }
                )
            }
            .sheet(isPresented: $showingEntry) {
                if let data = entryData {
                    EntryView(journal: nil, entryData: data, startInEditMode: false)
                }
            }
        }
    }

    private func calendarGrid(for month: Date, dates: [Date]) -> some View {
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let startingWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1 // 0 = Sunday

        let rows = calculateRows(daysInMonth: daysInMonth, startingWeekday: startingWeekday)

        return VStack(spacing: 12) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(0..<7, id: \.self) { column in
                        let day = row * 7 + column - startingWeekday + 1

                        if day > 0 && day <= daysInMonth {
                            let dateComponents = calendar.dateComponents([.year, .month], from: month)
                            if let date = calendar.date(from: DateComponents(year: dateComponents.year, month: dateComponents.month, day: day)) {
                                let hasContent = hasMessagesForDate(date) || hasEntryForDate(date)

                                DateCellButton(
                                    date: date,
                                    selectedDate: $selectedDate,
                                    showingDailyChat: $showingDailyChat,
                                    showingEntry: $showingEntry,
                                    entryData: $entryData,
                                    hasContent: hasContent,
                                    hasMessages: hasMessagesForDate(date),
                                    hasEntry: hasEntryForDate(date),
                                    onDismiss: { dismiss() }
                                )
                            } else {
                                Color.clear
                                    .frame(width: 30, height: 30)
                            }
                        } else {
                            Color.clear
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func calculateRows(daysInMonth: Int, startingWeekday: Int) -> Int {
        let totalCells = daysInMonth + startingWeekday
        return (totalCells + 6) / 7 // Round up
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Date Cell Button with Popover
struct DateCellButton: View {
    let date: Date
    @Binding var selectedDate: Date
    @Binding var showingDailyChat: Bool
    @Binding var showingEntry: Bool
    @Binding var entryData: EntryView.EntryData?
    let hasContent: Bool
    let hasMessages: Bool
    let hasEntry: Bool
    let onDismiss: () -> Void

    @State private var showingPopover = false
    private let calendar = Calendar.current

    var body: some View {
        Button(action: {
            showingPopover = true
        }) {
            DateCircle(
                date: date,
                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                isToday: calendar.isDateInToday(date),
                isFuture: date > Date(),
                isCompleted: hasMessages,
                hasEntry: hasEntry,
                showDate: hasContent,
                onTap: {
                    showingPopover = true
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 30, height: 30)
        .popover(isPresented: $showingPopover) {
            VStack(spacing: 0) {
                Button(action: {
                    selectedDate = date
                    showingPopover = false
                    onDismiss()
                }) {
                    Text("Select Date")
                        .frame(maxWidth: .infinity)
                        .padding()
                }

                Divider()

                Button(action: {
                    selectedDate = date
                    showingPopover = false
                    showingDailyChat = true
                }) {
                    Text("Open Chat")
                        .frame(maxWidth: .infinity)
                        .padding()
                }

                if hasEntry {
                    Divider()

                    Button(action: {
                        selectedDate = date
                        let formatter = DateFormatter()
                        formatter.dateFormat = "h:mm a"
                        let timeString = formatter.string(from: date)

                        entryData = EntryView.EntryData(
                            title: "Entry",
                            content: "Entry content...",
                            date: date,
                            time: timeString
                        )
                        showingPopover = false
                        showingEntry = true
                    }) {
                        Text("View Entry")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
            .frame(width: 200)
            .presentationCompactAdaptation(.popover)
        }
    }
}
