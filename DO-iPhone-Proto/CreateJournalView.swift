import SwiftUI

struct CreateJournalView: View {
    @Environment(\.dismiss) private var dismiss
    let onCreate: (String, Color, Bool) -> Void

    @State private var journalName = "Journal"
    @State private var isPersonal = true
    @State private var selectedColor = Color(hex: "44C0FF")
    @State private var pendingColor: Color?
    @State private var showingColorPicker = false
    @State private var colorPickerRotation: Double = 0
    @State private var nameChangeRotation: Double = 0
    @FocusState private var isNameFocused: Bool

    // Day One color palette (colors from populated journals)
    private let colors = [
        Color(hex: "44C0FF"), // DayOne Blue
        Color(hex: "FFC107"), // Honey
        Color(hex: "2DCC71"), // Green
        Color(hex: "3398DB"), // Blue
        Color(hex: "6A6DCD"), // Iris
        Color(hex: "607D8B"), // Slate
        Color(hex: "C27BD2"), // Lavender
        Color(hex: "FF983B"), // Fire
        Color(hex: "E91E63"), // Hot Pink
        Color(hex: "16D6D9")  // Aqua
    ]

    // Name suggestions
    private let nameSuggestions = [
        "Journal", "Daily", "2026", "Dreams", "Food", "Gratitude",
        "Intentions", "Vacation", "Pregnancy", "Meeting Notes",
        "Work", "Travel", "Fitness", "Reading", "Projects"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Personal/Shared Picker
                    Picker("Type", selection: $isPersonal) {
                        Text("Personal").tag(true)
                        Text("Shared").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 60)
                    .padding(.top, 20)
                    .padding(.bottom, 40)

                    // Book Preview
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedColor)
                            .aspectRatio(0.7, contentMode: .fit)
                            .frame(width: 240)
                            .overlay(
                                // Book spine effect
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(selectedColor.opacity(0.3))
                                        .frame(height: 3)
                                        .padding(.horizontal, 12)
                                    Spacer()
                                }
                            )
                            .overlay(
                                // Journal title overlay (bottom-left)
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text(journalName)
                                            .font(.body)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white.opacity(0.8))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                        Spacer()
                                    }
                                    .padding(.bottom, 8)
                                    .padding(.leading, 8)
                                }
                            )
                            .overlay(
                                // Shared icon (top-left, only when Shared mode)
                                VStack {
                                    HStack {
                                        if !isPersonal {
                                            Text(DayOneIcon.users.rawValue)
                                                .font(.custom("DayOneIcons", size: 20))
                                                .foregroundStyle(.white)
                                                .padding(8)
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            )
                            .shadow(color: selectedColor.opacity(0.4), radius: 8, x: 4, y: 6)
                            .rotation3DEffect(
                                .degrees(isPersonal ? 0 : 180),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .rotation3DEffect(
                                .degrees(colorPickerRotation),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .rotation3DEffect(
                                .degrees(nameChangeRotation),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .accessibilityLabel(isPersonal ? "Personal journal book preview" : "Shared journal book preview")

                        // Painter palette button
                        Button(action: {
                            showingColorPicker.toggle()
                        }) {
                            Circle()
                                .fill(.white)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "paintpalette.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.black)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .offset(x: 20, y: -20)
                    }
                    .padding(.bottom, 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75), value: isPersonal)

                    // Journal name text field
                    TextField("Journal", text: $journalName)
                        .font(.system(size: 32, weight: .regular))
                        .multilineTextAlignment(.center)
                        .focused($isNameFocused)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)

                    // Suggestions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(nameSuggestions, id: \.self) { suggestion in
                                Button(action: {
                                    // Start rotation
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                                        nameChangeRotation += 180
                                    }
                                    // Change name and color halfway through rotation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        journalName = suggestion
                                        if let randomColor = colors.randomElement() {
                                            selectedColor = randomColor
                                        }
                                    }
                                }) {
                                    Text(suggestion)
                                        .font(.body)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray5))
                                        .foregroundStyle(.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 20)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onCreate(journalName, selectedColor, isPersonal)
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(hex: "44C0FF"))
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerSheet(selectedColor: $selectedColor, pendingColor: $pendingColor, colors: colors)
                    .presentationDetents([.height(280)])
            }
            .onChange(of: pendingColor) { oldValue, newValue in
                if let newColor = newValue {
                    // Start rotation
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                        colorPickerRotation += 180
                    }
                    // Change color halfway through rotation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedColor = newColor
                        pendingColor = nil
                    }
                }
            }
            .onAppear {
                // Auto-focus the text field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFocused = true
                }
            }
        }
    }
}

// MARK: - Create Collection View


struct ColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: Color
    @Binding var pendingColor: Color?
    let colors: [Color]

    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)

    private func isSameColor(_ color1: Color, _ color2: Color) -> Bool {
        // Simple comparison - in practice, you might want to compare RGB values
        // For now, we'll use a simple reference comparison approach
        return color1.description == color2.description
    }

    var body: some View {
        VStack(spacing: 20) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 6)
                .padding(.top, 8)

            Text("Choose Color")
                .font(.headline)
                .padding(.top, 8)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    Button(action: {
                        pendingColor = color
                        dismiss()
                    }) {
                        Circle()
                            .fill(color)
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .strokeBorder(isSameColor(selectedColor, color) ? .white : .clear, lineWidth: 3)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(isSameColor(selectedColor, color) ? color.opacity(0.5) : .clear, lineWidth: 6)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            Spacer()
        }
    }
}

#Preview("Paged") {
    JournalsTabPagedView()
}
