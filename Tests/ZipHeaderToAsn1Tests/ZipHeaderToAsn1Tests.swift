import Testing

@testable import ZipHeaderToAsn1

@Test func testFileHeaderSerialization() throws {
  // 1. Create a FileHeader instance with valid data.
  let timestamp = Timestamp.unixTime(1_678_886_400)  // Example Unix timestamp
  let timeInfo = TimeInfo(timestamp: timestamp)

  let fileHeader = FileHeader(
    name: "test_file.txt",
    comment: "This is a test comment.",
    method: .stored,
    modified: timeInfo,
    crc32: 0x1234_5678,  // Example CRC32
    compressedSize64: 100,
    uncompressedSize64: 200
  )

  // 2. Call toDerBytes() on the FileHeader instance.
  let result = fileHeader.toDerBytes()

  // 3. Assert that the Result is a .success (i.e., no error was thrown).
  // If result.get() throws, the test will fail.
  let derBytes = try result.get()

  // 4. Assert that the resulting [UInt8] is not empty.
  #expect(!derBytes.isEmpty)
}
