//
//  DefaultCryptoProvider.swift
//  reOwnPOC
//
//  Created by Archas Srivastava on 16/03/25.
//


import Foundation
//import ReownAppKitBackport
//import ReownRouter
import ReownWalletKit
//import ReownAppKit

import Web3
import CryptoSwift
//import WalletConnectSigner

struct DefaultCryptoProvider: CryptoProvider {

    public func recoverPubKey(signature: EthereumSignature, message: Data) throws -> Data {
        let publicKey = try EthereumPublicKey(
            message: message.bytes,
            v: EthereumQuantity(quantity: BigUInt(signature.v)),
            r: EthereumQuantity(signature.r),
            s: EthereumQuantity(signature.s)
        )
        return Data(publicKey.rawPublicKey)
//        return Data(repeating: 0x01, count: 64)
    }

    public func keccak256(_ data: Data) -> Data {
        let digest = SHA3(variant: .keccak256)
        let hash = digest.calculate(for: [UInt8](data))
        return Data(hash)
//        return Data(repeating: 0x01, count: 64)
    }

}
