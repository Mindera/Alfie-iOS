import Foundation

/// Where the shopper opened the scanner from, in the vocabulary the `scan_started` analytics event
/// uses.
///
/// A type rather than a bare string for the same reason as ``ScanFailureReason``: the entry points
/// are read against each other, and a typo would quietly split one bar into two. Today the Search
/// bar is the only door in — a second case arrives with the second door, not before it.
public enum ScanEntryPoint: String {
    /// The Scan control inside the Search bar, on any screen that shows one.
    case searchBar = "search_bar"
}
