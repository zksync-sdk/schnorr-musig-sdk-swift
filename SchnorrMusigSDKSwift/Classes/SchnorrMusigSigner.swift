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
    
//    public Precommitment computePrecommitment(int[] seed) throws SchnorrMusigException {
//        Precommitment.ByReference precommitment = new Precommitment.ByReference();
//
//        int code = this.musig.schnorr_musig_compute_precommitment(this.signer.getPointer(), seed, seed.length,
//                precommitment);
//
//        SchnorrMusigResultCodes result = SchnorrMusigResultCodes.byCode(code);
//
//        if (result == SchnorrMusigResultCodes.OK) {
//            return precommitment;
//        } else {
//            throw new SchnorrMusigException(result);
//        }
//    }

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
    
//    public AggregatedCommitment receiveCommitments(Collection<Commitment> commitments) throws SchnorrMusigException {
//        byte[] commitmentsData = Bytes.joinStructData(commitments);
//        AggregatedCommitment.ByReference aggregatedCommitment = new AggregatedCommitment.ByReference();
//
//        int code = this.musig.schnorr_musig_receive_commitments(this.signer.getPointer(), commitmentsData,
//                commitmentsData.length, aggregatedCommitment);
//
//        SchnorrMusigResultCodes result = SchnorrMusigResultCodes.byCode(code);
//
//        if (result == SchnorrMusigResultCodes.OK) {
//            return aggregatedCommitment;
//        } else {
//            throw new SchnorrMusigException(result);
//        }
//    }

}

extension Array where Element: SMPrimitive {
    var joinedData: Data {
        self.reduce(into: Data()) { (data, primitive) in
            data.append(primitive.data())
        }
    }
}
