//
//  GestureButtonConfiguration.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2025-04-17.
//  Copyright © 2025 Daniel Saidi. All rights reserved.
//

import SwiftUI

/// This configuration can be used to setup a gesture button.
public struct GestureButtonConfiguration: Codable, Equatable, Hashable, Sendable {
    
    /// Create a gesture button configuration.
    ///
    /// - Parameters:
    ///   - cancelDelay: The time it takes for a cancelled press to cancel, if any.
    ///   - doubleTapTimeout: The max time between two taps for them to count as a double tap, by default `0.2` seconds.
    ///   - longPressDelay: The time it takes for a press to count as a long press, by default `0.5` seconds.
    ///   - repeatDelay: The time it takes for a press to start a repeating action, by default `0.5` seconds.
    public init(
        cancelDelay: TimeInterval? = nil,
        doubleTapTimeout: TimeInterval? = nil,
        longPressDelay: TimeInterval? = nil,
        repeatDelay: TimeInterval? = nil
    ) {
        self.cancelDelay = cancelDelay
        self.doubleTapTimeout = doubleTapTimeout ?? 0.2
        self.longPressDelay = longPressDelay ?? 0.5
        self.repeatDelay = repeatDelay ?? 0.5
    }

    public let cancelDelay: TimeInterval?
    public let longPressDelay: TimeInterval
    public let doubleTapTimeout: TimeInterval
    public let repeatDelay: TimeInterval
}

public extension GestureButtonConfiguration {
    
    /// A standard gesture button configuration.
    static let standard = GestureButtonConfiguration()
}

public extension EnvironmentValues {
    
    /// This value will inject a config into the environment.
    @Entry var gestureButtonConfiguration = GestureButtonConfiguration.standard
}
