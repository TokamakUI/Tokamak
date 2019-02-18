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

    public let title: String?
    public let titleMode: TitleMode

    public init(title: String? = nil, titleMode: TitleMode = .automatic) {
      self.title = title
      self.titleMode = titleMode
    }
  }

  public typealias Children = AnyNode
}
