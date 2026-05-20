import Foundation

/// Looks up and prepares markdown files bundled under the `guides/` folder
/// reference added to the app target. The folder is the live
/// `/Users/paulmayne/Projects/DayOne-Support/guides/` checkout, copied into the
/// app bundle by Xcode at build time.
enum Guides {

    struct LoadedGuide {
        let title: String
        let body: String
        let fileURL: URL
    }

    enum LoadError: Error {
        case rootMissing
        case fileMissing(relativePath: String)
        case unreadable(URL, Error)
    }

    /// URL of the bundled `guides/` folder, or nil if the folder reference
    /// wasn't included in the build (in which case the Guides UI shows an error
    /// state instead of crashing).
    static var rootURL: URL? {
        Bundle.main.url(forResource: "guides", withExtension: nil)
    }

    /// Loads a guide by its path relative to `rootURL`, e.g. `"writing/index.md"`.
    static func load(relativePath: String) throws -> LoadedGuide {
        guard let root = rootURL else { throw LoadError.rootMissing }
        let fileURL = root.appending(path: relativePath)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw LoadError.fileMissing(relativePath: relativePath)
        }
        let raw: String
        do {
            raw = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw LoadError.unreadable(fileURL, error)
        }
        let (frontmatter, body) = splitFrontmatter(raw)
        let cleanedBody = stripHTMLComments(body)
        let title = frontmatterTitle(frontmatter)
            ?? firstHeading(in: cleanedBody)
            ?? defaultTitle(for: fileURL)
        return LoadedGuide(title: title, body: cleanedBody, fileURL: fileURL)
    }

    /// Resolves a URL produced by Textual's link handling against the bundled
    /// guides root. Returns a relative path (e.g. `"organizing/index.md"`) when
    /// the URL points at a real markdown file or a folder under the bundle;
    /// returns nil otherwise (the caller should fall back to `.systemAction`).
    static func resolveBundleRelativePath(for url: URL) -> String? {
        guard let root = rootURL, url.isFileURL else { return nil }
        let standardized = url.standardizedFileURL.path
        let rootPath = root.standardizedFileURL.path
        guard standardized.hasPrefix(rootPath + "/") else { return nil }

        let relative = String(standardized.dropFirst(rootPath.count + 1))
        if relative.isEmpty { return nil }

        var isDir: ObjCBool = false
        let absolutePath = root.appending(path: relative).path
        guard FileManager.default.fileExists(atPath: absolutePath, isDirectory: &isDir) else {
            return nil
        }
        if isDir.boolValue {
            // Directory link → render that folder's index.md.
            return relative.hasSuffix("/") ? relative + "index.md" : relative + "/index.md"
        }
        guard relative.hasSuffix(".md") else { return nil }
        return relative
    }

    /// Strips `<!-- … -->` HTML comments. Textual renders them as literal text
    /// otherwise, which surfaces the `AUTO-INDEX:START/END` markers in
    /// auto-generated index.md files.
    private static func stripHTMLComments(_ input: String) -> String {
        guard let regex = try? NSRegularExpression(
            pattern: "<!--[\\s\\S]*?-->",
            options: []
        ) else { return input }
        let range = NSRange(input.startIndex..., in: input)
        return regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "")
    }

    // MARK: - Frontmatter parsing

    /// Splits a `---\n…\n---\n` frontmatter block off the top of a file.
    /// Returns the raw YAML (without the surrounding `---` lines) and the body
    /// content; if there is no leading frontmatter block, the body is the full
    /// input and the frontmatter string is empty.
    private static func splitFrontmatter(_ raw: String) -> (frontmatter: String, body: String) {
        guard raw.hasPrefix("---\n") || raw.hasPrefix("---\r\n") else {
            return ("", raw)
        }
        let afterOpen = raw.index(raw.startIndex, offsetBy: raw.hasPrefix("---\r\n") ? 5 : 4)
        let remainder = raw[afterOpen...]
        // Look for a line that is exactly `---` (optionally trailing CR).
        var idx = remainder.startIndex
        while idx < remainder.endIndex {
            let lineStart = idx
            while idx < remainder.endIndex, remainder[idx] != "\n" { idx = remainder.index(after: idx) }
            var line = remainder[lineStart..<idx]
            if line.hasSuffix("\r") { line = line.dropLast() }
            if line == "---" {
                let frontmatter = String(remainder[remainder.startIndex..<lineStart])
                let bodyStart = idx < remainder.endIndex ? remainder.index(after: idx) : remainder.endIndex
                let body = String(remainder[bodyStart..<remainder.endIndex])
                return (frontmatter, body)
            }
            if idx < remainder.endIndex { idx = remainder.index(after: idx) }
        }
        return ("", raw)
    }

    private static func frontmatterTitle(_ frontmatter: String) -> String? {
        for rawLine in frontmatter.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(rawLine).trimmingCharacters(in: .whitespaces)
            guard line.lowercased().hasPrefix("title:") else { continue }
            let valuePart = line.dropFirst("title:".count).trimmingCharacters(in: .whitespaces)
            var value = valuePart
            if (value.hasPrefix("\"") && value.hasSuffix("\""))
                || (value.hasPrefix("'") && value.hasSuffix("'")),
               value.count >= 2 {
                value = String(value.dropFirst().dropLast())
            }
            if !value.isEmpty { return value }
        }
        return nil
    }

    private static func firstHeading(in body: String) -> String? {
        for rawLine in body.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(rawLine)
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("# ") else { continue }
            return String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    private static func defaultTitle(for fileURL: URL) -> String {
        let stem = fileURL.deletingPathExtension().lastPathComponent
        if stem == "index" {
            return fileURL.deletingLastPathComponent().lastPathComponent
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
        }
        return stem.replacingOccurrences(of: "-", with: " ").capitalized
    }
}
