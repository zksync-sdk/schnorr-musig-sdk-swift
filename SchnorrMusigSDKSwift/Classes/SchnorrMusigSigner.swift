//
//  SchnorrMusigSigner.swift
//  SchnorrMusigSDKSwift
//
//  Created by Eugene Belyakov on 04/04/2021.
//

import Foundation

public class SchnorrMusigSigner {
    
    private var signer: UnsafeMutablePointer<MusigSigner>
    
    init(encodedPublicKeys: Data, position: Int) {
        self.signer = encodedPublicKeys.withUnsafeBytes { (encodedPublicKeysRaw) in
            let encodedPublicKeysBuffer = encodedPublicKeysRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return schnorr_musig_new_signer(encodedPublicKeysBuffer, encodedPublicKeys.count, position)!
        }
    }
    
    deinit {
        schnorr_musig_delete_signer(signer)
    }
    
    public func sign(privateKey: Data, message: Data) throws -> SMSignature {
        
        var signature: Signature = Signature()
        
        return try privateKey.withUnsafeBytes { (privateKeyRaw) in
            let privateKeyBuffer = privateKeyRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            
            return try message.withUnsafeBytes { (messageRaw) in
                
                let messageBuffer = messageRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
                
                let result = schnorr_musig_sign(signer, privateKeyBuffer, privateKey.count, messageBuffer, message.count, &signature)
                
                guard result == OK else {
                    throw SchnorrMusigError(code: result)
                }
                
                return withUnsafeBytes(of: &signature) { (pointer) in
                    return SMSignature(Data(pointer))
                }
            }
        }
    }
    
    public func computePrecommitment(seed: [UInt32]) throws -> SMPrecommitment {
        try seed.withUnsafeBufferPointer { (seedRaw) in
            
            var precommitment = Precommitment()
            
            let result = schnorr_musig_compute_precommitment(signer, seedRaw.baseAddress!, seed.count, &precommitment)
            
            guard result == OK else {
                throw SchnorrMusigError(code: result)
            }
            
            return withUnsafeBytes(of: &precommitment) { (pointer) in
                SMPrecommitment(Data(pointer))
            }
        }
    }
    
    public func receivePrecommitments(_ precommitments: SMPrecommitment...) throws -> SMCommitment {
        return try self.receivePrecommitments(precommitments)
    }
    
    public func receivePrecommitments(_ precommitments: [SMPrecommitment]) throws -> SMCommitment {
        let data = precommitments.joinedData
        
        return try data.withUnsafeBytes { (raw) in
            
            let pointer = raw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var commitment = Commitment()
            
            let result = schnorr_musig_receive_precommitments(signer, pointer, data.count, &commitment)
            
            guard result == OK else {
                throw SchnorrMusigError(code: result)
            }
            
            return  withUnsafeBytes(of: &commitment) { (pointer) in
                SMCommitment(Data(pointer))
            }
        }
    }
    
    public func receiveCommitments(_ commitments: SMCommitment...) throws -> SMAggregatedCommitment {
        return try self.receiveCommitments(commitments)
    }
    
    public func receiveCommitments(_ commitments: [SMCommitment]) throws -> SMAggregatedCommitment {
        let data = commitments.joinedData
        
        return try data.withUnsafeBytes { (raw) in
            
            let pointer = raw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var aggregatedCommitment = AggregatedCommitment()
            
            let result = schnorr_musig_receive_commitments(signer, pointer, data.count, &aggregatedCommitment)
            
            guard result == OK else {
                throw SchnorrMusigError(code: result)
            }
            
            return  withUnsafeBytes(of: &aggregatedCommitment) { (pointer) in
                SMAggregatedCommitment(Data(pointer))
            }
        }
    }
    
    public func aggregateSignature(_ signatures: SMSignature...) throws -> SMAggregatedSignature {
        return try self.aggregateSignature(signatures)
    }
    
    public func aggregateSignature(_ signatures: [SMSignature]) throws -> SMAggregatedSignature {
        let signaturesData = signatures.joinedData
        return try signaturesData.withUnsafeBytes { (signaturesRaw) in
            
            let signaturesPointer = signaturesRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var aggregatedSignature = AggregatedSignature()
            
            let result = schnorr_musig_receive_signature_shares(signer,
                                                                signaturesPointer,
                                                                signaturesData.count,
                                                                &aggregatedSignature)
            
            guard result == OK else {
                throw SchnorrMusigError(code: result)
            }
            
            return withUnsafeBytes(of: &aggregatedSignature) { (pointer) in
                SMAggregatedSignature(Data(pointer))
            }
        }
    }
}

extension Array where Element: SMPrimitive {
    var joinedData: Data {
        self.reduce(into: Data()) { (data, primitive) in
            data.append(primitive.data())
        }
    }
}
