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

  func build() throws {
    guard source.isRenderable else {
      HyperText.echo("Copying \(source.masked) -> \(target.masked)")
      try FileManager.default.copyFile(self)
      return
    }
    
    HyperText.echo("Rendering \(source.masked) -> \(target.masked)")
    render() // try FileManager.default.renderFile(self)
  }
  
  func render() {
    
  }
}