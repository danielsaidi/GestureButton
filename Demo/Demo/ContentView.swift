//
//  ContentView.swift
//  Demo
//
//  Created by Daniel Saidi on 2024-09-02.
//

import GestureButton
import SwiftUI

struct ContentView: View {
    
    @FocusState var isEditing: Bool
    
    @State var log = ""
    
    @StateObject var scrollState = GestureButtonScrollState()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Plain Buttons") {
                    buttonStack(count: 3)
                }
                Section("ScrollView Buttons") {
                    ScrollView(.horizontal, showsIndicators: true) {
                        buttonStack(inScrollView: true)
                    }
                }
                logSection
            }
        }
        .navigationTitle("GestureButton Demo")
        .navigationBarTitleDisplayMode(.inline)
        .scrollGestureState(scrollState)
        .task { isEditing = true }
    }
}

private extension ContentView {
    
    func buttonStack(
        count: Int = 50,
        inScrollView: Bool = false
    ) -> some View {
        HStack(spacing: 20) {
            ForEach(0..<count, id: \.self) { _ in
                GestureButton(
                    scrollState: inScrollView ? scrollState : nil,
                    pressAction: { log("Pressed") },
                    releaseInsideAction: { log("Release: Inside") },
                    releaseOutsideAction: { log("Release: Outside") },
                    longPressAction: { log("Long Press") },
                    doubleTapAction: { log("Double Tap") },
                    repeatAction: { log("Repeat") },
                    dragStartAction: { logDragValue("Start", $0) },
                    // dragAction: { logDragValue("Move", $0) },    // Will generate a lot of logs
                    dragEndAction: { logDragValue("End", $0) },
                    endAction: { log("Ended") }
                ) { isPressed in
                    Button("Button") {}
                        .tint(buttonColor(isPressed))
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .shadow(radius: 1, y: 1)
                }
            }
        }
    }
    
    func buttonColor(_ isPressed: Bool) -> AnyGradient {
        isPressed ? Color.green.gradient : Color.accentColor.gradient
    }

    @ViewBuilder
    var logSection: some View {
        TextField("", text: $log, axis: .vertical)
            .lineLimit(5, reservesSpace: true)
            .focused($isEditing)

        Button("Clear log") {
            log = ""
        }
        .buttonStyle(.borderedProminent)
    }
}

private extension ContentView {

    func log(_ text: String) {
        log = log + text + "\n"
    }

    func logDragValue(_ event: String, _ value: DragGesture.Value) {
        log("Drag \(event): \(value.location.x.rounded()) \(value.location.y.rounded())")
    }
}

#Preview {
    ContentView()
}
