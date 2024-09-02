//
//  GestureButtonState.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2024-09-01.
//  Copyright © 2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

/// This state class is used to manage state for the buttons
/// in this library.
class GestureButtonState: ObservableObject {
    
    /// Create a gesture button state value.
    ///
    /// - Parameters:
    ///   - isPressed: A custom, optional binding to track pressed state, by default `nil`.
    ///   - pressAction: The action to trigger when the button is pressed, by default `nil`.
    ///   - cancelDelay: The time it takes for a cancelled press to cancel itself.
    ///   - releaseInsideAction: The action to trigger when the button is released inside, by default `nil`.
    ///   - releaseOutsideAction: The action to trigger when the button is released outside of its bounds, by default `nil`.
    ///   - longPressDelay: The time it takes for a press to count as a long press.
    ///   - longPressAction: The action to trigger when the button is long pressed, by default `nil`.
    ///   - doubleTapTimeout: The max time between two taps for them to count as a double tap.
    ///   - doubleTapAction: The action to trigger when the button is double tapped, by default `nil`.
    ///   - repeatDelay: The time it takes for a press to count as a repeat trigger.
    ///   - repeatTimer: The repeat timer to use for the repeat action.
    ///   - repeatAction: The action to repeat while the button is being pressed, by default `nil`.
    ///   - dragStartAction: The action to trigger when a drag gesture starts.
    ///   - dragAction: The action to trigger when a drag gesture changes.
    ///   - dragEndAction: The action to trigger when a drag gesture ends.
    ///   - endAction: The action to trigger when a button gesture ends, by default `nil`.
    public init(
        isPressed: Binding<Bool>? = nil,
        pressAction: Action? = nil,
        cancelDelay: TimeInterval = GestureButtonDefaults.cancelDelay,
        releaseInsideAction: Action? = nil,
        releaseOutsideAction: Action? = nil,
        longPressDelay: TimeInterval = GestureButtonDefaults.longPressDelay,
        longPressAction: Action? = nil,
        doubleTapTimeout: TimeInterval = GestureButtonDefaults.doubleTapTimeout,
        doubleTapAction: Action? = nil,
        repeatDelay: TimeInterval = GestureButtonDefaults.repeatDelay,
        repeatAction: Action? = nil,
        dragStartAction: DragAction? = nil,
        dragAction: DragAction? = nil,
        dragEndAction: DragAction? = nil,
        endAction: Action? = nil
    ) {
        self.isPressedBinding = isPressed ?? .constant(false)
        self.pressAction = pressAction
        self.cancelDelay = cancelDelay
        self.releaseInsideAction = releaseInsideAction
        self.releaseOutsideAction = releaseOutsideAction
        self.longPressDelay = longPressDelay
        self.longPressAction = longPressAction
        self.doubleTapTimeout = doubleTapTimeout
        self.doubleTapAction = doubleTapAction
        self.repeatDelay = repeatDelay
        self.repeatAction = repeatAction
        self.dragStartAction = dragStartAction
        self.dragAction = dragAction
        self.dragEndAction = dragEndAction
        self.endAction = endAction
    }
    
    public typealias Action = () -> Void
    public typealias DragAction = (DragGesture.Value) -> Void
    
    var isPressedBinding: Binding<Bool>
    
    let pressAction: Action?
    let cancelDelay: TimeInterval
    let releaseInsideAction: Action?
    let releaseOutsideAction: Action?
    let longPressDelay: TimeInterval
    let longPressAction: Action?
    let doubleTapTimeout: TimeInterval
    let doubleTapAction: Action?
    let repeatDelay: TimeInterval
    let repeatAction: Action?
    let dragStartAction: DragAction?
    let dragAction: DragAction?
    let dragEndAction: DragAction?
    let endAction: Action?
    
    var dates = DateStorage()
    var isPressed = false
    var isRemoved = false
    var repeatTimer = RepeatGestureTimer()
}

extension GestureButtonState {
    
    /// We should always reset the state when a gesture ends.
    func reset() {
        isPressed = false
        dates.longPressDate = Date()    // Why reset?
        dates.repeatDate = Date()
        repeatTimer.stop()
    }
}

/// This class is used for mutable, non-observed state.
class DateStorage: ObservableObject {
    
    var lastGestureDate = Date()
    var longPressDate = Date()
    var releaseDate = Date()
    var repeatDate = Date()
}
