//
//  ContentView.swift
//  Demo
//
//  Created by Daniel Saidi on 2024-09-02.
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
                    pressAction: { log("Pressed") },
                    releaseInsideAction: { log("Release: Inside") },
                    releaseOutsideAction: { log("Release: Outside") },
                    longPressAction: { log("Long Press") },
                    doubleTapAction: { log("Double Tap") },
                    repeatAction: { logRepeat() },
                    dragStartAction: { logDragValue("Started", $0) },
                    // dragAction: { logDragValue("Move", $0) },    // Will generate a lot of logs
                    dragEndAction: { logDragValue("Ended", $0) },
                    endAction: { log("\nEnded") }
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

    func logDragValue(_ event: String, _ value: DragGesture.Value) {
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
