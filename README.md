# EliteBiometric Framework

A **simple, secure, and powerful** biometric authentication framework for iOS and watchOS applications with clean property wrapper APIs.

## 🌟 Features

- **🔐 Biometric Authentication**: Face ID, Touch ID, and Apple Watch support
- **🛡️ Secure Storage**: EliteSecure property wrapper for keychain storage
- **⚙️ Simple Preferences**: UserDefault property wrapper for app settings
- **⚡ Easy Integration**: Clean property wrapper APIs
- **📱 Multi-Platform**: iOS 17+ & watchOS 10+ support
- **🧪 Comprehensive Examples**: Complete implementation examples
- **📚 Full Documentation**: Extensive guides and tutorials

## 📋 Requirements

- iOS 17.0+ / watchOS 10.0+
- Swift 5.9+
- Xcode 15.0+

## 🚀 Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/eliteself/elitebio.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version you want to use

## 📦 Package Structure

```
EliteBiometric/
├─ Core/
   ├── EliteBiometric.swift          # Main biometric manager
   ├── EliteKeychain.swift           # Internal keychain operations
   ├── EliteSecure.swift             # Secure property wrapper
   ├── UserDefault.swift             # Preferences property wrapper
   └── CredentialsRepository.swift   # Credential management

```

## 🎯 Quick Start

### 1. Basic Biometric Authentication

```swift
import EliteBiometric

class AuthenticationManager: ObservableObject {
    private let biometricManager = EliteBiometric()
    
    func authenticate() async {
        do {
            let success = try await biometricManager.authenticate()
            if success {
                print("Authentication successful!")
            }
        } catch {
            print("Authentication failed: \(error)")
        }
    }
}
```

### 2. Secure Data Storage with EliteSecure

```swift
import EliteBiometric

class AuthManager {
    @EliteSecure("user_credentials") var credentials: UserCredentials?
    @EliteSecure("biometric_settings") var biometricSettings: BiometricSettings?
    
        @UserDefault(
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

### 3. App Preferences with UserDefault

```swift
import EliteBiometric

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
```

### 4. Combined Usage

```swift
import EliteBiometric

class AppManager {
    // Non-sensitive data - UserDefaults
    @UserDefault(key: "app_version", defaultValue: "1.0.0") var appVersion: String
    @UserDefault(key: "launch_count", defaultValue: 0) var launchCount: Int
    @UserDefault(key: "preferred_language", defaultValue: "en") var language: String
    
    // Sensitive data - Keychain
    @EliteSecure("user_session") var session: UserSession?
    @EliteSecure("encryption_key") var encryptionKey: Data?
    
    struct UserSession: Codable {
        var userId: String
        var isLoggedIn: Bool
        var lastActivity: Date
    }
    
    func incrementLaunchCount() {
        launchCount += 1
    }
    
    func saveSession(userId: String) {
        session = UserSession(
            userId: userId,
            isLoggedIn: true,
            lastActivity: Date()
        )
    }
}
```

## 🔧 Advanced Usage

### Custom Configuration

```swift
let config = BiometricConfig(
    reason: "Authenticate to access your account",
    fallbackTitle: "Use Passcode",
    cancelTitle: "Cancel",
    allowDevicePasscode: true,
    allowBiometricFallback: true,
    maxRetryAttempts: 3,
    lockoutDuration: 300
)

let success = try await biometricManager.authenticate(config: config)
```

### EliteSecure Convenience Methods

```swift
class SecureDataManager {
    @EliteSecure("pin_data") var pinData: PINData?
    @EliteSecure("encryption_key") var encryptionKey: Data?
    
    struct PINData: Codable {
        var pin: String
        var isSet: Bool = true
        var createdAt: Date = Date()
        var lastUsed: Date?
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
    }
    
    func clearSensitiveData() {
        encryptionKey = nil
        pinData = nil
    }
    
    func checkDataIntegrity() -> Bool {
        // Check if all required data exists
        return pinData?.exists() == true && 
               encryptionKey?.exists() == true
    }
}
```

## 🛡️ Security Features

- **Secure Keychain Storage**: All sensitive data stored in iOS Keychain
- **Biometric Lockout**: Automatic lockout after failed attempts
- **Device Passcode Fallback**: Graceful fallback to device passcode
- **Thread-Safe Operations**: All operations are thread-safe
- **Smart Caching**: Performance optimization with intelligent caching
- **Error Handling**: Graceful error handling with detailed logging

## 🎯 Property Wrapper APIs

### EliteSecure - For Sensitive Data

```swift
@EliteSecure("key_name") var value: Type?

// With custom encoders
@EliteSecure("key_name", encoder: customEncoder, decoder: customDecoder) var value: Type?

// Convenience methods
value?.refresh()     // Force refresh from storage
value?.clear()       // Remove from storage
value?.exists()      // Check if exists
value?.getRawData()  // Get raw data
```

### UserDefault - For App Preferences

```swift
@UserDefault(key: "key_name", defaultValue: defaultValue) var value: Type

// Works like a normal property
value = newValue
let currentValue = value
```

## 💡 Best Practices

### When to Use Each Property Wrapper:

#### ✅ Use EliteSecure For:
- User credentials and tokens
- PIN codes and passwords
- Encryption keys
- Biometric settings
- Session data
- Any sensitive information

#### ✅ Use UserDefault For:
- App preferences and settings
- UI state and theme settings
- Non-sensitive user data
- App configuration
- Analytics and tracking data
- Default values needed

### Security Guidelines:

1. **Never store sensitive data in UserDefaults**
2. **Always use EliteSecure for credentials**
3. **Provide meaningful default values**
4. **Handle nil values appropriately**
5. **Use descriptive key names**
6. **Clear sensitive data when not needed**

## 🔧 Architecture

```
EliteBiometric Framework
├── EliteBiometric.swift (Main biometric manager)
├── EliteSecure.swift (Secure property wrapper)
├── UserDefault.swift (Preferences property wrapper)
├── EliteKeychain.swift (Internal keychain implementation)
└── CredentialsRepository.swift (Credential management)
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support, email alexandra.beznosova@gmail.com or create an issue in this repository.

---

**Built with 🤍 by eliteself.tech** 
