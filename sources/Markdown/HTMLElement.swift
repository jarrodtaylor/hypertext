protocol HTMLElement {
  var attributes: [HTMLAttribute] { get set }
  var innerText: String { get set }
  var html: String { get }
}

struct HTMLAttribute {
  let key: String
  let value: String

  init(key: String, value: String) { self.key = key; self.value = value }

  init(keyValuePair: String) {
    let split: [String] = keyValuePair.split(separator: "=", maxSplits: 1).map { String($0) }
    self.key = split.first!
    self.value = split.last!.dropFirst(1).dropLast(1).toString
  }
}

extension HTMLElement {
  mutating func extractAttributes() -> Void {
    if let match: String = self.innerText.find(#"<!-- :attributes (.*?) -->"#).first {
      self.attributes = match
        .removingOccurrences(of: "<!-- :attributes")
        .removingOccurrences(of: "-->")
        .trimmingCharacters(in: .whitespaces)
        .find(#"\w+=\"(.*?)\""#)
        .map { HTMLAttribute(keyValuePair: $0) }
      self.innerText = self.innerText.removingOccurrences(of: match)
    }
  }

  mutating func formatInnerText() -> Void {
    var tags: [String] = []

    self.expandEscapes()
    self.expandAutoLinks()
    self.expandImages()
    self.expandLinks()
    self.expandLineBreaks()

    for tag in self.innerText.find("<(.*?)>") {
      self.innerText = self.innerText.replacingOccurrences(of: tag, with: "%\(tags.count)%")
      tags.append(tag)
    }

    self.expandQuotes()
    self.expandSpecialCharacters()
    self.expandEmphases()

    for (i, tag) in tags.enumerated() { self.innerText = self.innerText.replacingOccurrences(of: "%\(i)%", with: tag) }

    self.innerText = self.innerText.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  var html: String { Tag(name: tagName, attributes: attributes, innerText: innerText).html }
}

fileprivate extension HTMLElement {
  mutating func expandAutoLinks() -> Void {
    for link in self.innerText.find(#"<https:(.*?)>"#) {
      let url: String = link.dropFirstAndLast(1)
      let tag: Tag = Tag(name: "a", attributes: [.init(key: "href", value: url)], innerText: url)
      self.innerText = self.innerText.replacingOccurrences(of: link, with: tag.html)
    }

    for link in self.innerText.find(#"<mailto:(.*?)>"#) {
      let address: String = link.replacingFirstOccurrence(of: "mailto:", with: "").dropFirstAndLast(1)
      let tag: Tag = Tag(name: "a", attributes: [.init(key: "href", value: "mailto:\(address)")], innerText: address)
      self.innerText = self.innerText.replacingOccurrences(of: link, with: tag.html)
    }
  }

  mutating func expandEmphases() -> Void {
    [["**", "strong", #"\*\*(.+?)\*\*"#], ["__", "strong", #"\_\_(.+?)\_\_"#],
     ["~~", "s",      #"\~\~(.+?)\~\~"#], ["==", "mark",   "==(.+?)=="      ],
     ["*",  "em",     #"\*(.+?)\*"#    ], ["_",  "em",  #"\_(.+?)\_"#       ],
     ["`",  "code",   "`(.+?)`"        ], ["~",  "sub",    #"\~(.+?)\~"#    ],
     ["^",  "sup",    #"\^(.+?)\^"#    ]]
    .forEach { emphasis in let (char, tagName, pattern) = (emphasis[0], emphasis[1], emphasis[2])
      for match in self.innerText.find(pattern) {
        let str: String = match.replacingOccurrences(of: char, with: "")
        let tag: String = Tag(name: tagName, innerText: str).html
        self.innerText = self.innerText.replacingOccurrences(of: match, with: tag)
      }
    }
  }

  mutating func expandEscapes() -> Void {
    [[#"\\"#, "&#92;" ], [#"\`"#, "&#96;"], [#"\*"#, "&#42;"], [#"\_"#, "&#95;" ], [#"\{"#, "&#123;"],
     [#"\}"#, "&#125;"], [#"\["#, "&#91;"], [#"\]"#, "&#93;"], [#"\("#, "&#40;" ], [#"\)"#, "&#41;" ],
     ["\\#",  "&#35;" ], [#"\+"#, "&#43;"], [#"\-"#, "&#45;"], [#"\."#, "&#46;" ], [#"\!"#, "&#33;" ],
     [#"\&"#, "&amp;" ], [#"\""#, "&#34;"], [#"\'"#, "&#39;"], [#"\|"#, "&#124;"], [#"\~"#, "&#126;"],
     [#"\^"#, "&#94;" ]]
    .forEach { self.innerText = self.innerText.replacingOccurrences(of: $0[0], with: $0[1]) }
  }

  mutating func expandImages() -> Void {
    for img in self.innerText.find(#"!\[(.*?)\)"#) {
      var attrs: [HTMLAttribute] = []
      
      if let alt = img.find(#"\[(.*?)\]"#).first
      { attrs.append(.init(key: "alt", value: alt.dropFirstAndLast(1))) }
      if let src = img.find(#"](\(.*?)( |\))"#).first
      { attrs.append(.init(key: "src", value: src.dropFirst(2).dropLast(1).toString)) }
      if let title = img.find(#"\"(.*?)\""#).first
      { attrs.append(.init(key: "title", value: title.dropFirstAndLast(1))) }
      for attr in img.find(#"\w+=\"(.*?)\""#) { attrs.append(.init(keyValuePair: attr)) }
      let tag: String = Tag(name: "img", attributes: attrs).html
      self.innerText = self.innerText.replacingOccurrences(of: img, with: tag)
    }
  }

  mutating func expandLineBreaks()
  -> Void { self.innerText = self.innerText.replacingOccurrences(of: "  \n", with: "\n<br>\n") }

  mutating func expandQuotes() -> Void {
    self.innerText.find(#"'(.*?)'"#).forEach {
      self.innerText = self.innerText.replacingOccurrences(of: $0, with: "&lsquo;\($0.dropFirstAndLast(1))&rsquo;")
    }
    
    self.innerText.find(#"\"(.*?)\""#).forEach {
      self.innerText = self.innerText.replacingOccurrences(of: $0, with: "&ldquo;\($0.dropFirstAndLast(1))&rdquo;")
    }
  }

  mutating func expandLinks() -> Void {
    for link in self.innerText.find(#"\[(.*?)\)"#) {
      var attrs: [HTMLAttribute] = []
      var text: String = ""
      
      if let txt = link.find(#"\[(.*?)\]"#).first { text = txt.dropFirstAndLast(1) }
      if let href = link.find(#"](\(.*?)( |\))"#).first
      { attrs.append(.init(key: "href", value: href.dropFirst(2).dropLast(1).toString)) }
      if let title = link.find(#"\"(.*?)\""#).first
      { attrs.append(.init(key: "title", value: title.dropFirstAndLast(1))) }
      for attr in link.find(#"\w+=\"(.*?)\""#) { attrs.append(.init(keyValuePair: attr)) }
      let tag: String = Tag(name: "a", attributes: attrs, innerText: text).html
      self.innerText = self.innerText.replacingOccurrences(of: link, with: tag)
    }
  }

  mutating func expandSpecialCharacters() -> Void {
    [["(c)",  "&copy;"  ], ["(C)", "&copy;"  ], ["(r)", "&reg;"  ], ["(R)", "&reg;"   ],
     ["(tm)", "&trade;" ], ["(TM)", "&trade;"], [" & ", " &amp; "], ["...", "&hellip;"],
     [" - ", " &ndash; "], ["--",   "&mdash;"], ["'",    "&apos;"]]
    .forEach { self.innerText = self.innerText.replacingOccurrences(of: $0[0], with: $0[1]) }
  }

  var tagName: String { "\(self)".split(separator: "(").first!.lowercased() }
}