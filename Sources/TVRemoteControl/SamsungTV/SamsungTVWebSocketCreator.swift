import Foundation
import Starscream

class SamsungTVWebSocketCreator {
    let builder: SamsungTVWebSocketBuilder

    init(builder: SamsungTVWebSocketBuilder = .init()) {
        self.builder = builder
    }

    func createTVWebSocket(
        url: URL,
        certPinner: CertificatePinning?,
        delegate: WebSocketDelegate
    ) -> WebSocket {
        builder.setURLRequest(.init(url: url))
        builder.setCertPinner(certPinner ?? SamsungTVDefaultWebSocketCertPinner())
        builder.setDelegate(delegate)
        return builder.getWebSocket()!
    }
}

/// Default cert-pinning implementation that trusts all connections
private class SamsungTVDefaultWebSocketCertPinner: CertificatePinning {
    func evaluateTrust(trust: SecTrust, domain: String?, completion: ((PinningState) -> ())) {
        completion(.success)
    }
}
