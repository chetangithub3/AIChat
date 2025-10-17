//
//  UserModel.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/17/25.
//

import Foundation
import SwiftUI

struct UserModel {
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        dateCreated: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    static var mocks: [Self] {
        [
            UserModel(
                userId: UUID().uuidString,
                dateCreated: Date().adding(days: -2, hours: 1),
                didCompleteOnboarding: true,
                profileColorHex: "#007AFF"
            ),
            UserModel(
                userId: UUID().uuidString,
                dateCreated: Date().adding(days: -5, hours: 1),
                didCompleteOnboarding: false,
                profileColorHex: "#FF9500"
            ),
            UserModel(
                userId: UUID().uuidString,
                dateCreated: Date(),
                didCompleteOnboarding: true,
                profileColorHex: "#AF52DE"
            )
        ]
    }
    static var mock: Self {
        mocks[0]
    }
}
