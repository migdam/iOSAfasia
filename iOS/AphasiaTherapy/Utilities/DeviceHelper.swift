//
//  DeviceHelper.swift
//  AphasiaTherapy
//
//  Helper utilities for device-specific features
//

import SwiftUI
import UIKit

struct DeviceHelper {
    // MARK: - Device Type Detection

    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    // MARK: - Screen Size

    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    // MARK: - Layout Helpers

    static var columnsForGrid: Int {
        isIPad ? 3 : 2
    }

    static var sidebarWidth: CGFloat {
        isIPad ? 320 : 0
    }

    // MARK: - Safe Area

    static var safeAreaInsets: UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}

// MARK: - View Extension for iPad Support

extension View {
    @ViewBuilder
    func adaptiveNavigationViewStyle() -> some View {
        if DeviceHelper.isIPad {
            self.navigationViewStyle(DefaultNavigationViewStyle())
        } else {
            self.navigationViewStyle(StackNavigationViewStyle())
        }
    }

    func adaptivePadding() -> some View {
        self.padding(DeviceHelper.isIPad ? 20 : 16)
    }

    func adaptiveFont(size: CGFloat) -> some View {
        self.font(.system(size: DeviceHelper.isIPad ? size * 1.2 : size))
    }
}

// MARK: - Haptic Feedback

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
