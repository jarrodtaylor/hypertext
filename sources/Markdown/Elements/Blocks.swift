struct Blockquote: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  var html: String { Tag(name: "blockquote", attributes: attributes, innerText: innerText, nest: true).html }

  init(_ innerText: String) {
    self.innerText = innerText
    self.extractAttributes()
    self.innerText = self.innerText.unpadLines(2).markdownToHTML
  }
}

struct Code: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ innerText: String) {
    self.innerText = innerText.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
    if isLastLineEmpty { self.innerText = self.innerText.toLines.dropLast(1).map({ String($0) }).joinedLines }
  }

  fileprivate var isLastLineEmpty: Bool { self.innerText.toLines.last!.trimmingCharacters(in: .whitespaces).isEmpty }
}

struct Header: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String
  var level: Int

  var html: String { Tag(name: "h\(level)", attributes: attributes, innerText: innerText).html }

  init(_ innerText: String, level: Int) {
    self.level = level
    self.innerText = innerText
    self.extractAttributes()
    self.innerText = self.innerText.prefix(1) == "#"
    ? self.innerText.dropFirst(level + 1).toString
    : self.innerText.toLines.dropLast(1).map({ String($0) }).joinedLines
    self.formatInnerText()
  }
}

struct P: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ innerText: String) {
    self.innerText = innerText
    self.extractAttributes()
    self.formatInnerText()
  }
}

struct Pre: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ innerText: String) {
    self.innerText = innerText
    self.extractAttributes()
    self.innerText = Code(self.innerText).html
  }
}