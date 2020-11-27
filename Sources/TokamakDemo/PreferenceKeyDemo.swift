//
//  File.swift
//
//
//  Created by Carson Katri on 11/26/20.
//

import TokamakShim

struct TestPreferenceKey: PreferenceKey {
  static let defaultValue = Color.red
  static func reduce(value: inout Color, nextValue: () -> Color) {
    value = nextValue()
  }
}

@available(macOS 11, iOS 14, *)
struct PreferenceKeyDemo: View {
  @State private var testKeyValue: Color = .yellow
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    VStack {
      Text("Preferences are like reverse-environment values.")
      Text(
        "In this demo, the background color of each item is set to the value of the PreferenceKey."
      )
      Text("Default color: red")
      Text("Innermost child sets the color to blue.")
      Text("One level up sets the color to green, and so on.")
      SetColor(3, .purple) {
        SetColor(2, .green) {
          SetColor(1, .blue)
        }
      }
    }
    .padding()
    .background(testKeyValue)
//    .preferredColorScheme(colorScheme == .light ? .dark : .light)
    .onPreferenceChange(TestPreferenceKey.self) {
      print("Value changed to \($0)")
      testKeyValue = $0
    }
  }

  struct SetColor<Content: View>: View {
    let level: Int
    let color: Color
    let content: Content
    @State private var testKeyValue: Color = .yellow

    init(_ level: Int, _ color: Color, @ViewBuilder _ content: () -> Content) {
      self.level = level
      self.color = color
      self.content = content()
    }

    var body: some View {
      VStack {
        Text("Level \(level)")
          .padding(.bottom, level == 1 ? 0 : 8)
        content
      }
      .padding()
      .background(testKeyValue)
      .onPreferenceChange(TestPreferenceKey.self) {
        testKeyValue = $0
      }
      .preference(key: TestPreferenceKey.self, value: color)
    }
  }
}

@available(macOS 11, iOS 14, *)
extension PreferenceKeyDemo.SetColor where Content == EmptyView {
  init(_ level: Int, _ color: Color) {
    self.init(level, color) { EmptyView() }
  }
}
