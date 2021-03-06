//
//  md5.swift
//  Events
//
//  Created by Dmitry on 16.02.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import let CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

// https://stackoverflow.com/a/32166735
func md5Hex(string: String) -> String {
	let length = Int(CC_MD5_DIGEST_LENGTH)
	let messageData = string.data(using: .utf8)!
	var digestData = Data(count: length)

	_ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
			messageData.withUnsafeBytes { messageBytes -> UInt8 in
				if let messageBytesBaseAddress = messageBytes.baseAddress,
          let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
					let messageLength = CC_LONG(messageData.count)
					CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
				}
			return 0
		}
	}
	return digestData.map { String(format: "%02hhx", $0) }.joined()
}
