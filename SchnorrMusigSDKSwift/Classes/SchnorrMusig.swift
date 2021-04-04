//
//  SchnorrMusig.swift
//  SchnorrMusigSDKSwift
//
//  Created by Eugene Belyakov on 04/04/2021.
//

import Foundation


public class SchnorrMusig {
//    public SchnorrMusigSigner createSigner(byte[] encodedPublicKeys, int position) {
//        Pointer signer = this.musig.schnorr_musig_new_signer(encodedPublicKeys, encodedPublicKeys.length, position);
//        return new SchnorrMusigSigner(this.musig, new MusigSigner(signer));
//    }

    public func createSigner(encodedPublicKeys: Data, position: Int) -> SchnorrMusigSigner {
        encodedPublicKeys.withUnsafeBytes { (encodedPublicKeysRaw) in
            let encodedPublicKeysBuffer = encodedPublicKeysRaw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            let musig = schnorr_musig_new_signer(encodedPublicKeysBuffer, encodedPublicKeys.count, position)
            
            return SchnorrMusigSigner(signer: musig!)
        }
    }
}
