import Foundation

extension String {
  var asRef: String { self.split(separator: "/").joined(separator: "/") }
  
  func find(_ pattern: String) -> [String] {
    try! NSRegularExpression(pattern: pattern)
      .matches(in: self, range: NSRange(location: 0, length: self.utf16.count))
      .map { (self as NSString).substring(with: $0.range) }
  }
  
  func replacingFirstOccurrence(of: String, with: String) -> String {
    guard let range = self.range(of: of) else { return self }
    return self.replacingCharacters(in: range, with: with)
  }
}