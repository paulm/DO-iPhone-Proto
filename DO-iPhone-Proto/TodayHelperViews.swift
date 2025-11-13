import SwiftUI

// MARK: - Helper Views

// Placeholder Views for Today Insights
struct WeatherView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Image(dayOneIcon: .weather_partly_cloudy)
                .font(.system(size: 80))
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding()

            Text("Weather")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Weather information will be displayed here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .navigationTitle("Weather")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct EntriesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Image(dayOneIcon: .pen_edit)
                .font(.system(size: 80))
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding()

            Text("Entries")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Journal entries will be displayed here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .navigationTitle("Entries")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct OnThisDayView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Image(dayOneIcon: .calendar_clock)
                .font(.system(size: 80))
                .foregroundStyle(Color(hex: "44C0FF"))
                .padding()

            Text("On This Day")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Memories from this day in previous years will be displayed here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .navigationTitle("On This Day")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

// Today Insight Item Component
struct TodayInsightItem: View {
    let icon: String
    let title: String
    let detail: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(Color(hex: "44C0FF"))
                    .frame(height: 28)

                VStack(spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Chat Message Bubble View
struct ChatMessageBubbleView: View {
    let dayOfWeek: String
    @State private var animateIn = false

    var body: some View {
        HStack {
            Text("How's your \(dayOfWeek)?")
                .font(.body)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Spacer()
        }
        .padding(.horizontal, 16)
        .offset(y: animateIn ? 0 : 40)
        .opacity(animateIn ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                animateIn = true
            }
        }
        .onDisappear {
            animateIn = false
        }
    }
}

// Chat Input Box View
struct ChatInputBoxView: View {
    let action: () -> Void
    @State private var showCursor = true

    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                HStack(spacing: 0) {
                    // Blinking cursor
                    Rectangle()
                        .fill(Color(hex: "44C0FF"))
                        .frame(width: 2, height: 24)
                        .opacity(showCursor ? 1 : 0)

                    Text("Chat about your day...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(dayOneIcon: .microphone)
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)

                Image(dayOneIcon: .arrow_up_circle_filled)
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "44C0FF"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                showCursor.toggle()
            }
        }
    }
}

// TodayInsightItem without action for NavigationLink usage
struct TodayInsightItemView: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Color(hex: "44C0FF"))
                .frame(height: 40)

            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Entry Links Carousel View
struct EntryLinksCarouselView: View {
    let selectedDate: Date
    @Binding var showingEntries: Bool
    @Binding var showingOnThisDay: Bool

    var body: some View {
        let entryCount = DailyDataManager.shared.getEntryCount(for: selectedDate)
        let onThisDayCount = DailyDataManager.shared.getOnThisDayCount(for: selectedDate)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Entries button (shown first if > 0)
                if entryCount > 0 {
                    Button(action: {
                        showingEntries = true
                    }) {
                        Text("\(entryCount) \(entryCount == 1 ? "Entry" : "Entries")")
                            .font(.system(size: 13))
                            .fontWeight(.regular)
                            .foregroundStyle(Color.primary.opacity(0.8))
                            .frame(height: 38)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "F3F1F8"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 20)
                }

                // On This Day button (shown second if > 0)
                if onThisDayCount > 0 {
                    Button(action: {
                        showingOnThisDay = true
                    }) {
                        Text("\(onThisDayCount) On This Day")
                            .font(.system(size: 13))
                            .fontWeight(.regular)
                            .foregroundStyle(Color.primary.opacity(0.8))
                            .frame(height: 38)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "F3F1F8"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, entryCount == 0 ? 20 : 0)
                    .padding(.trailing, 20)
                }
            }
            .padding(.top, 12) // Add padding above buttons
        }
    }
}
