# EliteBiometric Customizable Framework

A highly customizable biometric authentication framework for SwiftUI apps that provides beautiful, secure, and easy-to-integrate biometric authentication views.

## 🚀 Features

- **Highly Customizable**: Complete control over colors, fonts, spacing, animations, and behavior
- **Pre-built Configurations**: Ready-to-use themes for medical, banking, gaming, and more
- **Easy Integration**: Simple view modifier for quick setup
- **Advanced Error Handling**: Comprehensive error management with recovery suggestions
- **Flexible Layout**: Custom header and footer content support
- **Animation Control**: Configurable animations and visual feedback
- **Security Focused**: Built-in retry limits, lockout protection, and secure fallbacks

## 📦 Installation

Add the following files to your SwiftUI project:
- `EliteBiometric.swift` - Core biometric functionality

## 🎨 Quick Start

### Basic Usage

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome to My App")
                .font(.title)
        }
        .customBiometricAuth {
            print("✅ User authenticated!")
        } onFailure: { error in
            print("❌ Authentication failed: \(error)")
        }
    }
}
```

### Using Pre-built Configurations

```swift
// your name App
.customBiometricAuth(config: .appconfig) {
    // Handle success
} onFailure: { error in
    // Handle failure
}

// Banking App
.customBiometricAuth(config: .banking) {
    // Handle success
} onFailure: { error in
    // Handle failure
}

// Minimal App
.customBiometricAuth(config: .minimal) {
    // Handle success
}
```

## 🎛️ Configuration Options

### Visual Customization

```swift
let config = CustomBiometricConfig(
    // Colors
    backgroundColor: .blue,
    accentColor: .white,
    textColor: .white,
    secondaryTextColor: .gray,
    errorColor: .red,
    successColor: .green,
    
    // Content
    appName: "My App",
    welcomeMessage: "Welcome Back!",
    biometricPrompt: "Sign in securely",
    buttonText: "Continue",
    
    // Layout
    iconSize: 80,
    spacing: 24,
    cornerRadius: 12,
    buttonHeight: 50,
    padding: EdgeInsets(top: 40, leading: 20, bottom: 40, trailing: 20)
)
```

### Animation Customization

```swift
let config = CustomBiometricConfig(
    // Animation Settings
    enableAnimations: true,
    animationDuration: 0.3,
    pulseAnimation: true,
    shakeOnError: true
)
```

### Behavior Customization

```swift
let config = CustomBiometricConfig(
    // Behavior Settings
    autoAuthenticate: true,
    showCancelButton: true,
    showSettingsButton: true,
    allowFallback: true,
    maxRetryAttempts: 3,
    lockoutDuration: 300
)
```

## 🎨 Pre-built Configurations

### Banking App Configuration
```swift
CustomBiometricConfig.banking
```
- Dark theme for security
- Minimal animations
- Strict retry limits
- Professional appearance

### Minimal App Configuration
```swift
CustomBiometricConfig.minimal
```
- Clean, simple design
- No animations
- Auto-authentication
- Minimal UI elements

### Colorful App Configuration
```swift
CustomBiometricConfig.colorful
```
- Gradient backgrounds
- Vibrant colors
- Full animations
- Modern design

## 🔧 Advanced Customization

### Custom Header and Footer

```swift
CustomBiometricView(
    config: .yourConfig,
    headerContent: {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("EliteNet")
                .font(.title)
                .fontWeight(.bold)
        }
    },
    footerContent: {
        VStack(spacing: 8) {
            Text("Your data is protected")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("HIPAA Compliant")
                .font(.caption2)
                .foregroundColor(.green)
        }
    }
) {
    // Handle success
} onFailure: { error in
    // Handle failure
}
```

### Dynamic Configuration

```swift
struct DynamicAuthView: View {
    @State private var isDarkMode = false
    
    var dynamicConfig: CustomBiometricConfig {
        CustomBiometricConfig(
            backgroundColor: isDarkMode ? .black : Color(uiColor: .systemBackground),
            accentColor: isDarkMode ? .purple : .blue,
            textColor: isDarkMode ? .white : Color(uiColor: .label),
            welcomeMessage: isDarkMode ? "Welcome to Dark Mode" : "Welcome to Light Mode"
        )
    }
    
    var body: some View {
        VStack {
            Toggle("Dark Mode", isOn: $isDarkMode)
                .padding()
            
            CustomBiometricView(config: dynamicConfig) {
                // Handle success
            } onFailure: { error in
                // Handle failure
            }
        }
    }
}
```

## 🎯 Use Cases

### Medical Applications
```swift
// Perfect for HIPAA-compliant medical apps
.customBiometricAuth(config: .medical) {
    // Navigate to medical dashboard
} onFailure: { error in
    // Show medical-specific error handling
}
```

### Banking Applications
```swift
// Secure banking authentication
.customBiometricAuth(config: .banking) {
    // Access banking features
} onFailure: { error in
    // Handle banking security errors
}
```

### Gaming Applications
```swift
// Quick gaming login
let gamingConfig = CustomBiometricConfig(
    backgroundColor: AnyShapeStyle(LinearGradient(colors: [.blue, .black])),
    accentColor: .orange,
    welcomeMessage: "Ready to Play?",
    buttonText: "Start Gaming!",
    autoAuthenticate: true
)

.customBiometricAuth(config: gamingConfig) {
    // Start gaming session
}
```

### Productivity Applications
```swift
// Professional productivity apps
let productivityConfig = CustomBiometricConfig(
    backgroundColor: Color(uiColor: .systemBackground),
    accentColor: .blue,
    enableAnimations: false,
    autoAuthenticate: true,
    showCancelButton: false
)

.customBiometricAuth(config: productivityConfig) {
    // Access workspace
}
```

## 🔒 Security Features

### Retry Limits
```swift
let secureConfig = CustomBiometricConfig(
    maxRetryAttempts: 3,
    lockoutDuration: 300 // 5 minutes
)
```

### Fallback Options
```swift
let config = CustomBiometricConfig(
    allowFallback: true, // Allow passcode fallback
    showSettingsButton: true // Show settings access
)
```

### Error Handling
The framework includes comprehensive error handling with:
- Automatic retry logic
- Settings integration
- User-friendly error messages
- Recovery suggestions

## 🎨 Customization Examples

### Gradient Background
```swift
let gradientConfig = CustomBiometricConfig(
    backgroundColor: AnyShapeStyle(LinearGradient(
        colors: [.purple, .blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )),
    accentColor: .white,
    textColor: .white
)
```

### Custom Animations
```swift
let animatedConfig = CustomBiometricConfig(
    enableAnimations: true,
    animationDuration: 0.5,
    pulseAnimation: true,
    shakeOnError: true
)
```

### Professional Styling
```swift
let professionalConfig = CustomBiometricConfig(
    backgroundColor: Color(uiColor: .systemBackground),
    accentColor: .blue,
    cornerRadius: 8,
    buttonHeight: 44,
    enableAnimations: false,
    autoAuthenticate: true
)
```

## 📱 Integration Patterns

### App Launch Authentication
```swift
struct AppView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                MainAppView()
            } else {
                AuthenticationView()
            }
        }
        .customBiometricAuth(config: .appConfig) {
            isAuthenticated = true
        }
    }
}
```

### Feature-Specific Authentication
```swift
struct SecureFeatureView: View {
    var body: some View {
        VStack {
            Text("Secure Feature")
                .font(.title)
        }
        .customBiometricAuth(config: .banking) {
            // Enable secure feature
        }
    }
}
```

### Conditional Authentication
```swift
struct ConditionalAuthView: View {
    @AppStorage("requireBiometric") private var requireBiometric = true
    
    var body: some View {
        VStack {
            Text("My App")
                .font(.title)
        }
        .customBiometricAuth(
            config: requireBiometric ? .medical : .minimal
        ) {
            // Handle authentication
        }
    }
}
```

## 🐛 Troubleshooting

### Common Issues

1. **Biometric Not Available**
   - Check device capabilities
   - Verify biometric enrollment
   - Use settings button to guide users

2. **Authentication Failures**
   - Review retry limits
   - Check lockout duration
   - Verify fallback options

3. **UI Issues**
   - Ensure proper color contrast
   - Test in different orientations
   - Verify accessibility support

### Debug Mode
```swift
let debugConfig = CustomBiometricConfig(
    enableAnimations: false,
    autoAuthenticate: false,
    showCancelButton: true,
    showSettingsButton: true
)
```

## 📋 Best Practices

1. **Choose Appropriate Configuration**
   - Use `.medical` for healthcare apps
   - Use `.banking` for financial apps
   - Use `.minimal` for simple apps

2. **Handle Errors Gracefully**
   - Provide clear error messages
   - Offer recovery options
   - Guide users to settings when needed

3. **Test Thoroughly**
   - Test on different devices
   - Test with/without biometrics
   - Test error scenarios

4. **Consider Accessibility**
   - Ensure proper color contrast
   - Support VoiceOver
   - Provide alternative authentication

## 📞 Support

For questions, issues, or feature requests:
- samples of usage will be provided here
- Check the examples in `.swift`
- Review error handling in `.swift`
- Test with different configurations

## 🎉 Conclusion

The EliteBiometric Customizable Framework provides a powerful, flexible, and secure way to implement biometric authentication in your SwiftUI apps. With pre-built configurations, extensive customization options, and comprehensive error handling, you can create beautiful and secure authentication experiences tailored to your app's needs. 
