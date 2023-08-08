import Foundation

extension FileManager {
  func copyFile(_ file: File) throws -> Void {
    try createDirectory(atPath: file.destination.deletingLastPathComponent().path(), withIntermediateDirectories: true)
    if file.destination.exists { try removeItem(at: file.destination) }
    try copyItem(at: file.origin, to: file.destination)
  }

  func renderFile(_ file: File) throws -> Void {
    try createDirectory(atPath: file.destination.deletingLastPathComponent().path(), withIntermediateDirectories: true)
    createFile(atPath: file.destination.path(), contents: try file.render().data(using: .utf8))
  }
}