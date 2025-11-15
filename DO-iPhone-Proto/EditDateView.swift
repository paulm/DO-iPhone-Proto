import SwiftUI

struct EditDateView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @Binding var isAllDay: Bool
    @State private var tempDate: Date
    @State private var tempIsAllDay: Bool

    init(selectedDate: Binding<Date>, isAllDay: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isAllDay = isAllDay
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
        self._tempIsAllDay = State(initialValue: isAllDay.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: $tempDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                }
                
                if !tempIsAllDay {
                    Section {
                        DatePicker("Time", selection: $tempDate, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                    }
                }

                Section {
                    Toggle("All day", isOn: $tempIsAllDay)
                }
                
                Section {
                    Button(action: {
                        tempDate = Date()
                        tempIsAllDay = false
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Set to current date and time")
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        selectedDate = tempDate
                        isAllDay = tempIsAllDay
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    EditDateView(selectedDate: .constant(Date()), isAllDay: .constant(false))
}