//
//  SchnorrMusig.swift
//  SchnorrMusigSDKSwift
//
//  Created by Eugene Belyakov on 04/04/2021.
//

import Foundation


public class SchnorrMusig {

    public init() {}
    
    public func createSigner(publicKeys: [Data], position: Int) -> SchnorrMusigSigner {
        let encodedKeys = publicKeys.reduce(into: Data()) { $0.append($1) }
        return createSigner(encodedPublicKeys: encodedKeys, position: position)
    }
    
    public func createSigner(encodedPublicKeys: Data, position: Int) -> SchnorrMusigSigner {
        return SchnorrMusigSigner(encodedPublicKeys: encodedPublicKeys, position: position)
    }

    public func verify(message: Data, signature: SMAggregatedSignature, aggregatedPublicKey: SMAggregatedPublicKey) throws -> Bool {
        return try self.verify(message: message, signature: signature, encodedPublicKeys: aggregatedPublicKey.data())
    }
    
    public func verify(message: Data, signature: SMAggregatedSignature, publicKeys: [Data]) throws -> Bool {
        let encodedKeys = publicKeys.reduce(into: Data()) { $0.append($1) }
        return try self.verify(message: message, signature: signature, encodedPublicKeys: encodedKeys)
    }
    
    public func verify(message: Data, signature: SMAggregatedSignature, encodedPublicKeys: Data) throws -> Bool {
        let signatureData = signature.data()
        return try message.withUnsafeBytes { (messageRaw) -> Bool in
            let messagePointer = messageRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return try signatureData.withUnsafeBytes { (signatureRaw) -> Bool in
                let signaturePointer = signatureRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
                return try encodedPublicKeys.withUnsafeBytes { (publicKeysRaw) -> Bool in
                    let publicKeysPointer = publicKeysRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
                    
                    let result = schnorr_musig_verify(messagePointer,
                                                      message.count,
                                                      publicKeysPointer,
                                                      encodedPublicKeys.count,
                                                      signaturePointer,
                                                      signatureData.count)
                    
                    if result == OK {
                        return true
                    } else if result == SIGNATURE_VERIFICATION_FAILED {
                        return false
                    } else {
                        throw SchnorrMusigError(code: result)
                    }
                }
            }
        }
    }
    
    public func aggregatePublicKeys(_ publicKeys: [Data]) throws -> SMAggregatedPublicKey {
        let publicKeys = publicKeys.reduce(into: Data()) { $0.append($1) }
        return try self.aggregatePublicKeys(publicKeys)
    }
    
    public func aggregatePublicKeys(_ encodedPublicKeys: Data) throws -> SMAggregatedPublicKey {
        
        try encodedPublicKeys.withUnsafeBytes { (publicKeysRaw) in
            let publicKeysPointer = publicKeysRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var aggregatedPublicKey = AggregatedPublicKey()
            let result = schnorr_musig_aggregate_pubkeys(publicKeysPointer, encodedPublicKeys.count, &aggregatedPublicKey)
            
            guard result == OK else {
                throw SchnorrMusigError(code: result)
            }
            
            return withUnsafeBytes(of: &aggregatedPublicKey) { (pointer) in
                return SMAggregatedPublicKey(Data(pointer))
            }
        }
    }
}
