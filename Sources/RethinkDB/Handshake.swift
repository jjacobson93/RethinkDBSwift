import Foundation
import Cryptor
import WarpCore

class Handshake {
    enum State {
        case initial
        case handshakeSent
        case handshakeReceived
        case authenticationSent
        case done
    }

    var state: State = .initial
    var user: String
    var password: String

    init(user: String, password: String) throws {
        self.user = user
        self.password = password
    }

    func nextMessage(_ response: Data?) throws -> Data? {
        // Overridden in subclasses
        return nil
    }
}

class HandshakeV0_4: Handshake {

    var authKey: String

    init(authKey: String) throws {
        self.authKey = authKey

        try super.init(user: "", password: "")
    }

    func sendHandshake() -> Data {
        var data = Data()

        // Append protocol version
        data.append(ProtocolVersion.v0_4.data())

        // Append authentication key length and the key itself (as ASCII)
        var authKey = Data()
        if let key = self.authKey.data(using: .ascii) {
            authKey = key
        }

        let keySize = UInt32(authKey.count)
        data.append(Data.withLittleEndianOf(keySize))

        if authKey.count != 0 {
            data.append(authKey)
        }

        // Append protocol type (JSON)
        data.append(Protocol.json.data())

        return data
    }

    override func nextMessage(_ response: Data?) throws -> Data? {
        switch self.state {
        case .initial:
            self.state = .authenticationSent
            return self.sendHandshake()
        case .authenticationSent:
            guard let responseString = String(data: response!, encoding: .ascii), response != nil else {
                throw ReqlError.driverError("Empty handshake response from server.")
            }

            if responseString != "SUCCESS" {
                if responseString.hasPrefix("ERROR: Incorrect authorization key.") {
                    throw ReqlError.authError("Incorrect authentication key.")
                }

                throw ReqlError.driverError("Server dropped connection with message: \"\(responseString)\"")
            }
        default:
            throw ReqlError.driverError("Unexpected handshake state")
        }

        return nil
    }
}

class HandshakeV1_0: Handshake {

    var nonce: String = ""
    var scram: SCRAMClient
    var serverSignature: [UInt8]?

    override init(user: String, password: String) throws {
        self.scram = SCRAMClient(algorithm: HMAC.Algorithm.sha256)

        try super.init(user: user, password: password)

        self.nonce = try self.generateRandomNonce()
    }

    override func nextMessage(_ response: Data?) throws -> Data? {
        var data: Data? = nil
        switch self.state {
        case .initial:
            if response != nil {
                throw ReqlError.driverError("Unexpected response")
            }

            data = try self.sendHandshake()
            self.state = .handshakeSent
        case .handshakeSent:
            data = try self.receiveHandshake(response)
            self.state = .handshakeReceived
        case .handshakeReceived:
            data = try self.sendAuthentication(response)
            self.state = .authenticationSent
        case .authenticationSent:
            try self.verifyAuthentication(response)
            data = nil
            self.state = .done
        case .done:
            data = nil
        }
        return data
    }

    func sendHandshake() throws -> Data {
        var data = Data()

        // Append protocol version
        data.append(ProtocolVersion.v1_0.data())

        let clientFirst = try self.scram.authenticate(self.user, usingNonce: self.nonce)
        
        let auth = try JSON.data(with: [
            "protocol_version": 0,
            "authentication_method": "SCRAM-SHA-256",
            "authentication": clientFirst
        ])

        // Append authentication JSON
        data.append(auth)

        // Append zero
        data.append(Data.zero)

        return data
    }

    func receiveHandshake(_ handshake: Data?) throws -> Data {
        guard let response = handshake else {
            throw ReqlError.driverError("Empty handshake response from server.")
        }

        if let responseString = String(data: response, encoding: .ascii), responseString.hasPrefix("ERROR") {
            throw ReqlError.driverError("Unexpected response - \(responseString)")
        }

        _ = try self.getJSONResponse(from: handshake)

        // we already sent the authentication with the initial message
        return Data()
    }

    func sendAuthentication(_ data: Data?) throws -> Data {
        let json = try self.getJSONResponse(from: data)

        guard let serverFirstMessage = json["authentication"] as? String else {
            throw ReqlError.authError("Invalid authentication server first message.")
        }

        //let passwordBytes = [UInt8](self.password.utf8)
        let clientProof = try self.scram.process(serverFirstMessage, with: (username: self.user, password: self.password), usingNonce: self.nonce)

        var data = try JSON.data(with: [ "authentication": clientProof.proof ])

        // Append zero
        data.append(Data.zero)

        self.serverSignature = clientProof.serverSignature

        return data
    }

    func verifyAuthentication(_ data: Data?) throws {
        let json = try self.getJSONResponse(from: data)
        guard let auth = json["authentication"] as? String else {
            throw ReqlError.authError("Invalid authentication response from server.")
        }

        guard let serverSignature = self.serverSignature else {
            throw ReqlError.authError("No server signature.")
        } 

        _ = try self.scram.complete(fromResponse: auth, verifying: serverSignature)
    }

    func getJSONResponse(from response: Data?) throws -> [String: Any] {
        guard let data = response else {
            throw ReqlError.driverError("Empty response from server.")
        }
        
        guard let json = try JSON.from(data).decode() as? [String: Any] else {
            throw ReqlError.driverError("Invalid JSON response.")
        }
        
        guard let success = json["success"] as? Bool, success else {
            throw self.handleError(json)
        }

        return json
    }

    func handleError(_ json: [String: Any]) -> ReqlError {
        if let error = json["error"] as? String {
            if let errorCode = json["error_code"] as? Int64, 10 ... 20 ~= errorCode {
                return ReqlError.authError("Authentication error: \(error)")
            }

            return ReqlError.driverError("Unexpected response: \(error)")
        }

        return ReqlError.driverError("Invalid JSON response.")
    }

    func generateRandomNonce() throws -> String {
        let randomBytes = try Random.generate(byteCount: 18)
        return Data(bytes: randomBytes).base64EncodedString()
    }
}
