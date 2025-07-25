//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import Foundation

// MARK: - Complete Property Wrapper Examples
/**
 # EliteBiometric - Complete Property Wrapper Solution
 
 ## 🚀 Two Property Wrappers for Complete Data Management:
 
 ### 1. UserDefault - For Non-Sensitive Data
 - **Simple UserDefaults access**
 - **Default values support**
 - **Perfect for app settings, preferences**
 
 ### 2. Codable Secure - For Sensitive Data
 - **Secure keychain storage**
 - **Smart caching**
 - **Perfect for credentials, tokens, PINs**
 
 ## 1. UserDefault Examples (UserDefaultPropertyWrapper.swift)
 
 ```swift
 class AppSettings {
     @UserDefault(key: "is_first_launch", defaultValue: true) var isFirstLaunch: Bool
     @UserDefault(key: "theme_mode", defaultValue: "light") var themeMode: String
     @UserDefault(key: "notification_enabled", defaultValue: true) var notificationsEnabled: Bool
     @UserDefault(key: "user_id", defaultValue: "") var userId: String
     @UserDefault(key: "last_sync_date", defaultValue: Date()) var lastSyncDate: Date
     @UserDefault(key: "app_version", defaultValue: "1.0.0") var appVersion: String
     @UserDefault(key: "launch_count", defaultValue: 0) var launchCount: Int
     
     func resetSettings() {
         isFirstLaunch = true
         themeMode = "light"
         notificationsEnabled = true
         userId = ""
         lastSyncDate = Date()
         launchCount = 0
     }
     
     func incrementLaunchCount() {
         launchCount += 1
     }
 }
 
 // Usage
 let settings = AppSettings()
 print(settings.isFirstLaunch) // true (default)
 settings.isFirstLaunch = false
 print(settings.isFirstLaunch) // false
 ```
 
 ## 2. Codable Secure Examples (Keychain.swift)
 
 ```swift
 class AuthManager {
     @Secure("user_credentials") var credentials: UserCredentials?
     @Secure("biometric_settings") var biometricSettings: BiometricSettings?
     @Secure("session_data") var session: SessionData?
     
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
         var biometricType: String = "none" // "faceid", "touchid", "none"
         var fallbackToPIN: Bool = true
         var maxRetryAttempts: Int = 3
     }
     
     struct SessionData: Codable {
         var sessionToken: String?
         var userId: String?
         var isLoggedIn: Bool = false
         var sessionDuration: Int = 3600
         var createdAt: Date = Date()
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
     
     func login(token: String, userId: String) {
         session = SessionData(
             sessionToken: token,
             userId: userId,
             isLoggedIn: true,
             createdAt: Date()
         )
     }
     
     func logout() {
         session = nil
     }
 }
 ```
 
 ## 3. Combined Usage - Complete App Manager
 
 ```swift
 class AppManager {
     // Non-sensitive data - UserDefaults (UserDefaultPropertyWrapper.swift)
     @UserDefault(key: "app_version", defaultValue: "1.0.0") var appVersion: String
     @UserDefault(key: "launch_count", defaultValue: 0) var launchCount: Int
     @UserDefault(key: "preferred_language", defaultValue: "en") var language: String
     @UserDefault(key: "theme_mode", defaultValue: "light") var themeMode: String
     @UserDefault(key: "notification_enabled", defaultValue: true) var notificationsEnabled: Bool
     @UserDefault(key: "last_sync_date", defaultValue: Date()) var lastSyncDate: Date
     
     // Sensitive data - Keychain (KeychainPropertyWrapper.swift)
     @Secure("user_session") var session: UserSession?
     @Secure("encryption_key") var encryptionKey: Data?
     @Secure("biometric_settings") var biometricSettings: BiometricSettings?
     @Secure("pin_code") var pinCode: String?
     
     struct UserSession: Codable {
         var userId: String
         var isLoggedIn: Bool
         var lastActivity: Date
         var sessionToken: String?
     }
     
     struct BiometricSettings: Codable {
         var isEnabled: Bool = false
         var biometricType: String = "none"
         var fallbackToPIN: Bool = true
     }
     
     func incrementLaunchCount() {
         launchCount += 1
     }
     
     func saveSession(userId: String, token: String) {
         session = UserSession(
             userId: userId,
             isLoggedIn: true,
             lastActivity: Date(),
             sessionToken: token
         )
     }
     
     func setupPIN(_ pin: String) {
         pinCode = pin
     }
     
     func enableBiometrics(type: String) {
         biometricSettings = BiometricSettings(
             isEnabled: true,
             biometricType: type,
             fallbackToPIN: true
         )
     }
     
     func clearSensitiveData() {
         session = nil
         encryptionKey = nil
         pinCode = nil
         biometricSettings = nil
     }
 }
 ```
 
 ## 4. SwiftUI Integration
 
 ```swift
 struct SettingsView: View {
     @StateObject private var appManager = AppManager()
     @StateObject private var authManager = AuthManager()
     
     var body: some View {
         Form {
             Section("App Settings") {
                 HStack {
                     Text("Language")
                     Spacer()
                     Text(appManager.language.uppercased())
                 }
                 
                 HStack {
                     Text("Theme")
                     Spacer()
                     Text(appManager.themeMode.capitalized)
                 }
                 
                 HStack {
                     Text("Launch Count")
                     Spacer()
                     Text("\(appManager.launchCount)")
                 }
                 
                 HStack {
                     Text("App Version")
                     Spacer()
                     Text(appManager.appVersion)
                 }
             }
             
             Section("Security") {
                 HStack {
                     Text("Biometric Auth")
                     Spacer()
                     if let settings = appManager.biometricSettings {
                         Text(settings.isEnabled ? "Enabled" : "Disabled")
                     } else {
                         Text("Not Set")
                     }
                 }
                 
                 HStack {
                     Text("PIN Code")
                     Spacer()
                     Text(appManager.pinCode != nil ? "Set" : "Not Set")
                 }
                 
                 HStack {
                     Text("Session")
                     Spacer()
                     Text(appManager.session?.isLoggedIn == true ? "Active" : "Inactive")
                 }
             }
             
             Section("Actions") {
                 Button("Clear Sensitive Data") {
                     appManager.clearSensitiveData()
                 }
                 .foregroundColor(.red)
             }
         }
     }
 }
 ```
 
 ## 5. Migration Examples
 
 ```swift
 class MigrationManager {
     @UserDefault(key: "needs_migration", defaultValue: true) var needsMigration: Bool
     @UserDefault(key: "migration_version", defaultValue: "1.0") var migrationVersion: String
     @Secure("migrated_data") var migratedData: MigratedData?
     
     struct MigratedData: Codable {
         var oldUserId: String
         var newUserId: String
         var migrationDate: Date
         var dataVersion: String
     }
     
     func performMigration() {
         if needsMigration {
             // Migration logic here
             let migratedData = MigratedData(
                 oldUserId: "old_user",
                 newUserId: "new_user",
                 migrationDate: Date(),
                 dataVersion: "2.0"
             )
             
             self.migratedData = migratedData
             needsMigration = false
             migrationVersion = "2.0"
         }
     }
 }
 ```
 
 ## 6. PIN Management Example
 
 ```swift
 class PINManager {
     @UserDefault(key: "pin_attempts", defaultValue: 0) var pinAttempts: Int
     @UserDefault(key: "last_pin_attempt", defaultValue: Date()) var lastPinAttempt: Date
     @Secure("pin_data") var pinData: PINData?
     
     struct PINData: Codable {
         var pin: String
         var isSet: Bool = true
         var createdAt: Date = Date()
         var lastUsed: Date?
     }
     
     func setPIN(_ pin: String) {
         pinData = PINData(pin: pin)
         pinAttempts = 0
     }
     
     func verifyPIN(_ inputPin: String) -> Bool {
         guard let pinData = pinData else { return false }
         
         let isValid = pinData.pin == inputPin
         
         if isValid {
             // Update last used time
             var updatedData = pinData
             updatedData.lastUsed = Date()
             self.pinData = updatedData
             pinAttempts = 0
         } else {
             pinAttempts += 1
             lastPinAttempt = Date()
         }
         
         return isValid
     }
     
     func isPINSet() -> Bool {
         return pinData?.isSet == true
     }
     
     func clearPIN() {
         pinData = nil
         pinAttempts = 0
     }
     
     func isLockedOut() -> Bool {
         return pinAttempts >= 5
     }
 }
 ```
 
 ## 🎯 When to Use Each:
 
 ### UserDefault - Use For:
 - ✅ App preferences and settings
 - ✅ UI state and theme settings
 - ✅ Non-sensitive user data
 - ✅ App configuration
 - ✅ Analytics and tracking data
 - ✅ Default values needed
 - ✅ Launch counts and usage statistics
 - ✅ Feature flags and toggles
 
 ### @Secure - Use For:
 - ✅ User credentials and tokens
 - ✅ PIN codes and passwords
 - ✅ Encryption keys
 - ✅ Biometric settings
 - ✅ Session data
 - ✅ Any sensitive information
 - ✅ Authentication tokens
 - ✅ Secure app settings
 
 ## 🚀 Benefits of This Complete Solution:
 
 ### ✅ **Right Tool for the Job**
 - UserDefaults for simple, non-sensitive data
 - Keychain for secure, sensitive data
 - Clear separation of concerns
 
 ### ✅ **Simple API**
 - Both work like normal properties
 - No complex async/await needed
 - Familiar property wrapper pattern
 
 ### ✅ **Performance**
 - UserDefault: Fast, direct UserDefaults access
 - Secure: Smart caching for keychain
 - Efficient data access patterns
 
 ### ✅ **Security**
 - UserDefault: Standard iOS persistence
 - Secure: Secure keychain storage
 - Proper data classification
 
 ### ✅ **Developer Experience**
 - Easy to understand and use
 - Clear when to use each
 - No learning curve
 - Comprehensive examples
 
 ## 🔧 Architecture Overview:
 
 ```
 EliteBiometric Property Wrappers
 ├── UserDefault (UserDefaultPropertyWrapper.swift)
 │   ├── UserDefaults.standard
 │   ├── Default values
 │   └── Simple access
 └── Secure (EliteKeychain.swift)
     ├── EliteKeychain
     ├── Smart caching
     ├── Thread safety
     └── Error handling
 ```
 
 ## 💡 Best Practices:
 
 1. **Use UserDefault for**: App settings, preferences, non-sensitive data
 2. **Use Secure for**: Credentials, tokens, PINs, sensitive data
 3. **Keep keys unique**: Use descriptive key names
 4. **Handle nil values**: Always check for nil before use
 5. **Clear sensitive data**: Set to nil when done
 6. **Use in classes**: Works best with reference types
 7. **Provide defaults**: Always provide sensible defaults for UserDefault
 8. **Migrate carefully**: Plan data migration between versions
 */
