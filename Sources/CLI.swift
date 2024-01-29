import ArgumentParser
import Foundation

@main
struct HyperText: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "hypertext",
    version: "0.0.0")
    
  @Argument(help: "Relative path to source directory.")
  var source: String
  
  @Argument(help: "Relative path to target directory.")
  var target: String
  
  @Flag(help: "Stream changes from source to target.")
  var stream = false
  
  mutating func run() throws {
    Project.source = URL(string: source, relativeTo: URL.currentDirectory())
    Project.target = URL(string: target, relativeTo: URL.currentDirectory())
    
    guard Project.source!.masked != Project.target!.masked else {
      throw ValidationError("Source and target cannot be the same directory.")
    }
    
    guard !Project.target!.masked.contains(Project.source!.masked) else {
      throw ValidationError("Source directory cannot contain target directory.")
    }
    
    guard !Project.source!.masked.contains(Project.target!.masked) else {
      throw ValidationError("Target directory cannot contain source directory.")
    }
    
    guard Project.source!.exists else {
      throw ValidationError("Source directory does not exist.")
    }
    
    stream ? Project.stream() : Project.build()
  }
}

extension HyperText {
  static func echo(_ message: String) -> Void {
    var standardError: FileHandle = FileHandle.standardError
    print(message, to: &standardError)
  }
}