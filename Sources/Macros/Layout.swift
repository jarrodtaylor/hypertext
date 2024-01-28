import Foundation

struct Layout {
  static let pattern = #"(<!-- #content -->)|(\/\* #content */)|(// #content.+)"#
  
  let template: File
  let content: String
  
  var context: [String: String] { get throws { try template.source.context } }
  
  func render() throws -> String {
    var text = try template.source.contents    
    
    for match in text.find(Layout.pattern) {
      text = text.replacingFirstOccurrence(of: match, with: content)
    }
    
    return text
  }
}