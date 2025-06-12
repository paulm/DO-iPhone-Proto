import SwiftUI

/// Today tab view - now delegates to TodayView
struct TimelineView: View {
    var body: some View {
        TodayView()
    }
}

#Preview {
    TimelineView()
}