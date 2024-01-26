import Foundation

extension URL {
  var exists: Bool {
    var isDirectory: ObjCBool = true
    return FileManager.default.fileExists(atPath: self.path(), isDirectory: &isDirectory)
  }
    
  var isDirectory: Bool { (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }
  
  var masked: String {
    absoluteString
      .replacingFirstOccurrence(of: FileManager.default.currentDirectoryPath, with: "")
      .replacingFirstOccurrence(of: "file:///", with: "")
      .asRef
  }
}