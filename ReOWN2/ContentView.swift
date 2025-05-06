//
//  ContentView.swift
//  ReOWN2
//
//  Created by Archas Srivastava on 21/04/25.
//

import SwiftUI
//import ReownAppKitUI
//import ReownAppKitBackport
//import ReownRouter
//import ReownWalletKit
import ReownAppKit
import CoinbaseWalletSDK

struct AccountDetails {
    let chain: String
    let methods: [String]
    let address: String
    var account: String {
        "\(chain):\(address)"
    }
}


struct ContentView: View {
    @StateObject private var viewModel = SocketViewModel()
    
    
    
    var body: some View {
        VStack {
            ScrollView {
                //            AppKitButton()
                Button("Connect"){
                    //                           AppKit.present()
                    viewModel.connectWalletWithW3M()
                }
                
                ConnectButton()
                
                VStack {
                    ForEach(viewModel.accountsDetails, id: \.account) { account in
                        Button {
                            //                        presenter.presentSessionAccount(sessionAccount: account)
                        } label: {
                            networkItem(title: account.account, icon: String(account.chain.split(separator: ":").first ?? ""), id: account.chain)
                        }
                        .accessibilityIdentifier(account.account)
                        
                        methodsView(methods: account.methods, account: account)
                        
                    }
                }
                .padding(12)
                
                Button("TEST") {
                    Task {
                        try await viewModel.tryTopicConnect()
                    }
                }
                
                Button("Check Session") {
                    //                Task {
                    //                    do { try await test() }
                    //                    catch {
                    //                        print(error)
                    //                    }
                    //                }
                    viewModel.getSession()
                }
                
//                Button("Send Disconnected Transaction") {
//                    viewModel.onMethod(method: "eth_sendTransaction", account: account)
//                }
            }
        }
        
        .padding()
    }
    
    
    private func test() async throws {
        //    let request = Action(jsonRpc: .eth_sendTransaction(fromAddress: <#T##EthAddress#>, toAddress: <#T##EthAddress?#>, weiValue: <#T##BigInt#>, data: <#T##EthTxData#>, nonce: <#T##Int?#>, gasPriceInWei: <#T##BigInt?#>, maxFeePerGas: <#T##BigInt?#>, maxPriorityFeePerGas: <#T##BigInt?#>, gasLimit: <#T##BigInt?#>, chainId: <#T##BigInt#>))
        
        //    (from: "0x9b2055d370f73ec7d8a03e965129118dc8f5bf83",
        //                                to: "0x9b2055d370f73ec7d8a03e965129118dc8f5bf83",
        //                                data: "0x",
        //                                gasLimit: "0x5208",
        //                                gasPrice: "0x013e3d2ed4",
        //                                value: "0x00",
        //                                nonce: "0x09")
        
        //    let result = getSession()
        
        //    let payload = AnyCodable(any: (fromAddress: result.first?.namespaces.values.first?.accounts.first?.address, toAddress: "0x9b2055d370f73ec7d8a03e965129118dc8f5bf83", value: "0x00", data: "EthTxData", chainId: "1"))
        
        //    print(result)
        
        //    try await AppKit.instance.request(
        //        params: .init(
        //            topic: result.first?.topic ?? "",
        //            method: "eth_sendTransaction",
        //            params: payload,
        //            chainId: Blockchain("1")!
        //        )
        //    )
        
        
        //    let requestParams = try getRequest(for: method)
        //
        //    let ttl: TimeInterval = 300
        //    let request = try Request(topic: result.first?.topic ?? "", method: "eth_sendTransaction", params: requestParams, chainId: Blockchain(sessionAccount.chain)!, ttl: ttl)
        //
        //    let request = Action(jsonRpc: .eth_sendTransaction(fromAddress: result.first?.namespaces.values.first?.accounts.first?.address ?? "0x", toAddress: "0x9b2055d370f73ec7d8a03e965129118dc8f5bf83", weiValue: "0x00", data: "0x", nonce: nil, gasPriceInWei: nil, maxFeePerGas: nil, maxPriorityFeePerGas: nil, gasLimit: nil, chainId: "1"))
        
        
        
    }
    
    
    
    private func networkItem(title: String, icon: String, id: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 30/255, green: 31/255, blue: 31/255))
            
            HStack(spacing: 10) {
                Image(icon == "eip155" ? "ethereum" : icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(title)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 228/255, green: 231/255, blue: 231/255))
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text(id)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(red: 0.58, green: 0.62, blue: 0.62))
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                            if !viewModel.accountsDetails.isEmpty {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(red: 0.58, green: 0.62, blue: 0.62))
                                    .padding(.trailing, 16)
                            }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
    }
    
    private func methodsView(methods: [String], account: AccountDetails) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.02))
            
            VStack(spacing: 5) {
                Text("Methods")
                    .font(
                        Font.system(size: 14, weight: .medium)
                    )
                    .foregroundColor(Color(red: 0.58, green: 0.62, blue: 0.62))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(12)
                
                ForEach(Array(methods.enumerated()), id: \.offset) { index, method in
                    Button {
                        viewModel.onMethod(method: method, account: account)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.02))
                            
                            HStack(spacing: 10) {
                                Text(method)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                        }
                        .padding(.bottom, 12)
                        .padding(.horizontal, 8)
                    }
                    .accessibilityIdentifier("method-\(index)")
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
