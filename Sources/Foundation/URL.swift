import Foundation
import Ink

extension URL {
  var contents: String {
    get throws {
      if pathExtension == "md" { MarkdownParser.shared.html(from: try rawContents) }
      else if try context.isEmpty { try rawContents }
      else {
        try rawContents.replacingFirstOccurrence(
          of: try rawContents.find(#"---(\n|.)*?---\n"#).first!,
          with: "")
      }
    }
  }
  
  var context: [String: String] {
    get throws { MarkdownParser.shared.parse(try rawContents).metadata }
  }
  
  var dependencies: [File] {
    get throws {
      guard isRenderable else { return [] }
      
      var deps: [File?] = []
      for match in try contents.find(Include.pattern) { deps.append(Include(fragment: match).file) }
      if let ref = try context["#layout"] { deps.append(Project.file(ref)) }
      
      return deps
        .filter { $0!.source.exists == true }
        .map { $0! }
    }
  }
  
  var exists: Bool {
    var isDirectory: ObjCBool = true
    return FileManager.default.fileExists(atPath: self.path(), isDirectory: &isDirectory)
  }
  
  var files: [URL] { list.filter { !$0.isDirectory } }
  
  var folders: [URL] { list.filter { $0.isDirectory } }
  
  var isDirectory: Bool { (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }
  
  var isRenderable: Bool {
    ["css", "htm", "html", "js", "md", "rss", "svg"].contains(pathExtension)
  }
  
  var list: [URL] {
    FileManager.default
      .subpaths(atPath: self.path())!
      .filter { !$0.contains(".DS_Store") }
      .map { self.appending(component: $0) }
  }
  
  var masked: String {
    absoluteString
      .replacingFirstOccurrence(of: FileManager.default.currentDirectoryPath, with: "")
      .replacingFirstOccurrence(of: "file:///", with: "")
      .asRef
  }
  
  var modificationDate: Date? {
    get throws {
      try FileManager.default
        .attributesOfItem(atPath: self.path())[FileAttributeKey.modificationDate] as? Date
    }
  }
  
  var rawContents: String {
    get throws { String(decoding: try Data(contentsOf: self), as: UTF8.self) }
  }
  
  init(bufferPath: UnsafePointer<Int8>) {
    self = URL(fileURLWithFileSystemRepresentation: bufferPath, isDirectory: false, relativeTo: nil)
  }
  
  func stream(_ callback: @escaping ([Stream.FileSystemEvent]) -> Void) -> Stream {
    Stream(self, callback: callback)
  }
}