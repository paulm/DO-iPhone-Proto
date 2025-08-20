import TipKit
import SwiftUI

struct JournalingMadeEasyTip: Tip {
    var title: Text {
        Text("Journaling, Made Easy")
    }
    
    var message: Text? {
        Text("Chat about your day and we'll turn it into a journal entry that reflects your words and mood for you.")
    }
    
    var image: Image? {
        Image("daily-chat-new")
    }
}

// Custom TipViewStyle with left-aligned image at top and drop shadow
struct CustomJournalingTipViewStyle: TipViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Main content
            VStack(alignment: .leading, spacing: 12) {
                // Image at the top left
                if let image = configuration.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 49, height: 17)
                }
                
                // Title and message
                VStack(alignment: .leading, spacing: 6) {
                    if let title = configuration.title {
                        title
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    
                    if let message = configuration.message {
                        message
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Close button
            Button {
                configuration.tip.invalidate(reason: .tipClosed)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(Color(hex: "F3F1F8"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}