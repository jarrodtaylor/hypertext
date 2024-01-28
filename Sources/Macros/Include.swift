import Foundation

struct Include {
  static let pattern = #"(<!-- #include (.*?) -->|/* #include (.*?) */|// #include (.*?).+)"#
  
  var fragment: String
  
  var file: File? {
    let ref = fragment
      .split(separator: " ")
      .dropFirst(2)
      .first!
      .description
      .trimmingCharacters(in: .whitespaces)
    
    return Project.file(ref)
  }
  
  var parameters: [String: String] {
    var macro = fragment
    if macro.suffix(2) == "*/"  { macro = macro.dropLast(2).trimmingCharacters(in: .whitespaces) }
    if macro.suffix(3) == "-->" { macro = macro.dropLast(3).trimmingCharacters(in: .whitespaces) }
    
    var params: [String: String] = [:]
    
    for variable in macro.split(separator: " ++ ").dropFirst() {
      let split = variable.split(separator: ": ", maxSplits: 1)
      if split.count == 2 {
        let key = split.first!.description.trimmingCharacters(in: .whitespaces)
        let val = split.last!.description.trimmingCharacters(in: .whitespaces)
        params[key] = val
      }
    }
    
    return params
  }
}