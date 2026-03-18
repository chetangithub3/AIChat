//
//  AnyAppAlert.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/15/25.
//

import SwiftUI

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

extension View {
    @ViewBuilder
    func showCustomAlert(type: AlertType = .alert, alert: Binding<AnyAppAlert?>) -> some View {
        switch type {
            case .alert:
                self
                    .alert(alert.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: alert)) {
                        alert.wrappedValue?.buttons()
                    } message: {
                        if let message = alert.wrappedValue?.message {
                            Text(message)
                        }
                    }
            case .confirmationDialog:
                self
                    .confirmationDialog(alert.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: alert)) {
                        alert.wrappedValue?.buttons()
                    } message: {
                        if let message = alert.wrappedValue?.message {
                            Text(message)
                        }
                    }
        }
    }
}

enum AlertType {
    case alert, confirmationDialog
}
