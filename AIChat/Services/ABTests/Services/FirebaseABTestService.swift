//
//  FirebaseABTestService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/18/26.
//

import SwiftUI
import FirebaseRemoteConfig

class FirebaseABTestService: ABTestService {
    var activeTests: ActiveABTests {
        ActiveABTests(config: RemoteConfig.remoteConfig())
    }

    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
        let defaultValues = ActiveABTests(
            createAccountTest: false,
            onboardingCommunityTest: false,
            categoryRowTest: .default
        )
        RemoteConfig.remoteConfig().setDefaults(defaultValues.asNSObjectDictionary)
        RemoteConfig.remoteConfig().activate()
    }

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        assertionFailure("Error: Firebase ABTests are not configurable from the client")
    }
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        let status = try await RemoteConfig.remoteConfig().fetchAndActivate()
        switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData: return activeTests
            case .error: throw RemoteConfigError.failedToFetch
            default:
                throw RemoteConfigError.failedToFetch
        }
    }

    enum RemoteConfigError: LocalizedError {
        case failedToFetch
    }
}
