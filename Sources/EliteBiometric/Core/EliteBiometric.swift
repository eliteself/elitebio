//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import Foundation
import LocalAuthentication
#if canImport(UIKit)
import UIKit
#endif

#if os(iOS) || os(watchOS)
import Combine
#endif

// MARK: - Biometric Types
public enum BiometricType: String, CaseIterable {
    case none = "None"
    case touchID = "Touch ID"
    case faceID = "Face ID"
    case watch = "Apple Watch"
    
    public var icon: String {
        switch self {
        case .none: return "lock.slash"
        case .touchID: return "touchid"
        case .faceID: return "faceid"
        case .watch: return "watch"
        }
    }
    
    public var displayName: String {
        switch self {
        case .none: return "No Biometrics"
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        case .watch: return "Apple Watch"
        }
    }
}

// MARK: - Authentication State
public enum BiometricAuthState: Equatable {
    case notAuthenticated
    case authenticating
    case authenticated
    case failed(String)
    case notAvailable(String)
    case lockedOut(String)
}

// MARK: - Biometric Configuration
public struct BiometricConfig {
    public let reason: String
    public let fallbackTitle: String?
    public let cancelTitle: String
    public let allowDevicePasscode: Bool
    public let allowBiometricFallback: Bool
    public let maxRetryAttempts: Int
    public let lockoutDuration: TimeInterval
    
    public static let `default` = BiometricConfig(
        reason: "Authenticate to access the app",
        fallbackTitle: "Use Passcode",
        cancelTitle: "Cancel",
        allowDevicePasscode: true,
        allowBiometricFallback: true,
        maxRetryAttempts: 3,
        lockoutDuration: 300 // 5 minutes
    )
    
    public init(
        reason: String = "Authenticate to access the app",
        fallbackTitle: String? = "Use Passcode",
        cancelTitle: String = "Cancel",
        allowDevicePasscode: Bool = true,
        allowBiometricFallback: Bool = true,
        maxRetryAttempts: Int = 3,
        lockoutDuration: TimeInterval = 300
    ) {
        self.reason = reason
        self.fallbackTitle = fallbackTitle
        self.cancelTitle = cancelTitle
        self.allowDevicePasscode = allowDevicePasscode
        self.allowBiometricFallback = allowBiometricFallback
        self.maxRetryAttempts = maxRetryAttempts
        self.lockoutDuration = lockoutDuration
    }
}

#if os(iOS) || os(watchOS)

// MARK: - Biometric Manager Protocol
public protocol BiometricManagerProtocol {
    var biometricType: BiometricType { get }
    var isAvailable: Bool { get }
    var authState: CurrentValueSubject<BiometricAuthState, Never> { get }
    
    func authenticate(config: BiometricConfig) async throws -> Bool
    func checkAvailability() -> Bool
    func resetLockout()
}

// MARK: - Elite Biometric Manager
public class EliteBiometric: BiometricManagerProtocol, ObservableObject {
    public let biometricType: BiometricType
    public let isAvailable: Bool
    public let authState = CurrentValueSubject<BiometricAuthState, Never>(.notAuthenticated)
    
    private let context = LAContext()
    private var retryCount = 0
    private var lockoutTimer: Timer?
    private var lockoutEndTime: Date?
    
    public init() {
        self.biometricType = Self.detectBiometricType()
        self.isAvailable = Self.checkBiometricAvailability()
    }
    
    // MARK: - Public Methods
    public func authenticate(config: BiometricConfig = .default) async throws -> Bool {
        guard isAvailable else {
            authState.send(.notAvailable("Biometric authentication not available"))
            throw BiometricError.notAvailable
        }
        
        // Check if locked out
        if let lockoutEndTime = lockoutEndTime, Date() < lockoutEndTime {
            let remainingTime = Int(lockoutEndTime.timeIntervalSinceNow)
            authState.send(.lockedOut("Try again in \(remainingTime) seconds"))
            throw BiometricError.lockedOut(remainingTime)
        }
        
        authState.send(.authenticating)
        
        do {
            let success = try await performBiometricAuth(config: config)
            
            if success {
                authState.send(.authenticated)
                resetRetryCount()
                return true
            } else {
                handleAuthFailure(config: config)
                return false
            }
        } catch {
            handleAuthError(error, config: config)
            throw error
        }
    }
    
    public func checkAvailability() -> Bool {
        return isAvailable
    }
    
    public func resetLockout() {
        retryCount = 0
        lockoutTimer?.invalidate()
        lockoutTimer = nil
        lockoutEndTime = nil
        authState.send(.notAuthenticated)
    }
    
    // MARK: - Private Methods
    private static func detectBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    private static func checkBiometricAvailability() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    private func performBiometricAuth(config: BiometricConfig) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
            
            context.evaluatePolicy(
                policy,
                localizedReason: config.reason
            ) { success, error in
                if let error = error {
                    let biometricError = self.mapLAErrorToBiometricError(error)
                    continuation.resume(throwing: biometricError)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    private func mapLAErrorToBiometricError(_ error: Error) -> BiometricError {
        guard let laError = error as? LAError else {
            return .authenticationFailedWithError(error)
        }
        
        switch laError.code {
        case .authenticationFailed:
            return .authenticationFailed(laError.localizedDescription)
        case .userCancel:
            return .userCancel
        case .userFallback:
            return .userFallback
        case .systemCancel:
            return .appCancel
        case .passcodeNotSet:
            return .passcodeNotSet
        case .biometryNotEnrolled:
            return .biometricNotEnrolled
        case .biometryLockout:
            return .biometryLockout
        case .invalidContext:
            return .invalidContext
        case .notInteractive:
            return .notInteractive
        case .appCancel:
            return .appCancel
        case .biometryNotAvailable:
            return .biometryNotAvailable
        @unknown default:
            return .systemError(laError)
        }
    }
    
    private func handleAuthFailure(config: BiometricConfig) {
        retryCount += 1
        
        if retryCount >= config.maxRetryAttempts {
            startLockout(duration: config.lockoutDuration)
        } else {
            let remainingAttempts = config.maxRetryAttempts - retryCount
            authState.send(.failed("Authentication failed. \(remainingAttempts) attempts remaining"))
        }
    }
    
    private func handleAuthError(_ error: Error, config: BiometricConfig) {
        if let biometricError = error as? BiometricError {
            switch biometricError {
            case .lockedOut(let remainingTime):
                authState.send(.lockedOut("Try again in \(remainingTime) seconds"))
            case .notAvailable, .biometricNotAvailable, .biometryNotAvailable:
                authState.send(.notAvailable("Biometric authentication not available"))
            case .authenticationFailed(let message):
                handleAuthFailure(config: config)
            case .userCancel, .userFallback, .appCancel:
                authState.send(.notAuthenticated)
            case .biometricNotEnrolled:
                authState.send(.notAvailable("No biometric data enrolled. Please set up Touch ID or Face ID in Settings."))
            case .passcodeNotSet:
                authState.send(.notAvailable("Device passcode is not set. Please set a passcode in Settings."))
            case .biometryLockout:
                authState.send(.lockedOut("Biometric authentication is locked. Please use your device passcode."))
            case .systemError(let laError):
                authState.send(.failed("System error: \(laError.localizedDescription)"))
            case .invalidContext, .notInteractive, .interactionNotAllowed:
                authState.send(.failed("Authentication context error: \(biometricError.localizedDescription)"))
            case .serverNotResponding, .networkUnavailable:
                authState.send(.failed("Network error: \(biometricError.localizedDescription)"))
            case .authenticationFailedWithError(let underlyingError):
                authState.send(.failed("Authentication failed: \(underlyingError.localizedDescription)"))
            }
        } else {
            authState.send(.failed(error.localizedDescription))
        }
    }
    
    private func startLockout(duration: TimeInterval) {
        lockoutEndTime = Date().addingTimeInterval(duration)
        authState.send(.lockedOut("Too many failed attempts. Try again in \(Int(duration)) seconds"))
        
        lockoutTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.resetLockout()
        }
    }
    
    private func resetRetryCount() {
        retryCount = 0
    }
}

// MARK: - Biometric Errors
public enum BiometricError: LocalizedError {
    case notAvailable
    case authenticationFailed(String)
    case lockedOut(Int)
    case userCancel
    case systemError(LAError)
    case biometricNotEnrolled
    case biometricNotAvailable
    case passcodeNotSet
    case biometryLockout
    case biometryNotAvailable
    case userFallback
    case invalidContext
    case notInteractive
    case appCancel
    case interactionNotAllowed
    case serverNotResponding
    case networkUnavailable
    case authenticationFailedWithError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .lockedOut(let remainingTime):
            return "Account locked. Try again in \(remainingTime) seconds"
        case .userCancel:
            return "Authentication was cancelled"
        case .systemError(let laError):
            return laError.localizedDescription
        case .biometricNotEnrolled:
            return "No biometric data enrolled. Please set up Touch ID or Face ID in Settings."
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device"
        case .passcodeNotSet:
            return "Device passcode is not set. Please set a passcode in Settings."
        case .biometryLockout:
            return "Biometric authentication is locked. Please use your device passcode."
        case .biometryNotAvailable:
            return "Biometric authentication is not available"
        case .userFallback:
            return "User chose to use fallback authentication"
        case .invalidContext:
            return "Invalid authentication context"
        case .notInteractive:
            return "Authentication requires user interaction"
        case .appCancel:
            return "Authentication was cancelled by the app"
        case .interactionNotAllowed:
            return "Authentication interaction is not allowed"
        case .serverNotResponding:
            return "Authentication server is not responding"
        case .networkUnavailable:
            return "Network is unavailable for authentication"
        case .authenticationFailedWithError(let error):
            return "Authentication failed: \(error.localizedDescription)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .biometricNotEnrolled:
            return "Go to Settings > Face ID & Passcode (or Touch ID & Passcode) to set up biometric authentication."
        case .passcodeNotSet:
            return "Go to Settings > Face ID & Passcode (or Touch ID & Passcode) to set a device passcode."
        case .biometryLockout:
            return "Use your device passcode to unlock biometric authentication."
        case .biometryNotAvailable:
            return "This device does not support biometric authentication."
        case .systemError(let laError):
            return laError.localizedDescription
        default:
            return nil
        }
    }
    
    public var isRecoverable: Bool {
        switch self {
        case .biometricNotEnrolled, .passcodeNotSet, .biometryLockout:
            return true
        case .userCancel, .userFallback, .appCancel:
            return true
        case .systemError(let laError):
            return laError.code != .biometryNotAvailable
        default:
            return false
        }
    }
    
    public var requiresUserAction: Bool {
        switch self {
        case .biometricNotEnrolled, .passcodeNotSet, .biometryLockout:
            return true
        case .userCancel, .userFallback:
            return true
        default:
            return false
        }
    }
}

// MARK: - Biometric Error Action
public enum BiometricErrorAction {
    case showSettings(String, String, String) // title, message, settingsURL
    case showAlert(String, String, String, String?) // title, message, primaryAction, secondaryAction?
    case retry
    case ignore
    case none
}

// MARK: - Biometric Error Handler
public struct BiometricErrorHandler {
    
    public static func handleError(_ error: BiometricError) -> BiometricErrorAction {
        switch error {
        case .biometricNotEnrolled, .passcodeNotSet:
            return .showSettings(
                "Setup Required",
                "Please set up biometric authentication in Settings",
                "App-Prefs:root=TOUCHID_PASSCODE"
            )
            
        case .biometryLockout, .lockedOut:
            return .showAlert(
                "Account Locked",
                "Too many failed attempts. Please wait before trying again.",
                "OK",
                nil
            )
            
        case .biometricNotAvailable, .biometryNotAvailable, .notAvailable:
            return .showSettings(
                "Biometric Not Available",
                "Biometric authentication is not available on this device",
                "App-Prefs:root=TOUCHID_PASSCODE"
            )
            
        case .userCancel:
            return .ignore
            
        case .userFallback:
            return .retry
            
        case .authenticationFailed:
            return .showAlert(
                "Authentication Failed",
                "Please try again or use your device passcode",
                "Try Again",
                "Use Passcode"
            )
            
        case .systemError(let laError):
            return handleLAError(laError)
            
        case .serverNotResponding, .networkUnavailable:
            return .showAlert(
                "Network Error",
                "Please check your internet connection and try again",
                "Retry",
                "Cancel"
            )
            
        case .invalidContext, .notInteractive, .interactionNotAllowed:
            return .showAlert(
                "System Error",
                "Please restart the app and try again",
                "OK",
                nil
            )
            
        case .appCancel:
            return .ignore
            
        case .authenticationFailedWithError:
            return .showAlert(
                "Authentication Error",
                "An unexpected error occurred. Please try again.",
                "Retry",
                "Cancel"
            )
        }
    }
    
    public static func canRetry(_ error: BiometricError) -> Bool {
        switch error {
        case .biometricNotEnrolled, .passcodeNotSet, .biometricNotAvailable, .biometryNotAvailable, .notAvailable:
            return false
        case .biometryLockout, .lockedOut:
            return false
        case .userCancel, .appCancel:
            return false
        case .userFallback, .authenticationFailed, .systemError, .serverNotResponding, .networkUnavailable, .invalidContext, .notInteractive, .interactionNotAllowed, .authenticationFailedWithError:
            return true
        }
    }
    
    private static func handleLAError(_ laError: LAError) -> BiometricErrorAction {
        switch laError.code {
        case .biometryNotEnrolled:
            return .showSettings(
                "Setup Required",
                "Please set up biometric authentication in Settings",
                "App-Prefs:root=TOUCHID_PASSCODE"
            )
            
        case .passcodeNotSet:
            return .showSettings(
                "Passcode Required",
                "Please set a device passcode in Settings",
                "App-Prefs:root=TOUCHID_PASSCODE"
            )
            
        case .biometryLockout:
            return .showAlert(
                "Biometric Locked",
                "Biometric authentication is temporarily locked. Please use your device passcode.",
                "OK",
                nil
            )
            
        case .biometryNotAvailable:
            return .showSettings(
                "Not Available",
                "Biometric authentication is not available on this device",
                "App-Prefs:root=TOUCHID_PASSCODE"
            )
            
        case .userCancel:
            return .ignore
            
        case .userFallback:
            return .retry
            
        case .authenticationFailed:
            return .showAlert(
                "Authentication Failed",
                "Please try again",
                "Retry",
                "Cancel"
            )
            
        case .systemCancel:
            return .ignore
            
        case .appCancel:
            return .ignore
            
        case .invalidContext:
            return .showAlert(
                "System Error",
                "Please restart the app and try again",
                "OK",
                nil
            )
            
        case .notInteractive:
            return .showAlert(
                "Not Interactive",
                "Authentication is not interactive at this time",
                "OK",
                nil
            )
            
        @unknown default:
            return .showAlert(
                "System Error",
                "An unexpected error occurred: \(laError.localizedDescription)",
                "OK",
                nil
            )
        }
    }
}

#endif
