//
//  UserServices.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/26/26.
//

protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistance { get }
}
struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistance
    init(user: UserModel? = nil) {
        self.remote = MockUserService(user: user)
        self.local = MockUserPersistance(user: user)
    }
}
struct ProductionUserServices: UserServices {
    let remote: RemoteUserService = FirebaseUserService()
    let local: LocalUserPersistance = FileManagerUserPersistance()
}
