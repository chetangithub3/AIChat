//
//  UserModel.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/17/25.
//

import Foundation
import SwiftUI

struct UserModel: Codable {
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?

    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool?,
        profileColorHex: String?
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }

    init(auth: UserAuthInfo, creationVersion: String? = nil) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            creationVersion: creationVersion,
            lastSignInDate: auth.lastSignInDate,
            didCompleteOnboarding: nil,
            profileColorHex: nil
        )
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
    }
    static var mocks: [Self] {
        [
            UserModel(
                userId: "user_001",
                creationDate: Date().adding(days: -2, hours: 1),
                didCompleteOnboarding: true,
                profileColorHex: "#007AFF"
            ),
            UserModel(
                userId: "user_001",
                creationDate: Date().adding(days: -5, hours: 1),
                didCompleteOnboarding: false,
                profileColorHex: "#FF9500"
            ),
            UserModel(
                userId: "user_001",
                creationDate: Date(),
                didCompleteOnboarding: true,
                profileColorHex: "#AF52DE"
            )
        ]
    }
    static var mock: Self {
        mocks[0]
    }
    var colorCalculated: Color {
        guard let hex = profileColorHex else { return .accent }
        return Color(hex: hex)
    }
}
