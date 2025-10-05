//
//  AuthErrorHandler.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import Foundation
import FirebaseAuth

/// Production-level error handler for authentication operations
/// Provides standardized error handling, user-friendly messages, and comprehensive logging
public struct AuthErrorHandler {
    
    // MARK: - Public Interface
    
    /// Handles authentication errors with standardized user messages and logging
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - operation: The operation being performed (e.g., "sign in", "sign up")
    ///   - provider: Optional provider name (e.g., "Apple", "Google")
    ///   - logManager: Log manager for tracking events
    /// - Returns: Standardized error information for UI display
    static func handle(
        _ error: Error,
        operation: String,
        provider: String? = nil,
        logManager: LogManager
    ) -> AuthErrorInfo {
        
        // Log the error
        let logEvent = createLogEvent(error: error, operation: operation, provider: provider)
        logManager.trackEvent(event: logEvent)
        
        // Generate user-friendly message
        let userMessage = generateUserMessage(for: error, operation: operation, provider: provider)
        
        // Determine if retry is recommended
        let isRetryable = determineRetryability(for: error, operation: operation)
        
        return AuthErrorInfo(
            title: generateTitle(for: error, operation: operation, provider: provider),
            message: userMessage,
            isRetryable: isRetryable,
            error: error,
            operation: operation,
            provider: provider
        )
    }
    
    /// Handles user login errors specifically
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - logManager: Log manager for tracking events
    /// - Returns: Standardized error information for UI display
    static func handleUserLoginError(
        _ error: Error,
        logManager: LogManager
    ) -> AuthErrorInfo {
        
        return handle(error, operation: "log in", provider: nil, logManager: logManager)
    }
    
    // MARK: - Private Helpers
    
    private static func createLogEvent(error: Error, operation: String, provider: String?) -> AuthErrorLogEvent {
        return AuthErrorLogEvent(error: error, operation: operation, provider: provider)
    }
    
    /// Logs any unhandled Firebase Auth error codes for debugging
    private static func logUnhandledAuthError(_ errorCode: AuthErrorCode, operation: String) {
        #if DEBUG
        print("⚠️ Unhandled Firebase Auth error: \(errorCode) for operation: \(operation)")
        #endif
    }
    
    private static func generateTitle(for error: Error, operation: String, provider: String?) -> String {
        if let nsError = error as NSError?,
           let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
            if let mapped = titleForAuthCode(authErrorCode, operation: operation) {
                return mapped
            } else {
                logUnhandledAuthError(authErrorCode, operation: operation)
            }
        }
        
        if let urlError = error as? URLError,
           let mapped = titleForURLError(urlError.code) {
            return mapped
        }
        
        if error is AuthTimeoutError {
            return "Request Timeout"
        }
        
        if let provider = provider {
            return "\(provider) Sign-In Failed"
        }
        
        return defaultTitle(for: operation)
    }
    
    private static func generateUserMessage(for error: Error, operation: String, provider: String?) -> String {
        if let nsError = error as NSError?,
           let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
            if let mapped = messageForAuthCode(authErrorCode, operation: operation) {
                return mapped
            } else {
                logUnhandledAuthError(authErrorCode, operation: operation)
                return "Unable to \(operation). Please try again."
            }
        }
        
        if let urlError = error as? URLError,
           let mapped = messageForURLError(urlError.code) {
            return mapped
        }
        
        if error is AuthTimeoutError {
            return "The operation took too long. Please check your internet connection and try again."
        }
        
        if let provider = provider {
            return providerSpecificMessage(provider)
        }
        
        return "Unable to \(operation). Please try again."
    }

    // MARK: - Mapping Helpers to reduce complexity

    private static let authTitleMap: [AuthErrorCode: String] = [
        .wrongPassword: "Sign In Failed",
        .emailAlreadyInUse: "Sign Up Failed",
        .weakPassword: "Weak Password",
        .invalidEmail: "Invalid Email",
        .userDisabled: "Account Disabled",
        .tooManyRequests: "Too Many Attempts",
        .networkError: "Connection Failed",
        .invalidCredential: "Invalid Credentials",
        .accountExistsWithDifferentCredential: "Account Exists",
        .providerAlreadyLinked: "Provider Already Linked",
        .credentialAlreadyInUse: "Credential Already In Use"
    ]

    private static func titleForAuthCode(_ code: AuthErrorCode, operation: String) -> String? {
        if code == .userNotFound {
            return operation == "sign in" ? "Account Not Found" : "Sign Up Failed"
        }
        return authTitleMap[code]
    }

    private static let urlErrorTitleMap: [URLError.Code: String] = [
        .notConnectedToInternet: "Connection Failed",
        .networkConnectionLost: "Connection Failed",
        .timedOut: "Request Timeout",
        .cannotConnectToHost: "Server Unavailable"
    ]

    private static func titleForURLError(_ code: URLError.Code) -> String? {
        return urlErrorTitleMap[code]
    }

    private static func defaultTitle(for operation: String) -> String {
        switch operation {
        case "sign in": return "Sign In Failed"
        case "sign up": return "Sign Up Failed"
        case "log in": return "Login Failed"
        default: return "Authentication Failed"
        }
    }

    private static let authMessageMap: [AuthErrorCode: String] = [
        .wrongPassword: "Incorrect password. Please try again.",
        .emailAlreadyInUse: "An account with this email already exists. Please sign in instead.",
        .weakPassword: "Password is too weak. Please choose a stronger password with at least 8 characters, including uppercase, lowercase, number, and special character.",
        .invalidEmail: "Please enter a valid email address.",
        .userDisabled: "This account has been disabled. Please contact support for assistance.",
        .tooManyRequests: "Too many attempts. Please wait a few minutes before trying again.",
        .networkError: "Network connection failed. Please check your internet connection and try again.",
        .invalidCredential: "Invalid credentials. Please check your email and password.",
        .accountExistsWithDifferentCredential: "An account already exists with this email using a different sign-in method. Please try signing in with the original method.",
        .requiresRecentLogin: "For security reasons, please sign in again to continue.",
        .operationNotAllowed: "This sign-in method is not enabled. Please try a different method.",
        .invalidUserToken: "Your session has expired. Please sign in again.",
        .userTokenExpired: "Your session has expired. Please sign in again.",
        .providerAlreadyLinked: "This account is already linked to this provider.",
        .credentialAlreadyInUse: "This credential is already associated with a different user account."
    ]

    private static func messageForAuthCode(_ code: AuthErrorCode, operation: String) -> String? {
        if code == .userNotFound {
            return operation == "sign in"
                ? "No account found with this email address. Please check your email or sign up."
                : "Unable to create account. Please try again."
        }
        return authMessageMap[code]
    }

    private static let urlErrorMessageMap: [URLError.Code: String] = [
        .notConnectedToInternet: "Please check your internet connection and try again.",
        .networkConnectionLost: "Please check your internet connection and try again.",
        .timedOut: "The request timed out. Please try again.",
        .cannotConnectToHost: "Unable to connect to our servers. Please try again later.",
        .dnsLookupFailed: "Unable to reach our servers. Please check your internet connection.",
        .secureConnectionFailed: "Secure connection failed. Please try again."
    ]

    private static func messageForURLError(_ code: URLError.Code) -> String? {
        return urlErrorMessageMap[code]
    }

    private static func providerSpecificMessage(_ provider: String) -> String {
        switch provider {
        case "Apple":
            return "Unable to continue with Apple Sign-In. Please try again or use a different sign-in method."
        case "Google":
            return "Unable to continue with Google Sign-In. Please try again or use a different sign-in method."
        default:
            return "Unable to continue with \(provider). Please try again or use a different sign-in method."
        }
    }
    
    private static func determineRetryability(for error: Error, operation: String) -> Bool {
        
        // Firebase-specific retry logic
        if let nsError = error as NSError?,
           let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
            
            switch authErrorCode {
            case .userNotFound, .emailAlreadyInUse, .invalidEmail, .weakPassword:
                return false // User action required, not retryable
            case .wrongPassword, .invalidCredential:
                return false // User needs to fix credentials
            case .userDisabled:
                return false // Account disabled, not user-fixable
            case .tooManyRequests:
                return true // Can retry after waiting
            case .networkError, .invalidUserToken, .userTokenExpired:
                return true // Network/token issues are retryable
            case .requiresRecentLogin:
                return true // Can retry after re-authentication
            case .providerAlreadyLinked:
                return false // Account linking conflict, not retryable
            case .credentialAlreadyInUse:
                return false // Credential conflict, not retryable
            default:
                logUnhandledAuthError(authErrorCode, operation: operation)
                return true // Default to retryable
            }
        }
        
        // Network errors are generally retryable
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotConnectToHost:
                return true
            default:
                return true
            }
        }
        
        // Timeout errors are retryable
        if error is AuthTimeoutError {
            return true
        }
        
        return true // Default to retryable
    }
}

// MARK: - Supporting Types

/// Standardized error information for UI display
public struct AuthErrorInfo {
    public let title: String
    public let message: String
    public let isRetryable: Bool
    public let error: Error
    public let operation: String
    public let provider: String?
    
    public init(title: String, message: String, isRetryable: Bool, error: Error, operation: String, provider: String?) {
        self.title = title
        self.message = message
        self.isRetryable = isRetryable
        self.error = error
        self.operation = operation
        self.provider = provider
    }
}

/// Timeout error for authentication operations
public enum AuthTimeoutError: LocalizedError {
    case operationTimeout
    
    public var errorDescription: String? {
        switch self {
        case .operationTimeout:
            return "Authentication operation timed out"
        }
    }
}

/// Log event for authentication errors
public struct AuthErrorLogEvent: LoggableEvent {
    public let error: Error
    public let operation: String
    public let provider: String?
    
    public init(error: Error, operation: String, provider: String?) {
        self.error = error
        self.operation = operation
        self.provider = provider
    }
    
    public var eventName: String {
        let baseName = "Auth_\(operation.capitalized)_Fail"
        if let provider = provider {
            return "\(baseName)_\(provider)"
        }
        return baseName
    }
    
    public var parameters: [String: Any]? {
        var params = error.eventParameters
        params["operation"] = operation
        if let provider = provider {
            params["provider"] = provider
        }
        return params
    }
    
    var type: LogType {
        return .severe
    }
}

// MARK: - Constants

public enum AuthConstants {
    public static let authTimeout: TimeInterval = 30
    public static let buttonHeight: CGFloat = 56
    public static let buttonCornerRadius: CGFloat = 28
    public static let passwordMinLength = 8
    public static let passwordMaxLength = 4096
}
