import Foundation

struct File {
  let origin: URL

  var destination: URL {
    let path: String = origin.absoluteString
      .replacingFirstOccurrence(of: Project.sourceURL.absoluteString, with: Project.targetURL.absoluteString)
    return URL(string: path.suffix(3) == ".md" ? path.dropLast(3) + ".html" : path)!
  }

  var ref: String {
    let path: String = origin.scrub.replacingFirstOccurrence(of: UserInput.parameter(.source)!, with: "")
    return path.prefix(1) == "/" ? path.dropFirst(1).toString : path
  }

  var isModified: Bool {
    get throws {
      guard destination.exists,
        let originModificationDate = try origin.modificationDate,
        let destinationModificationDate = try destination.modificationDate
      else { return true }

      if originModificationDate > destinationModificationDate { return true }

      for ref in try dependencies {
        if let dependency: File = Project.file(ref),
           let refModificationDate = try dependency.origin.modificationDate,
           refModificationDate > destinationModificationDate,
           try dependency.isModified
        { return true }
      }

      return false
    }
  }

  func render(_ currentContext: [String: String] = [:]) throws -> String {
    var currentContext: [String: String] = currentContext
    var text: String = try origin.contents

    if try !context.isEmpty {
      for (key, value) in try context { currentContext[key] = value }
      text = text.removingOccurrences(of: text.find(#"---(\n|.)*?---\n"#).first!)
    }

    if origin.pathExtension == "md" { text = text.markdownToHTML }

    if currentContext[":forceLayout"] == "true" || currentContext[":isIncluding"] != "true",
      let layoutRef: String = currentContext[":layout"],
      let layoutFile: File = Project.file(layoutRef)
    { text = try layout(text, in: layoutFile) }

    text = try expandIncludes(in: text, currentContext: currentContext)
    text = expandVariables(in: text, currentContext: currentContext)
    text = text.unpaddedCode

    return text
  }

  func build() throws -> Void {
    if origin.isRenderable {
      try FileManager.default.renderFile(self)
      HyperText.echo("\(origin.scrub) => \(destination.scrub)")
    }

    else {
      try FileManager.default.copyFile(self)
      HyperText.echo("\(origin.scrub) => \(destination.scrub)")
    }
  }
}

fileprivate extension File {
  var context: [String: String] {
    get throws {
      var ctx: [String: String] = [:]
      if try origin.contents.toLines.first == "---", let yaml = try origin.contents.find(#"---(\n|.)*?---"#).first {
        yaml.toLines
          .filter { $0 != "---" }
          .map { $0.split(separator: ": ", maxSplits: 1) }
          .filter { $0.count == 2 }
          .forEach { setting in let (k, v) = (setting[0].toString, setting[1].toString); ctx[k] = v }
      }

      return ctx
    }
  }

  var dependencies: [String] {
    get throws {
      if origin.isRenderable {
        return try origin.contents
          .find(#"(:layout: (.*?).+|<!-- :include (.*?) -->|// :include (.*?).+|\/\* :include (.*?) \*\/)"#)
          .map { $0
            .removingOccurrences(of: ":layout: ")
            .removingOccurrences(of: "<!-- :include ")
            .removingOccurrences(of: " -->")
            .removingOccurrences(of: "// :include ")
            .removingOccurrences(of: "/* :include ")
            .removingOccurrences(of: " */")
          }.map { $0.split(separator: "++", maxSplits: 1).first!.toString } }
      
      return []
    }
  }

  func expandIncludes(in text: String, currentContext: [String: String]) throws -> String {
    var currentContext = currentContext; currentContext[":isIncluding"] = "true"

    return try text.toLines.map { line in
      guard let match: String = line.find(#"(<!-- :include (.*?) -->|// :include (.*?).+|\/\* :include (.*?) \*\/)"#).first,
            let file: File = Project.file(match.split(separator: " ")[2].toString)
      else { return line }

      if line.contains("++") {
         line
          .removingOccurrences(of: "-->")
          .removingOccurrences(of: "*/")
          .split(separator: "++")
          .dropFirst(1)
          .map { $0.toString.trimmingCharacters(in: .whitespaces) }
          .forEach { setting in
            let split: [String] = setting.split(separator: ": ", maxSplits: 1).map { $0.toString }
            if split.count == 2 { currentContext[split[0]] = split[1] }
          }
      }

      return try file.render(currentContext).padLines(line.padding).dropFirst(line.padding).toString
    }.joinedLines
  }

  func expandVariables(in text: String, currentContext: [String: String]) -> String {
    var text = text
    text.find(#"(<!-- @(.*?) -->|\/\* @(.*?) \*\/)"#).forEach { match in
      var newValue: String = ""
      let varName: String = match
        .find(#"(<!-- @(.*?)\s|\/\* @(.*?)\s)"#).first!
        .removingOccurrences(of: "<!-- @")
        .removingOccurrences(of: "/* @")
        .trimmingCharacters(in: .whitespaces)
      if let value = currentContext[varName] { newValue = value }
      else if match.contains("??"), let backupValue = match
        .split(separator: "??", maxSplits: 1).last?.toString
        .removingOccurrences(of: "-->")
        .removingOccurrences(of: "*/")
        .trimmingCharacters(in: .whitespaces)
      { newValue = backupValue }
      text = text.replacingOccurrences(of: match, with: newValue)
    }

    return text
  }

  func layout(_ text: String, in layoutFile: File) throws -> String {
    try layoutFile.origin.contents.toLines
      .map { line in
        guard line.contains("<!-- :content -->") else { return line }
        return text.padLines(line.padding).dropFirst(line.padding).toString
      }.joinedLines
  }
}