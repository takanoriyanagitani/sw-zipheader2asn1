import struct Foundation.Data
import class Foundation.JSONDecoder
import struct SwiftASN1.ASN1Identifier
import struct SwiftASN1.ASN1UTF8String
import enum SwiftASN1.DER
import protocol SwiftASN1.DERSerializable

public enum CompressionMethod: Int, Hashable, Sendable, Codable {
  case stored = 0
  case deflated = 8
}

extension CompressionMethod: DERSerializable {
  public func serialize(into: inout DER.Serializer) throws {
    try into.serializeOptionalImplicitlyTagged(self.rawValue, withIdentifier: .enumerated)
  }
}

public enum Timestamp: Hashable, Sendable, Codable {
  case unixTime(Int)
  case unixTimeMs(Int)
  case unixTimeUs(Int)
  case unixTimeNs(Int)
  case rfc3339(String)
}

public func serializeContextSpecificInteger(
  _ value: Int,
  tagNumber: UInt,
  into serializer: inout DER.Serializer
) throws {
  try serializer.serializeOptionalImplicitlyTagged(
    value,
    withIdentifier: ASN1Identifier(tagWithNumber: tagNumber, tagClass: .contextSpecific)
  )
}

extension Timestamp: DERSerializable {
  public func serialize(into: inout DER.Serializer) throws {
    switch self {
    case .unixTime(let intValue):
      try serializeContextSpecificInteger(intValue, tagNumber: 0, into: &into)
    case .unixTimeMs(let intValue):
      try serializeContextSpecificInteger(intValue, tagNumber: 1, into: &into)
    case .unixTimeUs(let intValue):
      try serializeContextSpecificInteger(intValue, tagNumber: 2, into: &into)
    case .unixTimeNs(let intValue):
      try serializeContextSpecificInteger(intValue, tagNumber: 3, into: &into)
    case .rfc3339(let strValue):
      try into.serializeOptionalImplicitlyTagged(
        ASN1UTF8String(strValue),
        withIdentifier: ASN1Identifier(tagWithNumber: 4, tagClass: .contextSpecific)
      )
    }
  }
}

public struct TimeInfo: Hashable, Sendable, Codable {
  public var timestamp: Timestamp

  public init(timestamp: Timestamp) {
    self.timestamp = timestamp
  }
}

extension TimeInfo: DERSerializable {
  public func serialize(into: inout DER.Serializer) throws {
    try into.appendConstructedNode(identifier: .sequence) {
      try $0.serialize(self.timestamp)
    }
  }
}

public struct FileHeader: Hashable, Sendable, Codable {
  public var name: String
  public var comment: String
  public var method: CompressionMethod
  public var modified: TimeInfo
  public var crc32: UInt
  public var compressedSize64: UInt
  public var uncompressedSize64: UInt

  public func toDerBytes() -> Result<[UInt8], Error> {
    var ser: DER.Serializer = DER.Serializer()
    return ZipHeaderToAsn1.serialize(self, serializer: &ser)
  }

  public static func fromJsonBytes(
    _ data: Data,
    decoder: JSONDecoder = JSONDecoder(),
  ) -> Result<Self, Error> {
    Result {
      try decoder.decode(Self.self, from: data)
    }
  }
}

extension FileHeader: DERSerializable {
  public func serialize(into: inout DER.Serializer) throws {
    try into.appendConstructedNode(identifier: .sequence) {
      try $0.serialize(ASN1UTF8String(self.name))
      try $0.serialize(ASN1UTF8String(self.comment))
      try $0.serialize(self.method)
      try $0.serialize(self.modified)
      try $0.serialize(self.crc32)
      try $0.serialize(self.compressedSize64)
      try $0.serialize(self.uncompressedSize64)
    }
  }
}

public func serialize<T>(
  _ value: T,
  serializer: inout DER.Serializer,
) -> Result<[UInt8], Error>
where T: DERSerializable {
  Result { try serializer.serialize(value) }
    .map {
      _ = $0
      return serializer.serializedBytes
    }
}
