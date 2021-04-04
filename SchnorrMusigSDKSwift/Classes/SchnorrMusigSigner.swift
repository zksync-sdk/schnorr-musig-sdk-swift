//
//  SchnorrMusigSigner.swift
//  SchnorrMusigSDKSwift
//
//  Created by Eugene Belyakov on 04/04/2021.
//

import Foundation


public class SchnorrMusigSigner {
    
    var signer: UnsafeMutablePointer<MusigSigner>
    
    init(signer: UnsafeMutablePointer<MusigSigner>) {
        self.signer = signer
    }
    
    func sign(privateKey: Data, message: Data) -> SMSignature {
        
        var signature: Signature = Signature()
        
        return privateKey.withUnsafeBytes { (privateKeyRaw) in
            let privateKeyBuffer = privateKeyRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return message.withUnsafeBytes { (messageRaw) in
                let messageBuffer = messageRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
                let result = schnorr_musig_sign(signer, privateKeyBuffer, privateKey.count, messageBuffer, message.count, &signature)
                return withUnsafeBytes(of: &signature) { (pointer) in
                    return SMSignature(Data(pointer))
                }
            }
        }
    }
    
    func computePrecommitment(seed: [UInt32]) -> SMPrecommitment {
        seed.withUnsafeBufferPointer { (seedRaw) in
            var precommitment = Precommitment()
            schnorr_musig_compute_precommitment(signer, seedRaw.baseAddress!, seed.count, &precommitment)
            return withUnsafeBytes(of: &precommitment) { (pointer) in
                SMPrecommitment(Data(pointer))
            }
        }
    }
    
    func receivePrecommitments(_ precommitments: SMPrecommitment...) -> SMCommitment {
        return self.receivePrecommitments(precommitments)
    }
    
    func receivePrecommitments(_ precommitments: [SMPrecommitment]) -> SMCommitment {
        let data = precommitments.joinedData
        
        return data.withUnsafeBytes { (raw) in
            let pointer = raw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var commitment = Commitment()
            schnorr_musig_receive_precommitments(signer, pointer, data.count, &commitment)
            return  withUnsafeBytes(of: &commitment) { (pointer) in
                SMCommitment(Data(pointer))
            }
        }
    }
    
    func receiveCommitments(_ commitments: SMCommitment...) -> SMAggregatedCommitment {
        return self.receiveCommitments(commitments)
    }
    
    func receiveCommitments(_ commitments: [SMCommitment]) -> SMAggregatedCommitment {
        let data = commitments.joinedData
        
        return data.withUnsafeBytes { (raw) in
            let pointer = raw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var aggregatedCommitment = AggregatedCommitment()
            schnorr_musig_receive_commitments(signer, pointer, data.count, &aggregatedCommitment)
            return  withUnsafeBytes(of: &aggregatedCommitment) { (pointer) in
                SMAggregatedCommitment(Data(pointer))
            }
        }
    }
    
    func aggregateSignature(_ signatures: SMSignature...) -> SMAggregatedSignature {
        return aggregateSignature(signatures)
    }
    
    func aggregateSignature(_ signatures: [SMSignature]) -> SMAggregatedSignature {
        let signaturesData = signatures.joinedData
        return signaturesData.withUnsafeBytes { (signaturesRaw) in
            let signaturesPointer = signaturesRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var aggregatedSignature = AggregatedSignature()
            schnorr_musig_receive_signature_shares(signer,
                                                   signaturesPointer,
                                                   signaturesData.count,
                                                   &aggregatedSignature)
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
