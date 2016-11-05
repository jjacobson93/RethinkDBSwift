import Foundation
import Cryptor

let CLIENT_KEY = [UInt8]("Client Key".utf8)
let SERVER_KEY = [UInt8]("Server Key".utf8)

final public class SCRAMClient {
    let gs2BindFlag = "n,,"
    let algorithm: HMAC.Algorithm
    
    public init(algorithm: HMAC.Algorithm) {
        self.algorithm = algorithm
    }
    
    private func fixUsername(username user: String) -> String {
        return user.replacingOccurrences(of: "=", with: "=3D").replacingOccurrences(of: ",", with: "=2C")
    }
    
    private func parse(challenge response: String) throws -> (nonce: String, salt: String, iterations: Int) {
        var nonce: String? = nil
        var iterations: Int? = nil
        var salt: String? = nil
        
        for part in response.characters.split(separator: ",") where String(part).characters.count >= 3 {
            let part = String(part)
            
            if let first = part.characters.first {
                let data = part[part.index(part.startIndex, offsetBy: 2)..<part.endIndex]
                
                switch first {
                case "r":
                    nonce = data
                case "i":
                    iterations = Int(data)
                case "s":
                    salt = data
                default:
                    break
                }
            }
        }
        
        if let nonce = nonce, let iterations = iterations, let salt = salt {
            return (nonce: nonce, salt: salt, iterations: iterations)
        }
        
        throw SCRAMError.challengeParseError(challenge: response)
    }
    
    private func parse(finalResponse response: String) throws -> [UInt8] {
        var signature: [UInt8]? = nil
        
        for part in response.characters.split(separator: ",") where String(part).characters.count >= 3 {
            let part = String(part)
            
            if let first = part.characters.first {
                let data = part[part.index(part.startIndex, offsetBy: 2)..<part.endIndex]
                
                switch first {
                case "v":
                    signature = Data(base64Encoded: data)?.byteArray
                default:
                    break
                }
            }
        }
        
        if let signature = signature {
            return signature
        }
        
        throw SCRAMError.responseParseError(response: response)
    }
    
    private static func hmac(key: [UInt8], message: [UInt8]) throws -> [UInt8] {
        guard let bytes = HMAC(using: .sha256, key: key).update(byteArray: message)?.final() else {
            throw SCRAMError.digestFailure(key, message)
        }
        
        return bytes
    }
    
    // public
    
    public func authenticate(_ username: String, usingNonce nonce: String) throws -> String {
        return "\(gs2BindFlag)n=\(fixUsername(username: username)),r=\(nonce)"
    }
    
    public func process(_ challenge: String, with details: (username: String, password: [UInt8]), usingNonce nonce: String) throws -> (proof: String, serverSignature: [UInt8]) {
        let encodedHeader = Data(gs2BindFlag.utf8).base64EncodedString()
        
        let parsedResponse = try parse(challenge: challenge)
        
        let remoteNonce = parsedResponse.nonce
        
        guard String(remoteNonce[remoteNonce.startIndex..<remoteNonce.index(remoteNonce.startIndex, offsetBy: 24)]) == nonce else {
            throw SCRAMError.invalidNonce(nonce: parsedResponse.nonce)
        }
        
        let noProof = "c=\(encodedHeader),r=\(parsedResponse.nonce)"
        
        guard let salt = Data(base64Encoded: parsedResponse.salt)?.byteArray else {
            throw SCRAMError.base64Failure(original: parsedResponse.salt)
        }
        
        let saltedPassword = try PBKDF2.calculate(details.password, usingSalt: salt, iterating: parsedResponse.iterations, algorithm: self.algorithm)
        
        let clientKey = try SCRAMClient.hmac(key: saltedPassword, message: CLIENT_KEY)
        let serverKey = try SCRAMClient.hmac(key: saltedPassword, message: SERVER_KEY)
        
        guard let storedKey = Digest(using: .sha256).update(byteArray: clientKey)?.final() else {
            throw SCRAMError.digestFailure(clientKey, [])
        }
        
        let authMessage = "n=\(fixUsername(username: details.username)),r=\(nonce),\(challenge),\(noProof)"
        let authMessageBytes = [UInt8](authMessage.utf8)
        
        let clientSignature = try SCRAMClient.hmac(key: storedKey, message: authMessageBytes)
        let clientProof = clientKey ^ clientSignature
        let serverSignature = try SCRAMClient.hmac(key: serverKey, message: authMessageBytes)
        
        let proof = Data(bytes: clientProof).base64EncodedString()
        
        return (proof: "\(noProof),p=\(proof)", serverSignature: serverSignature)
    }
    
    public func complete(fromResponse response: String, verifying signature: [UInt8]) throws -> String {
        let sig = try parse(finalResponse: response)
        
        if sig != signature {
            throw SCRAMError.invalidSignature(signature: sig)
        }
        
        return ""
    }
}

public enum SCRAMError: Error {
    case invalidSignature(signature: [UInt8])
    case base64Failure(original: String)
    case challengeParseError(challenge: String)
    case responseParseError(response: String)
    case invalidNonce(nonce: String)
    case digestFailure([UInt8], [UInt8])
}
