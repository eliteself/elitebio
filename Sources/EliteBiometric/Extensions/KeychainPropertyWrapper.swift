//  EliteBiometric
//
//  Created by eliteself.tech on 15.07.2025.
//  Copyright © 2025 @eliteself.tech. All rights reserved.
//


import Foundation
import EliteBiometric

// MARK: - Keychain Property Wrapper
@propertyWrapper
public struct KeychainStored<T: Codable> {
    private let key: String
    private let defaultValue: T?
    
    public init(key: String, defaultValue: T? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T? {
        get {
            do {
                return try KeychainManager.shared.load(T.self, forKey: key)
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                if let newValue = newValue {
                    try KeychainManager.shared.save(newValue, forKey: key)
                } else {
                    try KeychainManager.shared.delete(key: key)
                }
            } catch {
                print("Failed to save to keychain: \(error)")
            }
        }
    }
}

// MARK: - String Keychain Property Wrapper
@propertyWrapper
public struct KeychainString {
    private let key: String
    private let defaultValue: String?
    
    public init(key: String, defaultValue: String? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: String? {
        get {
            do {
                return try KeychainManager.shared.loadString(forKey: key)
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                if let newValue = newValue {
                    try KeychainManager.shared.saveString(newValue, forKey: key)
                } else {
                    try KeychainManager.shared.delete(key: key)
                }
            } catch {
                print("Failed to save string to keychain: \(error)")
            }
        }
    }
}

// MARK: - Data Keychain Property Wrapper
@propertyWrapper
public struct KeychainData {
    private let key: String
    private let defaultValue: Data?
    
    public init(key: String, defaultValue: Data? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Data? {
        get {
            do {
                return try KeychainManager.shared.load(key: key)
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                if let newValue = newValue {
                    try KeychainManager.shared.save(key: key, data: newValue)
                } else {
                    try KeychainManager.shared.delete(key: key)
                }
            } catch {
                print("Failed to save data to keychain: \(error)")
            }
        }
    }
}

// MARK: - Bool Keychain Property Wrapper
@propertyWrapper
public struct KeychainBool {
    private let key: String
    private let defaultValue: Bool
    
    public init(key: String, defaultValue: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Bool {
        get {
            do {
                let data = try KeychainManager.shared.load(key: key)
                return data.first == 1
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                let data = Data([newValue ? 1 : 0])
                try KeychainManager.shared.save(key: key, data: data)
            } catch {
                print("Failed to save bool to keychain: \(error)")
            }
        }
    }
}

// MARK: - Int Keychain Property Wrapper
@propertyWrapper
public struct KeychainInt {
    private let key: String
    private let defaultValue: Int
    
    public init(key: String, defaultValue: Int = 0) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Int {
        get {
            do {
                let data = try KeychainManager.shared.load(key: key)
                return data.withUnsafeBytes { $0.load(as: Int.self) }
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                var value = newValue
                let data = Data(bytes: &value, count: MemoryLayout<Int>.size)
                try KeychainManager.shared.save(key: key, data: data)
            } catch {
                print("Failed to save int to keychain: \(error)")
            }
        }
    }
}

// MARK: - Double Keychain Property Wrapper
@propertyWrapper
public struct KeychainDouble {
    private let key: String
    private let defaultValue: Double
    
    public init(key: String, defaultValue: Double = 0.0) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Double {
        get {
            do {
                let data = try KeychainManager.shared.load(key: key)
                return data.withUnsafeBytes { $0.load(as: Double.self) }
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                var value = newValue
                let data = Data(bytes: &value, count: MemoryLayout<Double>.size)
                try KeychainManager.shared.save(key: key, data: data)
            } catch {
                print("Failed to save double to keychain: \(error)")
            }
        }
    }
} 
