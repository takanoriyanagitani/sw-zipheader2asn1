import Darwin

import struct Foundation.Data
import class Foundation.FileHandle
import struct ZipHeaderToAsn1.FileHeader

typealias IO<T> = () -> Result<T, Error>

func read(
  reader: FileHandle = .standardInput,
  limit: Int = 1_048_576,
) -> Result<Data, Error> {
  Result {
    try reader.read(upToCount: limit) ?? Data()
  }
}

func write(
  _ bytes: [UInt8],
  writer: FileHandle = .standardOutput,
) -> Result<(), Error> {
  Result {
    try writer.write(contentsOf: bytes)
  }
}

func headerJsonToDer(_ json: Data) -> Result<[UInt8], Error> {
  FileHeader.fromJsonBytes(json).flatMap { h in h.toDerBytes() }
}

func jsonDataFromStdin() -> Result<Data, Error> {
  read()
}

func derBytesToStdout(_ der: [UInt8]) -> IO<()> {
  return {
    write(der)
  }
}

func bind<T, U>(
  _ io: @escaping IO<T>,
  _ mapper: @escaping (T) -> IO<U>,
) -> IO<U> {
  return {
    let rt: Result<T, _> = io()
    return rt.flatMap {
      let t: T = $0
      return mapper(t)()
    }
  }
}

func lift<T, U>(
  _ pure: @escaping (T) -> Result<U, Error>,
) -> (T) -> IO<U> {
  return {
    let t: T = $0
    return {
      return pure(t)
    }
  }
}

func run() -> Result<(), Error> {
  let ijson: IO<Data> = jsonDataFromStdin
  let ider: IO<[UInt8]> = bind(
    ijson,
    lift(headerJsonToDer),
  )
  let ivoid: IO<()> = bind(ider, derBytesToStdout)
  return ivoid()
}

@main
struct ZipHeaderJsonToAsn1 {
  static func main() {
    let rslt: Result<_, _> = run()
    do {
      try rslt.get()
    } catch {
      let stderr = FileHandle.standardError
      let msg: String = "error: \(error)\n"
      let msgData: Data = Data(msg.utf8)
      stderr.write(msgData)
      exit(1)
    }
  }
}
