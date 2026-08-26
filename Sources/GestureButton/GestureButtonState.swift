//
//  GestureButtonState.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2024-09-01.
//  Copyright © 2024-2026 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS) || os(visionOS)
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

    let repeatTimer: GestureButtonTimer

    private(set) var isPressed = false

    private(set) var isDragGestureStarted = false
    private(set) var lastDragGestureLocation: CGPoint?
    private(set) var lastMaxDragDistance = -1.0

    var buttonGeometry = GestureButtonGeometry()

    private var isPressedBinding: Binding<Bool>?

    var isRemoved = false
    var longPressDate = Date()
    var releaseDate = Date()
    var repeatDate = Date()

    func setIsPressed(
        _ value: Bool
    ) {
        guard value != isPressed else { return }
        isPressed = value
        isPressedBinding?.wrappedValue = value
    }

    /// Tear down the state when the button is removed.
    ///
    /// This resets the state without publishing any changes,
    /// since publishing while the button is being removed can
    /// cause SwiftUI to warn about view update side-effects.
    func tearDown() {
        isRemoved = true
        reset()
    }

    /// Reset the pressed state and any pending press timers.
    func reset() {
        setIsPressed(false)
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
        lastDragGestureLocation = value.location
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
