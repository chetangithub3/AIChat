//
//  ABTestManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/16/26.
//
import SwiftUI
struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool

    init(createAccountTest: Bool, onboardingCommunityTest: Bool) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
    }

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202604_CreateAccTest"
        case onboardingCommunityTest = "_202604_OnboardingCommTest"
    }
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest
        ]
        return dict.compactMapValues { $0 }
    }
    mutating func update(createAccountTest newValue: Bool) {
        self.createAccountTest = newValue
    }
    mutating func update(onboardingCommunityTest newValue: Bool) {
        self.onboardingCommunityTest = newValue
    }
}
protocol ABTestService {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
}

class MockABTestService: ABTestService {
    var activeTests: ActiveABTests
    init(createAccountTest: Bool? = nil, onboardingCommunityTest: Bool? = nil) {
        self.activeTests = ActiveABTests(createAccountTest: createAccountTest ?? false, onboardingCommunityTest: onboardingCommunityTest ?? false)
    }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
}
class LocalAbTestService: ABTestService {
    @UserDefault(key: ActiveABTests.CodingKeys.createAccountTest.rawValue, startingvalue: .random()) private var createAccountTest: Bool
    @UserDefault(key: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue, startingvalue: .random()) private var onboardingCommunityTest: Bool
    var activeTests: ActiveABTests {
        ActiveABTests(createAccountTest: createAccountTest, onboardingCommunityTest: onboardingCommunityTest)
    }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
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
        activeTests = service.activeTests
        logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
}
