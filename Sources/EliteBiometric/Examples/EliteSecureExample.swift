//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import Foundation
import EliteBiometric

// MARK: - EliteSecure Usage Examples
class EliteSecureExample {
    
    // MARK: - Basic Usage
    static func basicEncryptionExample() {
        let eliteSecure = EliteSecure()
        
        // Create a secure key
        let key = EliteSecureKey(
            id: "user-session-key",
            algorithm: .aes256GCM,
            requiresBiometric: false
        )
        
        // Encrypt sensitive data
        let sensitiveData = "EliteNet Data".data(using: .utf8)!
        
        do {
            let encryptedData = try eliteSecure.encrypt(sensitiveData, withKey: key)
            
            // Store encrypted data
            try eliteSecure.store(encryptedData, forKey: "user-session")
            
            print("✅ Data encrypted and stored successfully")
            
            // Retrieve and decrypt
            let retrievedData = try eliteSecure.retrieve(forKey: "user-session")
            let decryptedData = try eliteSecure.decrypt(retrievedData, withKey: key)
            
            let decryptedString = String(data: decryptedData, encoding: .utf8)
            print("✅ Data decrypted: \(decryptedString ?? "Failed to decode")")
            
        } catch {
            print("❌ Encryption error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Biometric Authentication
    static func biometricExample() async {
        let eliteSecure = EliteSecure()
        
        // Check if biometric authentication is available
        if eliteSecure.isBiometricAvailable() {
            print("✅ Biometric authentication available")
            
            do {
                let authenticated = try await eliteSecure.authenticateWithBiometrics()
                if authenticated {
                    print("✅ Biometric authentication successful")
                    
                    // Create a key that requires biometric authentication
                    let biometricKey = EliteSecureKey(
                        id: "biometric-protected-key",
                        algorithm: .chacha20Poly1305,
                        requiresBiometric: true
                    )
                    
                    // Use the key for encryption
                    let data = "Highly sensitive data".data(using: .utf8)!
                    let encryptedData = try eliteSecure.encrypt(data, withKey: biometricKey)
                    
                    print("✅ Biometric-protected data encrypted successfully")
                    
                } else {
                    print("❌ Biometric authentication failed")
                }
            } catch {
                print("❌ Biometric authentication error: \(error.localizedDescription)")
            }
        } else {
            print("❌ Biometric authentication not available")
        }
    }
    
    // MARK: - Hybrid Encryption
    static func hybridEncryptionExample() {
        let eliteSecure = EliteSecure()
        
        // Create a key with hybrid encryption (AES + ChaCha20)
        let hybridKey = EliteSecureKey(
            id: "hybrid-encryption-key",
            algorithm: .hybrid,
            keySize: 512 // Combined key size
        )
        
        let sampleData = """
        {
            "patientId": "P12345",
            "implantType": "Cardiac Pacemaker",
            "serialNumber": "IMP-2024-001",
            "implantDate": "2024-01-15",
            "lastCalibration": "2024-06-01"
        }
        """.data(using: .utf8)!
        
        do {
            let encryptedData = try eliteSecure.encrypt(sampleData, withKey: hybridKey)
            try eliteSecure.store(encryptedData, forKey: "sampleData-data")
            
            print("✅ Data encrypted with hybrid algorithm")
            
            // Retrieve and decrypt
            let retrievedData = try eliteSecure.retrieve(forKey: "sampleData-data")
            let decryptedData = try eliteSecure.decrypt(retrievedData, withKey: hybridKey)
            
            let decryptedString = String(data: decryptedData, encoding: .utf8)
            print("✅ sampleData data decrypted: \(decryptedString ?? "Failed to decode")")
            
        } catch {
            print("❌ Hybrid encryption error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Key Expiration
    static func keyExpirationExample() {
        let eliteSecure = EliteSecure()
        
        // Create a key that expires in 1 hour
        let expiringKey = EliteSecureKey(
            id: "temporary-session-key",
            algorithm: .aes256GCM,
            expirationDate: Date().addingTimeInterval(3600) // 1 hour from now
        )
        
        let sessionData = "Temporary session token".data(using: .utf8)!
        
        do {
            let encryptedData = try eliteSecure.encrypt(sessionData, withKey: expiringKey)
            try eliteSecure.store(encryptedData, forKey: "temporary-session")
            
            print("✅ Temporary session encrypted with expiring key")
            
            // Try to decrypt immediately (should work)
            let retrievedData = try eliteSecure.retrieve(forKey: "temporary-session")
            let decryptedData = try eliteSecure.decrypt(retrievedData, withKey: expiringKey)
            
            print("✅ Session decrypted successfully")
            
        } catch {
            print("❌ Key expiration error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Custom Configuration
    static func customConfigurationExample() {
        // Create custom security configuration
        let customConfig = EliteSecureConfig(
            maxRetryAttempts: 5,
            lockoutDuration: 600, // 10 minutes
            enableAuditLogging: true,
            enableTamperDetection: true,
            keyDerivationRounds: 200_000, // Higher security
            secureMemoryWipe: true
        )
        
        let eliteSecure = EliteSecure(config: customConfig)
        
        // Create a high-security key
        let highSecurityKey = EliteSecureKey(
            id: "high-security-key",
            algorithm: .aes256GCM,
            requiresBiometric: true,
            useSecureEnclave: true
        )
        
        let criticalData = "Critical device configuration".data(using: .utf8)!
        
        do {
            let encryptedData = try eliteSecure.encrypt(criticalData, withKey: highSecurityKey)
            try eliteSecure.store(encryptedData, forKey: "critical-config")
            
            print("✅ Critical data encrypted with high-security configuration")
            
        } catch {
            print("❌ High-security encryption error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error Handling
    static func errorHandlingExample() {
        let eliteSecure = EliteSecure()
        
        // Try to decrypt non-existent data
        do {
            let nonExistentData = try eliteSecure.retrieve(forKey: "non-existent-key")
            print("This should not print")
        } catch EliteSecureError.keyNotFound(let keyId) {
            print("✅ Correctly caught key not found error for: \(keyId)")
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
        }
        
        // Try to use expired key
        let expiredKey = EliteSecureKey(
            id: "expired-key",
            expirationDate: Date().addingTimeInterval(-3600) // Expired 1 hour ago
        )
        
        let data = "Test data".data(using: .utf8)!
        
        do {
            let encryptedData = try eliteSecure.encrypt(data, withKey: expiredKey)
            print("This should not print")
        } catch EliteSecureError.keyExpired(let keyId) {
            print("✅ Correctly caught expired key error for: \(keyId)")
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Usage in ViewModels
extension EliteSecureExample {
    
    static func integrationWithViewModel() {
        // Example of how EliteSecure integrates with our existing architecture
        
        let eliteSecure = EliteSecure()
        
        // Create a secure credentials repository using EliteSecure
        class SecureCredentialsRepository {
            private let eliteSecure: EliteSecure
            private let accessTokenKey = EliteSecureKey(
                id: "access-token",
                algorithm: .aes256GCM,
                requiresBiometric: true
            )
            private let refreshTokenKey = EliteSecureKey(
                id: "refresh-token",
                algorithm: .chacha20Poly1305,
                requiresBiometric: false
            )
            
            init(eliteSecure: EliteSecure) {
                self.eliteSecure = eliteSecure
            }
            
            func saveAccessToken(_ token: String) throws {
                let tokenData = token.data(using: .utf8)!
                let encryptedToken = try eliteSecure.encrypt(tokenData, withKey: accessTokenKey)
                try eliteSecure.store(encryptedToken, forKey: "access-token")
            }
            
            func getAccessToken() throws -> String {
                let encryptedToken = try eliteSecure.retrieve(forKey: "access-token")
                let tokenData = try eliteSecure.decrypt(encryptedToken, withKey: accessTokenKey)
                return String(data: tokenData, encoding: .utf8) ?? ""
            }
            
            func saveRefreshToken(_ token: String) throws {
                let tokenData = token.data(using: .utf8)!
                let encryptedToken = try eliteSecure.encrypt(tokenData, withKey: refreshTokenKey)
                try eliteSecure.store(encryptedToken, forKey: "refresh-token")
            }
            
            func getRefreshToken() throws -> String {
                let encryptedToken = try eliteSecure.retrieve(forKey: "refresh-token")
                let tokenData = try eliteSecure.decrypt(encryptedToken, withKey: refreshTokenKey)
                return String(data: tokenData, encoding: .utf8) ?? ""
            }
        }
        
        // Use the secure repository
        let secureRepo = SecureCredentialsRepository(eliteSecure: eliteSecure)
        
        do {
            try secureRepo.saveAccessToken("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
            try secureRepo.saveRefreshToken("refresh_token_here")
            
            let accessToken = try secureRepo.getAccessToken()
            let refreshToken = try secureRepo.getRefreshToken()
            
            print("✅ Secure token storage working: \(accessToken.prefix(20))...")
            print("✅ Refresh token retrieved: \(refreshToken)")
            
        } catch {
            print("❌ Secure repository error: \(error.localizedDescription)")
        }
    }
} 
