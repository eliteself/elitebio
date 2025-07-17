//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//

import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#endif
import EliteBiometric

// MARK: - Customizable Biometric Configuration
public struct CustomBiometricConfig {
    // MARK: - Visual Customization
    public let backgroundColor: AnyShapeStyle
    public let accentColor: Color
    public let textColor: Color
    public let secondaryTextColor: Color
    public let errorColor: Color
    public let successColor: Color
    
    // MARK: - Content Customization
    public let appName: String
    public let welcomeMessage: String
    public let biometricPrompt: String
    public let buttonText: String
    public let cancelButtonText: String
    public let settingsButtonText: String
    
    // MARK: - Layout Customization
    public let iconSize: CGFloat
    public let spacing: CGFloat
    public let cornerRadius: CGFloat
    public let buttonHeight: CGFloat
    public let padding: EdgeInsets
    
    // MARK: - Animation Customization
    public let enableAnimations: Bool
    public let animationDuration: Double
    public let pulseAnimation: Bool
    public let shakeOnError: Bool
    
    // MARK: - Behavior Customization
    public let autoAuthenticate: Bool
    public let showCancelButton: Bool
    public let showSettingsButton: Bool
    public let allowFallback: Bool
    public let maxRetryAttempts: Int
    public let lockoutDuration: TimeInterval
    
    // MARK: - Default Configuration
    public static let `default` = CustomBiometricConfig(
        backgroundColor: AnyShapeStyle(Color(UIColor.systemBackground)),
        accentColor: .blue,
        textColor: Color(UIColor.label),
        secondaryTextColor: Color(UIColor.secondaryLabel),
        errorColor: .red,
        successColor: .green,
        appName: "App",
        welcomeMessage: "Welcome",
        biometricPrompt: "Sign in with biometric authentication",
        buttonText: "Authenticate",
        cancelButtonText: "Cancel",
        settingsButtonText: "Open Settings",
        iconSize: 80,
        spacing: 24,
        cornerRadius: 12,
        buttonHeight: 50,
        padding: EdgeInsets(top: 40, leading: 20, bottom: 40, trailing: 20),
        enableAnimations: true,
        animationDuration: 0.3,
        pulseAnimation: true,
        shakeOnError: true,
        autoAuthenticate: false,
        showCancelButton: true,
        showSettingsButton: true,
        allowFallback: true,
        maxRetryAttempts: 3,
        lockoutDuration: 300
    )
    
    public init(
        backgroundColor: AnyShapeStyle = AnyShapeStyle(Color(uiColor: .systemBackground)),
        accentColor: Color = .blue,
        textColor: Color = Color(uiColor: .label),
        secondaryTextColor: Color = Color(uiColor: .secondaryLabel),
        errorColor: Color = .red,
        successColor: Color = .green,
        appName: String = "App",
        welcomeMessage: String = "Welcome",
        biometricPrompt: String = "Sign in with biometric authentication",
        buttonText: String = "Authenticate",
        cancelButtonText: String = "Cancel",
        settingsButtonText: String = "Open Settings",
        iconSize: CGFloat = 80,
        spacing: CGFloat = 24,
        cornerRadius: CGFloat = 12,
        buttonHeight: CGFloat = 50,
        padding: EdgeInsets = EdgeInsets(top: 40, leading: 20, bottom: 40, trailing: 20),
        enableAnimations: Bool = true,
        animationDuration: Double = 0.3,
        pulseAnimation: Bool = true,
        shakeOnError: Bool = true,
        autoAuthenticate: Bool = false,
        showCancelButton: Bool = true,
        showSettingsButton: Bool = true,
        allowFallback: Bool = true,
        maxRetryAttempts: Int = 3,
        lockoutDuration: TimeInterval = 300
    ) {
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.textColor = textColor
        self.secondaryTextColor = secondaryTextColor
        self.errorColor = errorColor
        self.successColor = successColor
        self.appName = appName
        self.welcomeMessage = welcomeMessage
        self.biometricPrompt = biometricPrompt
        self.buttonText = buttonText
        self.cancelButtonText = cancelButtonText
        self.settingsButtonText = settingsButtonText
        self.iconSize = iconSize
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.buttonHeight = buttonHeight
        self.padding = padding
        self.enableAnimations = enableAnimations
        self.animationDuration = animationDuration
        self.pulseAnimation = pulseAnimation
        self.shakeOnError = shakeOnError
        self.autoAuthenticate = autoAuthenticate
        self.showCancelButton = showCancelButton
        self.showSettingsButton = showSettingsButton
        self.allowFallback = allowFallback
        self.maxRetryAttempts = maxRetryAttempts
        self.lockoutDuration = lockoutDuration
    }
}

// MARK: - Customizable Biometric View
public struct CustomBiometricView<HeaderContent: View, FooterContent: View>: View {
    @StateObject private var biometricManager = EliteBiometric()
    @State private var isAuthenticating = false
    @State private var showErrorAlert = false
    @State private var currentError: BiometricError?
    @State private var errorAction: BiometricErrorAction?
    @State private var shakeOffset: CGFloat = 0
    
    private let config: CustomBiometricConfig
    private let headerContent: HeaderContent?
    private let footerContent: FooterContent?
    private let onSuccess: () -> Void
    private let onFailure: (BiometricError) -> Void
    private let onCancel: () -> Void
    
    // MARK: - Initializers
    public init(
        config: CustomBiometricConfig = .default,
        @ViewBuilder headerContent: () -> HeaderContent? = { nil },
        @ViewBuilder footerContent: () -> FooterContent? = { nil },
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (BiometricError) -> Void,
        onCancel: @escaping () -> Void = {}
    ) {
        self.config = config
        self.headerContent = headerContent()
        self.footerContent = footerContent()
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.onCancel = onCancel
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Rectangle()
                    .fill(config.backgroundColor)
                    .ignoresSafeArea()
                
                VStack(spacing: config.spacing) {
                    Spacer()
                    
                    // Header Content
                    if let headerContent = headerContent {
                        headerContent
                    }
                    
                    // Main Content
                    VStack(spacing: config.spacing) {
                        // Biometric Icon
                        biometricIcon
                        
                        // Welcome Message
                        Text(config.welcomeMessage)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(config.textColor)
                            .multilineTextAlignment(.center)
                        
                        // Biometric Prompt
                        Text(biometricPromptText)
                            .font(.title3)
                            .foregroundColor(config.secondaryTextColor)
                            .multilineTextAlignment(.center)
                        
                        // Status Message
                        statusView
                    }
                    .offset(x: shakeOffset)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: config.spacing / 2) {
                        // Authenticate Button
                        authenticateButton
                        
                        // Settings Button
                        if config.showSettingsButton && !biometricManager.isAvailable {
                            settingsButton
                        }
                        
                        // Cancel Button
                        if config.showCancelButton {
                            cancelButton
                        }
                    }
                    
                    // Footer Content
                    if let footerContent = footerContent {
                        footerContent
                    }
                }
                .padding(config.padding)
            }
        }
        .onAppear {
            if config.autoAuthenticate && biometricManager.isAvailable {
                authenticate()
            }
        }
        .onReceive(biometricManager.authState) { state in
            handleAuthStateChange(state)
        }
        .alert("Authentication Error", isPresented: $showErrorAlert) {
            if let action = errorAction {
                switch action {
                case .showAlert(_, _, let primaryAction, let secondaryAction):
                    Button(primaryAction) {
                        handlePrimaryAction()
                    }
                    if let secondaryAction = secondaryAction {
                        Button(secondaryAction) {
                            handleSecondaryAction()
                        }
                    }
                default:
                    Button("OK") {
                        showErrorAlert = false
                    }
                }
            }
        } message: {
            if let action = errorAction {
                switch action {
                case .showAlert(_, let message, _, _):
                    Text(message)
                default:
                    Text("An error occurred")
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var biometricPromptText: String {
        if biometricManager.isAvailable {
            return config.biometricPrompt.replacingOccurrences(of: "biometric", with: biometricManager.biometricType.displayName.lowercased())
        } else {
            return "Biometric authentication is not available"
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var biometricIcon: some View {
        Image(systemName: biometricManager.biometricType.icon)
            .font(.system(size: config.iconSize))
            .foregroundColor(config.accentColor)
            .scaleEffect(isAuthenticating && config.pulseAnimation ? 1.1 : 1.0)
            .animation(
                config.enableAnimations ? 
                    .easeInOut(duration: config.animationDuration).repeatForever(autoreverses: true) : 
                    .none,
                value: isAuthenticating
            )
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch biometricManager.authState.value {
        case .notAuthenticated:
            EmptyView()
        case .authenticating:
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Authenticating...")
                    .foregroundColor(config.secondaryTextColor)
            }
        case .authenticated:
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(config.successColor)
                Text("Authentication successful!")
                    .foregroundColor(config.successColor)
            }
        case .failed(let message):
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(config.errorColor)
                Text(message)
                    .foregroundColor(config.errorColor)
                    .multilineTextAlignment(.center)
            }
        case .notAvailable(let message):
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(config.errorColor)
                Text(message)
                    .foregroundColor(config.errorColor)
                    .multilineTextAlignment(.center)
            }
        case .lockedOut(let message):
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(config.errorColor)
                Text(message)
                    .foregroundColor(config.errorColor)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    @ViewBuilder
    private var authenticateButton: some View {
        Button(action: authenticate) {
            HStack {
                if isAuthenticating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: biometricManager.biometricType.icon)
                        .foregroundColor(.white)
                }
                Text(isAuthenticating ? "Authenticating..." : config.buttonText)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: config.buttonHeight)
            .background(config.accentColor)
            .cornerRadius(config.cornerRadius)
        }
        .disabled(!biometricManager.isAvailable || isAuthenticating)
        .animation(config.enableAnimations ? .easeInOut(duration: config.animationDuration) : .none, value: isAuthenticating)
    }
    
    @ViewBuilder
    private var settingsButton: some View {
        Button(action: openSettings) {
            Text(config.settingsButtonText)
                .foregroundColor(config.accentColor)
                .fontWeight(.medium)
        }
    }
    
    @ViewBuilder
    private var cancelButton: some View {
        Button(action: onCancel) {
            Text(config.cancelButtonText)
                .foregroundColor(config.secondaryTextColor)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Actions
    private func authenticate() {
        isAuthenticating = true
        
        Task {
            do {
                let success = try await biometricManager.authenticate(
                    config: BiometricConfig(
                        reason: config.biometricPrompt,
                        fallbackTitle: config.allowFallback ? "Use Passcode" : nil,
                        maxRetryAttempts: config.maxRetryAttempts,
                        lockoutDuration: config.lockoutDuration
                    )
                )
                if success {
                    onSuccess()
                }
            } catch let error as BiometricError {
                handleBiometricError(error)
            } catch {
                handleBiometricError(.authenticationFailedWithError(error.localizedDescription as! Error))
            }
            isAuthenticating = false
        }
    }
    
    private func handleAuthStateChange(_ state: BiometricAuthState) {
        switch state {
        case .authenticated:
            onSuccess()
        case .failed(let message):
            handleBiometricError(.authenticationFailed(message))
        case .notAvailable(let message):
            handleBiometricError(.notAvailable)
        case .lockedOut(let message):
            handleBiometricError(.lockedOut(0))
        default:
            break
        }
    }
    
    private func handleBiometricError(_ error: BiometricError) {
        currentError = error
        errorAction = BiometricErrorHandler.handleError(error)
        
        if config.shakeOnError {
            withAnimation(.easeInOut(duration: 0.1).repeatCount(3)) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    shakeOffset = 0
                }
            }
        }
        
        switch errorAction {
        case .showSettings(_, _, let settingsURL):
            if let url = URL(string: settingsURL) {
                UIApplication.shared.open(url)
            }
        case .showAlert:
            showErrorAlert = true
        case .retry:
            authenticate()
        case .ignore:
            onFailure(error)
        case .none:
            onFailure(error)
        case .some(.none):
            showErrorAlert = true
        }
    }
    
    private func handlePrimaryAction() {
        showErrorAlert = false
        
        if let error = currentError, BiometricErrorHandler.canRetry(error) {
            authenticate()
        } else {
            onFailure(currentError ?? .authenticationFailed("Unknown error"))
        }
    }
    
    private func handleSecondaryAction() {
        showErrorAlert = false
        onFailure(currentError ?? .authenticationFailed("Unknown error"))
    }
    
    private func openSettings() {
        if let url = URL(string: "App-Prefs:root=TOUCHID_PASSCODE") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Convenience Initializers
public extension CustomBiometricView where HeaderContent == EmptyView, FooterContent == EmptyView {
    init(
        config: CustomBiometricConfig = .default,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (BiometricError) -> Void,
        onCancel: @escaping () -> Void = {}
    ) {
        self.init(
            config: config,
            headerContent: { EmptyView() },
            footerContent: { EmptyView() },
            onSuccess: onSuccess,
            onFailure: onFailure,
            onCancel: onCancel
        )
    }
}

// MARK: - Pre-built Configurations
public extension CustomBiometricConfig {
    static let elitenet = CustomBiometricConfig(
        backgroundColor: AnyShapeStyle(Color(.systemBackground)),
        accentColor: .blue,
        textColor: Color(.label),
        secondaryTextColor: Color(.secondaryLabel),
        errorColor: .red,
        successColor: .green,
        appName: "EliteNet",
        welcomeMessage: "Welcome to EliteNet",
        biometricPrompt: "Access your data",
        buttonText: "Sign In",
        cornerRadius: 16,
        buttonHeight: 56,
        enableAnimations: true,
        pulseAnimation: true,
        shakeOnError: true,
        autoAuthenticate: true,
        maxRetryAttempts: 5,
        lockoutDuration: 600
    )
    
    static let banking = CustomBiometricConfig(
        backgroundColor: AnyShapeStyle(.black),
        accentColor: .green,
        textColor: .white,
        secondaryTextColor: .gray,
        errorColor: .red,
        successColor: .green,
        appName: "Secure Banking",
        welcomeMessage: "Secure Access",
        biometricPrompt: "Authenticate to access your account",
        buttonText: "Authenticate",
        cornerRadius: 8,
        buttonHeight: 48,
        enableAnimations: false,
        pulseAnimation: false,
        shakeOnError: false,
        autoAuthenticate: true,
        maxRetryAttempts: 3,
        lockoutDuration: 300
    )
    
    static let minimal = CustomBiometricConfig(
        backgroundColor: AnyShapeStyle(Color(.systemBackground)),
        accentColor: Color(.label),
        textColor: Color(.label),
        secondaryTextColor: Color(.secondaryLabel),
        errorColor: .red,
        successColor: .green,
        appName: "App",
        welcomeMessage: "Welcome",
        biometricPrompt: "Sign in",
        buttonText: "Continue",
        iconSize: 60,
        spacing: 16,
        cornerRadius: 8,
        buttonHeight: 44,
        enableAnimations: false,
        pulseAnimation: false,
        shakeOnError: false,
        autoAuthenticate: true,
        showCancelButton: false,
        showSettingsButton: false,
        maxRetryAttempts: 3,
        lockoutDuration: 300
    )
    
    static let colorful = CustomBiometricConfig(
        backgroundColor: AnyShapeStyle(LinearGradient(
            colors: [.purple, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )),
        accentColor: .white,
        textColor: .white,
        secondaryTextColor: .white.opacity(0.8),
        errorColor: .red,
        successColor: .green,
        appName: "Colorful App",
        welcomeMessage: "Welcome Back!",
        biometricPrompt: "Quick and secure sign in",
        buttonText: "Sign In",
        iconSize: 100,
        spacing: 32,
        cornerRadius: 20,
        buttonHeight: 60,
        enableAnimations: true,
        pulseAnimation: true,
        shakeOnError: true,
        autoAuthenticate: false,
        maxRetryAttempts: 3,
        lockoutDuration: 300
    )
}

// MARK: - View Modifier for Easy Integration
public struct CustomBiometricAuthModifier: ViewModifier {
    @State private var showAuth = false
    private let config: CustomBiometricConfig
    private let onSuccess: () -> Void
    private let onFailure: (BiometricError) -> Void
    
    public init(
        config: CustomBiometricConfig = .default,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (BiometricError) -> Void = { _ in }
    ) {
        self.config = config
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                let biometricManager = EliteBiometric()
                if biometricManager.isAvailable {
                    showAuth = true
                } else {
                    onSuccess() // Skip auth if not available
                }
            }
            .sheet(isPresented: $showAuth) {
                CustomBiometricView(config: config) {
                    showAuth = false
                    onSuccess()
                } onFailure: { error in
                    onFailure(error)
                }
            }
    }
}

// MARK: - View Extension for Easy Integration
public extension View {
    func customBiometricAuth(
        config: CustomBiometricConfig = .default,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (BiometricError) -> Void = { _ in }
    ) -> some View {
        modifier(CustomBiometricAuthModifier(
            config: config,
            onSuccess: onSuccess,
            onFailure: onFailure
        ))
    }
} 
