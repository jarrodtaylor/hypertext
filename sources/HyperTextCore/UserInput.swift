struct UserInput {
  enum Parameter: Int { case source = 1, target  }
  enum Flag: String { case stream = "--stream", debug = "--debug", version = "--version" }

  static func parameter(_ position: Parameter) -> String? { CommandLine.parameter(position.rawValue) }
  static func flag(_ flag: Flag) -> Bool { CommandLine.flag(flag.rawValue) }
}