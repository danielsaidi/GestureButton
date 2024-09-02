//
//  RepeatGestureTimer.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2021-01-28.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import Foundation

/// This internal class can be used to repeat an action when
/// a button is kept pressed.
class RepeatGestureTimer: ObservableObject {

    init(
        repeatInterval: TimeInterval = 0.4
    ) {
        self.repeatInterval = repeatInterval
    }

    deinit { stop() }

    var repeatInterval: TimeInterval

    private var timer: Timer?

    private var startDate: Date?
}

extension RepeatGestureTimer {

    /// The elapsed time since the timer was started.
    var duration: TimeInterval? {
        guard let date = startDate else { return nil }
        return Date().timeIntervalSince(date)
    }

    /// Whether the timer is active.
    var isActive: Bool { timer != nil }

    /// Start the repeat gesture timer with a certain action.
    func start(action: @escaping @Sendable () -> Void) {
        if isActive { return }
        stop()
        startDate = Date()
        timer = Timer.scheduledTimer(
            withTimeInterval: repeatInterval,
            repeats: true
        ) { _ in action() }
    }

    /// Stop the repeat gesture timer.
    func stop() {
        timer?.invalidate()
        timer = nil
        startDate = nil
    }
}

extension RepeatGestureTimer {

    func modifyStartDate(to date: Date) {
        startDate = date
    }
}
