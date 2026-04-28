//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/5/25.
//

import SwiftUI

@Observable
@MainActor
class CreateAvatarViewModel {
    private let authManager: AuthManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager

    private(set) var isSaving = false
    private(set) var generatingImage: Bool = false
    private(set) var generatedImage: UIImage?

    var avatarName: String = ""
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var showAlert: AnyAppAlert?

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)
        self.aiManager = container.resolve(AIManager.self)
        self.avatarManager = container.resolve(AvatarManager.self)
        self.logManager = container.resolve(LogManager.self)
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
                    return ["prompt": prompt]
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
    func onGenerateImageButtonPressed() async {
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
    func onBackButtonPressed(onDismiss: @escaping () -> Void) {
        logManager.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }
    func onSavePressed(onDismiss: @escaping () -> Void) async {
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
                onDismiss()
            } catch {
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
        isSaving = false
    }
}
struct CreateAvatarView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateAvatarViewModel
    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributesSection
                imageSection
                saveSection
            }
            .showCustomAlert(alert: $viewModel.showAlert)
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
        AsyncCallToActionButton(title: "Save", isLoading: viewModel.isSaving) {
            Task {
                await viewModel.onSavePressed {
                    dismiss()
                }
            }
        }
        .removeListRowFormatting()
        .opacity(viewModel.generatedImage == nil ? 0.5 : 1)
        .disabled(viewModel.generatedImage == nil)
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
                                await viewModel.onGenerateImageButtonPressed()
                            }
                        }
                        .opacity(viewModel.generatingImage ? 0 : 1)
                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.generatingImage ? 1 : 0)
                }
                .disabled(viewModel.generatingImage || viewModel.avatarName.isEmpty)
                Spacer()
                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let image = viewModel.generatedImage {
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
            TextField("Player 1", text: $viewModel.avatarName)
        } header: {
            Text("Name your avatar*")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    private var attributesSection: some View {
        Section {
            Picker(selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("Is a...")
            }
            Picker(selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("That is...")
            }
            Picker(selection: $viewModel.characterLocation) {
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
                viewModel.onBackButtonPressed {
                    dismiss()
                }
            }
    }
}

#Preview {
    CreateAvatarView(
        viewModel: CreateAvatarViewModel(
            container: DevPreview.shared.container
        )
    )
    .previewEnvironment()
}
