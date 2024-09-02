//
//  ContentView.swift
//  Demo
//
//  Created by Daniel Saidi on 2024-09-02.
//

import GestureButton
import SwiftUI

struct ContentView: View {
    
    @State
    private var log = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 50) {
                    ForEach(0...50, id: \.self) { _ in
                        ScrollViewGestureButton(
                            pressAction: { log("Pressed") },
                            releaseInsideAction: { log("Release: Inside") },
                            releaseOutsideAction: { log("Release: Outside") },
                            longPressAction: { log("Long Press") },
                            doubleTapAction: { log("Double Tap") },
                            repeatAction: { log("Repeat") },
                            // dragAction: { _ in log("Drag") },
                            endAction: { log("Ended") }
                        ) { isPressed in
                            isPressed ? Color.green : Color.red
                        }
                        .frame(width: 100)
                    }
                }
            }
            Divider()
            TextField("",
                text: $log,
                axis: .vertical
            )
            .lineLimit(10, reservesSpace: true)
        }
    }
}

private extension ContentView {
    
    func log(_ text: String) {
        log.append("\n\(text)")
    }
}

#Preview {
    ContentView()
}
