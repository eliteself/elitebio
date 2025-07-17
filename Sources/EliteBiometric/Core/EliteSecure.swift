//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import Foundation
import Security
import LocalAuthentication
import CryptoKit

// MARK: - EliteSecure Core Protocol
public protocol EliteSecureProtocol {
    func encrypt(_ data: Data, withKey key: EliteSecureKey) throws -> EliteSecureData
    func decrypt(_ secureData: EliteSecureData, withKey key: EliteSecureKey) throws -> Data
    func store(_ secureData: EliteSecureData, forKey key: String) throws
    func retrieve(forKey key: String) throws -> EliteSecureData
    func delete(forKey key: String) throws
    func clearAll() throws
    func isBiometricAvailable() -> Bool
    func authenticateWithBiometrics() async throws -> Bool
}

// MARK: - EliteSecure Key Management
public struct EliteSecureKey {
    public let id: String
    public let algorithm: EncryptionAlgorithm
    public let keySize: Int
    public let requiresBiometric: Bool
    public let useSecureEnclave: Bool
    public let expirationDate: Date?
    
    public init(
        id: String,
        algorithm: EncryptionAlgorithm = .aes256GCM,
        keySize: Int = 256,
        requiresBiometric: Bool = false,
        useSecureEnclave: Bool = false,
        expirationDate: Date? = nil
    ) {
        self.id = id
        self.algorithm = algorithm
        self.keySize = keySize
        self.requiresBiometric = requiresBiometric
        self.useSecureEnclave = useSecureEnclave
        self.expirationDate = expirationDate
    }
}

// MARK: - Encryption Algorithms
public enum EncryptionAlgorithm: String, CaseIterable {
    case aes256GCM = "AES-256-GCM"
    case aes256CBC = "AES-256-CBC"
    case chacha20Poly1305 = "ChaCha20-Poly1305"
    case hybrid = "Hybrid-AES-ChaCha"
    
    public var keySize: Int {
        switch self {
        case .aes256GCM, .aes256CBC:
            return 256
        case .chacha20Poly1305:
            return 256
        case .hybrid:
            return 512 // Combined key size
        }
    }
}

// MARK: - Secure Data Structure
public struct EliteSecureData {
    public let encryptedData: Data
    public let iv: Data
    public let tag: Data
    public let algorithm: EncryptionAlgorithm
    public let timestamp: Date
    public let metadata: [String: String]
    public let integrityHash: Data
    
    public init(
        encryptedData: Data,
        iv: Data,
        tag: Data,
        algorithm: EncryptionAlgorithm,
        timestamp: Date = Date(),
        metadata: [String: String] = [:],
        integrityHash: Data
    ) {
        self.encryptedData = encryptedData
        self.iv = iv
        self.tag = tag
        self.algorithm = algorithm
        self.timestamp = timestamp
        self.metadata = metadata
        self.integrityHash = integrityHash
    }
}

// MARK: - Security Configuration
public struct EliteSecureConfig {
    public let maxRetryAttempts: Int
    public let lockoutDuration: TimeInterval
    public let enableAuditLogging: Bool
    public let enableTamperDetection: Bool
    public let keyDerivationRounds: Int
    public let secureMemoryWipe: Bool
    
    public static let `default` = EliteSecureConfig(
        maxRetryAttempts: 3,
        lockoutDuration: 300, // 5 minutes
        enableAuditLogging: true,
        enableTamperDetection: true,
        keyDerivationRounds: 100_000,
        secureMemoryWipe: true
    )
    
    public init(
        maxRetryAttempts: Int,
        lockoutDuration: TimeInterval,
        enableAuditLogging: Bool,
        enableTamperDetection: Bool,
        keyDerivationRounds: Int,
        secureMemoryWipe: Bool
    ) {
        self.maxRetryAttempts = maxRetryAttempts
        self.lockoutDuration = lockoutDuration
        self.enableAuditLogging = enableAuditLogging
        self.enableTamperDetection = enableTamperDetection
        self.keyDerivationRounds = keyDerivationRounds
        self.secureMemoryWipe = secureMemoryWipe
    }
}

// MARK: - Security Events
public enum EliteSecureEvent {
    case encryption(keyId: String, algorithm: EncryptionAlgorithm)
    case decryption(keyId: String, algorithm: EncryptionAlgorithm)
    case biometricAuth(success: Bool)
    case tamperDetected
    case keyExpired(keyId: String)
    case accessDenied(reason: String)
    case secureEnclaveOperation(success: Bool)
}

// MARK: - EliteSecure Implementation
public class EliteSecure: EliteSecureProtocol {
    private let config: EliteSecureConfig
    private let keychain: KeychainManager
    private let biometricContext: LAContext
    private let auditLogger: EliteSecureAuditLogger
    private let keyManager: EliteSecureKeyManager
    
    public init(config: EliteSecureConfig = .default) {
        self.config = config
        self.keychain = KeychainManager.shared
        self.biometricContext = LAContext()
        self.auditLogger = EliteSecureAuditLogger()
        self.keyManager = EliteSecureKeyManager(config: config)
    }
    
    // MARK: - Core Encryption/Decryption
    public func encrypt(_ data: Data, withKey key: EliteSecureKey) throws -> EliteSecureData {
        // Validate key expiration
        if let expirationDate = key.expirationDate, expirationDate < Date() {
            throw EliteSecureError.keyExpired(keyId: key.id)
        }
        
        // Generate or retrieve encryption key
        let encryptionKey = try keyManager.getOrCreateKey(for: key)
        
        // Perform encryption based on algorithm
        let encryptedResult: (encryptedData: Data, iv: Data, tag: Data)
        
        switch key.algorithm {
        case .aes256GCM:
            encryptedResult = try encryptWithAESGCM(data, key: encryptionKey)
        case .aes256CBC:
            encryptedResult = try encryptWithAESCBC(data, key: encryptionKey)
        case .chacha20Poly1305:
            encryptedResult = try encryptWithChaCha20(data, key: encryptionKey)
        case .hybrid:
            encryptedResult = try encryptWithHybrid(data, key: encryptionKey)
        }
        
        // Create integrity hash
        let integrityHash = try createIntegrityHash(data: encryptedResult.encryptedData, key: encryptionKey)
        
        // Create secure data
        let secureData = EliteSecureData(
            encryptedData: encryptedResult.encryptedData,
            iv: encryptedResult.iv,
            tag: encryptedResult.tag,
            algorithm: key.algorithm,
            metadata: ["keyId": key.id, "version": "1.0"],
            integrityHash: integrityHash
        )
        
        // Log event
        auditLogger.log(.encryption(keyId: key.id, algorithm: key.algorithm))
        
        return secureData
    }
    
    public func decrypt(_ secureData: EliteSecureData, withKey key: EliteSecureKey) throws -> Data {
        // Validate key expiration
        if let expirationDate = key.expirationDate, expirationDate < Date() {
            throw EliteSecureError.keyExpired(keyId: key.id)
        }
        
        // Verify integrity
        if config.enableTamperDetection {
            try verifyIntegrity(secureData: secureData, key: key)
        }
        
        // Get encryption key
        let encryptionKey = try keyManager.getKey(for: key)
        
        // Perform decryption
        let decryptedData: Data
        
        switch secureData.algorithm {
        case .aes256GCM:
            decryptedData = try decryptWithAESGCM(secureData, key: encryptionKey)
        case .aes256CBC:
            decryptedData = try decryptWithAESCBC(secureData, key: encryptionKey)
        case .chacha20Poly1305:
            decryptedData = try decryptWithChaCha20(secureData, key: encryptionKey)
        case .hybrid:
            decryptedData = try decryptWithHybrid(secureData, key: encryptionKey)
        }
        
        // Log event
        auditLogger.log(.decryption(keyId: key.id, algorithm: secureData.algorithm))
        
        return decryptedData
    }
    
    // MARK: - Storage Operations
    public func store(_ secureData: EliteSecureData, forKey key: String) throws {
        let encodedData = try JSONEncoder().encode(secureData)
        try keychain.save(key: key, data: encodedData)
    }
    
    public func retrieve(forKey key: String) throws -> EliteSecureData {
        let encodedData = try keychain.load(key: key)
        return try JSONDecoder().decode(EliteSecureData.self, from: encodedData)
    }
    
    public func delete(forKey key: String) throws {
        try keychain.delete(key: key)
    }
    
    public func clearAll() throws {
        // Note: KeychainManager doesn't have clearAll, so we'll implement it
        // For now, we'll throw an error indicating this needs to be implemented
        throw EliteSecureError.operationNotSupported
    }
    
    // MARK: - Biometric Authentication
    public func isBiometricAvailable() -> Bool {
        var error: NSError?
        return biometricContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    public func authenticateWithBiometrics() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            biometricContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access secure data"
            ) { success, error in
                if let error = error {
                    continuation.resume(throwing: EliteSecureError.biometricAuthFailed(error.localizedDescription))
                } else {
                    self.auditLogger.log(.biometricAuth(success: success))
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    // MARK: - Private Encryption Methods
    private func encryptWithAESGCM(_ data: Data, key: Data) throws -> (encryptedData: Data, iv: Data, tag: Data) {
        let sealedBox = try AES.GCM.seal(data, using: SymmetricKey(data: key))
        return (
            encryptedData: sealedBox.ciphertext,
            iv: sealedBox.nonce.withUnsafeBytes { Data($0) },
            tag: sealedBox.tag
        )
    }
    
    private func encryptWithAESCBC(_ data: Data, key: Data) throws -> (encryptedData: Data, iv: Data, tag: Data) {
        let iv = Data((0..<16).map { _ in UInt8.random(in: 0...255) })
        // Note: CryptoKit doesn't have AES.CBC, so we'll use CommonCrypto or implement our own
        // For now, we'll throw an error indicating this needs to be implemented
        throw EliteSecureError.algorithmNotImplemented
    }
    
    private func encryptWithChaCha20(_ data: Data, key: Data) throws -> (encryptedData: Data, iv: Data, tag: Data) {
        let nonce = Data((0..<12).map { _ in UInt8.random(in: 0...255) })
        let sealedBox = try ChaChaPoly.seal(data, using: SymmetricKey(data: key), nonce: ChaChaPoly.Nonce(data: nonce))
        return (
            encryptedData: sealedBox.ciphertext,
            iv: nonce,
            tag: sealedBox.tag
        )
    }
    
    private func encryptWithHybrid(_ data: Data, key: Data) throws -> (encryptedData: Data, iv: Data, tag: Data) {
        // Split key for hybrid encryption
        let aesKey = key.prefix(32)
        let chachaKey = key.suffix(32)
        
        // Encrypt with AES first
        let aesResult = try encryptWithAESGCM(data, key: aesKey)
        
        // Then encrypt AES result with ChaCha20
        let chachaResult = try encryptWithChaCha20(aesResult.encryptedData, key: chachaKey)
        
        return (
            encryptedData: chachaResult.encryptedData,
            iv: aesResult.iv + chachaResult.iv, // Combine IVs
            tag: aesResult.tag + chachaResult.tag // Combine tags
        )
    }
    
    // MARK: - Private Decryption Methods
    private func decryptWithAESGCM(_ secureData: EliteSecureData, key: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: secureData.iv),
            ciphertext: secureData.encryptedData,
            tag: secureData.tag
        )
        return try AES.GCM.open(sealedBox, using: SymmetricKey(data: key))
    }
    
    private func decryptWithAESCBC(_ secureData: EliteSecureData, key: Data) throws -> Data {
        // Note: CryptoKit doesn't have AES.CBC, so we'll use CommonCrypto or implement our own
        // For now, we'll throw an error indicating this needs to be implemented
        throw EliteSecureError.algorithmNotImplemented
    }
    
    private func decryptWithChaCha20(_ secureData: EliteSecureData, key: Data) throws -> Data {
        let sealedBox = try ChaChaPoly.SealedBox(
            nonce: ChaChaPoly.Nonce(data: secureData.iv),
            ciphertext: secureData.encryptedData,
            tag: secureData.tag
        )
        return try ChaChaPoly.open(sealedBox, using: SymmetricKey(data: key))
    }
    
    private func decryptWithHybrid(_ secureData: EliteSecureData, key: Data) throws -> Data {
        // Split key and IVs
        let aesKey = key.prefix(32)
        let chachaKey = key.suffix(32)
        let aesIV = secureData.iv.prefix(12)
        let chachaIV = secureData.iv.suffix(12)
        let aesTag = secureData.tag.prefix(16)
        let chachaTag = secureData.tag.suffix(16)
        
        // Create partial secure data for ChaCha20 decryption
        let chachaSecureData = EliteSecureData(
            encryptedData: secureData.encryptedData,
            iv: chachaIV,
            tag: chachaTag,
            algorithm: .chacha20Poly1305,
            integrityHash: Data()
        )
        
        // Decrypt ChaCha20 first
        let chachaDecrypted = try decryptWithChaCha20(chachaSecureData, key: chachaKey)
        
        // Create partial secure data for AES decryption
        let aesSecureData = EliteSecureData(
            encryptedData: chachaDecrypted,
            iv: aesIV,
            tag: aesTag,
            algorithm: .aes256GCM,
            integrityHash: Data()
        )
        
        // Then decrypt AES
        return try decryptWithAESGCM(aesSecureData, key: aesKey)
    }
    
    // MARK: - Integrity Verification
    private func createIntegrityHash(data: Data, key: Data) throws -> Data {
        let hash = SHA256.hash(data: data + key)
        return Data(hash)
    }
    
    private func verifyIntegrity(secureData: EliteSecureData, key: EliteSecureKey) throws {
        let encryptionKey = try keyManager.getKey(for: key)
        let expectedHash = try createIntegrityHash(data: secureData.encryptedData, key: encryptionKey)
        
        if secureData.integrityHash != expectedHash {
            auditLogger.log(.tamperDetected)
            throw EliteSecureError.integrityCheckFailed
        }
    }
}

// MARK: - Supporting Classes
private class EliteSecureKeyManager {
    private let config: EliteSecureConfig
    private var keyCache: [String: Data] = [:]
    
    init(config: EliteSecureConfig) {
        self.config = config
    }
    
    func getOrCreateKey(for secureKey: EliteSecureKey) throws -> Data {
        if let cachedKey = keyCache[secureKey.id] {
            return cachedKey
        }
        
        let key = try generateKey(for: secureKey)
        keyCache[secureKey.id] = key
        return key
    }
    
    func getKey(for secureKey: EliteSecureKey) throws -> Data {
        guard let key = keyCache[secureKey.id] else {
            throw EliteSecureError.keyNotFound(keyId: secureKey.id)
        }
        return key
    }
    
    private func generateKey(for secureKey: EliteSecureKey) throws -> Data {
        var keyData = Data(count: secureKey.keySize / 8)
        let result = keyData.withUnsafeMutableBytes { pointer in
            SecRandomCopyBytes(kSecRandomDefault, secureKey.keySize / 8, pointer.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            throw EliteSecureError.keyGenerationFailed
        }
        
        return keyData
    }
}

private class EliteSecureAuditLogger {
    private var events: [EliteSecureEvent] = []
    
    func log(_ event: EliteSecureEvent) {
        events.append(event)
        // In a real implementation, you might want to persist these events
        // or send them to a secure logging service
    }
    
    func getEvents() -> [EliteSecureEvent] {
        return events
    }
}

// MARK: - Errors
public enum EliteSecureError: Error, LocalizedError {
    case keyExpired(keyId: String)
    case keyNotFound(keyId: String)
    case keyGenerationFailed
    case biometricAuthFailed(String)
    case integrityCheckFailed
    case encryptionFailed
    case decryptionFailed
    case invalidAlgorithm
    case operationNotSupported
    case algorithmNotImplemented
    
    public var errorDescription: String? {
        switch self {
        case .keyExpired(let keyId):
            return "Key expired: \(keyId)"
        case .keyNotFound(let keyId):
            return "Key not found: \(keyId)"
        case .keyGenerationFailed:
            return "Failed to generate encryption key"
        case .biometricAuthFailed(let reason):
            return "Biometric authentication failed: \(reason)"
        case .integrityCheckFailed:
            return "Data integrity check failed"
        case .encryptionFailed:
            return "Encryption operation failed"
        case .decryptionFailed:
            return "Decryption operation failed"
        case .invalidAlgorithm:
            return "Invalid encryption algorithm"
        case .operationNotSupported:
            return "Operation not supported"
        case .algorithmNotImplemented:
            return "Algorithm not yet implemented"
        }
    }
}

// MARK: - Convenience Extensions
extension EliteSecureData: Codable {}
extension EliteSecureKey: Codable {}
extension EncryptionAlgorithm: Codable {} 
