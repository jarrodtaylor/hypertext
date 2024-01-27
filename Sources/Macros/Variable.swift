import Foundation

struct Variable {
  static let pattern = #"(<!-- @(.*?) -->|\/\* @(.*?) */|// @(.*?).+)"#
  
  var fragment: String
  
  var key: String {
    fragment
      .split(separator: " ")
      .dropFirst()
      .first!
      .description
      .trimmingCharacters(in: .whitespaces)
  }
  
  var defaultValue: String? {
    let split = fragment.split(separator: "??")
    guard split.count > 1 else { return nil }
    var value = split.last!.description
    if value.suffix(2) == "*/"  { value = value.dropLast(2).description }
    if value.suffix(3) == "-->" { value = value.dropLast(3).description }
    return value.trimmingCharacters(in: .whitespaces)
  }
}