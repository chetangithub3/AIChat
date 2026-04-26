//
//  ABTestService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/18/26.
//

@MainActor
protocol ABTestService: Sendable {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
    func fetchUpdatedConfig() async throws -> ActiveABTests
}
