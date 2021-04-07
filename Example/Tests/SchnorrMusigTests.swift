import XCTest
@testable import SchnorrMusigSDKSwift

class SchnorrMusigTests: XCTestCase {
    
    private static let Seed: [UInt32] = [16807, 282475249, 1622650073, 984943658]
    private static var Msg: Data {
        "hello".data(using: .utf8)!
    }
    
    func testSingle() throws {
        
        let expectedPrecommitment = "93ae6e6df739d76c088755078ed857e95119909c97bdd5cdc8aa12286abc0984"
        let expectedCommitment = "a18005f171a323d022a625e71aa53864ca6d1851a1fc50585b7627fba3f6c69f"
        let expectedAggregatedCommitment = "a18005f171a323d022a625e71aa53864ca6d1851a1fc50585b7627fba3f6c69f"
        let expectedSignature = "02bae431c052b9e4f7c9b511904a577c7ba5e035625879d5253440793337f7ff"
        let message = "hello".data(using: .utf8)!
        let publicKey: [Int8] = [23, -100, 58, 89, 20, 125, 48, 49, 108, -120, 102, 40, -123, 35, 72, -55, -76, 42, 24, -72, 33, 8, 74, -55, -17, 121, -67, 115, -23, -71, 78, -115]
        let privateKey: [Int8] = [1, 31, 91, -103, 8, 76, 92, 46, 45, 94, 99, 72, -114, 15, 113, 104, -43, -103, -91, -64, 31, -23, -2, -60, -55, -106, 5, 116, 61, -91, -24, 92]
        
        
        let publicKeyData = publicKey.withUnsafeBytes { (buffer) in
            return Data(buffer)
        }
        
        let privateKeyData = privateKey.withUnsafeBytes { (buffer) in
            return Data(buffer)
        }
        
        let schnorrMusig = SchnorrMusig()
        let signer = schnorrMusig.createSigner(encodedPublicKeys: publicKeyData, position: 0)
        let precommitment = try signer.computePrecommitment(seed: Self.Seed)
        XCTAssertEqual(precommitment.hexEncodedString().lowercased(),
                       expectedPrecommitment)
        let commitment = try signer.receivePrecommitments([precommitment])
        XCTAssertEqual(commitment.hexEncodedString().lowercased(),
                       expectedCommitment)
        let aggregatedCommitment = try signer.receiveCommitments([commitment])
        XCTAssertEqual(aggregatedCommitment.hexEncodedString().lowercased(),
                       expectedAggregatedCommitment)
        let signature = try signer.sign(privateKey: privateKeyData, message: message)
        XCTAssertEqual(signature.hexEncodedString().lowercased(),
                       expectedSignature)
        
        let aggregateSignature = try signer.aggregateSignature(signature)
        
        XCTAssertTrue(try schnorrMusig.verify(message: message,
                                              signature: aggregateSignature,
                                              encodedPublicKeys: publicKeyData))
    }
    
    func testMultiple() throws {
        
        let privateKeys: [[Int8]] = [
            [1,31,91,-103,8,76,92,46,45,94,99,72,-114,15,113,104,-43,-103,-91,-64,31,-23,-2,-60,-55,-106,5,116,61,-91,-24,92],
            [5,-66,-6,29,-59,-66,-72,-86,116,-61,72,-106,111,82,84,112,43,-64,-87,97,62,81,-98,-77,-17,47,-24,-60,68,-12,13,51],
            [3,-51,-119,71,-87,15,115,-88,117,98,53,116,-8,-32,-29,-45,-58,-85,-40,-7,54,123,-91,68,51,-19,2,-73,-90,37,51,-39],
            [2,85,108,35,44,-5,108,-126,116,-84,126,46,85,-2,31,-121,-74,-34,-31,25,-65,98,-93,-57,-124,16,45,-26,-62,92,37,18],
            [1,121,16,-119,-75,59,-18,104,33,71,-20,-68,94,38,50,83,41,-94,28,-119,74,98,5,-121,108,88,121,-115,28,38,-118,-28]
        ]
        let publicKeys: [[Int8]] = [
            [23,-100,58,89,20,125,48,49,108,-120,102,40,-123,35,72,-55,-76,42,24,-72,33,8,74,-55,-17,121,-67,115,-23,-71,78,-115],
            [10,-12,-71,-92,-23,-30,-75,-92,-44,-48,-90,-46,-21,-102,-15,-102,-67,-99,-116,95,0,-101,80,-13,-47,95,-86,126,112,100,-10,-97],
            [-50,-81,-40,-53,21,-95,0,-25,-83,13,-29,-41,63,125,-52,-24,-71,-29,36,60,-73,-37,-42,78,59,11,10,121,-102,-109,-77,-120],
            [63,6,62,-21,40,-71,18,-96,89,-4,-118,-116,100,33,-20,89,-51,45,-113,42,25,64,43,9,125,120,-33,-118,56,100,-9,15],
            [40,107,64,71,20,-37,-122,117,29,-110,92,118,-49,119,7,9,-105,-28,-120,101,-100,74,-65,116,-52,114,-102,55,17,-68,27,-92]
        ]
        
        let schnorrMusig = SchnorrMusig()
        
        let allPublicKeys = publicKeys.reduce(into: Data()) { (data, publicKey) in
            data.append(publicKey.withUnsafeBytes { Data($0) })
        }
        
        let signers = (0..<publicKeys.count).map { (position) -> SchnorrMusigSigner in
            schnorrMusig.createSigner(encodedPublicKeys: allPublicKeys, position: position)
        }
        
        let precommitments = try signers.map { (signer) -> SMPrecommitment in
            return try signer.computePrecommitment(seed: Self.Seed)
        }
        XCTAssertTrue(precommitments.verify())
        
        let commitments = try signers.map { (signer) -> SMCommitment in
            return try signer.receivePrecommitments(precommitments)
        }
        XCTAssertTrue(commitments.verify())
        
        let aggregatedCommitments = try signers.map { (signer) -> SMAggregatedCommitment in
            return try signer.receiveCommitments(commitments)
        }
        XCTAssertTrue(aggregatedCommitments.verify())
        
        let signatures = try (0..<signers.count).map { (position) -> SMSignature in
            let privateKey = privateKeys[position].withUnsafeBytes { Data($0) }
            return try signers[position].sign(privateKey: privateKey, message: Self.Msg)
        }
        
        let aggregatedSignatures = try signers.map { (signer) -> SMAggregatedSignature in
            return try signer.aggregateSignature(signatures)
        }
        XCTAssertTrue(aggregatedSignatures.verify())
        
        let aggregatedPublicKey = try schnorrMusig.aggregatePublicKeys(allPublicKeys)
        
        XCTAssertTrue(try schnorrMusig.verify(message: Self.Msg, signature: aggregatedSignatures[0], encodedPublicKeys: allPublicKeys))
        
        XCTAssertTrue(try schnorrMusig.verify(message: Self.Msg, signature: aggregatedSignatures[0], aggregatedPublicKey: aggregatedPublicKey))
    }
}

extension Array where Element: SMPrimitive {
    
    func verify() -> Bool {
        guard !isEmpty else {
            return false
        }
        let first = self.first!.data()
        return self.reduce(into: true) { $0 = $0 && ($1.data() == first) }
    }
}
