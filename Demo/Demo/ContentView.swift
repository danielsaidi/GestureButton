//
//  ContentView.swift
//  Demo
//
//  Created by Daniel Saidi on 2024-09-02.
//  Copyright © 2026 Daniel Saidi. All rights reserved.
//

import GestureButton
import SwiftUI

struct ContentView: View {
    
    @State var log = ""
    @State var repeatCount = 0

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 15) {
                GestureButton(
                    pressAction: { _ in log("Pressed") },
                    releaseInsideAction: { _ in log("Release: Inside") },
                    releaseOutsideAction: { _ in log("Release: Outside") },
                    longPressAction: { _ in log("Long Press") },
                    doubleTapAction: { _ in log("Double Tap") },
                    repeatAction: { _ in logRepeat() },
                    dragStartAction: { value, _ in logDrag("Started", value) },
                    // dragAction: { logDrag("Move", $0) },  // Lot of logs!
                    dragEndAction: { value, _ in logDrag("Ended", value) },
                    endAction: { _ in log("\nEnded") }
                ) { isPressed in
                    buttonColor(isPressed)
                        .overlay(Text(isPressed ? "Pressed!" : "Button"))
                        .compositingGroup()
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 10))
                        .shadow(radius: 1, y: 1)
                }
                Text("Log:")
                    .font(.caption)
                TextField("", text: $log, axis: .vertical)
                    .disabled(true)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(8, reservesSpace: true)
            }
            .padding(.horizontal)
            .navigationTitle("GestureButton Demo")
            .safeAreaInset(edge: .bottom) {
                Button("Clear log") {
                    log = ""
                }
            }
        }
    }
}

private extension ContentView {

    func buttonColor(_ isPressed: Bool) -> Color {
        isPressed ? .green : .accentColor
    }
}

private extension ContentView {

    func log(_ text: String) {
        log = text + "\n" + log
    }

    func logDrag(_ event: String, _ value: DragGesture.Value) {
        log("Drag \(event): \(value.location.x.rounded()) \(value.location.y.rounded())")
    }

    func logRelease(_ place: String) {
        log("Released \(place)")
    }

    func logRepeat() {
        repeatCount += 1
        guard repeatCount % 10 == 0 else { return }
        log("Repeat \(repeatCount)")
    }

    func resetState() {
        repeatCount = 0
    }
}

#Preview {
    ContentView()
}
