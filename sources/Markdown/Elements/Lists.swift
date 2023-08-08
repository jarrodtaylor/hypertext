struct OL: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ innerText: String) {
    self.innerText = innerText
    self.extractAttributes()
    self.innerText = LI.format(self.innerText, splitBy: #"\d+.\s+"#)
  }
}

struct UL: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ innerText: String) {
    self.innerText = innerText
    self.extractAttributes()
    self.innerText = LI.format(self.innerText, splitBy: #"[-*+]\s+"#)
  }
}

struct LI: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ innerText: String) {
    self.innerText = innerText
    self.innerText.toBlocks.count > 1
    ? self.innerText = self.innerText.markdownToHTML
    : self.formatInnerText()
  }

  static func format(_ text: String, splitBy: String) -> String {
    let items: [String] = text.split(separator: try! Regex("\n" + splitBy)).map({ $0.toString })
    let padding: Int = items.first!.find(splitBy).first!.count

    return items.enumerated()
      .map { (i, item) in i == 0 ? item : String(repeating: " ", count: padding) + item }
      .map { $0.unpadLines(padding) }
      .map { item in
        item.toLines.enumerated()
          .map { (i, line) in i == 1 && ["* ", "- ", "+ ", "1."].contains(line.prefix(2)) ? "\n\(line)" : line }
          .joinedLines
      }.map { LI($0).html }
      .joinedLines
  }
}