import Foundation

struct Project {
  static var source: URL?
  static var target: URL?
  
  static func build() -> Void {
    do {
      for file in manifest {
        guard try file.isModified else { continue }
        try file.build()
      }
      
      for url in diff {
        HyperText.echo("Deleting \(url.masked)")
        try FileManager.default.removeItem(at: url)
      }
      
      for url in target!.folders {
        if try FileManager.default.contentsOfDirectory(atPath: url.path()).isEmpty {
          HyperText.echo("Deleting \(url.masked)")
          try FileManager.default.removeItem(at: url)
        }
      }
    } catch {
      HyperText.echo(error.localizedDescription)
      exit(1)
    }
  }
  
  static func file(_ ref: String) -> File? {
    source!.files
      .map { File(source: $0) }
      .first(where: { $0.ref == ref })
  }
  
  static func stream() -> Void {
    HyperText.echo("Streaming \(source!.masked) -> \(target!.masked) (^c to stop)")
    build()
    let stream: Stream = source!.stream { _events in build() }
    withExtendedLifetime(stream, {})
    RunLoop.main.run()
  }
}

fileprivate extension Project {
  static let diff: [URL] = target!.list
    .filter {
      !manifest
        .map { $0.target.absoluteString }
        .contains($0.absoluteString) }
  
  static let manifest: [File] = source!.files
    .filter { $0.lastPathComponent.prefix(1) != "!" }
    .map { File(source: $0) }
}