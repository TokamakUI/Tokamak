import Dispatch
import Foundation
import SDL
@_spi(TokamakCore) import TokamakCore

extension EnvironmentValues {
  /// Returns default settings for the GTK environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey] = .light
    // environment._defaultAppStorage = LocalStorage.standard
    // _DefaultSceneStorageProvider.default = SessionStorage.standard

    return environment
  }
}

final class SDLRenderer: Renderer {
  static var shared: SDLRenderer?
  private(set) var reconciler: StackReconciler<SDLRenderer>?
  private(set) var window: OpaquePointer?
  private var renderer: OpaquePointer?

  init<A: App>(_ app: A, _ environment: EnvironmentValues) {
    window = SDL_CreateWindow(
      "SDL Tokamak Renderer",
      Int32(SDL_WINDOWPOS_CENTERED_MASK),
      Int32(SDL_WINDOWPOS_CENTERED_MASK),
      800,
      600,
      UInt32(SDL_WINDOW_SHOWN.rawValue)
    )

    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED.rawValue)

    if let window {
      reconciler = StackReconciler(
        app: app,
        target: SDLTarget(window: window),
        environment: .defaultEnvironment.merging(environment),
        renderer: self,
        scheduler: { next in
          DispatchQueue.main.async {
            next()
            SDL_ShowWindow(window)
          }
        }
      )
    }

    SDLRenderer.shared = self
  }

  func mountTarget(
    before sibling: SDLTarget?,
    to parent: SDLTarget,
    with host: MountedHost
  ) -> TargetType? {
    guard let anyTarget = mapAnyView(
      host.view,
      transform: { (target: AnySDL) in target }
    ) else {
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    let target: OpaquePointer?
    switch parent.storage {
    case let .application(app):
      target = app
    case let .renderer(view):
      target = view
      if let view {
        // Present the view content to the window
        SDL_RenderPresent(view)
      }
    }

    guard let target else { return nil }
    return SDLTarget(host.view, target)
  }

  func update(
    target: SDLTarget,
    with host: MountedHost
  ) {
    guard let view = mapAnyView(host.view, transform: { (target: AnySDL) in target })
    else { return }

    view.update(target: target)
  }

  func unmount(
    target: SDLTarget,
    from parent: SDLTarget,
    with task: UnmountHostTask<SDLRenderer>
  ) {
    defer { task.finish() }
    guard mapAnyView(task.host.view, transform: { (target: AnySDL) in target }) != nil
    else { return }
    target.destroy()
  }

  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    type is SDLPrimitive.Type
  }

  public func primitiveBody(for view: Any) -> AnyView? {
    (view as? SDLPrimitive)?.renderedBody
  }
}

protocol SDLPrimitive {
  var renderedBody: AnyView { get }
}
