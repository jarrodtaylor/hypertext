import Foundation

extension URL {
  var contents: String {
    get throws {
      let data: Data = try Data(contentsOf: self)
      return String(decoding: data, as: UTF8.self)
    }
  }

  var exists: Bool {
    var isDirectory: ObjCBool = true
    return FileManager.default.fileExists(atPath: self.path(), isDirectory: &isDirectory)
  }

  var folders: [URL] {
    FileManager.default
      .subpaths(atPath: self.path())!
      .filter { !$0.contains(".DS_Store") }
      .map { self.appending(component: $0) }
      .filter { $0.isDirectory }
  }

  init(bufferPath: UnsafePointer<Int8>) {
    self = URL(fileURLWithFileSystemRepresentation: bufferPath, isDirectory: false, relativeTo: nil)
  }

  init(relativeFolder path: String) {
    self.init(filePath: FileManager.default.currentDirectoryPath)
    self = self.appending(path: path.suffix(1) == "/" ? path : path + "/")
  }

  var isDirectory: Bool { (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }

  var isRenderable: Bool { ["css", "htm", "html", "js", "md", "rss", "svg"].contains(self.pathExtension) }

  var list: [URL] {
    FileManager.default
      .subpaths(atPath: self.path())!
      .filter { !$0.contains(".DS_Store") }
      .map { self.appending(component: $0) }
      .filter { !$0.isDirectory }
  }

  var modificationDate: Date? {
    get throws {
      try FileManager.default.attributesOfItem(atPath: self.path)[FileAttributeKey.modificationDate] as? Date
    }
  }

  var scrub: String {
    absoluteString
      .replacingFirstOccurrence(of: FileManager.default.currentDirectoryPath, with: "")
      .replacingFirstOccurrence(of: "file:///", with: "")
  }

  func stream(_ callback: @escaping ([Stream.FileSystemEvent]) -> Void) -> Stream { Stream(self, callback: callback) }
}