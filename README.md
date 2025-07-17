# elitebio Framework

A comprehensive, secure, and customizable biometric authentication framework for iOS and watchOS applications.

## 🌟 Features

- **🔐 Biometric Authentication**: Face ID, Touch ID, and Apple Watch support
- **🛡️ Secure Storage**: Keychain integration with EliteSecure
- **🎨 Customizable UI**: SwiftUI components and customizable themes
- **⚡ Easy Integration**: Simple API with comprehensive error handling
- **📱 Multi-Platform**: iOS & watchOS support
- **🧪 Extensive Examples**: Complete implementation examples
- **📚 Full Documentation**: Comprehensive guides and tutorials

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
├── Core/
│   ├── EliteBiometric.swift          # Main biometric manager
│   ├── KeychainManager.swift         # Secure keychain operations
│   ├── EliteSecure.swift            # Advanced security features
│   └── CredentialsRepository.swift  # Credential management
├── Extensions/
│   ├── EliteBiometricCustomizable.swift  # Customizable components - 🔨
│   └── KeychainPropertyWrapper.swift     # Property wrapper for keychain
└── Examples/
    ├── EliteSecureExample.swift              # Security examples
    └── StorageExample.swift                  # Storage examples
```

## 🎯 Quick Start

### Basic Biometric Authentication

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

### SwiftUI Integration

```swift
import SwiftUI
import EliteBiometric

struct BiometricAuthView: View {
    @StateObject private var biometricManager = EliteBiometric()
    
    var body: some View {
        VStack {
            Button("Authenticate with Biometrics") {
                Task {
                    await authenticate()
                }
            }
        }
    }
    
    private func authenticate() async {
        // Implementation here
    }
}
```

## 🔧 Advanced Usage

### Customizable Components

```swift
import EliteBiometricExtensions

// Use customizable biometric components
let customizableAuth = EliteBiometricCustomizable()
customizableAuth.configure(with: customConfig)
```

### Property Wrapper for Keychain

```swift
import EliteBiometricExtensions

class SecureDataManager {
    @KeychainProperty(key: "user_token")
    var userToken: String?
    
    @KeychainProperty(key: "user_pin")
    var userPIN: String?
}
```

## 🛡️ Security Features

- **Secure Keychain Storage**: All sensitive data stored in iOS Keychain
- **Biometric Lockout**: Automatic lockout after failed attempts
- **Device Passcode Fallback**: Graceful fallback to device passcode
- **Error Handling**: Comprehensive error handling and recovery
- **Audit Trail**: Detailed logging for security audits

## 📱 Platform Support

| Platform | Minimum Version | Features |
|----------|----------------|----------|
| iOS | 17.0+ | Face ID, Touch ID, Keychain, Optic ID |
| watchOS | 10.0+ | Apple Watch authentication |

## 🧪 Testing

Run the test suite:

```bash
swift test
```

## 📚 Documentation

For detailed documentation, see:
- [API Reference](docs/API.md)
- [Customization Guide](docs/Customization.md)
- [Security Best Practices](docs/Security.md)
- [Migration Guide](docs/Migration.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apple for LocalAuthentication framework
- SwiftUI community for inspiration
- Security researchers for best practices

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/eliteself/elitebio/issues)
- **Discussions**: [GitHub Discussions](https://github.com/eliteself/elitebio/discussions)
- **Email**: alexandra.beznosova@email.com

---

**Made with 🤍 by eliteself.tech** 
