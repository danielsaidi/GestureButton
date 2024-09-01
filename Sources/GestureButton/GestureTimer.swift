//
//  GestureTimer.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2021-02-17.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import Foundation

/// This timer can be used to calculate elapsed gesture time.
///
/// Call ``start()`` when a gesture starts, then inspect the
/// ``elapsedTime`` property to see how long the gesture has
/// been active.
public class GestureTimer: ObservableObject {
    
    public init() {}
    
    private var date: Date?
    
    /// The elapsed time since ``start()`` was called.
    public var elapsedTime: TimeInterval {
        guard let date = date else { return 0 }
        return Date().timeIntervalSince(date)
    }
    
    /// Start the timer.
    public func start() {
        if date != nil { return }
        date = Date()
    }
}
