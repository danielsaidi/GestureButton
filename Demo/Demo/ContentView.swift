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
    
    @StateObject var scrollGestureState = GestureButtonScrollState()
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                buttonStackTitle("Plain:")
                buttonStack(count: 3)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                buttonStackTitle("In ScrollView:")
                ScrollView(.horizontal, showsIndicators: true) {
                    buttonStack(isInScrollView: true)
                }
            }
            
            logSection
        }
        .scrollGestureState(scrollGestureState)
        .task { isEditing = true }
    }
}

private extension ContentView {
    
    @ViewBuilder
    var logSection: some View {
        VStack(alignment: .leading) {
            TextField("", text: $log, axis: .vertical)
                .lineLimit(10, reservesSpace: true)
                .textFieldStyle(.roundedBorder)
                .focused($isEditing)
            
            Text("You have to manually scroll the text to the bottom once to make it auto-scroll as you interact with the buttons.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        
        Button("Clear log") {
            log = ""
        }
        .buttonStyle(.borderedProminent)
    }
    
    func buttonStack(
        count: Int = 50,
        isInScrollView: Bool = false
    ) -> some View {
        HStack(spacing: 25) {
            ForEach(0..<count, id: \.self) { _ in
                button(isInScrollView: isInScrollView)
            }
        }
        .padding(.horizontal)
    }
    
    func buttonStackTitle(
        _ title: String
    ) -> some View {
        Text(title)
            .font(.headline)
            .padding()
    }
    
    func button(
        isInScrollView: Bool
    ) -> some View {
        GestureButton(
            scrollState: isInScrollView ? scrollGestureState: nil,
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
            Button("Gesture Button") {}
                .tint(buttonColor(isPressed))
                .buttonStyle(.borderedProminent)
                .controlSize(.extraLarge)
                .shadow(radius: 1, y: 1)
        }
    }
    
    func buttonColor(_ isPressed: Bool) -> AnyGradient {
        isPressed ? Color.green.gradient : Color.gray.gradient
    }
    
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
