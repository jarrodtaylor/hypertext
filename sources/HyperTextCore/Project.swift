import Foundation

struct Project {
  static let sourceURL: URL = URL(relativeFolder: UserInput.parameter(.source)!)
  static let targetURL: URL = URL(relativeFolder: UserInput.parameter(.target)!)

  static func file(_ ref: String) -> File? { list.first(where: { $0.ref == ref }) }

  static func build() -> Void {
    let startTime: Date = Date()

    do {
      for file in manifest {
        guard try file.isModified else { continue }
        try file.build()
      }

      try prune()

      let endTime: Int = Int(abs(startTime.timeIntervalSinceNow))
      debug("Finished building in \(endTime) seconds.")
    }

    catch {
      guard error.localizedDescription.contains("no such file") || error.localizedDescription.contains("doesn’t exist")
      else { crash("💀 \(error.localizedDescription)") }
    }
  }
}

fileprivate extension Project {
  static let list: [File] = sourceURL.list.map { File(origin: $0) }

  static let manifest: [File] = list.filter { $0.origin.lastPathComponent.prefix(1) != "!" }

  static let diff: [URL] = targetURL.list.filter { !manifest.map({ $0.destination }).contains($0) }

  static func prune() throws -> Void {
    for url in diff {
      try FileManager.default.removeItem(at: url)
      HyperText.echo("🗑️ \(url.scrub)")
    }

    for dir in targetURL.folders {
      if try FileManager.default.contentsOfDirectory(atPath: dir.path()).isEmpty {
        try FileManager.default.removeItem(at: dir)
        HyperText.echo("🗑️ \(dir.scrub)")
      }
    }
  }
}