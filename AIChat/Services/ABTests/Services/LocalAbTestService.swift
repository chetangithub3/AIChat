//
//  LocalAbTestService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/18/26.
//

import SwiftUI

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
