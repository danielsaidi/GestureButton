# Release Notes

GestureButton will honor semantic versioning after version 1.0.

* Deprecations can happen at any time.
* Deprecations should only be removed in `major` updates.
* Breaking changes should only occur in `major` updates.
* Breaking changes *can* occur in `minor` and `patch` updates.

Until then, breaking changes can also happen in `minor` updates.



## 0.5

The scroll view fixes that were added for iOS 18 no longer work in iOS 26. Adding a `GestureButton` to a `ScrollView` once again blocks scrolling, even when using a scroll state.

Since no attempts to solve this have worked, scroll view support has been removed in this version. Don't hesistate to reach out if you find a way to make it work again in iOS 26.

### 💡 Adjustments

* The package now uses Swift 6.1. 
* The demo app now targets iOS 26.

### 💥 Breaking Changes

* `GestureButtonScrollState` has been removed.
* `GestureButtonConfiguration` must be injected with the environment.
* `ScrollViewGestureButton` has been removed.



## 0.4.1

This version lets you customize the gesture button's accessibility traits.

### ✨ Features

* `GestureButton` has a new `accessibilityTraits` init argument.



## 0.4

This version replaces init parameters with a new configuration.

This version also makes it possible to configure a max drag distance after which long presses will cancel.

### ✨ Features

* `GestureButton` will now read configurations from the environment.
* `GestureConfiguration` is a new gesture button configuration struct.
* `GestureConfiguration` has a new `longPressMaxDragDistance` property.

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
