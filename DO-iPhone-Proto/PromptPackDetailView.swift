import SwiftUI

struct PromptItem: Identifiable {
    let id = UUID()
    let text: String
}

struct AnswerData {
    var count: Int
    var lastAnsweredDate: Date
}

// Helper function to format answer label
private func formatAnswerLabel(answerData: AnswerData, now: Date = Date()) -> String {
    let countPart = answerData.count > 1 ? "✓ \(answerData.count)×" : "✓"
    
    let calendar = Calendar.current
    let recencyPart: String
    
    if calendar.isDateInToday(answerData.lastAnsweredDate) {
        recencyPart = "Today"
    } else if calendar.isDateInYesterday(answerData.lastAnsweredDate) {
        recencyPart = "Yesterday"
    } else {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d ''yy"
        recencyPart = formatter.string(from: answerData.lastAnsweredDate)
    }
    
    return "\(countPart) • \(recencyPart)"
}

struct PromptPackDetailView: View {
    let packTitle: String
    let packIcon: String
    let promptCount: Int
    let author: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPrompt: String?
    @State private var isSaved = false
    @State private var answeredPrompts: [String: AnswerData] = [:]
    @State private var hiddenPrompts: Set<String> = []
    @State private var showingEntryView = false
    @State private var promptForEntry: String?
    
    // Sample prompts for Gratitude pack based on screenshot
    private let promptTexts = [
        "What am I grateful for today?",
        "What small things happened today that I am grateful for?",
        "What simple pleasures do I cherish most?",
        "What are today's highlights so far?"
    ]
    
    private var prompts: [PromptItem] {
        promptTexts.map { PromptItem(text: $0) }
    }
    
    // Computed properties to break down complex views
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: packIcon)
                .font(.system(size: 40))
                .foregroundStyle(.gray)
                .padding(.top, 24)
            
            // Title
            Text(packTitle)
                .font(.system(size: 32, weight: .bold, design: .serif))
            
            // Metadata
            HStack(spacing: 12) {
                Text("\(promptCount) prompts")
                    .foregroundStyle(.gray)
                
                Text("•")
                    .foregroundStyle(.gray)
                
                Text("By \(author)")
                    .foregroundStyle(.gray)
            }
            .font(.caption)
            
            // My Prompts button
            myPromptsButton
            
            // Description
            Text("Spark everyday thankfulness by noticing the large and small blessings that color your life.")
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(.white)
    }
    
    private var myPromptsButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isSaved.toggle()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: isSaved ? "checkmark" : "plus.circle.fill")
                    .font(.system(size: 18))
                Text(isSaved ? "Saved" : "My Prompts")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(isSaved ? .gray : .white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSaved ? Color.gray.opacity(0.2) : Color(hex: "44C0FF"))
            .clipShape(Capsule())
        }
        .padding(.vertical, 8)
    }
    
    private var progressBar: some View {
        Group {
            if !answeredPrompts.isEmpty {
                VStack(spacing: 8) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "44C0FF"))
                                .frame(width: geometry.size.width * (Double(answeredPrompts.keys.count) / Double(promptTexts.count)), height: 4)
                        }
                    }
                    .frame(height: 4)
                    
                    // Progress text
                    Text("\(answeredPrompts.keys.count) of \(promptTexts.count)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }
    
    private var unansweredPrompts: [PromptItem] {
        prompts.filter { !hiddenPrompts.contains($0.text) && answeredPrompts[$0.text] == nil }
    }
    
    private var answeredPromptsList: [PromptItem] {
        prompts.filter { !hiddenPrompts.contains($0.text) && answeredPrompts[$0.text] != nil }
    }
    
    private func makePromptCard(for promptItem: PromptItem, isAnswered: Bool) -> some View {
        PromptDetailCard(
            prompt: promptItem.text,
            isSelected: selectedPrompt == promptItem.text,
            isAnswered: isAnswered,
            answerData: answeredPrompts[promptItem.text],
            onTap: {
                selectedPrompt = promptItem.text
                promptForEntry = promptItem.text
                showingEntryView = true
            },
            onHide: {
                withAnimation(.easeOut(duration: 0.3)) {
                    _ = hiddenPrompts.insert(promptItem.text)
                }
            }
        )
    }
    
    @ViewBuilder
    private var promptsList: some View {
        VStack(spacing: 20) {
            // Unanswered prompts
            ForEach(Array(unansweredPrompts)) { promptItem in
                makePromptCard(for: promptItem, isAnswered: false)
            }
            
            // Answered section
            if !answeredPromptsList.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Answered")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .padding(.top, 20)
                    
                    ForEach(Array(answeredPromptsList)) { promptItem in
                        makePromptCard(for: promptItem, isAnswered: true)
                    }
                }
            }
        }
        .padding(20)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    progressBar
                    promptsList
                }
            }
            .background(.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "44C0FF"))
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: {
                            // TODO: Select journal functionality
                        }) {
                            Label("Select Journal", systemImage: "book.closed")
                        }
                        
                        Button(action: {
                            // TODO: Share prompt pack functionality
                        }) {
                            Label("Share Prompt Pack", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEntryView) {
            // Mark the prompt as answered when sheet is dismissed
            if let prompt = promptForEntry {
                if let existingData = answeredPrompts[prompt] {
                    // Increment count if already answered
                    answeredPrompts[prompt] = AnswerData(
                        count: existingData.count + 1,
                        lastAnsweredDate: Date()
                    )
                } else {
                    // First time answering
                    answeredPrompts[prompt] = AnswerData(
                        count: 1,
                        lastAnsweredDate: Date()
                    )
                }
            }
        } content: {
            EntryView(
                journal: nil,
                entryData: promptForEntry != nil ? EntryView.EntryData(
                    title: promptForEntry!,
                    content: "",
                    date: Date(),
                    time: ""
                ) : nil
            )
        }
    }
}

struct PromptDetailCard: View {
    let prompt: String
    let isSelected: Bool
    let isAnswered: Bool
    let answerData: AnswerData?
    let onTap: () -> Void
    let onHide: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(prompt)
                .font(.system(size: 17, weight: .thin, design: .serif))
                .foregroundStyle(isAnswered ? .gray : .primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            if let answerData = answerData {
                Text(formatAnswerLabel(answerData: answerData))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isAnswered ? .gray.opacity(0.05) : .white)
                .shadow(color: .black.opacity(isAnswered ? 0.02 : 0.04), radius: 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: "44C0FF") : Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            if isAnswered {
                Button(action: onTap) {
                    Label("View Entry", systemImage: "doc.text")
                }
                
                Button(action: onTap) {
                    Label("Answer Again", systemImage: "arrow.clockwise")
                }
            } else {
                Button(action: onTap) {
                    Label("Answer", systemImage: "square.and.pencil")
                }
            }
            
            Button(action: {
                UIPasteboard.general.string = prompt
            }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            
            Button(role: .destructive, action: onHide) {
                Label("Hide", systemImage: "eye.slash")
            }
        }
    }
}

#Preview {
    PromptPackDetailView(
        packTitle: "Gratitude",
        packIcon: "heart.text.square",
        promptCount: 37,
        author: "Day One Team"
    )
}
