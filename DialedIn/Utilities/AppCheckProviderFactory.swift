//
//  AppCheckProviderFactory.swift
//  DialedIn
//
//  Created by Assistant on 29/09/2025.
//

import FirebaseCore
import FirebaseAppCheck

class MyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    if #available(iOS 14.0, *) {
      return AppAttestProvider(app: app)
    } else {
      return DeviceCheckProvider(app: app)
    }
  }
}
