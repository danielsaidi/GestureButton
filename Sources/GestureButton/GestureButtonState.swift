//
//  GestureButtonState.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2024-09-01.
//  Copyright © 2024-2026 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS) || os(visionOS)
import Combine
import SwiftUI

/// This type is used internally to manage button state.
class GestureButtonState: ObservableObject {

    /// Create a gesture button state value.
    init(
        isPressed: Binding<Bool>? = nil,
        repeatTimer: GestureButtonTimer? = nil
    ) {
        self.isPressedBinding = isPressed
        self.repeatTimer = repeatTimer ?? .init()
    }

    let objectWillChange = ObservableObjectPublisher()
    let repeatTimer: GestureButtonTimer

    private(set) var isPressed = false

    private(set) var isDragGestureStarted = false
    private(set) var lastDragGestureValue: DragGesture.Value?
    private(set) var lastMaxDragDistance = -1.0
    var buttonGeometry = GestureButtonGeometry()

    private var isPressedBinding: Binding<Bool>?

    var isRemoved = false
    var longPressDate = Date()
    var releaseDate = Date()
    var repeatDate = Date()

    func setIsPressed(
        _ value: Bool,
        updatesLabelWithPressedState: Bool = true
    ) {
        guard value != isPressed else { return }
        if updatesLabelWithPressedState {
            objectWillChange.send()
        }
        isPressed = value
        isPressedBinding?.wrappedValue = value
    }

    /// Reset the pressed state and any pending press timers.
    func reset(
        updatesLabelWithPressedState: Bool = true
    ) {
        setIsPressed(
            false,
            updatesLabelWithPressedState: updatesLabelWithPressedState
        )
        longPressDate = Date()
        repeatDate = Date()
        guard repeatTimer.isActive else { return }
        repeatTimer.stop()
    }

    func startDragGesture(
        with value: DragGesture.Value
    ) {
        isDragGestureStarted = true
        lastMaxDragDistance = -1
        updateDragGesture(with: value)
    }

    func stopDragGesture() {
        isDragGestureStarted = false
    }

    func updateDragGesture(
        with value: DragGesture.Value
    ) {
        lastDragGestureValue = value
        let distance = distance(
            from: value.startLocation,
            to: value.location
        )
        guard distance > lastMaxDragDistance else { return }
        lastMaxDragDistance = distance
    }
}

extension GestureButtonState {

    func distance(
        from point1: CGPoint,
        to point2: CGPoint
    ) -> CGFloat {
        let xDistance = point2.x - point1.x
        let yDistance = point2.y - point1.y
        return sqrt(xDistance * xDistance + yDistance * yDistance)
    }
}

extension CGSize {

    func containsGestureLocation(_ location: CGPoint) -> Bool {
        let x = location.x
        let y = location.y
        guard x > 0, y > 0 else { return false }
        guard x < width, y < height else { return false }
        return true
    }
}

extension GeometryProxy {

    func contains(_ dragEndLocation: CGPoint) -> Bool {
        size.containsGestureLocation(dragEndLocation)
    }
}
#endif
