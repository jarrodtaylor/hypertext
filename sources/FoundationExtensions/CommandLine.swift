extension CommandLine {
  static func flag(_ flag: String) -> Bool { flags.contains(flag) || shortFlags.contains(flag.dropFirst(2).first!.toString) }
  static func parameter(_ position: Int) -> String? { params.count > position ? params[position] : nil }
}

fileprivate extension CommandLine {
  static let flags:  [String] = arguments.filter { $0.prefix(2) == "--" }
  static let params: [String] = arguments.filter { $0.prefix(1) != "-"  }
  
  static let shortFlags: String = arguments
    .filter { $0.prefix(1) == "-" && $0.prefix(2) != "--" }
    .map { $0.dropFirst(1).toString }
    .joined()
}