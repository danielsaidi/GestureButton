import SwiftUI

#if os(iOS) || os(macOS) || os(watchOS)
struct MyView: View {

    @State private var isPressed = false
    
    var body: some View {
        GestureButton(
            isPressed: $isPressed,
            pressAction: { print("Pressed") },
            releaseInsideAction: { print("Released Inside") },
            releaseOutsideAction: { print("Released Outside") },
            longPressAction: { print("Long Pressed") },
            doubleTapAction: { print("Double Tapped") },
            repeatAction: { print("Repeating Action") },
            dragStartAction: { value in print("Drag Started at \(value)") },
            dragAction: { value in print("Drag \(value)") },
            dragEndAction: { value in print("Drag Ended at \(value)") },
            endAction: { print("Gesture Ended") },
            label: { isPressed in
                isPressed ? Color.green : Color.gray // Add any label view here.
            }
        )
    }
}
#endif
