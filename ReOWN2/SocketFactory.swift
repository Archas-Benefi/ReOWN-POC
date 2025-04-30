//
//  SocketFactory.swift
//  ReOWN2
//
//  Created by Archas Srivastava on 21/04/25.
//


import Starscream
import ReownAppKit


extension WebSocket: WebSocketConnecting { }

struct SocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("relay.walletconnect.com", forHTTPHeaderField: "Origin")
        return WebSocket(url: url)
    }
}

final class SocketViewModel: ObservableObject {
    
    var accountsDetails = [AccountDetails]()
    @Published private var session: Session?

    
    init() {
        connect()
        AppkitConfigure()
        getSession()
    }

    func connectWalletWithW3M() {
        Task {
            AppKit.set(sessionParams: .init(
                requiredNamespaces: Proposal.requiredNamespaces,
                optionalNamespaces: Proposal.optionalNamespaces
            ))
        }
        AppKit.present(from: nil)
    }
    
    func connect() {
        Networking.configure(groupIdentifier: "group.poc.reown", projectId: "3d755509533a6e38fa9f05480a0ec0b4", socketFactory: SocketFactory())
    }
    
    func AppkitConfigure() {
        let metadata = AppMetadata(
            name: "Benefi",
            description: "Benefi Description",
            url: "https://benefi.org",
            icons: ["https://avatars.githubusercontent.com/u/179229932"],
            // Used for the Verify: to opt-out verification ignore this parameter
            redirect: try! AppMetadata.Redirect(native: "benefi://", universal: "https://benefi.org")
        )

        AppKit.configure(
            projectId: "3d755509533a6e38fa9f05480a0ec0b4",
            metadata: metadata,
            crypto: DefaultCryptoProvider(),
            authRequestParams: nil
        )
    }
    
    
    func getSession() {
        self.session = nil
        accountsDetails = []
        if let session = AppKit.instance.getSessions().first {
            self.session = session
            session.namespaces.values.forEach { namespace in
                namespace.accounts.forEach { account in
                    accountsDetails.append(
                        AccountDetails(
                            chain: account.blockchainIdentifier,
                            methods: Array(namespace.methods),
                            address: account.address
                        )
                    )
                }
            }
        }
    }
    
    func onMethod(method: String, account: AccountDetails) {
        do {
            guard let session = session else {
                print("No active session")
                return
            }


            let requestParams = try getRequest(for: method)
            
            let ttl: TimeInterval = 300
            let request = try Request(topic: session.topic, method: method, params: requestParams, chainId: Blockchain(account.chain)!, ttl: ttl)
            Task {
                do {
//                    ActivityIndicatorManager.shared.start()
                    try await AppKit.instance.request(params: request)
//                    lastRequest = request
//                    ActivityIndicatorManager.shared.stop()
//                    requesting = true
                    DispatchQueue.main.async { [weak self] in
                        self?.openWallet()
                    }
                } catch {
                    print(error.localizedDescription)
//                    ActivityIndicatorManager.shared.stop()
//                    requesting = false
//                    showError.toggle()
//                    errorMessage = error.localizedDescription
                }
            }
        } catch {
            print(error.localizedDescription)
//            showError.toggle()
//            errorMessage = error.localizedDescription
        }
    }
    
    private func openWallet() {
        guard let session = session else {
            print("No active session")
            return
        }

        if let nativeUri = session.peer.redirect?.native {
            UIApplication.shared.open(URL(string: "\(nativeUri)wc?requestSent")!)
        } else {
//            showRequestSent.toggle()
        }
    }
    
    private func getRequest(for method: String) throws -> AnyCodable {
        guard let session = session else {
            print("No active session")
            throw ErrorType.writeTimeoutError
        }

        let account = session.namespaces.first!.value.accounts.first!.address
        if method == "eth_sendTransaction" {
            let tx = Stub.tx(from: account)
            return AnyCodable(tx)
        } else if method == "personal_sign" {
            return AnyCodable(["0x4d7920656d61696c206973206a6f686e40646f652e636f6d202d2031363533333933373535313531", account])
        }
        throw ErrorType.writeTimeoutError
    }

}


    private enum Stub {
        struct Transaction: Codable {
            let from, to, data, gasLimit: String?
            let gasPrice, value, nonce: String?
        }

        static func tx(from: String) -> [Transaction] {
//            return [Transaction(from: from,
//                                to: "0x9b2055d370f73ec7d8a03e965129118dc8f5bf83",
//                                data: "0x",
//                                gasLimit: "0x5208",
//                                gasPrice: "0x013e3d2ed4",
//                                value: "0x16345785D8A0000",
//                                nonce: "0x09")]
            
            return [Transaction(
                from: from,
                to: "0xdAC17F958D2ee523a2206206994597C13D831ec7", // USDT Contract
                data: "0xa9059cbb000000000000000000000000b92eF7CddEC3e3A89cdC32E9F229B12b6357F29A00000000000000000000000000000000000000000000000000000000004c4b40", // No ETH
                gasLimit: nil, // ~32060
                gasPrice: nil,
                value: "0x0",
                nonce: nil
              )]
        }
    }
