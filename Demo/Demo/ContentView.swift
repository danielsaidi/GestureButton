//
//  ContentView.swift
//  Demo
//
//  Created by Daniel Saidi on 2024-09-02.
//

import GestureButton
import SwiftUI

struct ContentView: View {
    
    @State var isPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0...50, id: \.self) {
                        Button("\($0)") {
                            print("tap")
                        }
                    }
                }
                .controlSize(.large)
                .buttonStyle(.bordered)
            }
            GestureButton(
                isPressed: $isPressed,
                pressAction: { print("Pressed") },
                releaseInsideAction: { print("Release: Inside") },
                releaseOutsideAction: { print("Release: Outside") },
                longPressAction: { print("Long Press") },
                doubleTapAction: { print("Double Tap") },
                repeatAction: { print("Repeat") },
                endAction: { print("Ended") }
            ) { isPressed in
                isPressed ? Color.green : Color.red
            }
        }
    }
}

#Preview {
    ContentView()
}
