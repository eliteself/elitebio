//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import Foundation

// MARK: - Simple UserDefaults Property Wrapper
@propertyWrapper
public struct UserDefault<T> {
    private let key: String
    private let defaultValue: T
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

// MARK: - Usage Examples
/**
 # UserDefault Property Wrapper - Simple & Effective
 
 ## 🚀 Key Features:
 - **Simple UserDefaults access** - Works like a normal property
 - **Default values support** - Always has a fallback value
 - **Type safety** - Generic type ensures type safety
 - **Perfect for app settings** - Non-sensitive data storage
 
 ## 1. Basic Usage Examples
 
 ```swift
 class AppSettings {
     @UserDefault(key: "is_first_launch", defaultValue: true) var isFirstLaunch: Bool
     @UserDefault(key: "theme_mode", defaultValue: "light") var themeMode: String
     @UserDefault(key: "notification_enabled", defaultValue: true) var notificationsEnabled: Bool
     @UserDefault(key: "user_id", defaultValue: "") var userId: String
     @UserDefault(key: "last_sync_date", defaultValue: Date()) var lastSyncDate: Date
     @UserDefault(key: "app_version", defaultValue: "1.0.0") var appVersion: String
     @UserDefault(key: "launch_count", defaultValue: 0) var launchCount: Int
     @UserDefault(key: "preferred_language", defaultValue: "en") var language: String
     
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
 
 ## 2. SwiftUI Integration
 
 ```swift
 struct SettingsView: View {
     @StateObject private var appSettings = AppSettings()
     
     var body: some View {
         Form {
             Section("App Settings") {
                 HStack {
                     Text("Language")
                     Spacer()
                     Text(appSettings.language.uppercased())
                 }
                 
                 HStack {
                     Text("Theme")
                     Spacer()
                     Text(appSettings.themeMode.capitalized)
                 }
                 
                 HStack {
                     Text("Launch Count")
                     Spacer()
                     Text("\(appSettings.launchCount)")
                 }
                 
                 HStack {
                     Text("App Version")
                     Spacer()
                     Text(appSettings.appVersion)
                 }
                 
                 Toggle("Notifications", isOn: $appSettings.notificationsEnabled)
                 Toggle("First Launch", isOn: $appSettings.isFirstLaunch)
             }
             
             Section("Actions") {
                 Button("Reset Settings") {
                     appSettings.resetSettings()
                 }
                 .foregroundColor(.red)
             }
         }
     }
 }
 ```
 
 ## 3. Feature Flags and Toggles
 
 ```swift
 class FeatureManager {
     @UserDefault(key: "beta_features_enabled", defaultValue: false) var betaFeaturesEnabled: Bool
     @UserDefault(key: "analytics_enabled", defaultValue: true) var analyticsEnabled: Bool
     @UserDefault(key: "debug_mode", defaultValue: false) var debugMode: Bool
     @UserDefault(key: "auto_sync", defaultValue: true) var autoSync: Bool
     
     func toggleBetaFeatures() {
         betaFeaturesEnabled.toggle()
     }
     
     func enableDebugMode() {
         debugMode = true
     }
     
     func disableAnalytics() {
         analyticsEnabled = false
     }
 }
 ```
 
 ## 4. User Preferences
 
 ```swift
 class UserPreferences {
     @UserDefault(key: "font_size", defaultValue: 16) var fontSize: Int
     @UserDefault(key: "sound_enabled", defaultValue: true) var soundEnabled: Bool
     @UserDefault(key: "vibration_enabled", defaultValue: true) var vibrationEnabled: Bool
     @UserDefault(key: "auto_lock_timeout", defaultValue: 300) var autoLockTimeout: Int
     @UserDefault(key: "preferred_currency", defaultValue: "USD") var preferredCurrency: String
     
     func increaseFontSize() {
         fontSize = min(fontSize + 2, 24)
     }
     
     func decreaseFontSize() {
         fontSize = max(fontSize - 2, 12)
     }
     
     func setAutoLockTimeout(_ seconds: Int) {
         autoLockTimeout = max(seconds, 60) // Minimum 60 seconds
     }
 }
 ```
 
 ## 5. App State Management
 
 ```swift
 class AppState {
     @UserDefault(key: "last_active_date", defaultValue: Date()) var lastActiveDate: Date
     @UserDefault(key: "session_count", defaultValue: 0) var sessionCount: Int
     @UserDefault(key: "onboarding_completed", defaultValue: false) var onboardingCompleted: Bool
     @UserDefault(key: "terms_accepted", defaultValue: false) var termsAccepted: Bool
     @UserDefault(key: "privacy_policy_accepted", defaultValue: false) var privacyPolicyAccepted: Bool
     
     func markAppActive() {
         lastActiveDate = Date()
         sessionCount += 1
     }
     
     func completeOnboarding() {
         onboardingCompleted = true
     }
     
     func acceptTerms() {
         termsAccepted = true
     }
     
     func acceptPrivacyPolicy() {
         privacyPolicyAccepted = true
     }
 }
 ```
 
 ## 6. Analytics and Tracking
 
 ```swift
 class AnalyticsManager {
     @UserDefault(key: "total_app_opens", defaultValue: 0) var totalAppOpens: Int
     @UserDefault(key: "last_analytics_send", defaultValue: Date()) var lastAnalyticsSend: Date
     @UserDefault(key: "user_segment", defaultValue: "general") var userSegment: String
     @UserDefault(key: "ab_test_group", defaultValue: "control") var abTestGroup: String
     
     func incrementAppOpens() {
         totalAppOpens += 1
     }
     
     func updateUserSegment(_ segment: String) {
         userSegment = segment
     }
     
     func assignABTestGroup(_ group: String) {
         abTestGroup = group
     }
     
     func markAnalyticsSent() {
         lastAnalyticsSend = Date()
     }
 }
 ```
 
 ## 7. Migration and Version Management
 
 ```swift
 class MigrationManager {
     @UserDefault(key: "needs_migration", defaultValue: true) var needsMigration: Bool
     @UserDefault(key: "migration_version", defaultValue: "1.0") var migrationVersion: String
     @UserDefault(key: "last_migration_date", defaultValue: Date()) var lastMigrationDate: Date
     @UserDefault(key: "data_version", defaultValue: "1.0") var dataVersion: String
     
     func performMigration() {
         if needsMigration {
             // Migration logic here
             needsMigration = false
             migrationVersion = "2.0"
             lastMigrationDate = Date()
             dataVersion = "2.0"
         }
     }
     
     func checkForUpdates() -> Bool {
         return needsMigration
     }
 }
 ```
 
 ## 8. PIN Management (Non-sensitive tracking)
 
 ```swift
 class PINManager {
     @UserDefault(key: "pin_attempts", defaultValue: 0) var pinAttempts: Int
     @UserDefault(key: "last_pin_attempt", defaultValue: Date()) var lastPinAttempt: Date
     @UserDefault(key: "pin_lockout_until", defaultValue: Date()) var pinLockoutUntil: Date
     @UserDefault(key: "pin_enabled", defaultValue: false) var pinEnabled: Bool
     
     func incrementPinAttempts() {
         pinAttempts += 1
         lastPinAttempt = Date()
         
         if pinAttempts >= 5 {
             pinLockoutUntil = Date().addingTimeInterval(300) // 5 minutes
         }
     }
     
     func resetPinAttempts() {
         pinAttempts = 0
     }
     
     func isLockedOut() -> Bool {
         return Date() < pinLockoutUntil
     }
     
     func enablePIN() {
         pinEnabled = true
     }
     
     func disablePIN() {
         pinEnabled = false
         resetPinAttempts()
     }
 }
 ```
 
 ## 🎯 When to Use UserDefault:
 
 ### ✅ **Perfect For:**
 - App preferences and settings
 - UI state and theme settings
 - Non-sensitive user data
 - App configuration
 - Analytics and tracking data
 - Default values needed
 - Launch counts and usage statistics
 - Feature flags and toggles
 - User preferences
 - App state management
 - Migration tracking
 
 ### ❌ **Not For:**
 - User credentials and tokens
 - PIN codes and passwords
 - Encryption keys
 - Biometric settings
 - Session data
 - Any sensitive information
 - Authentication tokens
 - Secure app settings
 
 ## 🚀 Benefits:
 
 ### ✅ **Simple & Predictable**
 - Works like a normal property
 - No complex setup needed
 - Clear, readable code
 
 ### ✅ **Default Values**
 - Always has a fallback value
 - No nil checking required
 - Safe to use immediately
 
 ### ✅ **Performance**
 - Fast, direct UserDefaults access
 - No caching overhead
 - Efficient for frequent access
 
 ### ✅ **Type Safety**
 - Generic type ensures type safety
 - Compile-time type checking
 - No runtime type errors
 
 ### ✅ **Developer Experience**
 - Easy to understand and use
 - Familiar property wrapper pattern
 - No learning curve
 
 ## 💡 Best Practices:
 
 1. **Use descriptive keys** - Make keys self-documenting
 2. **Provide sensible defaults** - Always provide meaningful default values
 3. **Group related settings** - Keep related settings in the same class
 4. **Use for non-sensitive data only** - Never store sensitive information
 5. **Plan for migration** - Consider data migration between app versions
 6. **Use in classes** - Works best with reference types
 7. **Keep it simple** - Don't over-engineer simple settings
 8. **Document your keys** - Keep a list of all UserDefaults keys used
 
 ## 🔧 Architecture:
 
 ```
 UserDefault Property Wrapper
 ├── UserDefaults.standard
 ├── Default values
 ├── Type safety
 └── Simple access
 ```
 */ 