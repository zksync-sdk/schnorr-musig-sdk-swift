import XCTest
@testable import SchnorrMusigSDKSwift

class Tests: XCTestCase {
    
    private static let Seed: [UInt32] = [16807, 282475249, 1622650073, 984943658]
    private static var Msg: Data {
        "hello".data(using: .utf8)!
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let expectedPrecommitment = "93ae6e6df739d76c088755078ed857e95119909c97bdd5cdc8aa12286abc0984"
        let expectedCommitment = "a18005f171a323d022a625e71aa53864ca6d1851a1fc50585b7627fba3f6c69f"
        let expectedAggregatedCommitment = "a18005f171a323d022a625e71aa53864ca6d1851a1fc50585b7627fba3f6c69f"
        let expectedSignature = "02bae431c052b9e4f7c9b511904a577c7ba5e035625879d5253440793337f7ff"
        
        let publicKey: [Int8] = [23, -100, 58, 89, 20, 125, 48, 49, 108, -120, 102, 40, -123, 35, 72, -55, -76, 42, 24, -72, 33, 8, 74, -55, -17, 121, -67, 115, -23, -71, 78, -115]
        let privateKey: [Int8] = [1, 31, 91, -103, 8, 76, 92, 46, 45, 94, 99, 72, -114, 15, 113, 104, -43, -103, -91, -64, 31, -23, -2, -60, -55, -106, 5, 116, 61, -91, -24, 92]
        
        
        let publicKeyData = publicKey.withUnsafeBytes { (buffer) in
            return Data(buffer)
        }

        let privateKeyData = privateKey.withUnsafeBytes { (buffer) in
            return Data(buffer)
        }

        let schnorrMuisig = SchnorrMusig()
        let signer = schnorrMuisig.createSigner(encodedPublicKeys: publicKeyData, position: 0)
        let precommitment = signer.computePrecommitment(seed: Tests.Seed)
        XCTAssertEqual(precommitment.hexEncodedString().lowercased(),
                       expectedPrecommitment)
        let commitment = signer.receivePrecommitments([precommitment])
        XCTAssertEqual(commitment.hexEncodedString().lowercased(),
                       expectedCommitment)
        let aggregatedCommitment = signer.receiveCommitments([commitment])
        XCTAssertEqual(aggregatedCommitment.hexEncodedString().lowercased(),
                       expectedAggregatedCommitment)
        let signature = signer.sign(privateKey: privateKeyData, message: "hello".data(using: .utf8)!)
        XCTAssertEqual(signature.hexEncodedString().lowercased(),
                       expectedSignature)

        
        
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
