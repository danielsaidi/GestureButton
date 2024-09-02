//
//  ContentView.swift
//  Demo
//
//  Created by Daniel Saidi on 2024-09-02.
//

import GestureButton
import SwiftUI

struct ContentView: View {
    
    @State private var log = ""
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                buttonStackTitle("Plain:")
                buttonStack(count: 3)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                buttonStackTitle("ScrollView:")
                ScrollView(.horizontal, showsIndicators: true) {
                    buttonStack(inScrollView: true)
                }
            }
            
            TextField("", text: $log, axis: .vertical)
                .lineLimit(10, reservesSpace: true)
                .clipShape(.rect(cornerRadius: 10))
                .border(.gray)
                .padding()
        }
    }
}

private extension ContentView {
    
    func buttonStack(
        count: Int = 50,
        inScrollView: Bool = false
    ) -> some View {
        HStack(spacing: 50) {
            ForEach(0..<count, id: \.self) { _ in
                button(inScrollView: inScrollView)
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
        inScrollView: Bool
    ) -> some View {
        GestureButton(
            isInScrollView: inScrollView,
            pressAction: { log("Pressed") },
            releaseInsideAction: { log("Release: Inside") },
            releaseOutsideAction: { log("Release: Outside") },
            longPressAction: { log("Long Press") },
            doubleTapAction: { log("Double Tap") },
            repeatAction: { log("Repeat") },
            dragStartAction: { logDragValue("Start", $0) },
            // dragAction: { logDragValue("Move", $0) },
            dragEndAction: { logDragValue("End", $0) },
            endAction: { log("Ended") }
        ) { isPressed in
            Color.clear
                .overlay(buttonColor(isPressed))
                .clipShape(.rect(cornerRadius: 5))
                .shadow(radius: 1, y: 1)
                .frame(width: inScrollView ? 100 : nil)
        }
    }
    
    func buttonColor(_ isPressed: Bool) -> AnyGradient {
        isPressed ? Color.green.gradient : Color.gray.gradient
    }
    
    func log(_ text: String) {
        log = text + "\n" + log
    }
    
    func logDragValue(_ event: String, _ value: DragGesture.Value) {
        log("Drag \(event): \(value.location.x) \(value.location.y)")
    }
}

#Preview {
    ContentView()
}
