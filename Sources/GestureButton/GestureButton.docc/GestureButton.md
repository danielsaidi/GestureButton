# ``GestureButton``

GestureButton is a SwiftUI button that can trigger many different gesture-specific actions with a single gesture.

![GestureButton Logo](Logo_rounded)

You can use a ``GestureButton/GestureButton`` just like a regular `Button`, and can define different actions for different gestures:

```swift
struct ContentView: View {

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
            dragStartAction: { value in print("Drag Started") },
            dragAction: { value in print("Drag \(value)") },
            dragEndAction: { value in print("Drag Ended") },
            endAction: { print("Gesture Ended") }
        ) { isPressed in
            Color.yellow // You can use any button content view.
        }
    }
}
```

You can pass in various delays and timeouts to change how the button behaves, e.g. the max time between two taps for the taps to count as a double-tap. You can use any `View` as the button label.



## Installation

GestureButton can be installed with the Swift Package Manager:

```
https://github.com/danielsaidi/GestureButton.git
```



## Getting Started

A ``GestureButton`` can be used like a regular button, as shown above, but needs some extra handling when it's used in a scroll view.

In iOS 17 and earlier, you have to pass in a ``GestureButtonScrollState`` into the ``GestureButton`` initializer, for the button to not block the scroll gesture.

In iOS 18 and later, you must pass in a ``GestureButtonScrollState`` and apply it to the scroll view as well:

```swift
struct ContentView: View {

    @StateObject private var scrollState = GestureButtonScrollState()
    
    var body: some View {
        ScrollView(.horizontal) {
            GestureButton(
                scrollState: scrollState,
                pressAction: { print("Pressed") },
                label: { isPressed in
                    Color.yellow // You can use any button content view.
                }
            )
        }
        .scrollGestureState(scrollState)
    }
}
```

A future version of this library should aim to streamline this setup to only require the modifier. The gesture button should then access the state as an environment value.



## License

GestureButton is available under the MIT license.



## Topics

### Essentials

- ``GestureButton/GestureButton``
- ``GestureButtonConfiguration``
- ``GestureButtonTimer``
