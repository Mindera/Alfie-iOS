import UIKit

public final class ShareConfiguration: UIActivityItemProvider {
    public let url: URL
    public let message: String
    public let subject: String

    public init(url: URL, message: String, subject: String) {
        self.url = url
        self.message = message
        self.subject = subject
        super.init(placeholderItem: message)
    }
}

public extension ShareConfiguration {
    override var item: Any {
        message
    }

    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        subject
    }
}
