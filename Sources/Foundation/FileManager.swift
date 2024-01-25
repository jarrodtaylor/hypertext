import Foundation

extension FileManager {
  func copyFile(_ file: File) throws -> Void {
    if file.target.exists { try removeItem(at: file.target) }
    try createDirectory(file.target)
    try copyItem(at: file.source, to: file.target)
  }

  private func createDirectory(_ path: URL) throws -> Void {
    let directory: String = path.deletingLastPathComponent().path()
    try createDirectory(atPath: directory, withIntermediateDirectories: true)
  }
}