import Foundation
import Ink

struct File {
  let source: URL
  
  var ref: String {
    source.absoluteString
      .replacingFirstOccurrence(of: Project.source!.absoluteString, with: "")
      .asRef
  }
  
  var target: URL {
    let url = URL(string: source.absoluteString
      .replacingFirstOccurrence(
        of: Project.source!.absoluteString,
        with: Project.target!.absoluteString))!
    
    return url.pathExtension == "md"
    ? url.deletingPathExtension().appendingPathExtension("html")
    : url
  }
  
  func build() throws -> Void {
    guard try isModified else { return }
    
    if target.exists { try FileManager.default.removeItem(at: target) }
    try FileManager.default.createDirectory(
      atPath: target.deletingLastPathComponent().path(),
      withIntermediateDirectories: true)
    
    if source.isRenderable {
      HyperText.echo("Rendering \(source.masked) -> \(target.masked)")
      FileManager.default.createFile(
        atPath: target.path(),
        contents: try render().data(using: .utf8))
    }
    
    else {
      HyperText.echo("Copying \(source.masked) -> \(target.masked)")
      try FileManager.default.copyItem(at: source, to: target)
    }
  }
}

fileprivate extension File {  
  var isModified: Bool {
    get throws {
      guard target.exists,
        let sourceModDate = try source.modificationDate,
        let targetModDate = try target.modificationDate,
        targetModDate > sourceModDate
      else { return true }
      
      for dep in try source.dependencies {
        if let depModDate = try dep.source.modificationDate,
          depModDate > targetModDate,
          try dep.isModified
        { return true }
      }
      
      return false
    }
  }
  
  func render(_ cxt: [String: String] = [:]) throws -> String {
    var cxt = cxt
    for (key, val) in try source.context { cxt[key] = val }
    
    var text = try source.contents
    
    if cxt["#forceLayout"] == "true" || cxt["#isIncluding"] != "true",
      let layoutRef = cxt["#layout"], let layoutFile = Project.file(layoutRef)
    {
      let macro = Layout(template: layoutFile, content: text)
      for (key, value) in try macro.context { if cxt[key] == nil { cxt[key] = value } }
      text = try macro.render()
    }
    
    for match in text.find(Include.pattern) {
      let macro = Include(fragment: match)
      if macro.file?.source.exists == true {
        var params = macro.parameters
        for (key, value) in params { if let val = cxt[value] { params[key] = val } }
        params["#isIncluding"] = "true"
        text = text.replacingFirstOccurrence(of: match, with: try macro.file!.render(params))
      }
    }
    
    for match in text.find(Variable.pattern) {
      let macro = Variable(fragment: match)
      if let value = cxt.contains(where: { $0.key == macro.key })
      ? cxt[macro.key] : macro.defaultValue {
        text = text.replacingFirstOccurrence(of: match, with: value as String)
      }
    }
    
    return text
  }
}