//
//  ABTestManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/16/26.
//
import SwiftUI
struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    init(createAccountTest: Bool) {
        self.createAccountTest = createAccountTest
    }

    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202411_CreateAccTest"
    }
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest
        ]
        return dict.compactMapValues { $0 }
    }
    mutating func update(createAccountTest newValue: Bool) {
        self.createAccountTest = newValue
    }
}
protocol ABTestService {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
}

class MockABTestService: ABTestService {
    var activeTests: ActiveABTests
    init(createAccountTest: Bool? = nil) {
        self.activeTests = ActiveABTests(createAccountTest: createAccountTest ?? false)
    }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
}
class LocalAbTestService: ABTestService {
    @UserDefault(key: ActiveABTests.CodingKeys.createAccountTest.rawValue, startingvalue: .random()) private var createAccountTest: Bool

    var activeTests: ActiveABTests {
        ActiveABTests(createAccountTest: createAccountTest)
    }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
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
