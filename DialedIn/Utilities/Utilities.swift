//
//  Utilities.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/9/24.
//
import SwiftfulUtilities
import Foundation
#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#else
import AppKit
public typealias PlatformImage = NSImage
#endif

final class Utilities {
    static let shared = Utilities()

    private init() {}

    // Scene-aware key window fetch to avoid deprecated `keyWindow`
    private static func activeKeyWindow() -> UIWindow? {
        // Get the foreground active scene
        let scenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
        // Prefer a window scene
        let windowScene = scenes.compactMap { $0 as? UIWindowScene }.first
        // Return the key window if available, otherwise the first window
        return windowScene?.windows.first(where: { $0.isKeyWindow }) ?? windowScene?.windows.first
    }

    func topViewController(controller: UIViewController? = Utilities.activeKeyWindow()?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension Date {
    var dayKey: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Calendar.current.startOfDay(for: self))
    }
    
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
}
