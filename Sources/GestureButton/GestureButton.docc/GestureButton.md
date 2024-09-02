# ``GestureButton``

GestureButton is a SwiftUI button that can handle many different gestures.

![GestureButton Logo](Logo_rounded)

You can use a ``GestureButton/GestureButton`` just like a regular view, and specify custom actions for any gesture that you want to handle:

```swift
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
            dragStartAction: { value in print("Drag Started") },
            dragAction: { value in print("Drag \(value)") },
            dragEndAction: { value in print("Drag Ended") },
            endAction: { print("Gesture Ended") }
        ) { isPressed in
            Color.yellow // Add any label view here.
        }
    }
}
```

You can customize the various delays and timeouts to take full control over how gestures are handled, for instance the time allowed between two taps for them to count as a double-tap.



## Installation

GestureButton can be installed with the Swift Package Manager:

```
https://github.com/danielsaidi/GestureButton.git
```

GestureButton supports iOS, iPadOS, macOS, watchOS, and visionOS.



## License

GestureButton is available under the MIT license.



## Topics

### Essentials

- ``GestureButton/GestureButton``
