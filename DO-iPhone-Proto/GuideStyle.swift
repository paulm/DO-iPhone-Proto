import SwiftUI
import Textual

// Day One-themed Textual styles for the in-app support guides.
//
// - Headings only minimally increase from body size (~1.0× to 1.25×) so the
//   help content reads as prose rather than a marketing page; visual hierarchy
//   leans on weight and block spacing rather than scale.
// - Inline links pick up the Day One brand cyan (`BrandColors.primary`).
// - Block quotes get a brand-tinted background with a brand-blue accent bar.

// MARK: - Heading style

extension StructuredText {
    /// Minimal-scale heading style.
    ///
    /// Scales (multiples of body font size):
    /// - H1: 1.25
    /// - H2: 1.15
    /// - H3: 1.08
    /// - H4–H6: 1.0
    ///
    /// All headings render semibold; spacing above is generous so the heading
    /// still separates clearly from the preceding paragraph.
    struct GuideHeadingStyle: HeadingStyle {
        // Index by `headingLevel - 1`. H1 first, H6 last.
        private static let fontScales: [CGFloat]   = [1.25, 1.15, 1.08, 1.00, 1.00, 1.00]
        private static let lineSpacings: [CGFloat] = [0.08, 0.08, 0.10, 0.10, 0.10, 0.10]

        func makeBody(configuration: Configuration) -> some View {
            let level = min(max(configuration.headingLevel, 1), 6)
            let fontScale   = Self.fontScales[level - 1]
            let lineSpacing = Self.lineSpacings[level - 1]

            configuration.label
                .textual.fontScale(fontScale)
                .textual.lineSpacing(.fontScaled(lineSpacing))
                .textual.blockSpacing(.fontScaled(top: 1.2, bottom: 0.4))
                .fontWeight(.semibold)
        }
    }
}

extension StructuredText.HeadingStyle where Self == StructuredText.GuideHeadingStyle {
    static var guideMinimal: Self { .init() }
}

// MARK: - Block quote style

extension StructuredText {
    /// Subtle Day One-tinted block quote: brand cyan accent bar + soft tinted
    /// background.
    struct GuideBlockQuoteStyle: BlockQuoteStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity, alignment: .leading)
                .textual.lineSpacing(.fontScaled(0.4))
                .textual.padding(.fontScaled(0.9))
                .background {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(BrandColors.primary.opacity(0.08))
                        Rectangle()
                            .fill(BrandColors.primary)
                            .frame(width: 4)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
        }
    }
}

extension StructuredText.BlockQuoteStyle where Self == StructuredText.GuideBlockQuoteStyle {
    static var guide: Self { .init() }
}

// MARK: - Inline style

extension InlineStyle {
    /// Inline runs themed to Day One: links pick up the brand cyan; code spans,
    /// emphasis, strong, and strikethrough use Textual's defaults.
    static var guide: InlineStyle {
        InlineStyle()
            .link(.foregroundColor(BrandColors.primary))
    }
}
