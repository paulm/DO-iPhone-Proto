import SwiftUI

struct DailyChatSettingsView: View {
    @AppStorage("dailyChatJournal") private var selectedJournal = "Daily"
    @State private var showingJournalPicker = false
    @State private var showingBioView = false
    
    // Sample journals for selection
    private let availableJournals = ["Daily", "Personal", "Work", "Travel", "Fitness", "Gratitude"]
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Journal")
                    Spacer()
                    Text(selectedJournal)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showingJournalPicker = true
                }
                
                HStack {
                    Text("Bio")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showingBioView = true
                }
            }
        }
        .navigationTitle("Daily Chat")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingJournalPicker) {
            JournalPickerView(selectedJournal: $selectedJournal)
        }
        .sheet(isPresented: $showingBioView) {
            BioEditView()
        }
    }
}

struct JournalPickerView: View {
    @Binding var selectedJournal: String
    @Environment(\.dismiss) private var dismiss
    
    private let availableJournals = ["Daily", "Personal", "Work", "Travel", "Fitness", "Gratitude"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableJournals, id: \.self) { journal in
                    HStack {
                        Text(journal)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if selectedJournal == journal {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(hex: "44C0FF"))
                                .fontWeight(.semibold)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedJournal = journal
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DailyChatSettingsView()
    }
}