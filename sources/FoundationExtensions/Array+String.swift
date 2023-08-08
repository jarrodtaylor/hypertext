extension Array where Element == String {
  var htmlElements: Self {
    self.map { block in
      if block.prefix(1) == "<" && block.prefix(5) != "<http" && block.prefix(5) != "<mail" { return block }
  
      if block.prefix(2) == "  " { return Pre(block).html }
  
      if ["---", "***", "___"].contains(block.trimmingCharacters(in: .whitespacesAndNewlines).removingOccurrences(of: " "))
      { return "<hr>" }
  
      if let underlines: String = block.components(separatedBy: "\n").last?.prefix(3).toString {
        if underlines == "===" { return Header(block, level: 1).html }
        if underlines == "---" { return Header(block, level: 2).html }
      }
  
      let prefix: String = block.split(separator: " ", maxSplits: 1).first!.toString
      switch prefix {
        case "#", "##", "###", "####", "#####", "######":
          return Header(block, level: prefix.count).html
        case ">":
          return Blockquote(block).html
        case "-", "+", "*":
          return UL(block).html
        case "1.":
          return OL(block).html
        case "|":
          return Table(block).html
        default:
          return P(block).html
      }
    }
  }

  var joinedLines: String { self.joined(separator: "\n") }
}