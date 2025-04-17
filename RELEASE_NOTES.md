# Release Notes

GestureButton will honor semantic versioning after version 1.0.

* Deprecations can happen at any time.
* Deprecations should only be removed in `major` updates.
* Breaking changes should only occur in `major` updates.
* Breaking changes *can* occur in `minor` and `patch` updates.

Until then, breaking changes can also happen in `minor` updates.



## 0.4

This version replaces init parameters with a new configuration.

### ✨ Features

* `GestureButton` will now read configurations from the environment.

### 🗑️ Deprecations

* `GestureButton` has temporary deprecations .




## 0.3

This version makes the GestureButton `.cancelDelay` opt-in.

If no delay is provided, the button will not cancel its gestures.



## 0.2

This version makes GestureButton use Swift 6 and strict concurrency.

It also fixes a bug where the scroll gesture button sometimes didn't trigger the repeat action in iOS 17 and earlier.  



## 0.1.2

This version makes scroll gesture state available for tvOS, although it does nothing.



## 0.1.1

This version adds support for visionOS.



## 0.1

This version adds a `GestureButtonScrollState` value to make scroll view buttons behave better.

### ✨ Features

* This version adds a `GestureButtonScrollState` class.



## 0.0.3

This version adjusts the repeat timer interval to 0.1.



## 0.0.2

This version makes the gesture timer public, so that you can reuse a timer across buttons.



## 0.0.1

This is the first beta release of this package.

### ✨ Features

* This version adds a `GestureButton` with many internal types.
