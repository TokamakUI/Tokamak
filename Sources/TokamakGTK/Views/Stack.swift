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

func getChildren<T>(hostView: MountedElement<T>) -> [MountedHostView<T>] {
  var children: [MountedHostView<T>] = []
  print("MOUNTEDCHILDREN COUNT", hostView.mountedChildren.count)
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
      print("CHILD 3", type(of: childView))
      children.append(contentsOf: getChildren(hostView: childView))
    }
  }
  return children
}

extension _Overlay: AnyWidget, BuiltinView where Content: View, Overlay: View {

  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget>? {
    nil
  }

  func update(widget: Widget) {}

  public func layout<T>(size: CGSize, element: MountedHostView<T>) {
    print("LAYOUT _OVERLAY CONTENT", size, content)
    let children = getChildren(hostView: element)
    content._layout(size: size, element: children[0])

    let childSize = overlay._size(for: ProposedSize(width: size.width, height: size.height), element: element)
    print("CHILDSIZE", childSize)
    overlay._layout(size: childSize, element: children[1])
  }

  public func size<T>(for proposedSize: ProposedSize, element: MountedHostView<T>) -> CGSize {
    print("SIZING _OVERLAY CONTENT")
    //    return .zero
    let children = getChildren(hostView: element)
    return content._size(for: proposedSize, element: children[0])
  }
}

extension _Overlay: ParentView {
  public var children: [AnyView] {
    [AnyView(content), AnyView(overlay)]
  }
}

struct Box<Content: View>: View, ParentView, AnyWidget, BuiltinView, StackProtocol {
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

  func layout<T>(size: CGSize, element: MountedHostView<T>) {
    let children = getChildren(hostView: element)
    guard !children.isEmpty else { return }
    print("CHILDREN", children, size)
    var i: Int32 = 0
    let proposedSize = ProposedSize(width: size.width, height: size.height / CGFloat(children.count))
    for childElement in children {
      guard let childView = childElement as? MountedHostView<T>,
            let view = mapAnyView(
              childView.view,
              transform: { (view: View) in view }
            ) else {
        continue
      }

      let size = view._size(for: proposedSize, element: childView)
      print(size)
      //            if let widget = element.target as? Widget, let childWidget = childView.target as? Widget {
      //                if case let .widget(w) = childWidget.storage {
      //                    widget.context.parent.withMemoryRebound(to: GtkFixed.self, capacity: 1) {
      //                        gtk_fixed_move($0, w, 0, i)
      //                    }
      //                }
      //            }

      if let widget = childView.target as? Widget {
        widget.context.push()
        widget.context.translate(x: CGFloat(0), y: CGFloat(i))
        view._layout(size: size, element: childView)
        widget.context.pop()
      }
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
