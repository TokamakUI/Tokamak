//
//  File.swift
//
//
//  Created by Carson Katri on 8/7/20.
//

import TokamakShim

struct HoverDemo: View {
  @State private var isHovering = false
  var body: some View {
    Text(isHovering ? "Hovering" : "Not Hovering")
      .onHover {
        isHovering = $0
      }
  }
}
