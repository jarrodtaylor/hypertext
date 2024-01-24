import Foundation

struct Project {
  static var source: URL?
  static var target: URL?
  
  static func build() -> Void {}
  static func stream() -> Void {}
}