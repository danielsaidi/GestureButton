# ``GestureButton``

GestureButton can trigger many different actions with a single gesture.

![GestureButton Logo](Logo_rounded)

You can use a ``GestureButton/GestureButton`` like a regular `Button`, and define different gesture actions:

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
            if isPressed {
                Color.green
            } else {
                Color.yellow
            }
        }
        .gestureButtonConfiguration(...)
    }
}
```

You can pass in custom configurations to change how the button behaves, e.g. the max time between two taps for the taps to count as a double-tap. You can use any content `View` as the button label, based on the `isPressed` state.



## Installation

GestureButton can be installed with the Swift Package Manager:

```
https://github.com/danielsaidi/GestureButton.git
```


## Support My Work

You can [become a sponsor][Sponsors] to help me dedicate more time on my various [open-source tools][OpenSource]. Every contribution, no matter the size, makes a real difference in keeping these tools free and actively developed.



## License

GestureButton is available under the MIT license.



## Topics

### Essentials

- ``GestureButton/GestureButton``
- ``GestureButtonConfiguration``
- ``GestureButtonTimer``



[Email]: mailto:daniel.saidi@gmail.com
[Website]: https://danielsaidi.com
[GitHub]: https://github.com/danielsaidi
[OpenSource]: https://danielsaidi.com/opensource
[Sponsors]: https://github.com/sponsors/danielsaidi
