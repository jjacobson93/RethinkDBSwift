import Foundation
import Socket

class SocketWrapper {

    var socket: Socket
    private var host: String
    private var port: Int32
    private var buffer: [Data]

    public var isOpen: Bool {
        return self.socket.isConnected
    }

    init(host: String, port: Int32) throws {
        self.socket = try Socket.create()
        self.host = host
        self.port = port
        self.buffer = []
    }

    deinit {
        self.close()
    }

    func connect(_ handshake: Handshake) throws {
        try socket.connect(to: self.host, port: self.port)
        
        var response: Data? = nil
        while let message = try handshake.nextMessage(response) {
            if message.count != 0 {
                try self.write(message)
            }

            response = try self.readZeroTerminatedASCII()
        }
    }

    func readZeroTerminatedASCII() throws -> Data? {
        // is there any thing in the buffer?
        if self.buffer.count != 0 {
            let last = self.buffer.removeLast()
            return self.splitData(last)
        }

        let data = try self.read()
        return self.splitData(data)
    }
    
    func splitData(_ data: Data) -> Data? {
        // find index of \0 character
        guard let idx = data.index(of: 0) else {
            return data
        }
        
        let result = data.subdata(in: 0..<idx)
        let rest = data.subdata(in: (idx+1)..<data.count)
        // save the rest of the data to the buffer
        if rest.count != 0 {
            self.buffer.append(rest)
        }
        
        return result
    }

    func read() throws -> Data {
        if !self.isOpen {
            throw ReqlError.driverError("Attempting to read on a closed socket.")
        }

        var data = Data()
        do {
            _ = try self.socket.read(into: &data) 
        } catch let e {
            throw e
        }
        return data
    }

    func read(_ bytes: Int) throws -> Data {
        if !self.isOpen {
            throw ReqlError.driverError("Attempting to read on a closed socket.")
        }

        if self.buffer.count != 0 {
            if let bufferData = self.buffer.last {
                if bufferData.count <= bytes {
                    var data = Data(bufferData)
                    if bufferData.count != bytes {
                        data.append(try self.read(bytes - bufferData.count))
                    }
                    self.buffer.remove(at: self.buffer.endIndex-1)
                    return data
                }
            }

            if let last = self.buffer.last {
                let data = last.subdata(in: 0..<bytes)
                self.buffer[self.buffer.count-1] = last.subdata(in: bytes..<last.count)
                return data
            }
        }

        let data = try self.read()
        if data.count < bytes {
            throw ReqlError.driverError("Expected \(bytes) byte\(bytes != 1 ? "s" : "") from socket, but read \(data.count)")
        }

        if data.count > bytes {
            self.buffer.append(data.subdata(in: bytes..<data.count))
            return data.subdata(in: 0..<bytes)
        }

        return data
    }

    func readResponse() throws -> Response {
        let header = try self.read(12)
        let queryToken = header.readLittleEndianUInt64(at: 0)
        let responseSize = header.readLittleEndianUInt32(at: 8)
        let data = try self.read(Int(responseSize))

        return try Response(data: data, token: queryToken)
    }

    func write(_ message: Data) throws {
        try self.socket.write(from: message)
    }

    func writeQuery(_ query: Query) throws {
        var data = Data()

        // Append query token
        data.append(Data.withLittleEndianOf(query.token))

        // Append size of query
        data.append(Data.withLittleEndianOf(UInt32(query.data.count)))

        // Append query
        data.append(query.data)

        try self.write(data)
    }

    func close() {
        if !self.isOpen {
            return
        }

        self.socket.close()
    }
}
