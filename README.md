<p align="center">
    <img src ="Resources/Logo_rounded.png" alt="GestureButton Logo" title="GestureButton" />
</p>

<p align="center">
    <img src="https://img.shields.io/github/v/release/danielsaidi/GestureButton?color=%2300550&sort=semver" alt="Version" title="Version" />
    <img src="https://img.shields.io/badge/swift-5.10-orange.svg" alt="Swift 5.10" title="Swift 5.10" />
    <img src="https://img.shields.io/badge/platform-SwiftUI-blue.svg" alt="Swift UI" title="Swift UI" />
    <img src="https://img.shields.io/github/license/danielsaidi/GestureButton" alt="MIT License" title="MIT License" />
    <a href="https://twitter.com/danielsaidi"><img src="https://img.shields.io/twitter/url?label=Twitter&style=social&url=https%3A%2F%2Ftwitter.com%2Fdanielsaidi" alt="Twitter: @danielsaidi" title="Twitter: @danielsaidi" /></a>
    <a href="https://mastodon.social/@danielsaidi"><img src="https://img.shields.io/mastodon/follow/000253346?label=mastodon&style=social" alt="Mastodon: @danielsaidi@mastodon.social" title="Mastodon: @danielsaidi@mastodon.social" /></a>
</p>


## About GestureButton

GestureButton is a SwiftUI button that can trigger many different gesture-specific actions with a single gesture.

You can use a ``GestureButton`` just like a regular `Button`, and can define different actions for different gestures:

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

A ``GestureButton`` can be used just like a regular `Button`, as shown above, but needs some extra handling when used within a `ScrollView`.

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



## Documentation

The online [documentation][Documentation] has more information, articles, code examples, etc.



## Demo Application

The demo app lets you explore the library. To try it out, just open and run the `Demo` project.



## Support my work 

You can [sponsor me][Sponsors] on GitHub Sponsors or [reach out][Email] for paid support, to help support my [open-source projects][OpenSource].

Your support makes it possible for me to put more work into these projects and make them the best they can be.



## Contact

Feel free to reach out if you have questions or if you want to contribute in any way:

* Website: [danielsaidi.com][Website]
* Mastodon: [@danielsaidi@mastodon.social][Mastodon]
* Twitter: [@danielsaidi][Twitter]
* E-mail: [daniel.saidi@gmail.com][Email]



## License

GestureButton is available under the MIT license. See the [LICENSE][License] file for more info.



[Email]: mailto:daniel.saidi@gmail.com

[Website]: https://danielsaidi.com
[GitHub]: https://github.com/danielsaidi
[Twitter]: https://twitter.com/danielsaidi
[Mastodon]: https://mastodon.social/@danielsaidi
[OpenSource]: https://danielsaidi.com/opensource
[Sponsors]: https://github.com/sponsors/danielsaidi

[Documentation]: https://danielsaidi.github.io/GestureButton
[Getting-Started]: https://danielsaidi.github.io/GestureButton/documentation/gesturebutton/getting-started
[License]: https://github.com/danielsaidi/GestureButton/blob/master/LICENSE
