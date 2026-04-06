//
//  AppearAnalyticsViewModifier.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/6/26.
//

import SwiftUI

struct AppearAnalyticsViewModifier: ViewModifier {
    @Environment(LogManager.self) private var logManager
    let name: String
    func body(content: Content) -> some View {
        content
            .onAppear {
                logManager.trackScreenEvent(event: Event.appear(name: name))
            }
            .onDisappear {
                logManager.trackEvent(event: Event.disappear(name: name))
            }
            
    }
    enum Event: LoggableEvent {
        var eventName: String {
            switch self {
                case .appear(let name): return "\(name)_Appear"
                case .disappear(let name): return "\(name)_Disappear"
            }
        }
        
        var parameters: [String : Any]? {
            nil
        }
        
        var type: LogType {
            .analytic
        }
        
        case appear(name: String), disappear(name: String)
        
    }
}

extension View {
    
    func screenAppearAnalytic(name: String) -> some View {
        modifier(AppearAnalyticsViewModifier(name: name))
    }
}
