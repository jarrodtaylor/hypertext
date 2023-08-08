struct Tag: HTMLElement {
  let name: String
  var attributes: [HTMLAttribute] = []
  var innerText: String = ""
  var nest: Bool = false

  var html: String {
    var element:String = "<\(name) \(attributes.toString)".trimmingCharacters(in: .whitespacesAndNewlines) + ">"

    if !innerText.isEmpty {
      element += nest == true || innerText.toLines.count > 1
      ? "\n\(innerText.padLines(2).dropFirst(2))\n</\(name)>"
      : "\(innerText)</\(name)>"
    }

    return element
  }
}