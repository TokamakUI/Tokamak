//
//  ModalPresenter.swift
//  Tokamak
//
//  Created by Max Desiatov on 31/12/2018.
//

public struct ModalPresenter: HostComponent {
  public struct Props: Equatable, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public enum PresentationStyle {
      /** Renderer targets up in the tree of nodes owning the presenter node are
       removed after the presentation completes.
       */
      case fullScreen
      case pageSheet
      case formSheet

      /** Renderer targets up in the tree of nodes owning the presenter node are
       removed after the presentation completes.
       */
      case currentContext

      /** Renderer targets up in the tree of nodes owning the presenter node are
       not removed from the target hierarchy when the presentation finishes.
       So if the presented component does not fill the screen with opaque
       content, the underlying content shows through.
       */
      case overCurrentContext

      /** Renderer targets up in the tree of nodes owning the presenter node are
       not removed from the target hierarchy when the presentation finishes.
       So if the presented component does not fill the screen with opaque
       content, the underlying content shows through.
       */
      case overFullScreen

      case blurOverFullScreen

      case popover
    }

    public enum TransitionStyle {
      case coverVertical
      case flipHorizontal
      case crossDissolve
      case partialCurl
    }

    public let dismissAnimated: Bool
    public let presentAnimated: Bool
    public let presentationStyle: PresentationStyle?
    public let transitionStyle: TransitionStyle?

    public init(
      dismissAnimated: Bool = true,
      presentAnimated: Bool = true,
      presentationStyle: PresentationStyle? = nil,
      transitionStyle: TransitionStyle? = nil
    ) {
      self.dismissAnimated = dismissAnimated
      self.presentAnimated = presentAnimated
      self.presentationStyle = presentationStyle
      self.transitionStyle = transitionStyle
    }
  }

  public typealias Children = AnyNode
}
