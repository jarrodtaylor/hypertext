import Foundation

struct Project {
  static var source: URL?
  static var target: URL?
  
  static func build() -> Void {
    do {
      try manifest.forEach { try $0.build() }
      
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
    }
    
    catch {
      HyperText.echo(error.localizedDescription)
      exit(1)
    }
  }
  
  static func stream() -> Void {
    HyperText.echo("Streaming \(source!.masked) -> \(target!.masked) (^c to stop)")
    build()
    withExtendedLifetime(source!.stream { _events in build() }, {})
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
  
  static func file(_ ref: String) -> File? {
    source!.files
      .map { File(source: $0) }
      .first(where: { $0.ref == ref })
  }
}