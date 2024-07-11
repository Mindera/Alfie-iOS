@available(*, deprecated, message: "Please import \"Common\" package and use log() instead.")
public func print(_ items: String..., separator: String = " ", terminator: String = "\n") {
    Swift.print(items, separator: separator, terminator: terminator)
}
