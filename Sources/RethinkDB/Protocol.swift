import Foundation

public enum Protocol: UInt32 {
    case protobuf = 0x271ffc41
    case json = 0x7e6970c7

    public func data() -> Data {
        return Data.withLittleEndianOf(self.rawValue)
    }
}

public enum ProtocolVersion: UInt32 {
    case v0_4 = 0x400c2d20
    case v1_0 = 0x34c2bdc3

    public func data() -> Data {
        return Data.withLittleEndianOf(self.rawValue)
    }
}
