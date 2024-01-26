import Foundation
import Ink

struct File {
  let source: URL
  
  var isModified: Bool {
    get throws {
      true
    }
  }

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
    if target.exists { try FileManager.default.removeItem(at: target) }
    
    try FileManager.default.createDirectory(
      atPath: target.deletingLastPathComponent().path(),
      withIntermediateDirectories: true)
    
    if source.isRenderable {
      HyperText.echo("Copying \(source.masked) -> \(target.masked)")
      try FileManager.default.copyItem(at: source, to: target)
    }
    
    else {
      HyperText.echo("Rendering \(source.masked) -> \(target.masked)")
      FileManager.default.createFile(
        atPath: target.path(),
        contents: try render().data(using: .utf8))
    }
  }
  
  func render() throws -> String {
    ""
  }
}