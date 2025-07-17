//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import Foundation

// MARK: - Credentials Model
public struct Credentials: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
    public let tokenType: String
    public let userId: String?
    public let createdAt: Date
    
    public init(
        accessToken: String,
        refreshToken: String,
        expiresIn: Int,
        tokenType: String,
        userId: String? = nil
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
        self.userId = userId
        self.createdAt = Date()
    }
    
    public var isExpired: Bool {
        let expirationDate = createdAt.addingTimeInterval(TimeInterval(expiresIn))
        return Date() > expirationDate
    }
    
    public var willExpireSoon: Bool {
        let expirationDate = createdAt.addingTimeInterval(TimeInterval(expiresIn))
        let fiveMinutesFromNow = Date().addingTimeInterval(300)
        return fiveMinutesFromNow > expirationDate
    }
}

// MARK: - Credentials Repository Protocol
public protocol CredentialsRepositoryProtocol {
    func saveCredentials(_ credentials: Credentials) throws
    func loadCredentials() throws -> Credentials?
    func deleteCredentials() throws
    func hasValidCredentials() -> Bool
    func getValidCredentials() throws -> Credentials?
}

// MARK: - Credentials Repository Implementation
public class CredentialsRepository: CredentialsRepositoryProtocol {
    private let keychainManager = KeychainManager.shared
    private let credentialsKey = "com.elitenet.credentials"
    
    public init() {}
    
    public func saveCredentials(_ credentials: Credentials) throws {
        try keychainManager.save(credentials, forKey: credentialsKey)
    }
    
    public func loadCredentials() throws -> Credentials? {
        guard keychainManager.exists(key: credentialsKey) else {
            return nil
        }
        
        return try keychainManager.load(Credentials.self, forKey: credentialsKey)
    }
    
    public func deleteCredentials() throws {
        try keychainManager.delete(key: credentialsKey)
    }
    
    public func hasValidCredentials() -> Bool {
        guard let credentials = try? loadCredentials() else {
            return false
        }
        
        return !credentials.isExpired
    }
    
    public func getValidCredentials() throws -> Credentials? {
        guard let credentials = try loadCredentials() else {
            return nil
        }
        
        return credentials.isExpired ? nil : credentials
    }
}
