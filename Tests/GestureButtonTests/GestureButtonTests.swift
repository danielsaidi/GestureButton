#if os(iOS) || os(macOS) || os(watchOS) || os(visionOS)
import Combine
import SwiftUI
import XCTest
@testable import GestureButton

private final class Recorder<Value: Sendable>: @unchecked Sendable {

    private let lock = NSLock()
    private var storage = [Value]()

    var count: Int {
        lock.withLock { storage.count }
    }

    var values: [Value] {
        lock.withLock { storage }
    }

    func append(_ value: Value) {
        lock.withLock { storage.append(value) }
    }
}

final class GestureButtonTests: XCTestCase {

    func testButtonSizeContainsLocation() {
        let size = CGSize(width: 100, height: 50)

        XCTAssertTrue(size.containsGestureLocation(CGPoint(x: 50, y: 25)))
        XCTAssertFalse(size.containsGestureLocation(CGPoint(x: 0, y: 25)))
        XCTAssertFalse(size.containsGestureLocation(CGPoint(x: 50, y: 0)))
        XCTAssertFalse(size.containsGestureLocation(CGPoint(x: 100, y: 25)))
        XCTAssertFalse(size.containsGestureLocation(CGPoint(x: 50, y: 50)))
        XCTAssertFalse(size.containsGestureLocation(CGPoint(x: -1, y: 25)))
        XCTAssertFalse(size.containsGestureLocation(CGPoint(x: 50, y: 51)))
        XCTAssertFalse(CGSize.zero.containsGestureLocation(CGPoint(x: 0, y: 0)))
    }

    func testSetIsPressedPublishesAndWritesOnlyChanges() {
        let bindings = Recorder<Bool>()
        let changes = Recorder<Void>()
        let binding = Binding(
            get: { false },
            set: { bindings.append($0) }
        )
        let state = GestureButtonState(isPressed: binding)
        let cancellable = state.objectWillChange.sink {
            changes.append(())
        }

        state.setIsPressed(false)
        state.setIsPressed(true)
        state.setIsPressed(true)
        state.setIsPressed(false)
        state.setIsPressed(false)

        XCTAssertEqual(changes.count, 2)
        XCTAssertEqual(bindings.values, [true, false])
        withExtendedLifetime(cancellable) {}
    }

    func testSetIsPressedPublishesWithoutBinding() {
        let changes = Recorder<Void>()
        let state = GestureButtonState()
        let cancellable = state.objectWillChange.sink {
            changes.append(())
        }

        state.setIsPressed(true)

        XCTAssertTrue(state.isPressed)
        XCTAssertEqual(changes.count, 1)
        withExtendedLifetime(cancellable) {}
    }

    func testSetIsPressedPublishesWithConstantBinding() {
        let changes = Recorder<Void>()
        let state = GestureButtonState(isPressed: .constant(false))
        let cancellable = state.objectWillChange.sink {
            changes.append(())
        }

        state.setIsPressed(true)

        XCTAssertTrue(state.isPressed)
        XCTAssertEqual(changes.count, 1)
        withExtendedLifetime(cancellable) {}
    }

    func testSetIsPressedCanSkipPublishingLabelChanges() {
        let bindings = Recorder<Bool>()
        let changes = Recorder<Void>()
        let binding = Binding(
            get: { false },
            set: { bindings.append($0) }
        )
        let state = GestureButtonState(isPressed: binding)
        let cancellable = state.objectWillChange.sink {
            changes.append(())
        }

        state.setIsPressed(true, updatesLabelWithPressedState: false)
        XCTAssertTrue(state.isPressed)
        state.setIsPressed(false, updatesLabelWithPressedState: false)

        XCTAssertFalse(state.isPressed)
        XCTAssertEqual(changes.count, 0)
        XCTAssertEqual(bindings.values, [true, false])
        withExtendedLifetime(cancellable) {}
    }
}
#endif
