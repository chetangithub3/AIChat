//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/5/25.
//

import SwiftUI

struct CreateAvatarView: View {
    @Environment(LogManager.self) private var logManager
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
            .screenAppearAnalytic(name: "CreateAvatarView")
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
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
                    .frame(maxHeight: 300)
            }
            .removeListRowFormatting()
        }

    }
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("Name your avatar*")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
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
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton {
                onBackButtonPressed()
            }
    }
    private func onGenerateImageButtonPressed() async {
        Task {
            do {
                generatingImage = true
                let prompt = AvatarModelDescriptionBuilder(charaterOption: characterOption, characterAction: characterAction, characterLocation: characterLocation).characterDescription
                logManager.trackEvent(event: Event.generateImageStart(prompt: prompt))
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.generateImageSuccess)
            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
            generatingImage = false
        }
    }
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    private func onSavePressed() async {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        isSaving = true
        Task {
            do {
                try TextValidationHelper.validateMessage(for: avatarName)
                let uid = try authManager.getAuthId()
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )
                try await avatarManager.createAavatar(avatar: avatar, image: generatedImage)
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
        isSaving = false
    }
    enum Event: LoggableEvent {
        case backButtonPressed
        case generateImageStart(prompt: String), generateImageSuccess, generateImageFail(error: Error)
        case saveAvatarStart, saveAvatarSuccess(avatar: AvatarModel), saveAvatarFail(error: Error)
        var eventName: String {
            switch self {
                case .generateImageStart: return "CreateAvatarView_GenerateImage_Start"
                case .generateImageSuccess: return "CreateAvatarView_GenerateImage_Success"
                case .generateImageFail: return "CreateAvatarView_GenerateImage_Fail"
                case .saveAvatarStart: return "CreateAvatarView_SaveAvatar_Start"
                case .saveAvatarSuccess: return "CreateAvatarView_SaveAvatar_Success"
                case .saveAvatarFail: return "CreateAvatarView_SaveAvatar_Fail"
                case .backButtonPressed: return "CreateAvatarView_BackButton_Pressed"
            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .generateImageStart(prompt: let prompt):
                    return [ "prompt": prompt]
                case .saveAvatarSuccess(avatar: let avatar):
                    return avatar.eventParameters
                case .saveAvatarFail(error: let error), .generateImageFail(error: let error):
                    return error.eventParameters
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .saveAvatarFail, .generateImageFail: return .severe
                default: return .analytic
            }
        }
    }
}

#Preview {
    CreateAvatarView()
        .environment(AIManager(service: MockAIService()))
        .environment(AuthManager(service: MockAuthService(user: .mock)))
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()
}
