//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import Foundation
import EliteBiometricExtensions
import EliteBiometric

// MARK: - Example User Settings Class
final class UserSettings {
    // MARK: - Keychain Properties
    @KeychainString(key: "com.elitenet.user.email")
    var userEmail: String?
    
    @KeychainString(key: "com.elitenet.user.username")
    var username: String?
    
    @KeychainBool(key: "com.elitenet.user.rememberMe", defaultValue: false)
    var rememberMe: Bool
    
    @KeychainInt(key: "com.elitenet.user.loginCount", defaultValue: 0)
    var loginCount: Int
    
    @KeychainDouble(key: "com.elitenet.user.lastLoginTime", defaultValue: 0.0)
    var lastLoginTime: Double
    
    // MARK: - Complex Object Storage
    @KeychainStored(key: "com.elitenet.user.preferences")
    var userPreferences: UserPreferences?
    
    // MARK: - App Settings
    @KeychainBool(key: "com.elitenet.app.firstLaunch", defaultValue: true)
    var isFirstLaunch: Bool
    
    @KeychainString(key: "com.elitenet.app.language", defaultValue: "en")
    var language: String?
    
    @KeychainBool(key: "com.elitenet.app.darkMode", defaultValue: false)
    var isDarkMode: Bool
    
    // MARK: - API Configuration
    @KeychainString(key: "com.elitenet.api.baseURL")
    var apiBaseURL: String?
    
    @KeychainInt(key: "com.elitenet.api.timeout", defaultValue: 30)
    var apiTimeout: Int
}

// MARK: - Example User Preferences Model
struct UserPreferences: Codable {
    let theme: String
    let notificationsEnabled: Bool
    let autoRefresh: Bool
    let refreshInterval: Int
    
    init(
        theme: String = "light",
        notificationsEnabled: Bool = true,
        autoRefresh: Bool = true,
        refreshInterval: Int = 300
    ) {
        self.theme = theme
        self.notificationsEnabled = notificationsEnabled
        self.autoRefresh = autoRefresh
        self.refreshInterval = refreshInterval
    }
}

// MARK: - Example Usage
final class StorageExample {
    static func demonstrateUsage() {
        let settings = UserSettings()
        
        // Store user information
        settings.userEmail = "user@example.com"
        settings.username = "john_doe"
        settings.rememberMe = true
        settings.loginCount = 42
        settings.lastLoginTime = Date().timeIntervalSince1970
        
        // Store complex object
        let preferences = UserPreferences(
            theme: "dark",
            notificationsEnabled: true,
            autoRefresh: true,
            refreshInterval: 600
        )
        settings.userPreferences = preferences
        
        // Store app settings
        settings.isFirstLaunch = false
        settings.language = "es"
        settings.isDarkMode = true
        
        // Store API configuration
        settings.apiBaseURL = "https://api.elitenet.com"
        settings.apiTimeout = 45
        
        // Read values
        print("User email: \(settings.userEmail ?? "Not set")")
        print("Remember me: \(settings.rememberMe)")
        print("Login count: \(settings.loginCount)")
        print("Dark mode: \(settings.isDarkMode)")
        print("API timeout: \(settings.apiTimeout)")
        
        if let preferences = settings.userPreferences {
            print("Theme: \(preferences.theme)")
            print("Notifications: \(preferences.notificationsEnabled)")
        }
    }
    
    static func demonstrateCredentialsStorage() {
        // Example of storing credentials using the repository
        let credentialsRepository = CredentialsRepository()
        
        // Create credentials
        let credentials = Credentials(
            accessToken: "eyJhbGciOiJSUzI1NiIs...",
            refreshToken: "def50200...",
            expiresIn: 3600,
            tokenType: "Bearer",
            userId: "user123"
        )
        
        do {
            // Save credentials
            try credentialsRepository.saveCredentials(credentials)
            print("Credentials saved successfully")
            
            // Check if credentials exist and are valid
            if credentialsRepository.hasValidCredentials() {
                print("Valid credentials found")
                
                // Load credentials
                if let loadedCredentials = try credentialsRepository.getValidCredentials() {
                    print("Access token: \(loadedCredentials.accessToken)")
                    print("User ID: \(loadedCredentials.userId ?? "None")")
                    print("Expires in: \(loadedCredentials.expiresIn) seconds")
                }
            }
            
            // Delete credentials
            try credentialsRepository.deleteCredentials()
            print("Credentials deleted")
            
        } catch {
            print("Error: \(error)")
        }
    }
}

// MARK: - Secure Settings Manager
class SecureSettingsManager {
    // MARK: - Singleton
    static let shared = SecureSettingsManager()
    
    // MARK: - Keychain Properties
    @KeychainStored(key: "com.elitenet.credentials")
    private var storedCredentials: Credentials?
    
    @KeychainString(key: "com.elitenet.user.id")
    var currentUserId: String?
    
    @KeychainBool(key: "com.elitenet.user.isLoggedIn", defaultValue: false)
    var isLoggedIn: Bool
    
    @KeychainString(key: "com.elitenet.user.sessionId")
    var sessionId: String?
    
    private init() {}
    
    // MARK: - Credentials Management
    func saveCredentials(_ credentials: Credentials) {
        storedCredentials = credentials
        currentUserId = credentials.userId
        isLoggedIn = true
        sessionId = UUID().uuidString
    }
    
    func getCredentials() -> Credentials? {
        return storedCredentials
    }
    
    func clearCredentials() {
        storedCredentials = nil
        currentUserId = nil
        isLoggedIn = false
        sessionId = nil
    }
    
    func hasValidCredentials() -> Bool {
        guard let credentials = storedCredentials else { return false }
        return !credentials.isExpired
    }
    
    func getValidCredentials() -> Credentials? {
        guard let credentials = storedCredentials, !credentials.isExpired else {
            return nil
        }
        return credentials
    }
} 
