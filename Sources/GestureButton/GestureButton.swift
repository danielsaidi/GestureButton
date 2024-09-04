//
//  GestureButton.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2022-11-24.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS)
import SwiftUI

/// This button can be used to trigger gesture-based actions.
///
/// > Important: Make sure to use ``GestureButtonScrollState``
/// if the button is within a `ScrollView`, otherwise it may
/// block the scroll view gestures in iOS 17 and earlier and
/// trigger unwanted actions in iOS 18 and later.
public struct GestureButton<Label: View>: View {
    
    /// Create a gesture button.
    ///
    /// - Parameters:
    ///   - isPressed: A custom, optional binding to track pressed state, if any.
    ///   - scrollState: The scroll state to use, if any.
    ///   - pressAction: The action to trigger when the button is pressed, if any.
    ///   - cancelDelay: The time it takes for a cancelled press to cancel itself, by default `3.0` seconds.
    ///   - releaseInsideAction: The action to trigger when the button is released inside, if any.
    ///   - releaseOutsideAction: The action to trigger when the button is released outside of its bounds, if any.
    ///   - longPressDelay: The time it takes for a press to count as a long press, by default `0.5` seconds.
    ///   - longPressAction: The action to trigger when the button is long pressed, if any.
    ///   - doubleTapTimeout: The max time between two taps for them to count as a double tap, by default `0.2` seconds.
    ///   - doubleTapAction: The action to trigger when the button is double tapped, if any.
    ///   - repeatDelay: The time it takes for a press to start a repeating action, by default `0.5` seconds.
    ///   - repeatTimer: A custom repeat timer to use for the repeating action, if any.
    ///   - repeatAction: The action to repeat while the button is being pressed, if any.
    ///   - dragStartAction: The action to trigger when a drag gesture starts, if any.
    ///   - dragAction: The action to trigger when a drag gesture changes, if any.
    ///   - dragEndAction: The action to trigger when a drag gesture ends, if any.
    ///   - endAction: The action to trigger when a button gesture ends, if any.
    ///   - label: The button label.
    public init(
        isPressed: Binding<Bool>? = nil,
        scrollState: GestureButtonScrollState? = nil,
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
        endAction: Action? = nil,
        label: @escaping LabelBuilder
    ) {
        self._state = .init(wrappedValue: .init(
            isPressed: isPressed,
            pressAction: pressAction,
            cancelDelay: cancelDelay,
            releaseInsideAction: releaseInsideAction,
            releaseOutsideAction: releaseOutsideAction,
            longPressDelay: longPressDelay,
            longPressAction: longPressAction,
            doubleTapTimeout: doubleTapTimeout,
            doubleTapAction: doubleTapAction,
            repeatDelay: repeatDelay,
            repeatTimer: repeatTimer,
            repeatAction: repeatAction,
            dragStartAction: dragStartAction,
            dragAction: dragAction,
            dragEndAction: dragEndAction,
            endAction: endAction
        ))
        self.isInScrollView = scrollState != nil
        self._scrollState = .init(wrappedValue: scrollState ?? .init())
        self.label = label
    }

    public typealias Action = () -> Void
    public typealias DragAction = (DragGesture.Value) -> Void
    public typealias LabelBuilder = (_ isPressed: Bool) -> Label
    
    @StateObject
    private var state: GestureButtonState
    
    @ObservedObject
    private var scrollState: GestureButtonScrollState
    
    private let isInScrollView: Bool
    private let label: LabelBuilder
    
    public var body: some View {
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, *) {
            content
        } else if isInScrollView {
            /// The `simultaneousGesture` below doesn't work
            /// in iOS 17 and `ScrollViewGestureButton` does
            /// only work in iOS 17 and earlier.
            ScrollViewGestureButton(
                isPressed: $state.isPressed,
                pressAction: state.pressAction,
                releaseInsideAction: state.releaseInsideAction,
                releaseOutsideAction: state.releaseOutsideAction,
                longPressDelay: state.longPressDelay,
                longPressAction: state.longPressAction,
                doubleTapTimeout: state.doubleTapTimeout,
                doubleTapAction: state.doubleTapAction,
                repeatAction: state.repeatAction,
                dragStartAction: state.dragStartAction,
                dragAction: state.dragAction,
                dragEndAction: state.dragEndAction,
                endAction: state.endAction,
                label: label
            )
        } else {
            content
        }
    }
    
    var content: some View {
        label(state.isPressed)
            .overlay(gestureView)
            .onDisappear { state.isRemoved = true }
            .accessibilityAddTraits(.isButton)
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
        if scrollState.isScrolling { return }
        if isInScrollView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                handleDragWithState(value)
            }
        } else {
            handleDragWithState(value)
        }
    }
    
    func handleDragWithState(
        _ value: DragGesture.Value
    ) {
        if scrollState.isScrolling { return }
        if state.gestureWasStarted { return }
        state.gestureWasStarted = true
        setScrollGestureDisabledState(true)
        state.lastGestureValue = value
        state.tryHandlePress(value)
        state.tryHandleDrag(value)
    }
    
    func handleDragEnded(_ value: DragGesture.Value, in geo: GeometryProxy) {
        guard state.gestureWasStarted else { return }
        if isInScrollView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                handleDragEndedWithState(value, in: geo)
            }
        } else {
            handleDragEndedWithState(value, in: geo)
        }
    }
    
    func handleDragEndedWithState(
        _ value: DragGesture.Value,
        in geo: GeometryProxy
    ) {
        defer { resetGestureWasStarted() }
        guard state.gestureWasStarted else { return }
        setScrollGestureDisabledState(false)
        state.tryHandleRelease(value, in: geo)
    }
    
    func resetGestureWasStarted() {
        state.gestureWasStarted = false
    }
    
    func setScrollGestureDisabledState(_ new: Bool) {
        if scrollState.isScrollGestureDisabled == new { return }
        scrollState.isScrollGestureDisabled = new
    }
}

#Preview {
    
    struct Preview: View {

        @StateObject var state = GestureButtonPreview.State()
        @StateObject var scrollState = GestureButtonScrollState()

        var body: some View {
            GestureButtonPreview.Content(state: state) {
                GestureButton(
                    isPressed: $state.isPressed,
                    scrollState: scrollState,
                    pressAction: { state.pressCount += 1 },
                    releaseInsideAction: { state.releaseInsideCount += 1 },
                    releaseOutsideAction: { state.releaseOutsideCount += 1 },
                    longPressDelay: 0.8,
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
        }
    }
    
    return Preview()
}
#endif
