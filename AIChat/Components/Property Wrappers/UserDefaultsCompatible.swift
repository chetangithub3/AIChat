//
//  UserDefaultsCompatible.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/17/26.
//

import SwiftUI

protocol UserDefaultsCompatible {}
extension Bool: UserDefaultsCompatible {}
extension Int: UserDefaultsCompatible {}
extension Double: UserDefaultsCompatible {}
extension String: UserDefaultsCompatible {}
extension URL: UserDefaultsCompatible {}
extension Float: UserDefaultsCompatible {}

@propertyWrapper
struct UserDefault<Value: UserDefaultsCompatible> {
    var wrappedValue: Value {
        get {
            if let savedValue = UserDefaults.standard.value(forKey: key) as? Value {
                return savedValue
            } else {
                UserDefaults.standard.set(startingvalue, forKey: key)
                return startingvalue
            }
        } set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    private let key: String
    private let startingvalue: Value
    
    init(key: String, startingvalue: Value) {
        self.key = key
        self.startingvalue = startingvalue
    }
}
