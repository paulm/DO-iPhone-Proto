import SwiftUI
import Textual

/// Renders a single bundled markdown guide by relative path under the
/// `guides/` folder reference. Markdown links are intercepted via the
/// SwiftUI `openURL` environment so cross-guide navigation stays in-app;
/// each level owns its own `navigationDestination(item:)` so taps recursively
/// push the next guide onto the surrounding NavigationStack.
struct GuideView: View {
    let relativePath: String

    @State private var pushedGuide: String?

    var body: some View {
        Group {
            switch Result(catching: { try Guides.load(relativePath: relativePath) }) {
            case .success(let guide):
                content(for: guide)
            case .failure(let error):
                errorView(for: error)
            }
        }
        .navigationDestination(item: $pushedGuide) { relative in
            GuideView(relativePath: relative)
        }
    }

    @ViewBuilder
    private func content(for guide: Guides.LoadedGuide) -> some View {
        ScrollView {
            StructuredText(
                markdown: guide.body,
                baseURL: guide.fileURL
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.openURL, OpenURLAction { url in route(url) })
    }

    @ViewBuilder
    private func errorView(for error: Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Couldn't load this guide")
                .font(.headline)
            Text(String(describing: error))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Decide whether a tapped link stays in-app (push another guide) or hands
    /// off to the system (Safari, mail, etc).
    private func route(_ url: URL) -> OpenURLAction.Result {
        // Pure-fragment links (e.g. `#section`) — keep us on the same page.
        let frag = url.fragment ?? ""
        if url.scheme == nil, url.host == nil, !frag.isEmpty, url.path.isEmpty {
            return .handled
        }
        if let relative = Guides.resolveBundleRelativePath(for: url) {
            pushedGuide = relative
            return .handled
        }
        return .systemAction
    }
}
