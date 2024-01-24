import ArgumentParser
import Foundation

@main
struct HyperText: ParsableCommand {
  static var configuration = CommandConfiguration(commandName: "hypertext")
  
  @Argument(help: "Relative path to source directory.")
  var source: String
  
  @Argument(help: "Relative path to target directory.")
  var target: String
  
  @Flag(help: "Stream changes from source to target.")
  var stream = false

  mutating func run() throws {
    print("hi")
  }
}