//
//  GestureButtonGeometry.swift
//  GestureButton
//
//  Created by Daniel Saidi on 2026-08-25.
//  Copyright © 2026 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS) || os(visionOS)
import SwiftUI

/// This type provides gesture button actions with geometric
/// information about the button, without having to wrap the
/// button in a `GeometryReader`.
///
/// A button will always resolve its ``size``, and will only
/// resolve a ``frame`` if a coordinate space is provided in
/// the ``GestureButton`` initializer.
public struct GestureButtonGeometry: Equatable, Sendable {

    /// Create a gesture button geometry value.
    ///
    /// - Parameters:
    ///   - size: The size of the button.
    ///   - frame: The frame of the button, in the coordinate space it was resolved in.
    public init(
        size: CGSize = .zero,
        frame: CGRect = .zero
    ) {
        self.size = size
        self.frame = frame
    }

    /// The size of the button.
    public var size: CGSize

    /// The frame of the button, within the coordinate space
    /// that was provided to the button, otherwise `.zero`.
    public var frame: CGRect
}

public extension GestureButtonGeometry {

    /// Whether the geometry contains a local gesture point.
    func contains(_ location: CGPoint) -> Bool {
        size.containsGestureLocation(location)
    }
}

extension View {

    /// Track the geometry of the view, without wrapping the
    /// view in a `GeometryReader`.
    ///
    /// The frame is only resolved when a coordinate space
    /// is provided, otherwise it's left as `.zero`.
    @ViewBuilder
    func trackGestureButtonGeometry(
        in coordinateSpace: CoordinateSpace?,
        action: @escaping (GestureButtonGeometry) -> Void
    ) -> some View {
        if let coordinateSpace {
            self.onGeometryChange(for: GestureButtonGeometry.self) { proxy in
                .init(
                    size: proxy.size,
                    frame: proxy.frame(in: coordinateSpace)
                )
            } action: { geo in
                action(geo)
            }
        } else {
            self.onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                action(.init(size: size))
            }
        }
    }
}
#endif
