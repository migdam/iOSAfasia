//
//  Extensions.swift
//  AphasiaTherapy
//
//  Useful extensions for SwiftUI and Foundation types
//

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    func formatted(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }

    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute], from: self, to: now)

        if let years = components.year, years > 0 {
            return "\(years) year\(years == 1 ? "" : "s") ago"
        } else if let months = components.month, months > 0 {
            return "\(months) month\(months == 1 ? "" : "s") ago"
        } else if let weeks = components.weekOfYear, weeks > 0 {
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        } else if let days = components.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - String Extensions

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
}

// MARK: - Color Extensions

extension Color {
    static let primaryBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    static let primaryPurple = Color(red: 0.686, green: 0.322, blue: 0.871)

    static let successGreen = Color(red: 0.298, green: 0.686, blue: 0.314)
    static let errorRed = Color(red: 0.937, green: 0.325, blue: 0.314)
    static let warningOrange = Color(red: 1.0, green: 0.584, blue: 0.0)

    static let backgroundLight = Color(red: 0.949, green: 0.949, blue: 0.969)
    static let cardBackground = Color.white
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
}

// MARK: - Double Extensions

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    var formattedAsPercentage: String {
        return String(format: "%.1f%%", self)
    }
}

// MARK: - View Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Rounded Corner Shape

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Array Extensions

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    func setCodable<T: Codable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            set(encoded, forKey: key)
        }
    }

    func codable<T: Codable>(forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
