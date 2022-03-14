//
//  Extensions.swift
//  Todolist
//
//  Created by Clément FLORET on 31/12/2021.
//

import Foundation
import SwiftUI
import UIKit

extension String {
    var isBlank: Bool {
        return allSatisfy { char in
            char.isWhitespace
        }
    }
}

extension Color {
    var toListColor: TodoListVM.ListColor {
        if #available(iOS 15.0, *) {
            switch self {
            case .blue:
                return .blue
            case .gray:
                return .gray
            case .green:
                return .green
            case .orange:
                return .orange
            case .pink:
                return .pink
            case .purple:
                return .purple
            case .red:
                return .red
            case .yellow:
                return .yellow
            case .brown:
                return .brown
            case .cyan:
                return .cyan
            case .indigo:
                return .indigo
            case .mint:
                return .mint
            default:
                return .gray
            }
        } else {
            switch self {
            case .blue:
                return .blue
            case .gray:
                return .gray
            case .green:
                return .green
            case .orange:
                return .orange
            case .pink:
                return .pink
            case .purple:
                return .purple
            case .red:
                return .red
            case .yellow:
                return .yellow
            default:
                return .gray
            }
        }
    }
}

extension Date {
    func isToday() -> Bool {
        Calendar.current.isDate(self, inSameDayAs: Date())
    }
    
    func isAlreadyHappened() -> Bool {
        if self < Date() {
            return true
        } else {
            return false
        }
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}
