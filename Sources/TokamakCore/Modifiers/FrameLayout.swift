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

public struct _FrameLayout: ViewModifier {
  public let width: CGFloat?
  public let height: CGFloat?
  public let alignment: Alignment

  init(width: CGFloat?, height: CGFloat?, alignment: Alignment) {
    self.width = width
    self.height = height
    self.alignment = alignment
  }

  public func body(content: Content) -> some View {
    content
  }
}

extension RenderingContext {
  func align(_ childSize: CGSize, in parentSize: CGSize, alignment: Alignment) {
    let parentPoint = alignment.point(for: parentSize)
    let childPoint = alignment.point(for: childSize)
    translate(x: parentPoint.x - childPoint.x, y: parentPoint.y - childPoint.y)
  }
}

public extension _FrameLayout {
  func size<T, C: View>(for proposedSize: ProposedSize, hostView: MountedHostView<T>,
                        content: C) -> CGSize
  {
    print("FRAMELAYOUT SIZE")
    if let width = self.width, let height = self.height {
      print("W", width, "H", height)
      return CGSize(width: width, height: height)
    }
    let children = hostView.getChildren()
    let childSize = content._size(
      for: ProposedSize(width: width ?? proposedSize.width, height: height ?? proposedSize.height),
      hostView: children[0]
    )
    return CGSize(width: width ?? childSize.width, height: height ?? childSize.height)
  }

  func layout<T, C: View>(size: CGSize, hostView: MountedHostView<T>, content: C) {
    guard let context = hostView.target?.context else { return }
    print("FRAMELAYOUT LAYOUT")
    let children = hostView.getChildren()

    context.push()

    let childSize = content._size(for: ProposedSize(size), hostView: children[0])

    context.align(childSize, in: size, alignment: alignment)

    content._layout(size: childSize, hostView: children[0])
    context.pop()
  }
}

public extension View {
  func frame(
    width: CGFloat? = nil,
    height: CGFloat? = nil,
    alignment: Alignment = .center
  ) -> some View {
    modifier(_FrameLayout(width: width, height: height, alignment: alignment))
  }
}
