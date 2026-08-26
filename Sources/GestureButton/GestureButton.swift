//
//  GestureButton.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2022-11-24.
//  Copyright © 2022-2026 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS) || os(visionOS)
import SwiftUI

/// This button can be used to trigger gesture-based actions.
///
/// A `cancelDelay` can be specified to make a button cancel
/// its gesture if no values are registered during the delay.
/// This can be used to avoid a button from getting stuck in
/// a pressed state, if a gesture is cancelled by the system.
public struct GestureButton<Label: View>: View {

    /// Create a gesture button.
    ///
    /// - Parameters:
    ///   - isPressed: A custom, optional binding to track pressed state, if any.
    ///   - coordinateSpace: A coordinate space in which to resolve the button frame, if any.
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
        coordinateSpace: CoordinateSpace? = nil,
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
        self.coordinateSpace = coordinateSpace
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

    public typealias Action = (GestureButtonGeometry) -> Void
    public typealias DragAction = (DragGesture.Value, GestureButtonGeometry) -> Void
    public typealias LabelBuilder = (_ isPressed: Bool) -> Label

    private let coordinateSpace: CoordinateSpace?
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
        gestureContent
            .onDisappear { state.tearDown() }
            .accessibilityAddTraits(accessibilityTraits)
    }
}

private extension GestureButton {

    @ViewBuilder
    var gestureContent: some View {
        label(state.isPressed)
            .contentShape(Rectangle())
            .simultaneousGesture(modernGesture)
            .trackGestureButtonGeometry(in: coordinateSpace) { geo in
                state.buttonGeometry = geo
            }
    }

    /// The current button geometry.
    var geometry: GestureButtonGeometry {
        state.buttonGeometry
    }

    var modernGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { handleDrag($0) }
            .onEnded {
                handleDragEnded(
                    $0,
                    isInside: geometry.contains($0.location)
                )
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
        isInside: Bool
    ) {
        defer { state.stopDragGesture() }
        guard state.isDragGestureStarted else { return }
        tryHandleRelease(value, isInside: isInside)
    }

    func handleRepeatAction() {
        guard let repeatAction else { return }
        repeatAction(geometry)
    }
}

private extension GestureButton {

    func tryHandlePress(_ value: DragGesture.Value) {
        if state.isPressed { return }
        state.setIsPressed(true)
        pressAction?(geometry)
        dragStartAction?(value, geometry)
        tryTriggerCancelAfterDelay()
        tryTriggerLongPressAfterDelay()
        tryTriggerRepeatAfterDelay()
    }

    /// Try to handle any new drag gestures as a press event.
    func tryHandleDrag(_ value: DragGesture.Value) {
        guard state.isPressed else { return }
        dragAction?(value, geometry)
    }

    /// This function triggers several actions, based on how the gesture is ended.
    ///
    /// This function will always trigger the drag end and end actions, then either
    /// of the release inside or outside actions.
    func tryHandleRelease(
        _ value: DragGesture.Value,
        isInside: Bool
    ) {
        let shouldTrigger = state.isPressed
        state.reset()
        guard shouldTrigger else { return }
        state.releaseDate = tryTriggerDoubleTap() ? .distantPast : Date()
        dragEndAction?(value, geometry)
        if isInside {
            releaseInsideAction?(geometry)
        } else {
            releaseOutsideAction?(geometry)
        }
        endAction?(geometry)
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
        let startLocation = state.lastDragGestureLocation
        let state = state
        let endAction = endAction
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if state.isRemoved { return }
            guard state.lastDragGestureLocation == startLocation else { return }
            state.reset()
            endAction?(state.buttonGeometry)
        }
    }

    /// This function tries to trigger the double tap action if the date is within the
    /// double tap timeout since the last release.
    func tryTriggerDoubleTap() -> Bool {
        let interval = Date().timeIntervalSince(state.releaseDate)
        let isDoubleTap = interval < config.doubleTapTimeout
        if isDoubleTap { doubleTapAction?(geometry) }
        return isDoubleTap
    }

    /// This function tries to trigger the long press action after the specified long
    /// press delay.
    func tryTriggerLongPressAfterDelay() {
        guard let action = longPressAction else { return }
        let date = Date()
        let maxDragDistance = config.longPressMaxDragDistance
        let state = state
        state.longPressDate = date
        DispatchQueue.main.asyncAfter(deadline: .now() + config.longPressDelay) {
            if state.isRemoved { return }
            if state.lastMaxDragDistance > maxDragDistance { return }
            guard state.longPressDate == date else { return }
            action(state.buttonGeometry)
        }
    }

    /// This function tries to start a repeat action trigger timer after repeat delay.
    func tryTriggerRepeatAfterDelay() {
        guard repeatAction != nil else { return }
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
}

#Preview {

    struct Preview: View {

        @StateObject var state = GestureButtonPreview.State()

        var body: some View {
            GestureButtonPreview.Content(state: state) {
                GestureButton(
                    isPressed: $state.isPressed,
                    pressAction: { _ in
                        state.pressCount += 1
                    },
                    releaseInsideAction: { _ in
                        state.releaseInsideCount += 1
                    },
                    releaseOutsideAction: { _ in
                        state.releaseOutsideCount += 1
                    },
                    longPressAction: { _ in
                        state.longPressCount += 1
                    },
                    doubleTapAction: { _ in
                        state.doubleTapCount += 1
                    },
                    repeatAction: { _ in
                        state.repeatCount += 1
                    },
                    dragStartAction: { value, _ in
                        state.dragStartValue = value.location
                    },
                    dragAction: { value, _ in
                        state.dragChangedValue = value.location
                    },
                    dragEndAction: { value, _ in
                        state.dragEndValue = value.location
                    },
                    endAction: { _ in
                        state.endCount += 1
                    },
                    label: {
                        GestureButtonPreview.Item(
                            isPressed: $0
                        )
                    }
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
