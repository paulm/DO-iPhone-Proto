import SwiftUI

/// Observable view model managing root-level UI state
@Observable
final class RootViewModel {
    /// Controls presentation of the new entry modal sheet
    var showingNewEntry = false
    
    /// Initializes the root view model with default state
    init() {}
}