//
//  TimeFormatting.swift
//  SeaBearKit
//
//  Simple time formatting extensions for displaying durations.
//

import Foundation

extension Int {
    /// Formats seconds as MM:SS string for timer display.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// 45.formattedAsTime      // "0:45"
    /// 125.formattedAsTime     // "2:05"
    /// 3661.formattedAsTime    // "61:01"
    /// ```
    ///
    /// - Returns: Time string in M:SS or MM:SS format
    public var formattedAsTime: String {
        let minutes = self / 60
        let seconds = self % 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}

extension Double {
    /// Formats seconds as MM:SS string for timer display.
    ///
    /// Also works for `TimeInterval` since it's a typealias for `Double`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let duration: TimeInterval = 125.7
    /// duration.formattedAsTime  // "2:05"
    /// ```
    ///
    /// - Returns: Time string in M:SS or MM:SS format
    public var formattedAsTime: String {
        Int(self).formattedAsTime
    }
}
