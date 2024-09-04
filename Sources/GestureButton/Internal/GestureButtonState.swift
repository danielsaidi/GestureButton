//
//  GestureButtonState.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2024-09-01.
//  Copyright © 2024 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS)
import SwiftUI

/// This state is used to manage values for a gesture button.
class GestureButtonState: ObservableObject {
    
    /// Create a gesture button state value.
    init(
        isPressed: Binding<Bool>? = nil,
        pressAction: Action? = nil,
        cancelDelay: TimeInterval? = nil,
        releaseInsideAction: Action? = nil,
        releaseOutsideAction: Action? = nil,
        longPressDelay: TimeInterval? = nil,
        longPressAction: Action? = nil,
        doubleTapTimeout: TimeInterval? = nil,
        doubleTapAction: Action? = nil,
        repeatDelay: TimeInterval? = nil,
        repeatTimer: GestureButtonTimer? = nil,
        repeatAction: Action? = nil,
        dragStartAction: DragAction? = nil,
        dragAction: DragAction? = nil,
        dragEndAction: DragAction? = nil,
        endAction: Action? = nil
    ) {
        self.isPressedBinding = isPressed ?? .constant(false)
        self.pressAction = pressAction
        self.cancelDelay = cancelDelay ?? GestureButtonDefaults.cancelDelay
        self.releaseInsideAction = releaseInsideAction
        self.releaseOutsideAction = releaseOutsideAction
        self.longPressDelay = longPressDelay ?? GestureButtonDefaults.longPressDelay
        self.longPressAction = longPressAction
        self.doubleTapTimeout = doubleTapTimeout ?? GestureButtonDefaults.doubleTapTimeout
        self.doubleTapAction = doubleTapAction
        self.repeatTimer = repeatTimer ?? .init()
        self.repeatDelay = repeatDelay ?? GestureButtonDefaults.repeatDelay
        self.repeatAction = repeatAction
        self.dragStartAction = dragStartAction
        self.dragAction = dragAction
        self.dragEndAction = dragEndAction
        self.endAction = endAction
    }
    
    typealias Action = () -> Void
    typealias DragAction = (DragGesture.Value) -> Void
    
    let pressAction: Action?
    let cancelDelay: TimeInterval
    let releaseInsideAction: Action?
    let releaseOutsideAction: Action?
    let longPressDelay: TimeInterval
    let longPressAction: Action?
    let doubleTapTimeout: TimeInterval
    let doubleTapAction: Action?
    let repeatTimer: GestureButtonTimer
    let repeatDelay: TimeInterval
    let repeatAction: Action?
    let dragStartAction: DragAction?
    let dragAction: DragAction?
    let dragEndAction: DragAction?
    let endAction: Action?
    
    @Published
    var isPressed = false {
        didSet { isPressedBinding.wrappedValue = isPressed }
    }
    
    var gestureWasStarted = false
    var isPressedBinding: Binding<Bool>
    var isRemoved = false
    var lastGestureValue: DragGesture.Value?
    var longPressDate = Date()
    var releaseDate = Date()
    var repeatDate = Date()
}

extension GestureButtonState {
    
    /// We should always reset the state when a gesture ends.
    func reset() {
        isPressed = false
        longPressDate = Date()
        repeatDate = Date()
        tryStopRepeatTimer()
    }
    
    /// Try to handle any new drag gestures as a press event.
    func tryHandlePress(_ value: DragGesture.Value) {
        if isPressed { return }
        isPressed = true
        pressAction?()
        dragStartAction?(value)
        tryTriggerCancelAfterDelay()
        tryTriggerLongPressAfterDelay()
        tryTriggerRepeatAfterDelay()
    }
    
    /// Try to handle any new drag gestures as a press event.
    func tryHandleDrag(_ value: DragGesture.Value) {
        guard isPressed else { return }
        dragAction?(value)
    }
    
    /// Try to handle drag end gestures as a release event.
    ///
    /// This function will trigger several actions, based on
    /// how the gesture is ended. It will always trigger the
    /// drag end and end actions, then either of the release
    /// inside or outside actions.
    func tryHandleRelease(_ value: DragGesture.Value, in geo: GeometryProxy) {
        let shouldTrigger = self.isPressed
        reset()
        guard shouldTrigger else { return }
        releaseDate = tryTriggerDoubleTap() ? .distantPast : Date()
        dragEndAction?(value)
        if geo.contains(value.location) {
            releaseInsideAction?()
        } else {
            releaseOutsideAction?()
        }
        endAction?()
    }
    
    /// This function tries to fix an iOS bug, where buttons
    /// may not always receive a gesture end event. This can
    /// for instance happen when the button is near a scroll
    /// view and is accidentally touched when a user scrolls.
    /// The function checks if the original gesture is still
    /// the last gesture when the cancel delay triggers, and
    /// will if so cancel the gesture. Since this will cause
    /// completely still gestures to be seen as accidentally
    /// triggered, this function can yield incorrect results
    /// and should be replaced by a proper bug fix.
    func tryTriggerCancelAfterDelay() {
        let value = lastGestureValue
        let delay = cancelDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard self.lastGestureValue?.location == value?.location else { return }
            self.reset()
            self.endAction?()
        }
    }
    
    /// This function tries to trigger the double tap action
    /// if the current date is within the double tap timeout
    /// since the last release.
    func tryTriggerDoubleTap() -> Bool {
        let interval = Date().timeIntervalSince(releaseDate)
        let isDoubleTap = interval < doubleTapTimeout
        if isDoubleTap { doubleTapAction?() }
        return isDoubleTap
    }
    
    /// This function tries to trigger the long press action
    /// after the specified long press delay.
    func tryTriggerLongPressAfterDelay() {
        guard let action = longPressAction else { return }
        let date = Date()
        longPressDate = date
        let delay = longPressDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.isRemoved { return }
            guard self.longPressDate == date else { return }
            action()
        }
    }
    
    /// This function tries to start a repeat action trigger
    /// timer after repeat delay.
    func tryTriggerRepeatAfterDelay() {
        let date = Date()
        repeatDate = date
        let delay = repeatDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.isRemoved { return }
            guard self.repeatDate == date else { return }
            self.tryStartRepeatTimer()
        }
    }
    
    /// Try to start the repeat timer.
    func tryStartRepeatTimer() {
        guard let action = repeatAction else { return }
        if repeatTimer.isActive { return }
        repeatTimer.start {
            action()
        }
    }
    
    /// Try to stop the repeat timer.
    func tryStopRepeatTimer() {
        guard repeatTimer.isActive else { return }
        repeatTimer.stop()
    }
}

extension GeometryProxy {
    
    func contains(_ dragEndLocation: CGPoint) -> Bool {
        let x = dragEndLocation.x
        let y = dragEndLocation.y
        guard x > 0, y > 0 else { return false }
        guard x < size.width, y < size.height else { return false }
        return true
    }
}
#endif
