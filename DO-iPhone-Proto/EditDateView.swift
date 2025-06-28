import SwiftUI

struct EditDateView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @State private var isAllDay = false
    @State private var tempDate: Date
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: $tempDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                }
                
                if !isAllDay {
                    Section {
                        DatePicker("Time", selection: $tempDate, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                    }
                }
                
                Section {
                    Toggle("All day", isOn: $isAllDay)
                }
                
                Section {
                    Button(action: {
                        tempDate = Date()
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
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    EditDateView(selectedDate: .constant(Date()))
}