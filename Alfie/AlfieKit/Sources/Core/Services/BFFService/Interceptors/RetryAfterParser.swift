import Foundation

/// Parses the `Retry-After` HTTP header per RFC 7231 §7.1.3. Accepts a delta-seconds
/// integer or any of the three RFC 7231 §7.1.1.1 date formats. Returns `nil` on
/// unparseable input — callers fall back to their own backoff math.
enum RetryAfterParser {
    static func parse(headerValue: String?, now: Date = Date()) -> TimeInterval? {
        guard let raw = headerValue?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else { return nil }

        if let seconds = TimeInterval(raw), seconds >= 0 { return seconds }

        for formatter in dateFormatters {
            if let date = formatter.date(from: raw) {
                let delta = date.timeIntervalSince(now)
                return max(0, delta)
            }
        }
        return nil
    }

    // RFC 7231 §7.1.1.1 — three accepted HTTP-date formats. Locale and timezone are
    // fixed so parsing is independent of device settings.
    private static let dateFormatters: [DateFormatter] = {
        let patterns = [
            "EEE, dd MMM yyyy HH:mm:ss zzz", // IMF-fixdate
            "EEEE, dd-MMM-yy HH:mm:ss zzz",  // RFC 850
            "EEE MMM d HH:mm:ss yyyy"         // asctime
        ]
        return patterns.map { pattern in
            let formatter = DateFormatter()
            formatter.dateFormat = pattern
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "GMT")
            return formatter
        }
    }()
}
