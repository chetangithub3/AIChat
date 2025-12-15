//
//  Binding+Ext.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/15/25.
//
import SwiftUI

extension Binding where Value == Bool {
    init<T: Sendable>(ifNotNil value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}
