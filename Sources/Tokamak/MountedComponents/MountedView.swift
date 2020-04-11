//
//  Created by Max Desiatov on 28/11/2018.
//

public class MountedView<R: Renderer> {
  public internal(set) var view: AnyView

  init(_ view: AnyView) {
    self.view = view
  }

  func mount(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  func unmount(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  func update(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }
}

extension View {
  func makeMountedView<R: Renderer>(_ parentTarget: R.TargetType)
    -> MountedView<R> {
    let anyView = self as? AnyView ?? AnyView(self)
    if anyView.type == EmptyView.self {
      return MountedNull(anyView)
    } else if anyView.bodyType == Never.self && !(anyView.type is ViewDeferredToRenderer.Type) {
      return MountedHostView(anyView, parentTarget)
    } else {
      return MountedCompositeView(anyView, parentTarget)
    }
  }
}
