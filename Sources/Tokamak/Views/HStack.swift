//
//  Created by Max Desiatov on 08/04/2020.
//

public enum VerticalAlignment: Equatable {
  case top
  case center
  case bottom
}

public struct HStack<Content>: View where Content: View {
  let alignment: VerticalAlignment
  let spacing: CGFloat?
  public let content: Content

  public init(
    alignment: VerticalAlignment = .center,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }
}

extension HStack: ParentView {
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}
