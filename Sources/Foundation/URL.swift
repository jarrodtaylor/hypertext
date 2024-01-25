import Foundation

extension URL {
  var exists: Bool {
    var isDirectory: ObjCBool = true
    return FileManager.default.fileExists(atPath: self.path(), isDirectory: &isDirectory)
  }
  
  var files: [URL] { list.filter { !$0.isDirectory } }
  
  var folders: [URL] { list.filter { $0.isDirectory } }
  
  var isDirectory: Bool { (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }
  
  var isRenderable: Bool {
    ["css", "htm", "html", "js", "md", "rss", "svg"]
    .contains(self.pathExtension)
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
  
  init(bufferPath: UnsafePointer<Int8>) {
    self = URL(fileURLWithFileSystemRepresentation: bufferPath, isDirectory: false, relativeTo: nil)
  }
  
  func stream(_ callback: @escaping ([Stream.FileSystemEvent]) -> Void) -> Stream {
    Stream(self, callback: callback)
  }
}