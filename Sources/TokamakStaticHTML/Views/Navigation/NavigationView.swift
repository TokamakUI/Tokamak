// Copyright 2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import TokamakCore

extension NavigationView: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    let proxy = _NavigationViewProxy(self)
    return AnyView(HTML("div", [
      "class": "_tokamak-navigationview",
    ]) {
      proxy.makeToolbar { title, toolbarContent in
        if let toolbarContent = toolbarContent {
          HTML("div", [
            "class": "_tokamak-toolbar",
          ]) {
            Group {
              if toolbarContent.isEmpty {
                HTML("div", ["class": "_tokamak-toolbar-leading"]) {
                  title.font(.headline)
                }
              } else {
                HTML("div", ["class": "_tokamak-toolbar-leading"]) {
                  items(from: toolbarContent, at: .navigationBarLeading)
                  items(from: toolbarContent, at: .navigation)
                  title
                    .font(.headline)
                    .padding(.trailing)
                  items(from: toolbarContent, at: .navigationBarTrailing)
                  items(from: toolbarContent, at: .automatic, .primaryAction)
                  items(from: toolbarContent, at: .destructiveAction)
                    .foregroundColor(.red)
                }
                HTML("div", ["class": "_tokamak-toolbar-center"]) {
                  items(from: toolbarContent, at: .principal, .status)
                }
                HTML("div", ["class": "_tokamak-toolbar-trailing"]) {
                  items(from: toolbarContent, at: .cancellationAction)
                  items(from: toolbarContent, at: .confirmationAction)
                    .foregroundColor(.accentColor)
                }
              }
            }
            .font(.caption)
            .buttonStyle(ToolbarButtonStyle())
            .textFieldStyle(ToolbarTextFieldStyle())
          }
        }
        HTML("div", [
          "class": toolbarContent != nil ? "_tokamak-navigationview-with-toolbar-content" : "",
        ]) {
          proxy.content
        }
        HTML("div", [
          "class": "_tokamak-navigationview-destination",
          "style": toolbarContent != nil ? "padding-top: 50px;" : "",
        ]) {
          proxy.destination
        }
      }
    })
  }

  func items(from items: [AnyToolbarItem], at placements: ToolbarItemPlacement...) -> some View {
    ForEach(
      Array(items.filter { placements.contains($0.placement) }.enumerated()),
      id: \.offset
    ) { item in
      item.element.anyContent
    }
  }
}

struct ToolbarButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    HTML("div", ["class": "_tokamak-toolbar-button"]) {
      configuration.label
        .opacity(configuration.isPressed ? 1 : 0.75)
    }
  }
}

struct ToolbarTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<_Label>) -> some View {
    HTML("div", ["class": "_tokamak-toolbar-textfield"]) {
      configuration
    }
    .frame(height: 27)
  }
}
