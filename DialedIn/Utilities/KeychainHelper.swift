//
//  KeychainHelper.swift
//  DialedIn
//

import Foundation
import Security

struct KeychainHelper {

    static func save(_ value: String, forKey key: String, synchronizable: Bool = false) {
        let data = Data(value.utf8)
        // Delete both the local and synchronizable variants to avoid duplicates
        for sync in [true, false] {
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecAttrSynchronizable: sync ? kCFBooleanTrue! : kCFBooleanFalse!
            ]
            SecItemDelete(query as CFDictionary)
        }
        let attributes: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrSynchronizable: synchronizable ? kCFBooleanTrue! : kCFBooleanFalse!
        ]
        SecItemAdd(attributes as CFDictionary, nil)
    }

    static func read(forKey key: String, synchronizable: Bool = false) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecAttrSynchronizable: synchronizable ? kCFBooleanTrue! : kCFBooleanFalse!
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(forKey key: String, synchronizable: Bool = false) {
        for sync in [true, false] {
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecAttrSynchronizable: sync ? kCFBooleanTrue! : kCFBooleanFalse!
            ]
            SecItemDelete(query as CFDictionary)
        }
    }
}
