//
//  GestureButton.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2022-11-24.
//  Copyright © 2022-2025 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS) || os(visionOS)
import SwiftUI

/// This button can be used to trigger gesture-based actions.
///
/// A `cancelDelay` can be specified to make a button cancel its gesture if no
/// values are registered during the delay. This can be used to avoid a button from
/// getting stuck in a pressed state.
public struct GestureButton<Label: View>: View {
    
    /// Create a gesture button.
    ///
    /// - Parameters:
    ///   - isPressed: A custom, optional binding to track pressed state, if any.
    ///   - pressAction: The action to trigger when the button is pressed, if any.
    ///   - releaseInsideAction: The action to trigger when the button is released inside, if any.
    ///   - releaseOutsideAction: The action to trigger when the button is released outside of its bounds, if any.
    ///   - longPressAction: The action to trigger when the button is long pressed, if any.
    ///   - doubleTapAction: The action to trigger when the button is double tapped, if any.
    ///   - repeatTimer: A custom repeat timer to use for the repeating action, if any.
    ///   - repeatAction: The action to repeat while the button is being pressed, if any.
    ///   - dragStartAction: The action to trigger when a drag gesture starts, if any.
    ///   - dragAction: The action to trigger when a drag gesture changes, if any.
    ///   - dragEndAction: The action to trigger when a drag gesture ends, if any.
    ///   - endAction: The action to trigger when a button gesture ends, if any.
    ///   - accessibilityTraits: The accessibility traits to apply, by default `.isButton`.
    ///   - label: The button label.
    public init(
        isPressed: Binding<Bool>? = nil,
        pressAction: Action? = nil,
        releaseInsideAction: Action? = nil,
        releaseOutsideAction: Action? = nil,
        longPressAction: Action? = nil,
        doubleTapAction: Action? = nil,
        repeatTimer: GestureButtonTimer? = nil,
        repeatAction: Action? = nil,
        dragStartAction: DragAction? = nil,
        dragAction: DragAction? = nil,
        dragEndAction: DragAction? = nil,
        endAction: Action? = nil,
        accessibilityTraits: AccessibilityTraits = .isButton,
        label: @escaping LabelBuilder
    ) {
        self._state = .init(wrappedValue: .init(
            isPressed: isPressed,
            repeatTimer: repeatTimer
        ))
        self.pressAction = pressAction
        self.releaseInsideAction = releaseInsideAction
        self.releaseOutsideAction = releaseOutsideAction
        self.longPressAction = longPressAction
        self.doubleTapAction = doubleTapAction
        self.repeatAction = repeatAction
        self.dragStartAction = dragStartAction
        self.dragAction = dragAction
        self.dragEndAction = dragEndAction
        self.endAction = endAction
        self.accessibilityTraits = accessibilityTraits
        self.label = label
    }
    
    public typealias Action = () -> Void
    public typealias DragAction = (DragGesture.Value) -> Void
    public typealias LabelBuilder = (_ isPressed: Bool) -> Label
    
    private let pressAction: Action?
    private let releaseInsideAction: Action?
    private let releaseOutsideAction: Action?
    private let longPressAction: Action?
    private let doubleTapAction: Action?
    private let repeatAction: Action?
    private let dragStartAction: DragAction?
    private let dragAction: DragAction?
    private let dragEndAction: DragAction?
    private let endAction: Action?
    private let accessibilityTraits: AccessibilityTraits
    private let label: LabelBuilder

    @StateObject
    private var state: GestureButtonState

    @Environment(\.gestureButtonConfiguration)
    private var config
    
    public var body: some View {
        label(state.isPressed)
            .overlay(gestureView)
            .onDisappear { state.isRemoved = true }
            .accessibilityAddTraits(accessibilityTraits)
    }
}

private extension GestureButton {
    
    func gesture(
        for geo: GeometryProxy
    ) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { handleDrag($0) }
            .onEnded { handleDragEnded($0, in: geo) }
    }
    
    var gestureView: some View {
        GeometryReader { geo in
            Color.clear
                .contentShape(Rectangle())
                .simultaneousGesture(gesture(for: geo))
        }
    }
    
    func handleDrag(
        _ value: DragGesture.Value
    ) {
        state.updateDragGesture(with: value)
        tryHandleDrag(value)
        if state.isDragGestureStarted { return }
        state.startDragGesture(with: value)
        tryHandlePress(value)
    }
    
    func handleDragEnded(
        _ value: DragGesture.Value,
        in geo: GeometryProxy
    ) {
        defer { state.stopDragGesture() }
        guard state.isDragGestureStarted else { return }
        tryHandleRelease(value, in: geo)
    }

    func handleRepeatAction() {
        guard let repeatAction else { return }
        repeatAction()
    }

    func reset() {
        state.isPressed = false
        state.longPressDate = Date()
        state.repeatDate = Date()
        tryStopRepeatTimer()
    }
}

private extension GestureButton {

    func tryHandlePress(_ value: DragGesture.Value) {
        if state.isPressed { return }
        state.isPressed = true
        pressAction?()
        dragStartAction?(value)
        tryTriggerCancelAfterDelay()
        tryTriggerLongPressAfterDelay()
        tryTriggerRepeatAfterDelay()
    }

    /// Try to handle any new drag gestures as a press event.
    func tryHandleDrag(_ value: DragGesture.Value) {
        guard state.isPressed else { return }
        dragAction?(value)
    }

    /// This function triggers several actions, based on how the gesture is ended.
    ///
    /// This function will always trigger the drag end and end actions, then either
    /// of the release inside or outside actions.
    func tryHandleRelease(_ value: DragGesture.Value, in geo: GeometryProxy) {
        let shouldTrigger = state.isPressed
        reset()
        guard shouldTrigger else { return }
        state.releaseDate = tryTriggerDoubleTap() ? .distantPast : Date()
        dragEndAction?(value)
        if geo.contains(value.location) {
            releaseInsideAction?()
        } else {
            releaseOutsideAction?()
        }
        endAction?()
    }

    /// This function tries to fix an iOS bug where a button not always receives a
    /// gesture end event.
    ///
    /// This can for instance happen when the button is near a scroll view and is
    /// accidentally touched as a user scrolls. This function checks if the original
    /// gesture is still the last gesture when a cancel delay triggers, and will if so
    /// cancel the gesture.
    ///
    /// Since this causes completely still gestures to be considered accidentally
    /// triggered, this function can yield incorrect results and should be replaced
    /// by a proper bug fix.
    func tryTriggerCancelAfterDelay() {
        guard let delay = config.cancelDelay else { return }
        let value = state.lastDragGestureValue
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let location = state.lastDragGestureValue?.location
            guard location == value?.location else { return }
            self.reset()
            self.endAction?()
        }
    }

    /// This function tries to trigger the double tap action if the date is within the
    /// double tap timeout since the last release.
    func tryTriggerDoubleTap() -> Bool {
        let interval = Date().timeIntervalSince(state.releaseDate)
        let isDoubleTap = interval < config.doubleTapTimeout
        if isDoubleTap { doubleTapAction?() }
        return isDoubleTap
    }

    /// This function tries to trigger the long press action after the specified long
    /// press delay.
    func tryTriggerLongPressAfterDelay() {
        guard let action = longPressAction else { return }
        let date = Date()
        state.longPressDate = date
        DispatchQueue.main.asyncAfter(deadline: .now() + config.longPressDelay) {
            if state.isRemoved { return }
            if state.lastMaxDragDistance > config.longPressMaxDragDistance { return }
            guard state.longPressDate == date else { return }
            action()
        }
    }

    /// This function tries to start a repeat action trigger timer after repeat delay.
    func tryTriggerRepeatAfterDelay() {
        let date = Date()
        state.repeatDate = date
        DispatchQueue.main.asyncAfter(deadline: .now() + config.repeatDelay) {
            if state.isRemoved { return }
            guard state.repeatDate == date else { return }
            self.tryStartRepeatTimer()
        }
    }

    /// Try to start the repeat timer.
    func tryStartRepeatTimer() {
        if state.repeatTimer.isActive { return }
        state.repeatTimer.start {
            Task { @MainActor in
                handleRepeatAction()
            }
        }
    }

    /// Try to stop the repeat timer.
    func tryStopRepeatTimer() {
        guard state.repeatTimer.isActive else { return }
        state.repeatTimer.stop()
    }
}

#Preview {
    
    struct Preview: View {

        @StateObject var state = GestureButtonPreview.State()

        var body: some View {
            GestureButtonPreview.Content(state: state) {
                GestureButton(
                    isPressed: $state.isPressed,
                    pressAction: { state.pressCount += 1 },
                    releaseInsideAction: { state.releaseInsideCount += 1 },
                    releaseOutsideAction: { state.releaseOutsideCount += 1 },
                    longPressAction: { state.longPressCount += 1 },
                    doubleTapAction: { state.doubleTapCount += 1 },
                    repeatAction: { state.repeatCount += 1 },
                    dragStartAction: { state.dragStartValue = $0.location },
                    dragAction: { state.dragChangedValue = $0.location },
                    dragEndAction: { state.dragEndValue = $0.location },
                    endAction: { state.endCount += 1 },
                    label: { GestureButtonPreview.Item(isPressed: $0) }
                )
            }
            .gestureButtonConfiguration(
                .init(longPressDelay: 0.8)
            )
        }
    }
    
    return Preview()
}
#endif
