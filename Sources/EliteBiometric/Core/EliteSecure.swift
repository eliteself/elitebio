//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import Foundation

// MARK: - EliteSecure Property Wrapper 
@propertyWrapper
public struct EliteSecure<WrappedValue: Codable> {
    
    private let key: String
    private let keychain = EliteKeychain()
    private var cachedValue: WrappedValue?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init(_ key: String, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
        self.key = key
        self.encoder = encoder
        self.decoder = decoder
    }
    
    public init(wrappedValue: WrappedValue, _ key: String, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
        self.key = key
        self.encoder = encoder
        self.decoder = decoder
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: WrappedValue? {
        mutating get {
            if let cachedValue = cachedValue {
                return cachedValue
            }
            
            cachedValue = loadFromStorage()
            return cachedValue
        }
        
        set {
            if let value = newValue {
                saveToStorage(value)
                cachedValue = value
            } else {
                removeFromStorage()
                cachedValue = nil
            }
        }
    }
    
    // MARK: - Private Storage Methods
    private mutating func loadFromStorage() -> WrappedValue? {
        return execute {
            guard let data = keychain.fetch(for: key) else {
                return nil
            }
            return try decoder.decode(WrappedValue.self, from: data)
        }
    }
    
    private func saveToStorage(_ value: WrappedValue) {
        execute {
            let data = try encoder.encode(value)
            try keychain.update(data, for: key)
        }
    }
    
    private func removeFromStorage() {
        execute {
            try keychain.delete(for: key)
        }
    }
}

// MARK: - Convenience Methods
extension EliteSecure {
    
    /// Force refresh the cached value from storage
    public mutating func refresh() {
        cachedValue = loadFromStorage()
    }
    
    /// Clear the cached value and remove from storage
    public mutating func clear() {
        removeFromStorage()
        cachedValue = nil
    }
    
    /// Check if a value exists in storage
    public func exists() -> Bool {
        return keychain.fetch(for: key) != nil
    }
    
    /// Get the raw data from storage
    public func getRawData() -> Data? {
        return keychain.fetch(for: key)
    }
}

// MARK: - Private Helper Methods
private extension EliteSecure {
    
    @discardableResult
    func execute<T>(_ function: () throws -> T?) -> T? {
        do {
            return try function()
        } catch {
            print("EliteSecure: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Usage Examples
/**
 # EliteSecure Property Wrapper Implementation!
 
 ## 🚀 What Makes Our Implementation Special:
 
 ### ✅ **Smart Caching**
 - Automatic caching for performance
 - Force refresh when needed
 - Memory efficient
 
 ### ✅ **Flexible Encoding**
 - Custom JSONEncoder/JSONDecoder support
 - Date formatting, key strategies, etc.
 - Full control over serialization
 
 ### ✅ **Error Handling**
 - Graceful error handling
 - Detailed error logging
 - No crashes on keychain errors
 
 ### ✅ **Convenience Methods**
 - `refresh()` - Force reload from storage
 - `clear()` - Remove from storage
 - `exists()` - Check if value exists
 - `getRawData()` - Get raw data
 
 ## 1. Basic Usage
 
 ```swift
 class AuthManager {
     @EliteSecure("user_credentials") var credentials: UserCredentials?
     @EliteSecure("biometric_settings") var biometricSettings: BiometricSettings?
     
     struct UserCredentials: Codable {
         let accessToken: String
         let refreshToken: String
         let expiresIn: Int
         let createdAt: Date
         
         var isExpired: Bool {
             let expirationDate = createdAt.addingTimeInterval(TimeInterval(expiresIn))
             return Date() > expirationDate
         }
     }
     
     struct BiometricSettings: Codable {
         var isEnabled: Bool = false
         var biometricType: String = "none"
         var fallbackToPIN: Bool = true
     }
     
     func saveCredentials(_ creds: UserCredentials) {
         credentials = creds
     }
     
     func enableBiometrics(type: String) {
         biometricSettings = BiometricSettings(
             isEnabled: true,
             biometricType: type,
             fallbackToPIN: true
         )
     }
     
     func clearAllData() {
         credentials = nil
         biometricSettings = nil
     }
 }
 ```
 
 ## 2. Custom Encoding/Decoding
 
 ```swift
 class AdvancedAuthManager {
     // Custom encoder with specific date format
     private let customEncoder: JSONEncoder = {
         let encoder = JSONEncoder()
         encoder.dateEncodingStrategy = .iso8601
         encoder.keyEncodingStrategy = .convertToSnakeCase
         return encoder
     }()
     
     private let customDecoder: JSONDecoder = {
         let decoder = JSONDecoder()
         decoder.dateDecodingStrategy = .iso8601
         decoder.keyDecodingStrategy = .convertFromSnakeCase
         return decoder
     }()
     
     @EliteSecure("user_session", encoder: customEncoder, decoder: customDecoder) var session: UserSession?
     
     struct UserSession: Codable {
         let userId: String
         let isLoggedIn: Bool
         let lastActivity: Date
         let sessionToken: String?
     }
     
     func login(userId: String, token: String) {
         session = UserSession(
             userId: userId,
             isLoggedIn: true,
             lastActivity: Date(),
             sessionToken: token
         )
     }
     
     func logout() {
         session = nil
     }
 }
 ```
 
 ## 3. Advanced Usage with Convenience Methods
 
 ```swift
 class SecureDataManager {
     @EliteSecure("encryption_key") var encryptionKey: Data?
     @EliteSecure("pin_data") var pinData: PINData?
     @EliteSecure("app_secrets") var appSecrets: AppSecrets?
     
     struct PINData: Codable {
         var pin: String
         var isSet: Bool = true
         var createdAt: Date = Date()
         var lastUsed: Date?
     }
     
     struct AppSecrets: Codable {
         var apiKey: String
         var secretToken: String
         var environment: String
     }
     
     func setupPIN(_ pin: String) {
         pinData = PINData(pin: pin)
     }
     
     func verifyPIN(_ inputPin: String) -> Bool {
         guard let pinData = pinData else { return false }
         
         let isValid = pinData.pin == inputPin
         
         if isValid {
             // Update last used time
             var updatedData = pinData
             updatedData.lastUsed = Date()
             self.pinData = updatedData
         }
         
         return isValid
     }
     
     func refreshAllData() {
         // Force refresh all cached values
         pinData?.refresh()
         encryptionKey?.refresh()
         appSecrets?.refresh()
     }
     
     func clearSensitiveData() {
         encryptionKey = nil
         pinData = nil
         appSecrets = nil
     }
     
     func checkDataIntegrity() -> Bool {
         // Check if all required data exists
         return pinData?.exists() == true && 
                encryptionKey?.exists() == true
     }
 }
 ```
 
 ## 4. SwiftUI Integration
 
 ```swift
 struct SecuritySettingsView: View {
     @StateObject private var authManager = AuthManager()
     @StateObject private var dataManager = SecureDataManager()
     
     var body: some View {
         Form {
             Section("Authentication") {
                 HStack {
                     Text("Credentials")
                     Spacer()
                     Text(authManager.credentials != nil ? "Saved" : "Not Set")
                 }
                 
                 HStack {
                     Text("Biometric Auth")
                     Spacer()
                     if let settings = authManager.biometricSettings {
                         Text(settings.isEnabled ? "Enabled" : "Disabled")
                     } else {
                         Text("Not Set")
                     }
                 }
             }
             
             Section("Security") {
                 HStack {
                     Text("PIN Code")
                     Spacer()
                     Text(dataManager.pinData != nil ? "Set" : "Not Set")
                 }
                 
                 HStack {
                     Text("Encryption Key")
                     Spacer()
                     Text(dataManager.encryptionKey != nil ? "Available" : "Missing")
                 }
             }
             
             Section("Actions") {
                 Button("Refresh All Data") {
                     authManager.credentials?.refresh()
                     authManager.biometricSettings?.refresh()
                 }
                 
                 Button("Clear All Data") {
                     authManager.clearAllData()
                     dataManager.clearSensitiveData()
                 }
                 .foregroundColor(.red)
             }
         }
     }
 }
 ```
 
 ## 5. Error Handling and Debugging
 
 ```swift
 class DebugSecureManager {
     @EliteSecure("debug_data") var debugData: DebugData?
     
     struct DebugData: Codable {
         var lastError: String?
         var errorCount: Int = 0
         var lastOperation: String?
         var timestamp: Date = Date()
     }
     
     func logError(_ error: Error, operation: String) {
         var data = debugData ?? DebugData()
         data.lastError = error.localizedDescription
         data.errorCount += 1
         data.lastOperation = operation
         data.timestamp = Date()
         debugData = data
     }
     
     func getDebugInfo() -> String {
         guard let data = debugData else { return "No debug data" }
         return """
         Last Error: \(data.lastError ?? "None")
         Error Count: \(data.errorCount)
         Last Operation: \(data.lastOperation ?? "None")
         Timestamp: \(data.timestamp)
         """
     }
     
     func clearDebugData() {
         debugData = nil
     }
 }
 ```
 
 ## 🎯 Why Our Implementation is Awesome:
 
 ### ✅ **Performance**
 - Smart caching reduces keychain calls
 - Lazy loading for efficiency
 - Memory optimized
 
 ### ✅ **Flexibility**
 - Custom encoders/decoders
 - Multiple convenience methods
 - Full control over serialization
 
 ### ✅ **Reliability**
 - Graceful error handling
 - No crashes on keychain errors
 - Detailed error logging
 
 ### ✅ **Developer Experience**
 - Simple to use
 - Powerful when needed
 - Great debugging support
 
 ### ✅ **Security**
 - Uses our thread-safe SecureStorage
 - Proper keychain integration
 - Secure by design
 
 ## 💡 Best Practices:
 
 1. **Use for sensitive data only** - Credentials, tokens, PINs
 2. **Provide meaningful keys** - Use descriptive key names
 3. **Handle nil values** - Always check before use
 4. **Use custom encoders** - For specific date formats, etc.
 5. **Refresh when needed** - Use refresh() for fresh data
 6. **Clear when done** - Remove sensitive data when not needed
 7. **Monitor errors** - Check logs for keychain issues
 8. **Test thoroughly** - Keychain operations can fail
 
 ## 🔧 Architecture:
 
 ```
 EliteSecure Property Wrapper
 ├── Smart Caching (cachedValue)
 ├── Flexible Encoding (JSONEncoder/JSONDecoder)
 ├── SecureStorage Integration
 ├── Convenience Methods
 └── Error Handling
 ```
 */ 
