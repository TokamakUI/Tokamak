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
//
//  Created by Carson Katri on 10/10/20.
//

import CGTK
import Foundation
import TokamakCore

protocol StackProtocol {
  var alignment: Alignment { get }
}

extension _Overlay: AnyWidget where Content: AnyWidget, Overlay: AnyWidget {
    func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>? {
      nil
    }

    func update(widget: Widget) {}

    func layout<T>(size: CGSize, element: MountedHostView<T>) {
        content.layout(size: size, element: element)
        let childSize = overlay.size(for: ProposedSize(width: size.width, height: size.height), element: element)
        overlay.layout(size: childSize, element: element)
    }

  func size<T>(for proposedSize: ProposedSize, element: MountedHostView<T>) -> CGSize {
    print("SIZING _OVERLAY CONTENT")
    return content.size(for: proposedSize, element: element)
  }

}

struct Box<Content: View>: View, ParentView, AnyWidget, StackProtocol {
  let content: Content
  let orientation: GtkOrientation
  let spacing: TokamakCore.CGFloat
  let alignment: Alignment

  let expand = true

  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>? {
    nil
  }

  func update(widget: Widget) {}

  var body: Never {
    neverBody("Box")
  }

  public var children: [AnyView] {
    [AnyView(content)]
  }

    func getChildren<T>(hostView: MountedElement<T>) -> [MountedHostView<T>] {
        var children: [MountedHostView<T>] = []
        for childElement in hostView.mountedChildren {
            guard let childView = childElement as? MountedHostView<T> else {
                print("CHILD", childElement)
                children.append(contentsOf: getChildren(hostView: childElement))

                continue
            }
            if let anyWidget = mapAnyView(
                childView.view,
              transform: { (widget: AnyWidget) in widget }
            ) {
                print("CHILD 2", anyWidget)
                children.append(childView)
            } else {
                print("CHILD 3", childView)
                children.append(contentsOf: getChildren(hostView: childView))
            }
        }
        return children
    }

    func layout<T>(size: CGSize, element: MountedHostView<T>) {
        let children = getChildren(hostView: element)
        guard !children.isEmpty else { return }
        print("CHILDREN", children, size)
        var i: Int32 = 0
        let proposedSize = ProposedSize(width: size.width, height: size.height / CGFloat(children.count))
        for childElement in children {
            guard let childView = childElement as? MountedHostView<T>,
                  let anyWidget = mapAnyView(
                      childView.view,
                    transform: { (widget: AnyWidget) in widget }
                  ) else {
                continue
            }

            let size = anyWidget.size(for: proposedSize, element: childView)
            print(size)
            if let widget = element.target as? Widget, let childWidget = childView.target as? Widget {
                if case let .widget(w) = childWidget.storage {
                    widget.context.parent.withMemoryRebound(to: GtkFixed.self, capacity: 1) {
                        gtk_fixed_move($0, w, 0, i)
                    }
                }
            }
            anyWidget.layout(size: size, element: childView)
            i += Int32(size.height)

        }

    }


  func size<T>(for proposedSize: ProposedSize, element: MountedHostView<T>) -> CGSize {
    // TODO: Measure size of children, perform layout and return answer
    if let parentView = content as? ParentView {
      print("CONTENT IS PARENT")
      for child in children {
        print("CHILD", child)
      }
    } else {
      print("CONTENT IS NOT PARENT")
    }
    return .zero
  }
}


extension VStack: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(
      Box(
        content: content,
        orientation: GTK_ORIENTATION_VERTICAL,
        spacing: spacing ?? 8,
        alignment: .init(horizontal: alignment, vertical: .center)
      )
    )
  }
}

extension HStack: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(
      Box(
        content: content,
        orientation: GTK_ORIENTATION_HORIZONTAL,
        spacing: spacing ?? 8,
        alignment: .init(horizontal: .center, vertical: alignment)
      )
    )
  }
}

extension HorizontalAlignment {
  var gtkValue: GtkAlign {
    switch self {
    case .center: return GTK_ALIGN_CENTER
    case .leading: return GTK_ALIGN_START
    case .trailing: return GTK_ALIGN_END
    }
  }
}

extension VerticalAlignment {
  var gtkValue: GtkAlign {
    switch self {
    case .center: return GTK_ALIGN_CENTER
    case .top: return GTK_ALIGN_START
    case .bottom: return GTK_ALIGN_END
    }
  }
}
