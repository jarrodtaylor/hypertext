struct Table: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ innerText: String) {
    self.innerText = innerText
    self.extractAttributes()

    var headCells: [String] = []
    var alignments: [String] = []
    var bodyRows: [[String]] = []

    bodyRows = self.innerText
      .replacingOccurrences(of: "\\|", with: "&#124;").toLines
      .map { line in
        line
          .components(separatedBy: "|")
          .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
          .filter { !$0.isEmpty }
      }.filter({ !$0.isEmpty })

    if bodyRows.count > 1 && ["--", ":-"].contains(bodyRows[1].first!.prefix(2)) {
      headCells = bodyRows.first!
      bodyRows.remove(at: 0)
    }

    alignments = Array(repeating: "left", count: bodyRows[0].count)
    if ["--", ":-"].contains(bodyRows[0].first!.prefix(2)) {
      alignments = bodyRows[0]
        .map { $0.first! == ":" && $0.last! == ":"
          ? "center"
          : $0.last! == ":"
          ? "right"
          : "left" }
      bodyRows.remove(at: 0)
    }

    self.innerText = ""
    if !headCells.isEmpty { self.innerText += THead(headCells, alignments: alignments).html }
    if !headCells.isEmpty && !bodyRows.isEmpty { self.innerText += "\n" }
    if  !bodyRows.isEmpty { self.innerText += TBody(bodyRows, alignments: alignments).html }
  }
}

struct TBody: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ rows:[[String]], alignments:[String]) {
    self.innerText = rows
      .map { row in
        let cells: [TD] = row.enumerated().map { (i, cell) in TD(cell, alignment: alignments[i]) }
        return TR(cells).html
      }.joinedLines
  }
}

struct TD: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ innerText:String, alignment:String) {
    self.attributes.append(.init(key: "style", value: "text-align: \(alignment)"))
    self.innerText = innerText
    self.formatInnerText()
  }
}

struct TH: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ innerText: String, alignment: String) {
    self.attributes.append(.init(key: "style", value: "text-align: \(alignment)"))
    self.innerText = innerText
    self.formatInnerText()
  }
}

struct THead: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ cells: [String], alignments: [String]) {
    let cells: [TH] = cells.enumerated().map { (i, text) in TH(text, alignment: alignments[i]) }
    self.innerText = TR(cells).html
  }
}

struct TR: HTMLElement {
  var attributes: [HTMLAttribute] = []
  var innerText: String

  init(_ cells: [HTMLElement]) { self.innerText = cells.map({ $0.html }).joinedLines }
}