import Foundation

extension FileHandle: TextOutputStream {
  public func write(_ message: String) -> Void { self.write(message.data(using: .utf8)!) }
}