//
//  SchnorrMusig.swift
//  SchnorrMusigSDKSwift
//
//  Created by Eugene Belyakov on 04/04/2021.
//

import Foundation


public class SchnorrMusig {

    public func createSigner(publicKeys: [Data], position: Int) -> SchnorrMusigSigner {
        return createSigner(encodedPublicKeys: publicKeys.joined(), position: position)
    }
    
    public func createSigner(encodedPublicKeys: Data, position: Int) -> SchnorrMusigSigner {
        encodedPublicKeys.withUnsafeBytes { (encodedPublicKeysRaw) in
            let encodedPublicKeysBuffer = encodedPublicKeysRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            let musig = schnorr_musig_new_signer(encodedPublicKeysBuffer, encodedPublicKeys.count, position)
            return SchnorrMusigSigner(signer: musig!)
        }
    }
}
