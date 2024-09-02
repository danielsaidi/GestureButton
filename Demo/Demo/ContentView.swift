//
//  ContentView.swift
//  Demo
//
//  Created by Daniel Saidi on 2024-09-02.
//

import GestureButton
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 50) {
                    ForEach(0...50, id: \.self) { _ in
                        GestureButton(
                            pressAction: { print("Pressed") },
                            releaseInsideAction: { print("Release: Inside") },
                            releaseOutsideAction: { print("Release: Outside") },
                            longPressAction: { print("Long Press") },
                            doubleTapAction: { print("Double Tap") },
                            repeatAction: { print("Repeat") },
                            dragAction: { _ in print("Drag") },
                            endAction: { print("Ended") }
                        ) { isPressed in
                            isPressed ? Color.green : Color.red
                        }
                        .frame(width: 100)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
