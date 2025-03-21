import Foundation

public struct LGTVRequestSignature: Codable {
    public init(signature: String = "", signatureVersion: Int = 1) {
        self.signature = signature
        self.signatureVersion = signatureVersion
    }
    
    public var signature: String =
    ""
    public var signatureVersion: Int = 1
}
