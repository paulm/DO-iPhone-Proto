#if DEBUG
import SwiftUI

/// PROTOTYPE — Floating bottom bar that cycles through UI variants on a host
/// page. Only compiled in DEBUG so a stray merge can't ship the chrome.
/// Delete this file once all prototypes have resolved.
struct PrototypeVariantSwitcher: View {
    let variants: [(key: String, name: String)]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 10) {
            Button(action: previous) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(spacing: 0) {
                Text("PROTOTYPE")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.55))
                Text("\(selection) — \(currentName)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .frame(minWidth: 150)

            Button(action: next) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.82))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
    }

    private var currentIndex: Int {
        variants.firstIndex(where: { $0.key == selection }) ?? 0
    }
    private var currentName: String {
        guard variants.indices.contains(currentIndex) else { return "?" }
        return variants[currentIndex].name
    }

    private func previous() {
        let new = (currentIndex - 1 + variants.count) % variants.count
        selection = variants[new].key
    }

    private func next() {
        let new = (currentIndex + 1) % variants.count
        selection = variants[new].key
    }
}
#endif
