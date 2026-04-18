//
//  DevSettingsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/1/26.
//

import SwiftUI

struct DevSettingsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ABTestManager.self) private var abTestManager
    @Environment(\.dismiss) private var dismiss
    @Binding var showSettings: Bool
    @State var createAccountTest: Bool = false
    @State var onboardingCommunityTest: Bool = false
    @State private var categoryRowTest: CategoryRowTestOption = .original
    var body: some View {
        NavigationStack {
            List {
                authSection
                userSection
                abTestSection
                miscSection
            }
            .navigationTitle("Dev Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                   backbuttonView
                }
            }
            .onFirstAppear {
                loadAbTests()
            }
        }
    }
    private func loadAbTests() {
        createAccountTest = abTestManager.activeTests.createAccountTest
        onboardingCommunityTest = abTestManager.activeTests.onboardingCommunityTest
        categoryRowTest = abTestManager.activeTests.categoryRowTest
    }
    private func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.createAccountTest) { tests in
                tests.update(createAccountTest: newValue)
            }
    }
    private func handleOnboardingCommunityChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.onboardingCommunityTest) { tests in
                tests.update(onboardingCommunityTest: newValue)
            }
    }
    private func handleCategoryRowTestChange(oldValue: CategoryRowTestOption, newValue: CategoryRowTestOption) {
        updateTest(
            property: &categoryRowTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.categoryRowTest) { tests in
                tests.update(categoryRowTest: newValue)
            }
    }
    private func updateTest<T: Equatable>(
        property: inout T,
        newValue: T,
        savedValue: T,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = abTestManager.activeTests
                updateAction(&tests)
                try abTestManager.override(updatedTests: tests)
            } catch {
                property = savedValue
            }
        }
    }
    private func onBackButtonPressed() {
        dismiss()
    }
    private var backbuttonView: some View {
        Image(systemName: "xmark")
            .anyButton {
                onBackButtonPressed()
            }
    }
    private var abTestSection: some View {
        Section {
            Toggle("Create account test", isOn: $createAccountTest)
                .onChange(of: createAccountTest, handleCreateAccountChange)
            Toggle("Create account test", isOn: $onboardingCommunityTest)
                .onChange(of: onboardingCommunityTest, handleOnboardingCommunityChange)
            Picker("Category Row Test", selection: $categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: categoryRowTest, handleCategoryRowTestChange)
        } header: {
            Text("ABTest Info")
        }
    }
    private var authSection: some View {
        Section {
            let dict = authManager.auth?.eventParameters.asAlphabeticalArray ?? []
            ForEach(dict, id: \.key) { item in
                HStack {
                    Text(item.key)
                    Spacer()
                    if let str = String.convertToString(item.value) {
                        Text(str)
                    }
                }
            }
        } header: {
            Text("Auth Info")
        }
    }
    private var userSection: some View {
        Section {
            let dict =  userManager.currentUser?.eventParameters.asAlphabeticalArray ?? []
            ForEach(dict, id: \.key) { item in
                HStack {
                    Text(item.key)
                    Spacer()
                    if let str = String.convertToString(item.value) {
                        Text(str)
                    }
                }
            }
        } header: {
            Text("User Info")
        }
    }
    private var miscSection: some View {
        Section {
            let dict =  Utilities.eventParameters.asAlphabeticalArray
            ForEach(dict, id: \.key) { item in
                HStack {
                    Text(item.key)
                    Spacer()
                    if let str = String.convertToString(item.value) {
                        Text(str)
                    }
                }
            }
        } header: {
            Text("Utilities")
        }

    }
}

#Preview {
    DevSettingsView(showSettings: .constant(true))
        .previewEnvironment()
}
