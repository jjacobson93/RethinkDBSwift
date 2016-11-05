//
//  PBKDF2.swift
//  RethinkDBSwift
//
//  Created by Jeremy Jacobson on 11/4/16.
//
//

import Foundation
import Cryptor

public enum PBKDF2Error: Error {
    case invalidInput
}

func ^(_ a: [UInt8], _ b: [UInt8]) -> [UInt8] {
    return zip(a, b).map { (x, y) in
        return x ^ y
    }
}

public final class PBKDF2 {    
    /// Applies the `hi` (PBKDF2 with HMAC as PseudoRandom Function)
    public static func calculate(_ password: [UInt8], usingSalt salt: [UInt8], iterating iterations: Int, algorithm: HMAC.Algorithm) throws -> [UInt8] {
        
        let mac = HMAC(using: algorithm, key: password)
        let digest = { (bytes: [UInt8]) -> [UInt8] in
            guard let b = mac.update(byteArray: bytes)?.final() else {
                throw PBKDF2Error.invalidInput
            }
            return b
        }
        
        var bytes = try digest(salt + [0x00, 0x00, 0x00, 0x01])
        for _ in 0..<(iterations-1) {
            let b = try digest(bytes)
            bytes = bytes ^ b
        }
        
        return bytes
    }
    
    /// Applies the `hi` (PBKDF2 with HMAC as PseudoRandom Function)
    public static func calculate(_ password: String, usingSalt salt: [UInt8], iterating iterations: Int, algorithm: HMAC.Algorithm) throws -> [UInt8] {
        return try self.calculate([UInt8](password.utf8), usingSalt: salt, iterating: iterations, algorithm: algorithm)
    }
}
