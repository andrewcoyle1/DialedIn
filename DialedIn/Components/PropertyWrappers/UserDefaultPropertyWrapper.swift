//
//  UserDefaultPropertyWrapper.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/12/2025.
//

import SwiftUI

protocol UserDefaultsCompatible { }
extension Bool: UserDefaultsCompatible { }
extension Int: UserDefaultsCompatible { }
extension Float: UserDefaultsCompatible { }
extension Double: UserDefaultsCompatible { }
extension String: UserDefaultsCompatible { }
extension URL: UserDefaultsCompatible { }

@propertyWrapper
struct UserDefault<Value: UserDefaultsCompatible> {
    private let key: String
    private let startingValue: Value
    
    init(key: String, startingValue: Value) {
        self.key = key
        self.startingValue = startingValue
    }
    
    var wrappedValue: Value {
        get {
            if let savedValue = UserDefaults.standard.value(forKey: key) as? Value {
                return savedValue
            } else {
                UserDefaults.standard.set(startingValue, forKey: key)
                return startingValue
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
