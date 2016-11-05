import CoreFoundation
import Foundation

internal extension Data {
    static var zero: Data {
        return Data(bytes: [0x00])
    }
    
    var byteArray: [UInt8] {
        return self.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: self.count))
        }
    }
    
    static func withLittleEndianOf(_ int: UInt64) -> Data {
        var le = int.littleEndian
        let buffer = UnsafeBufferPointer(start: &le, count: 1)
        return Data(buffer: buffer)
    }

    static func withLittleEndianOf(_ int: UInt32) -> Data {
        var le = int.littleEndian
        let buffer = UnsafeBufferPointer(start: &le, count: 1)
        return Data(buffer: buffer)
    }

    func readLittleEndianUInt64(at idx: Int = 0) -> UInt64 {
        assert(self.count >= idx + 8)

        var read: UInt64 = 0
        self.withUnsafeBytes { (buffer: UnsafePointer<UInt8>) in
            for i in (0...7).reversed() {
                read = (read << 8) + UInt64(buffer[idx + i])
            }
        }

        return CFSwapInt64LittleToHost(read)
    }

    func readLittleEndianUInt32(at idx: Int = 0) -> UInt32 {
        assert(self.count >= (idx + 4))

        var read: UInt32 = 0
        self.withUnsafeBytes { (buffer: UnsafePointer<UInt8>) in
            for i in (0...3).reversed() {
                read = (read << 8) + UInt32(buffer[idx + i])
            }
        }

        return CFSwapInt32LittleToHost(read)
    }
}
