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
      true
    }
  }
  
  func render(_ cxt: [String: String] = [:]) throws -> String {
    var cxt = cxt
    for (key, val) in try source.context { cxt[key] = val }
    
    var text = try source.contents
    
    // layout
    
    // includes
    
    for match in text.find(Variable.pattern) {
      let include = Variable(fragment: match)
      if let value = cxt.contains(where: { $0.key == include.key })
      ? cxt[include.key] : include.defaultValue {
        text = text.replacingFirstOccurrence(of: match, with: value as String)
      }      
    }
    
    return text
  }
}