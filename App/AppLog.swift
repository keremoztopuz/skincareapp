//
//  AppLog.swift
//  SkinCare
//

import Foundation
import os

/// The app's only logging entry point.
///
/// Everything goes through the unified logging system rather than `print` or
/// `NSLog`: interpolated values are redacted as `<private>` in device logs, so
/// a failure can still be diagnosed without spilling server error codes or
/// user data into a console anyone can read.
enum AppLog {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.keremoztopuz.SkinCare",
        category: "app"
    )

    static func error(_ message: StaticString, _ error: Error? = nil) {
        if let error {
            logger.error("\(message, privacy: .public): \(String(describing: error))")
        } else {
            logger.error("\(message, privacy: .public)")
        }
    }
}
