//
//  NavigationItem.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 04/02/2019.
//

public struct NavigationItem: HostComponent {
  public struct Props: Equatable {
    /// The mode to use when displaying the title of the navigation bar.
    public enum TitleMode {
      case automatic
      case large
      case standard
    }

    public let backItem: AnyNode?
    public let hidesBackItem: Bool
    public let leftItems: [AnyNode]
    public let rightItems: [AnyNode]
    public let title: String?
    public let titleMode: TitleMode
    public let titleView: AnyNode?

    public init(
      backItem: AnyNode? = nil,
      hidesBackItem: Bool = false,
      leftItems: [AnyNode] = [],
      rightItems: [AnyNode] = [],
      title: String? = nil,
      titleMode: TitleMode = .automatic,
      titleView: AnyNode? = nil
    ) {
      self.backItem = backItem
      self.hidesBackItem = hidesBackItem
      self.leftItems = leftItems
      self.rightItems = rightItems
      self.title = title
      self.titleMode = titleMode
      self.titleView = titleView
    }
  }

  public typealias Children = AnyNode
}
