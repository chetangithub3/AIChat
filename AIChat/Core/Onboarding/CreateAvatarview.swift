//
//  CreateAvatarview.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/5/25.
//

import SwiftUI

struct CreateAvatarview: View {
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(\.dismiss) private var dismiss
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    @State private var generatingImage: Bool = false
    @State private var generatedImage: UIImage?
    @State private var isSaving = false
    @State private var showAlert: AnyAppAlert?
    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributesSection
                imageSection
                saveSection
            }
            .showCustomAlert(alert: $showAlert)
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
        }
    }
    private var saveSection: some View {
        AsyncCallToActionButton(title: "Save", isLoading: isSaving) {
            Task {
                await onSavePressed()
            }
        }
        .removeListRowFormatting()
        .opacity(generatedImage == nil ? 0.5 : 1)
        .disabled(generatedImage == nil)
    }
    private var imageSection: some View {
        Section {
            HStack {
                ZStack {
                    Text("Generate Image")
                        .foregroundStyle(.accent)
                        .underline()
                        .anyButton {
                            Task {
                               await onGenerateImageButtonPressed()
                            }
                        }
                        .opacity(generatingImage ? 0 : 1)
                    ProgressView()
                        .tint(.accent)
                        .opacity(generatingImage ? 1 : 0)
                }
                .disabled(generatingImage || avatarName.isEmpty)
                Spacer()
                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let image = generatedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .clipShape(Circle())
            }
            .removeListRowFormatting()
        }

    }
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("Name your avatar*")
        }
    }
    private var attributesSection: some View {
        Section {
            Picker(selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("Is a...")
            }
            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("That is...")
            }
            Picker(selection: $characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("in the...")
            }
        } header: {
            Text("Attributes")
        }

    }
    private func onGenerateImageButtonPressed() async {
        Task {
            do {
                generatingImage = true
                let prompt = AvatarModelDescriptionBuilder(charaterOption: characterOption, characterAction: characterAction, characterLocation: characterLocation).characterDescription
                generatedImage = try await aiManager.generateImage(input: prompt)
            } catch {
                print("Error generating imahe \(error)")
            }
            generatingImage = false
        }
    }
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton {
                onBackButtonPressed()
            }
    }
    private func onBackButtonPressed() {
        dismiss()
    }
    private func onSavePressed() async {
        guard let generatedImage else { return }
        isSaving = true
        Task {
            do {
                try TextValidationHelper.validateMessage(for: avatarName)
                let uid = try authManager.getAuthId()
                let avatar = AvatarModel(
                    avatarId: UUID().uuidString,
                    name: avatarName,
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation,
                    profileImageName: nil,
                    authorId: uid,
                    dateCreated: Date()
                )
                try await avatarManager.createAavatar(avatar: avatar, image: generatedImage)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
        isSaving = false
    }
}

#Preview {
    CreateAvatarview()
        .environment(AIManager(service: MockAIService()))
        .environment(AuthManager(service: MockAuthService(user: .mock)))
        .environment(AvatarManager(service: MockAvatarService()))
}
