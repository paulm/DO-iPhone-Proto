import SwiftUI

// Test file to demonstrate iPad split view functionality
struct iPadSplitViewTest: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
            Text("Current Device Mode:")
                .font(.title2)
            
            if horizontalSizeClass == .regular {
                Text("iPad - Split View Active")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text("NavigationSplitView is being used")
                    .font(.caption)
            } else {
                Text("iPhone - Tab View Active")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                Text("TabView is being used")
                    .font(.caption)
            }
            
            Spacer()
            
            Text("Size Class: \(horizontalSizeClass == .regular ? "Regular" : "Compact")")
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
        .padding()
    }
}

#Preview("iPhone") {
    iPadSplitViewTest()
        .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPad") {
    iPadSplitViewTest()
        .environment(\.horizontalSizeClass, .regular)
}