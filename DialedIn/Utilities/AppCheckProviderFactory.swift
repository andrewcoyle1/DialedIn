//
//  AppCheckProviderFactory.swift
//  DialedIn
//
//  Created by Assistant on 29/09/2025.
//

import Foundation
import FirebaseCore
import FirebaseAppCheck
import DeviceCheck

final class ProductionAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if canImport(UIKit)
        if #available(iOS 14.0, *), DCAppAttestService.shared.isSupported {
            return AppAttestProvider(app: app)
        } else {
            return DeviceCheckProvider(app: app)
        }
        #else
        return DeviceCheckProvider(app: app)
        #endif
    }
}
