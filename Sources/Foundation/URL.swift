import Foundation

extension URL {
  var exists: Bool {
    var isDirectory: ObjCBool = true
    return FileManager.default.fileExists(atPath: self.path(), isDirectory: &isDirectory)
  }

  var masked: String {
    absoluteString
      .replacingFirstOccurrence(of: FileManager.default.currentDirectoryPath, with: "")
      .replacingFirstOccurrence(of: "file:///", with: "")
      .asRef
  }
}