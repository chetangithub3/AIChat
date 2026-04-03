//
//  UserAuthInfo.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/19/26.
//

import SwiftUI
import FirebaseAuth

struct UserAuthInfo: Sendable, Codable {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?

    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
    }
}

extension UserAuthInfo {

    static let mock = UserAuthInfo(
        uid: "12345",
        email: "test@example.com",
        isAnonymous: false,
        creationDate: Date(timeIntervalSince1970: 1_700_000_000),
        lastSignInDate: Date()
    )

    static let anonymousMock = UserAuthInfo(
        uid: "anon_12345",
        email: nil,
        isAnonymous: true,
        creationDate: Date(timeIntervalSince1970: 1_700_000_000),
        lastSignInDate: Date()
    )

    static let newUserMock = UserAuthInfo(
        uid: "new_user_123",
        email: "newuser@example.com",
        isAnonymous: false,
        creationDate: Date(),
        lastSignInDate: Date()
    )

    static let oldUserMock = UserAuthInfo(
        uid: "old_user_123",
        email: "olduser@example.com",
        isAnonymous: false,
        creationDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()),
        lastSignInDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())
    )

    static let noEmailMock = UserAuthInfo(
        uid: "no_email_123",
        email: nil,
        isAnonymous: false,
        creationDate: Date(),
        lastSignInDate: Date()
    )
}

extension UserAuthInfo {

    static func mock(
        uid: String = UUID().uuidString,
        email: String? = "test@example.com",
        isAnonymous: Bool = false,
        creationDate: Date? = Date(),
        lastSignInDate: Date? = Date()
    ) -> UserAuthInfo {
        UserAuthInfo(
            uid: uid,
            email: email,
            isAnonymous: isAnonymous,
            creationDate: creationDate,
            lastSignInDate: lastSignInDate
        )
    }
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "uauth_\(CodingKeys.uid.rawValue)": uid,
            "uauth_\(CodingKeys.email.rawValue)": email,
            "uauth_\(CodingKeys.isAnonymous.rawValue)": isAnonymous.description,
            "uauth_\(CodingKeys.creationDate.rawValue)": creationDate?.description,
            "uauth_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate?.description
        ]
        return dict.compactMapValues({ $0 })
    }
}
