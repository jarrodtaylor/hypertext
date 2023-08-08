import Foundation

extension String {
  func dropFirstAndLast(_ k: Int) -> String { self.dropFirst(k).dropLast(k).toString }

  func find(_ pattern: String) -> [String] {
    try! NSRegularExpression(pattern: pattern)
      .matches(in: self, range: NSRange(location: 0, length: self.utf16.count))
      .map { (self as NSString).substring(with: $0.range) }
  }
  
  var markdownToHTML: String { self.expandingReferences.toBlocks.htmlElements.joinedLines }

  var padding: Int { self.prefix(while: { $0 == " " }).count }

  func padLines(_ spaces: Int) -> String {
    let padding: String = String(repeating: " ", count: spaces)
    return padding + self.toLines.map({ padding + $0 }).joined(separator: "\n")
  }

  func replacingFirstOccurrence(of: String, with: String) -> String {
    guard let range = self.range(of: of) else { return self }
    return self.replacingCharacters(in: range, with: with)
  }

  func removingOccurrences(of text: String) -> String { self.replacingOccurrences(of: text, with: "") }

  var toBlocks
  : [String] { self.components(separatedBy: "\n\n").map({ $0.trimmingCharacters(in: .newlines) }).filter({ $0.count != 0 }) }

  var toLines: [String] { self.components(separatedBy: "\n") }

  var unpaddedCode: String {
    var text = self
    for block in text.find(#"<pre(.*?)>\s+<code>(\n|.)*?<\/code>\s+<\/pre>"#) {
      let lines   : [String] = block.toLines.dropFirst(2).dropLast(2)
      let padding :  Int     = lines.reduce(999) { $0 < $1.padding ? $0 : $1.padding }
      let innerText: String = lines.joinedLines
      text = text.replacingOccurrences(of: innerText, with: innerText.unpadLines(padding))
    }
    
    return text
  }

  func unpadLines(_ by: Int) -> String { self.toLines.map({ $0.dropFirst(by).toString }).joinedLines }
}

fileprivate extension String {
  var expandingReferences: String {
    var text = self
    text.toLines
      .filter { line in
        guard let prefix: String = line.split(separator: " ", maxSplits: 1).first?.toString
        else { return false }
        return line.find(#"\[(.*?)\]:"#).contains(prefix)
      }.forEach { line in
        let ref: String = line.trimmingCharacters(in: .whitespacesAndNewlines)
        let key: String = ref.components(separatedBy: ": ").first!
        let val: String = ref.components(separatedBy: ": ").last!
        text = text
          .removingOccurrences(of: line)
          .replacingOccurrences(of: key, with: "(\(val))")
          .replacingOccurrences(of: "] (", with: "](") }
  
    return text
  }
}