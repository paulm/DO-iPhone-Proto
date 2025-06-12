import SwiftUI

// MARK: - Survey Question Data Model
struct SurveyQuestion: Identifiable, Codable {
    let id = UUID()
    var text: String
    var isEnabled: Bool
    var order: Int
    
    static let defaultQuestions = [
        SurveyQuestion(text: "How are you feeling today?", isEnabled: true, order: 0),
        SurveyQuestion(text: "What's the most important thing you want to accomplish?", isEnabled: true, order: 1),
        SurveyQuestion(text: "What's on your mind right now?", isEnabled: true, order: 2),
        SurveyQuestion(text: "What are you grateful for today?", isEnabled: true, order: 3),
        SurveyQuestion(text: "What challenges are you facing?", isEnabled: true, order: 4)
    ]
}

@Observable
class SurveyQuestionsManager {
    var questions: [SurveyQuestion] = SurveyQuestion.defaultQuestions
    
    static let shared = SurveyQuestionsManager()
    
    private init() {}
    
    var enabledQuestions: [SurveyQuestion] {
        questions.filter { $0.isEnabled }.sorted { $0.order < $1.order }
    }
}

struct DailySurveyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestionIndex = 0
    @State private var responses: [String?] = []
    @State private var currentResponse = ""
    @State private var showingQuestionEditor = false
    @State private var questionsManager = SurveyQuestionsManager.shared
    let onCompletion: () -> Void
    
    private var activeQuestions: [String] {
        questionsManager.enabledQuestions.map { $0.text }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Progress indicator
                HStack {
                    ForEach(0..<activeQuestions.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentQuestionIndex ? Color(hex: "44C0FF") : .gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top)
                
                Spacer()
                
                // Question
                VStack(spacing: 20) {
                    Text(activeQuestions[currentQuestionIndex])
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextField("Your response...", text: $currentResponse, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Navigation buttons
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        if currentQuestionIndex > 0 {
                            Button("Previous") {
                                saveCurrentResponse()
                                currentQuestionIndex -= 1
                                loadCurrentResponse()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Spacer()
                        
                        Button("Skip") {
                            skipCurrentQuestion()
                        }
                        .buttonStyle(.bordered)
                        
                        Button(currentQuestionIndex == activeQuestions.count - 1 ? "Finish" : "Next") {
                            saveCurrentResponse()
                            moveToNextQuestion()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Daily Survey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingQuestionEditor = true
                    }
                }
            }
            .onAppear {
                // Initialize responses array
                if responses.isEmpty {
                    responses = Array(repeating: nil, count: activeQuestions.count)
                }
                loadCurrentResponse()
            }
            .sheet(isPresented: $showingQuestionEditor) {
                SurveyQuestionsEditor()
            }
        }
    }
    
    private func saveCurrentResponse() {
        if responses.count <= currentQuestionIndex {
            responses.append(currentResponse.isEmpty ? nil : currentResponse)
        } else {
            responses[currentQuestionIndex] = currentResponse.isEmpty ? nil : currentResponse
        }
    }
    
    private func loadCurrentResponse() {
        if currentQuestionIndex < responses.count,
           let savedResponse = responses[currentQuestionIndex] {
            currentResponse = savedResponse
        } else {
            currentResponse = ""
        }
    }
    
    private func skipCurrentQuestion() {
        if responses.count <= currentQuestionIndex {
            responses.append(nil)
        } else {
            responses[currentQuestionIndex] = nil
        }
        currentResponse = ""
        moveToNextQuestion()
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex == activeQuestions.count - 1 {
            onCompletion()
            dismiss()
        } else {
            currentQuestionIndex += 1
            loadCurrentResponse()
        }
    }
}

struct SurveyQuestionsEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var questionsManager = SurveyQuestionsManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(questionsManager.questions.sorted { $0.order < $1.order }) { question in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(question.text)
                                .font(.body)
                                .foregroundStyle(question.isEnabled ? .primary : .secondary)
                            
                            Text("Question \(question.order + 1)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { question.isEnabled },
                            set: { newValue in
                                if let index = questionsManager.questions.firstIndex(where: { $0.id == question.id }) {
                                    questionsManager.questions[index].isEnabled = newValue
                                }
                            }
                        ))
                        .labelsHidden()
                    }
                    .padding(.vertical, 4)
                }
                .onMove { source, destination in
                    var sortedQuestions = questionsManager.questions.sorted { $0.order < $1.order }
                    sortedQuestions.move(fromOffsets: source, toOffset: destination)
                    
                    // Update order values
                    for (index, question) in sortedQuestions.enumerated() {
                        if let originalIndex = questionsManager.questions.firstIndex(where: { $0.id == question.id }) {
                            questionsManager.questions[originalIndex].order = index
                        }
                    }
                }
            }
            .navigationTitle("Edit Questions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                        Text("Drag to reorder • Toggle to show/hide")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
        }
    }
}

#Preview {
    DailySurveyView(onCompletion: {
        print("Survey completed")
    })
}