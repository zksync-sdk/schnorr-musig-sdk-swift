//
//  SchnorrMusig.swift
//  SchnorrMusigSDKSwift
//
//  Created by Eugene Belyakov on 04/04/2021.
//

import Foundation


public class SchnorrMusig {

    public func createSigner(publicKeys: [Data], position: Int) -> SchnorrMusigSigner {
        let encodedKeys = publicKeys.reduce(into: Data()) { $0.append($1) }
        return createSigner(encodedPublicKeys: encodedKeys, position: position)
    }
    
    public func createSigner(encodedPublicKeys: Data, position: Int) -> SchnorrMusigSigner {
        encodedPublicKeys.withUnsafeBytes { (encodedPublicKeysRaw) in
            let encodedPublicKeysBuffer = encodedPublicKeysRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            let musig = schnorr_musig_new_signer(encodedPublicKeysBuffer, encodedPublicKeys.count, position)
            return SchnorrMusigSigner(signer: musig!)
        }
    }

    public func verify(message: Data, signature: SMAggregatedSignature, aggregatedPublicKeys: SMAggregatedPublicKey) -> Bool {
        self.verify(message: message, signature: signature, encodedPublicKeys: aggregatedPublicKeys.data())
    }
    
    public func verify(message: Data, signature: SMAggregatedSignature, publicKeys: [Data]) -> Bool {
        let encodedKeys = publicKeys.reduce(into: Data()) { $0.append($1) }
        return self.verify(message: message, signature: signature, encodedPublicKeys: encodedKeys)
    }
    
    public func verify(message: Data, signature: SMAggregatedSignature, encodedPublicKeys: Data) -> Bool {
        let signatureData = signature.data()
        return message.withUnsafeBytes { (messageRaw) -> Bool in
            let messagePointer = messageRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return signatureData.withUnsafeBytes { (signatureRaw) -> Bool in
                let signaturePointer = signatureRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
                return encodedPublicKeys.withUnsafeBytes { (publicKeysRaw) -> Bool in
                    let publicKeysPointer = publicKeysRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
                    
                    let result = schnorr_musig_verify(messagePointer,
                                                      message.count,
                                                      publicKeysPointer,
                                                      encodedPublicKeys.count,
                                                      signaturePointer,
                                                      signatureData.count)
                    
                    return result == OK
                }
            }
        }
    }
    
    public func aggregatePublicKeys(_ publicKeys: [Data]) -> SMAggregatedPublicKey {
        let publicKeys = publicKeys.reduce(into: Data()) { $0.append($1) }
        return self.aggregatePublicKeys(publicKeys)
    }
    
    public func aggregatePublicKeys(_ encodedPublicKeys: Data) -> SMAggregatedPublicKey {
        
        encodedPublicKeys.withUnsafeBytes { (publicKeysRaw) in
            let publicKeysPointer = publicKeysRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var aggregatedPublicKey = AggregatedPublicKey()
            schnorr_musig_aggregate_pubkeys(publicKeysPointer, encodedPublicKeys.count, &aggregatedPublicKey)
            return withUnsafeBytes(of: &aggregatedPublicKey) { (pointer) in
                return SMAggregatedPublicKey(Data(pointer))
            }
        }
    }
    
//    public AggregatedPublicKey aggregatePublicKeys(List<byte[]> publicKeys) throws SchnorrMusigException {
//        return aggregatePublicKeys(Bytes.join(publicKeys));
//    }
//
//    public AggregatedPublicKey aggregatePublicKeys(byte[] encodedPublicKeys) throws SchnorrMusigException {
//        AggregatedPublicKey.ByReference aggregatedPublicKey = new AggregatedPublicKey.ByReference();
//
//        int code = this.musig.schnorr_musig_aggregate_pubkeys(encodedPublicKeys, encodedPublicKeys.length, aggregatedPublicKey);
//
//        SchnorrMusigResultCodes result = SchnorrMusigResultCodes.byCode(code);
//
//        if (result == SchnorrMusigResultCodes.OK) {
//            return aggregatedPublicKey;
//        } else {
//            throw new SchnorrMusigException(result);
//        }
//    }

}
