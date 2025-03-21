import Foundation

public class LGTVClient: NSObject, LGTVClientProtocol, @unchecked Sendable {
    private var url: URL
    private var urlSession: URLSession?
    private var primaryWebSocketTask: URLSessionWebSocketTask?
    private var secondaryWebSocketTask: URLSessionWebSocketTask?
    private var pointerRequestId: String?

    public weak var delegate: LGTVClientDelegate?

    required public init(
        url: URL,
        delegate: LGTVClientDelegate? = nil
    ) {
        self.url = url
        self.delegate = delegate
        super.init()
    }

    public func connect() {
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        connect(url, task: &primaryWebSocketTask)
    }

    @discardableResult
    public func send(_ target: LGTVTarget, id: String) -> String? {
        guard let jsonRequest = target.request.jsonWithId(id) else {
            return nil
        }
        let message = URLSessionWebSocketTask.Message.string(jsonRequest)
        sendURLSessionWebSocketTaskMessage(message, task: primaryWebSocketTask)
        return id
    }

    public func send(jsonRequest: String) {
        let message = URLSessionWebSocketTask.Message.string(jsonRequest)
        sendURLSessionWebSocketTaskMessage(message, task: primaryWebSocketTask)
    }

    public func sendKey(_ key: LGTVKeyTarget) {
        guard let request = key.request else {
            return
        }
        let message = URLSessionWebSocketTask.Message.data(request)
        sendURLSessionWebSocketTaskMessage(message, task: secondaryWebSocketTask)
    }

    public func sendKey(keyData: Data) {
        let message = URLSessionWebSocketTask.Message.data(keyData)
        sendURLSessionWebSocketTaskMessage(message, task: secondaryWebSocketTask)
    }

    public func disconnect() {
        secondaryWebSocketTask?.cancel(with: .goingAway, reason: nil)
        primaryWebSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    deinit {
        disconnect()
    }
}

extension LGTVClient {
    fileprivate func connect(
        _ url: URL,
        task: inout URLSessionWebSocketTask?
    ) {
        task = urlSession?.webSocketTask(with: url)
        task?.resume()
    }

    fileprivate func sendURLSessionWebSocketTaskMessage(
        _ message: URLSessionWebSocketTask.Message,
        task: URLSessionWebSocketTask?
    ) {
        task?.send(message) { [weak self] error in
            guard let self else {
                return
            }
            if let error {
                delegate?.didReceiveNetworkError(error)
            }
        }
    }

    fileprivate func listen(
        _ completion: @escaping @Sendable (Result<LGTVResponse, Error>) -> Void
    ) {
        primaryWebSocketTask?.receive { [weak self] result in
            guard let self else {
                return
            }
            if case .success(let response) = result {
                handle(response, completion: completion)
                listen(completion)
            }
        }
    }

    fileprivate func handle(
        _ response: URLSessionWebSocketTask.Message,
        completion: @escaping (Result<LGTVResponse, Error>) -> Void
    ) {
        if case .string(let jsonResponse) = response {
            delegate?.didReceive(jsonResponse: jsonResponse)
        }
        guard let response = response.decode(),
            let type = response.type,
            let responseType = LGTVResponseType(rawValue: type)
        else {
            completion(.failure(NSError(domain: "Unknown error", code: 0, userInfo: nil)))
            return
        }
        switch responseType {
        case .error:
            completion(.failure(NSError(domain: "Unknown error", code: 0, userInfo: nil)))
        case .registered:
            if let clientKey = response.payload?.clientKey {
                delegate?.didRegister(with: clientKey)
                pointerRequestId = send(.getPointerInputSocket)
            }
            fallthrough
        default:
            if let socketPath = response.payload?.socketPath,
                let url = URL(string: socketPath),
                response.id == pointerRequestId
            {
                connect(url, task: &secondaryWebSocketTask)
            }
            completion(.success(response))
        }
    }
}

extension LGTVClient: URLSessionWebSocketDelegate {
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        guard webSocketTask === primaryWebSocketTask else {
            return
        }
        delegate?.didConnect()
        listen { [weak self] result in
            guard let self else {
                return
            }
            delegate?.didReceive(result)
        }
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        delegate?.didReceiveNetworkError(error)
    }

    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        guard webSocketTask === primaryWebSocketTask else {
            return
        }
        delegate?.didDisconnect()
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge
            .protectionSpace
            .authenticationMethod == NSURLAuthenticationMethodServerTrust
        {
            completionHandler(
                .useCredential,
                URLCredential(trust: challenge.protectionSpace.serverTrust!)
            )
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
