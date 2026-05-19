import UIKit

/// Width of the device screen in points, read from the foreground window scene.
///
/// iOS 26 deprecates `UIScreen.main` in favor of context-found instances. This
/// helper looks up the active scene's screen, avoiding the deprecation entirely.
/// The fallback (393pt — iPhone 17 base width) only fires in pathological
/// contexts where no UIWindowScene is connected; not reachable from app code.
var screenWidth: CGFloat {
    UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?.screen.bounds.width ?? 393
}
