import Foundation

class Stream {
  struct FileSystemEvent { let url: URL, flag: FSEventStreamEventFlags }
  
  fileprivate let url: URL
  fileprivate let callback: (_ events: [FileSystemEvent]) -> Void
  fileprivate var stream: FSEventStreamRef? = nil
  fileprivate var started: Bool = false
  
  init(_ url: URL, callback: @escaping (_ events: [FileSystemEvent]) -> Void) {
    self.url = url
    self.callback = callback
    self.started = self.start()
  }
}

fileprivate extension Stream {
  func start() -> Bool {
    precondition(self.stream == nil)
    
    var context = FSEventStreamContext()
    context.info = Unmanaged.passUnretained(self).toOpaque()
    
    guard let stream = FSEventStreamCreate(
      nil,
      { (_, info, count, paths, flags, _) in
        Unmanaged<Stream>.fromOpaque(info!)
          .takeUnretainedValue()
          .handleEvents(count: count, paths: paths, flags: flags)
      },
      &context,
      [self.url.path() as NSString] as NSArray,
      UInt64(kFSEventStreamEventIdSinceNow),
      1.0,
      FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents)
    ) else { return false }
    
    self.stream = stream
    FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
    
    guard FSEventStreamStart(stream)
    else { FSEventStreamInvalidate(stream); self.stream = nil; return false }
    
    return true
  }
  
  func handleEvents(
    count: Int,
    paths: UnsafeMutableRawPointer,
    flags: UnsafePointer<FSEventStreamEventFlags>
  ) -> Void {
    let pathsBase: UnsafeMutablePointer = paths.assumingMemoryBound(to: UnsafePointer<CChar>.self)
    let pathsBuffer: UnsafeBufferPointer = UnsafeBufferPointer(start: pathsBase, count: count)
    let flagsBuffer: UnsafeBufferPointer = UnsafeBufferPointer(start: flags, count: count)
    
    let events = (0..<count)
      .map { i -> FileSystemEvent in
        FileSystemEvent(url: URL(bufferPath: pathsBuffer[i]), flag: flagsBuffer[i])
      }
      .filter { $0.url.lastPathComponent != ".DS_Store" }
      .filter { "\($0.flag)" != "4259840" } // Ignore events created by this process (I think).
    
    if !events.isEmpty { callback(events) }
  }
}