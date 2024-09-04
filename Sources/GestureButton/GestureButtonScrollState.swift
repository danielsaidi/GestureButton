//
//  GestureButtonScrollState.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2024-09-04.
//  Copyright © 2022-2024 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS)
import SwiftUI

/// This class can be used to coordinate gesture state for a
/// scroll view and any nested ``GestureButton``.
///
/// The state will be used to avoid the gesture buttons from
/// triggering their gesture actions when scrolling. It will
/// also disable scrolling for the scroll view when a button
/// gesture is active.
///
/// To use this class, create a `@StateValue` instance of it
/// within the view that contains your scroll view, apply it
/// to the scroll view with `.scrollGestureState(state)` and
/// pass the state into the ``GestureButton``.
public class GestureButtonScrollState: ObservableObject {
    
    /// Create a scroll state value.
    public init() {}
    
    @Published
    public var isScrolling = false
    
    @Published
    public var isScrollGestureDisabled = false
}

public extension View {
    
    @ViewBuilder
    func scrollGestureState(
        _ state: GestureButtonScrollState
    ) -> some View {
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            self.scrollDisabled(state.isScrollGestureDisabled)
                .onScrollPhaseChange { oldPhase, newPhase in
                    state.isScrolling = newPhase != .idle
                }
        } else {
            self
        }
    }
}
#endif