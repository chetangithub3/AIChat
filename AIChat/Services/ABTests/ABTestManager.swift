//
//  ABTestManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/16/26.
//
import SwiftUI
import FirebaseRemoteConfig
enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original, top, hidden

    static var `default`: Self {
        .original
    }
}

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    private(set) var categoryRowTest: CategoryRowTestOption

    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOption
    ) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
    }

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202604_CreateAccTest"
        case onboardingCommunityTest = "_202604_OnboardingCommTest"
        case categoryRowTest = "_202604_CategoryRowTest"
    }
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue
        ]
        return dict.compactMapValues { $0 }
    }
    mutating func update(createAccountTest newValue: Bool) {
        self.createAccountTest = newValue
    }
    mutating func update(onboardingCommunityTest newValue: Bool) {
        self.onboardingCommunityTest = newValue
    }
    mutating func update(categoryRowTest newValue: CategoryRowTestOption) {
        self.categoryRowTest = newValue
    }
}
extension ActiveABTests {
    init(config: RemoteConfig) {
        let createAccountTest = config.configValue(forKey: ActiveABTests.CodingKeys.createAccountTest.rawValue).boolValue
        self.createAccountTest = createAccountTest
        let onboardingCommunityTest = config.configValue(forKey: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue).boolValue
        self.onboardingCommunityTest = onboardingCommunityTest
        let categoryRowTestString = config.configValue(forKey: ActiveABTests.CodingKeys.categoryRowTest.rawValue).stringValue
        if let option = CategoryRowTestOption(rawValue: categoryRowTestString) {
            self.categoryRowTest = option
        } else {
            self.categoryRowTest = .default
        }
    }

    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject
        ]
    }

}

@MainActor
protocol ABTestService: Sendable {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
    func fetchUpdatedConfig() async throws -> ActiveABTests
}
@MainActor
class MockABTestService: ABTestService {
    var activeTests: ActiveABTests
    init(
        createAccountTest: Bool? = nil,
        onboardingCommunityTest: Bool? = nil,
        categoryRowTest: CategoryRowTestOption? = nil
    ) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false,
            categoryRowTest: categoryRowTest ?? .default
        )
    }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
@MainActor
class LocalAbTestService: ABTestService {
    @UserDefault(
        key: ActiveABTests.CodingKeys.createAccountTest.rawValue,
        startingvalue: .random()
    ) private var createAccountTest: Bool
    @UserDefault(
        key: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue,
        startingvalue: .random()
    ) private var onboardingCommunityTest: Bool
    @UserDefaultEnum(
        key: ActiveABTests.CodingKeys.categoryRowTest.rawValue,
        startingvalue: CategoryRowTestOption.allCases.randomElement() ?? .default
    ) private var categoryRowTest: CategoryRowTestOption
    var activeTests: ActiveABTests {
        ActiveABTests(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest,
            categoryRowTest: categoryRowTest
        )
    }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
        categoryRowTest = updatedTests.categoryRowTest
    }
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
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

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws{
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
@MainActor
@Observable
class ABTestManager {

    private let service: ABTestService
    var activeTests: ActiveABTests
    private let logManager: LogManager?

    init(service: ABTestService, logManager: LogManager? = nil) {
        self.service = service
        self.activeTests = service.activeTests
        self.logManager = logManager
        configure()
    }
    private func configure() {
        Task {
            do {
                activeTests = try await service.fetchUpdatedConfig()
                logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
                logManager?.trackEvent(event: Event.fetchRemoteConfigSuccess)
            } catch {
                logManager?.trackEvent(event: Event.fetchRemoteConfigFail(error: error))
            }
        }
    }
    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
    enum Event: LoggableEvent {
        case fetchRemoteConfigSuccess
        case fetchRemoteConfigFail(error: Error)
        var eventName: String {
            switch self {
                case .fetchRemoteConfigSuccess: return "ABTestManager_FetchRemoteConfig_Success"
                case .fetchRemoteConfigFail: return "ABTestManager_FetchRemoteConfig_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .fetchRemoteConfigFail(error: let error): return error.eventParameters
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .fetchRemoteConfigFail: return .severe
                default: return .analytic
            }
        }
    }
}
