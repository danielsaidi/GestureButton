//
//  GestureButton.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2022-11-24.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS)
import SwiftUI

/// This button can be used to trigger gesture-based actions
/// in a way that doesn't work with a `ScrollView`.
///
/// Use a ``Gestures/ScrollViewGestureButton`` when you must
/// add the button to a `ScrollView`.
public struct GestureButton<Label: View>: View {
    
    /// Create a scroll gesture button.
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
    ///   - label: The button label.
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
        endAction: Action? = nil,
        label: @escaping LabelBuilder
    ) {
        self._state = .init(wrappedValue: .init(
            isPressed: isPressed ?? .constant(false),
            pressAction: pressAction,
            cancelDelay: cancelDelay,
            releaseInsideAction: releaseInsideAction,
            releaseOutsideAction: releaseOutsideAction,
            longPressDelay: longPressDelay,
            longPressAction: longPressAction,
            doubleTapTimeout: doubleTapTimeout,
            doubleTapAction: doubleTapAction,
            repeatDelay: repeatDelay,
            repeatAction: repeatAction,
            dragStartAction: dragStartAction,
            dragAction: dragAction,
            dragEndAction: dragEndAction,
            endAction: endAction
        ))
        self.label = label
    }
    
    public typealias Action = () -> Void
    public typealias DragAction = (DragGesture.Value) -> Void
    public typealias LabelBuilder = (_ isPressed: Bool) -> Label
    
    @StateObject 
    private var state: GestureButtonState
    
    let label: LabelBuilder
    
    public var body: some View {
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
            .onChanged { value in
                state.lastGestureValue = value
                state.tryHandlePress(value)
                state.tryHandleDrag(value)
            }
            .onEnded { value in
                state.tryHandleRelease(value, in: geo)
            }
    }
    
    var gestureView: some View {
        GeometryReader { geo in
            Color.clear
                .contentShape(Rectangle())
                .gesture(gesture(for: geo)) // TODO: simultaneousGesture in iOS 18
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
