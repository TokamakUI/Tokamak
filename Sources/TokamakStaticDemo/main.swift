//
//  File.swift
//
//
//  Created by Carson Katri on 7/20/20.
//

import TokamakStatic

struct ContentView: View {
  var body: some View {
    Text("Hello, world!")
  }
}

let renderer = StaticRenderer(ContentView())
print(renderer.html)
