import Foundation

extension String {
  var asRef: String { self.split(separator: "/").joined(separator: "/") }

  func replacingFirstOccurrence(of: String, with: String) -> String {
    guard let range = self.range(of: of) else { return self }
    return self.replacingCharacters(in: range, with: with)
  }
}