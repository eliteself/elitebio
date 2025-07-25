//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import Foundation
import Security

final class EliteKeychain {
    
    private var lock = pthread_rwlock_t()
    
    init() {
        pthread_rwlock_init(&lock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    func addItem(query: [CFString: Any]) throws {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
    
    func findItem(query: [CFString: Any]) throws -> [CFString: Any]? {
        pthread_rwlock_rdlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        
        var query = query
        query[kSecReturnAttributes] = kCFBooleanTrue
        query[kSecReturnData] = kCFBooleanTrue
        
        var searchResult: AnyObject?
        
        let status = withUnsafeMutablePointer(to: &searchResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }
        
        if status != errSecSuccess {
            throw KeychainError(status: status)
        } else {
            return searchResult as? [CFString: Any]
        }
    }
    
    func updateItem(query: [CFString: Any], attributesToUpdate: [CFString: Any]) throws {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
    
    func deleteItem(query: [CFString: Any]) throws {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
}

extension EliteKeychain {
    
    func create(_ data: Data, for key: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]
        
        try addItem(query: query)
    }
    
    func update(_ data: Data, for key: String) throws {
        guard let _ = fetch(for: key) else {
            return try create(data, for: key)
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        let attr: [CFString: Any] = [
            kSecValueData: data
        ]
        
        try updateItem(query: query, attributesToUpdate: attr)
    }
    
    func fetch(for key: String) -> Data? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        guard let result = try? findItem(query: query) else {
            return nil
        }
        
        return result[kSecValueData] as? Data
    }
    
    func delete(for key: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        try deleteItem(query: query)
    }
}

extension EliteKeychain {
    
    enum KeychainError: Error {
        case itemAlreadyExist
        case itemNotFound
        case errorStatus(String?)
        
        init(status: OSStatus) {
            switch status {
            case errSecDuplicateItem:
                self = .itemAlreadyExist
            case errSecItemNotFound:
                self = .itemNotFound
            default:
                let message = SecCopyErrorMessageString(status, nil) as String?
                self = .errorStatus(message)
            }
        }
    }
} 