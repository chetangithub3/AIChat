struct AnyAppAlert: Sendable {
    var title: String
    var message: String?
    var buttons: @Sendable () -> AnyView

    init(
        title: String,
        message: String? = nil,
        buttons: (@Sendable () -> AnyView)? = nil
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons ?? { AnyView(Button("Ok", action: {})) }
    }
    init(error: Error) {
        self.init(title: "Error!", message: error.localizedDescription, buttons: nil)
    }
}