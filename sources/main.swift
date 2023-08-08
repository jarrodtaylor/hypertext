import Foundation

func echo(_ message: String) -> Void {
  var standardError: FileHandle = FileHandle.standardError
  print(message, to: &standardError)
}

func debug(_ message: String) -> Void {
  guard UserInput.flag(.debug) else { return }
  echo(message)
}

func crash(_ message: String) -> Never { echo(message); exit(1) }

if UserInput.flag(.version) {
  echo("HyperText version 0.0.0")
  exit(0)
}

guard UserInput.parameter(.source) != nil && UserInput.parameter(.target) != nil
else { crash("usage: hypertext source/ target/ --stream") }

guard Project.sourceURL.exists
else { crash("Can't find source directory at: \(Project.sourceURL.scrub)") }

guard Project.sourceURL.absoluteString != Project.targetURL.absoluteString
else { crash("The source and target can't be the same directory.") }

guard !Project.targetURL.absoluteString.contains(Project.sourceURL.absoluteString)
else { crash("The source directory can't contain the target directory.") }

guard !Project.sourceURL.absoluteString.contains(Project.targetURL.absoluteString)
else { crash("The target directory can't contain the source directory.") }

if UserInput.flag(.stream) {
  echo("Streaming \(Project.sourceURL.scrub) => \(Project.targetURL.scrub) (^c to stop)")
  Project.build()
  let stream: Stream = Project.sourceURL.stream { _events in Project.build() }
  withExtendedLifetime(stream, {})
  RunLoop.main.run()
}

else {
  echo("Building \(Project.sourceURL.scrub) => \(Project.targetURL.scrub)")
  Project.build()
}