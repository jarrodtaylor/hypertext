extension Array where Element == HTMLAttribute {
  var toString: String { self.map({ "\($0.key)=\"\($0.value)\"" }).joined(separator: " ") }
}