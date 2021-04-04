//
//  SchnorrMusig+Types.swift
//  SchnorrMusigSDKSwift
//
//  Created by Eugene Belyakov on 04/04/2021.
//

import Foundation

public class SMPrimitive {
    class var bytesLength: Int {
        return 0
    }
    
    private var content: Data
    
    public init(_ content: Data) {
        assert(content.count == Self.bytesLength, "Incorrect data length. Should be \(Self.bytesLength)")

        self.content = content
    }
    
    public convenience init(_ content: [UInt8]) {
        self.init(Data(content))
    }
    
    public func data() -> Data {
        return content
    }
    
    public func base64String() -> String {
        return content.base64EncodedString()
    }
    
    public func hexEncodedString() -> String {
        return content.map { String(format: "%02hhX", $0) }.joined()
    }
    
    func withUnsafeBytes<ResultType>(_ body: (UnsafeRawBufferPointer) throws -> ResultType) rethrows -> ResultType {
        return try! content.withUnsafeBytes(body)
    }
}

fileprivate let StandardEncodingLength = 32
fileprivate let AggregateSignatureEncodingLength = 64

public class SMAggregatedPublicKey: SMPrimitive {
    override class var bytesLength: Int {
        return StandardEncodingLength
    }
}

public class SMPrecommitment: SMPrimitive {
    override class var bytesLength: Int {
        return StandardEncodingLength
    }
}

public class SMAggregatedCommitment: SMPrimitive {
    override class var bytesLength: Int {
        return StandardEncodingLength
    }
}

public class SMCommitment: SMPrimitive {
    override class var bytesLength: Int {
        return StandardEncodingLength
    }
}

public class SMAggregatedSignature: SMPrimitive {
    override class var bytesLength: Int {
        return AggregateSignatureEncodingLength
    }
}

public class SMSignature: SMPrimitive {
    override class var bytesLength: Int {
        return StandardEncodingLength
    }
}
