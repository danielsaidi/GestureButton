//
//  ScrollViewGestureButton.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2022-11-16.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS)
import SwiftUI

/// This button can be used to trigger gesture-based actions
/// in a way that works within a `ScrollView`.
///
/// Use a ``Gestures/GestureButton`` when you do not have to
/// add it to a `ScrollView`, since it's more performant.
///
/// > Note: This view uses a `ButtonStyle` to trick the view
/// into making gestures work. It can thus not apply another
/// button style. Instead, you can use the `isPressed` value
/// in the `label` builder to configure the content view.
public struct ScrollViewGestureButton<Label: View>: View {

    /// Create a gesture button.
    ///
    /// - Parameters:
    ///   - isPressed: The binding used to track pressed state, if any.
    ///   - pressAction: An action to trigger when the button is pressed, if any.
    ///   - releaseInsideAction: An action to trigger when the button is released inside, if any.
    ///   - releaseOutsideAction: An action to trigger when the button is released outside, if any.
    ///   - longPressDelay: The time it takes for a press to count as a long press, by default ``GestureButtonDefaults/longPressDelay``.
    ///   - longPressAction: An action to trigger when the button is long pressed, if any.
    ///   - doubleTapTimeout: The max time between two taps to count as a double tap, by default ``GestureButtonDefaults/doubleTapTimeout``.
    ///   - doubleTapAction: An action to trigger when the button is double tapped, if any.
    ///   - repeatDelay: The time it takes for a press to count as a repeat trigger, by default ``GestureButtonDefaults/repeatDelay``.
    ///   - repeatTimer: The repeat timer to use for the repeat action, by default a new instance.
    ///   - repeatAction: An action to repeat while the button is being pressed, if any.
    ///   - dragStartAction: An action to trigger when a drag gesture starts.
    ///   - dragAction: An action to trigger when a drag gesture changes.
    ///   - dragEndAction: An action to trigger when a drag gesture ends.
    ///   - endAction: An action to trigger when a button gesture ends, if any.
    ///   - label: The button label.
    public init(
        isPressed: Binding<Bool>? = nil,
        pressAction: Action? = nil,
        releaseInsideAction: Action? = nil,
        releaseOutsideAction: Action? = nil,
        longPressDelay: TimeInterval = GestureButtonDefaults.longPressDelay,
        longPressAction: Action? = nil,
        doubleTapTimeout: TimeInterval = GestureButtonDefaults.doubleTapTimeout,
        doubleTapAction: Action? = nil,
        repeatAction: Action? = nil,
        dragStartAction: DragAction? = nil,
        dragAction: DragAction? = nil,
        dragEndAction: DragAction? = nil,
        endAction: Action? = nil,
        label: @escaping LabelBuilder
    ) {
        self.isPressedBinding = isPressed ?? .constant(false)
        self._config = State(wrappedValue: GestureConfiguration(
            state: GestureState(),
            pressAction: pressAction ?? {},
            releaseInsideAction: releaseInsideAction ?? {},
            releaseOutsideAction: releaseOutsideAction ?? {},
            longPressDelay: longPressDelay,
            longPressAction: longPressAction ?? {},
            doubleTapTimeout: doubleTapTimeout,
            doubleTapAction: doubleTapAction ?? {},
            repeatAction: repeatAction,
            dragStartAction: dragStartAction,
            dragAction: dragAction,
            dragEndAction: dragEndAction,
            endAction: endAction ?? {},
            label: label
        ))
    }

    public typealias Action = () -> Void
    public typealias DragAction = (DragGesture.Value) -> Void
    public typealias LabelBuilder = (_ isPressed: Bool) -> Label

    var isPressedBinding: Binding<Bool>

    @State
    var config: GestureConfiguration

    @State
    private var isPressed = false

    @State
    private var isPressedByGesture = false

    public var body: some View {
        Button(action: config.releaseInsideAction) {
            config.label(isPressed)
                .withDragGestureActions(
                    for: self.config,
                    isPressed: $isPressed,
                    isPressedByGesture: $isPressedByGesture
                )
        }
        .buttonStyle(
            Style(
                isPressed: $isPressed,
                isPressedByGesture: $isPressedByGesture,
                config: config
            )
        )
        .onChange(of: isPressed) { newValue in
            isPressedBinding.wrappedValue = newValue
        }
        .onChange(of: isPressedByGesture) { newValue in
            isPressed = newValue
        }
    }
}

extension ScrollViewGestureButton {

    class GestureState: ObservableObject {

        @Published
        var doubleTapDate = Date()
    }

    struct GestureConfiguration {
        let state: GestureState
        let pressAction: Action
        let releaseInsideAction: Action
        let releaseOutsideAction: Action
        let longPressDelay: TimeInterval
        let longPressAction: Action
        let doubleTapTimeout: TimeInterval
        let doubleTapAction: Action
        let repeatAction: Action?
        let dragStartAction: DragAction?
        let dragAction: DragAction?
        let dragEndAction: DragAction?
        let endAction: Action
        let label: LabelBuilder
        
        let repeatTimer = RepeatGestureTimer()

        func tryStartRepeatTimer() {
            if repeatTimer.isActive { return }
            guard let action = repeatAction else { return }
            repeatTimer.start {
                action()
            }
        }

        func tryStopRepeatTimer() {
            guard repeatTimer.isActive else { return }
            repeatTimer.stop()
        }

        func tryTriggerDoubleTap() {
            let interval = Date().timeIntervalSince(state.doubleTapDate)
            let trigger = interval < doubleTapTimeout
            state.doubleTapDate = trigger ? .distantPast : Date()
            guard trigger else { return }
            doubleTapAction()
        }
    }

    struct Style: ButtonStyle {
        
        var isPressed: Binding<Bool>
        var isPressedByGesture: Binding<Bool>
        var config: GestureConfiguration

        @State
        var longPressDate = Date()

        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .onChange(of: configuration.isPressed) { isPressed in
                    longPressDate = Date()
                    if isPressed {
                        handleIsPressed()
                    } else {
                        handleIsEnded()
                    }
                }
        }
    }
}

private extension ScrollViewGestureButton.Style {

    func handleIsPressed() {
        isPressed.wrappedValue = true
        config.pressAction()
        tryTriggerLongPressAfterDelay(triggered: longPressDate)
    }

    func handleIsEnded() {
        if isPressedByGesture.wrappedValue { return }
        isPressed.wrappedValue = false
        config.endAction()
    }

    func tryTriggerLongPressAfterDelay(triggered date: Date) {
        DispatchQueue.main.asyncAfter(deadline: .now() + config.longPressDelay) {
            guard date == longPressDate else { return }
            config.longPressAction()
        }
    }
}

private extension View {

    typealias Action = () -> Void
    typealias DragAction = (DragGesture.Value) -> Void

    @ViewBuilder
    func withDragGestureActions<Label: View>(
        for config: ScrollViewGestureButton<Label>.GestureConfiguration,
        isPressed: Binding<Bool>,
        isPressedByGesture: Binding<Bool>
    ) -> some View {
        self.overlay(
            GeometryReader { geo in
                gesture(
                    TapGesture(count: 1).onEnded { _ in
                        let pressed = isPressed.wrappedValue
                        if !pressed { config.pressAction() }
                        toggleIsPressedForQuickTap(isPressed)
                        config.releaseInsideAction()
                        config.tryTriggerDoubleTap()
                        config.tryStopRepeatTimer()
                        if !pressed { config.endAction() }
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isPressedByGesture.wrappedValue {
                                config.dragStartAction?(value)
                            }
                            isPressedByGesture.wrappedValue = true
                            config.dragAction?(value)
                            if config.longPressDelay > 0.6 && !config.repeatTimer.isActive {
                                config.longPressAction()
                            }
                            config.tryStartRepeatTimer()
                        }
                        .onEnded { value in
                            config.dragEndAction?(value)
                            isPressedByGesture.wrappedValue = false
                            config.tryStopRepeatTimer()
                            if geo.contains(value.location) {
                                config.releaseInsideAction()
                            } else {
                                config.releaseOutsideAction()
                            }
                            config.endAction()
                        }
                )
            }
        )
    }

    func toggleIsPressedForQuickTap(_ isPressed: Binding<Bool>) {
        isPressed.wrappedValue = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPressed.wrappedValue = false
        }
    }
}

private extension GeometryProxy {

    func contains(_ dragEndLocation: CGPoint) -> Bool {
        let x = dragEndLocation.x
        let y = dragEndLocation.y
        guard x > 0, y > 0 else { return false }
        guard x < size.width, y < size.height else { return false }
        return true
    }
}

#Preview {
    
    struct Preview: View {

        @StateObject var state = GestureButtonPreview.State()

        var body: some View {
            GestureButtonPreview.Content(state: state) {
                ScrollViewGestureButton(
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
