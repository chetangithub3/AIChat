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

@propertyWrapper
struct UserDefaultEnum<T: RawRepresentable> where T.RawValue == String {
    var wrappedValue: T {
        get {
            if let savedString = UserDefaults.standard.string(forKey: key), let savedValue = T(rawValue: savedString) {
                return savedValue
            } else {
                UserDefaults.standard.set(startingvalue.rawValue, forKey: key)
                return startingvalue
            }
        } set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
    private let key: String
    private let startingvalue: T
    init(key: String, startingvalue: T) {
        self.key = key
        self.startingvalue = startingvalue
    }
}
