import Foundation
import SDL
@_spi(TokamakCore) import TokamakCore

protocol AnySDL {
  var expand: Bool { get }
  func new(_ application: OpaquePointer) -> SDLTarget
  func update(target: SDLTarget)
}

extension AnySDL {
  var expand: Bool { false }
}

struct SDLView<Content: View>: View, AnySDL, ParentView {
  let build: (OpaquePointer) -> SDLTarget
  let update: (SDLTarget) -> ()
  let content: Content
  let expand: Bool

  init(
    build: @escaping (OpaquePointer) -> SDLTarget,
    update: @escaping (SDLTarget) -> () = { _ in },
    expand: Bool = false,
    @ViewBuilder content: () -> Content
  ) {
    self.build = build
    self.expand = expand
    self.content = content()
    self.update = update
  }

  func new(_ application: OpaquePointer) -> SDLTarget {
    build(application)
  }

  func update(target: SDLTarget) {
    if case .renderer = target.storage {
      update(target)
    }
  }

  var body: Never {
    neverBody("SDLView")
  }

  var children: [AnyView] {
    [AnyView(content)]
  }
}

extension SDLView where Content == EmptyView {
  init(
    build: @escaping (OpaquePointer) -> SDLTarget,
    expand: Bool = false
  ) {
    self.init(build: build, expand: expand) { EmptyView() }
  }
}

final class SDLTarget: Target {
  enum Storage {
    case application(OpaquePointer?)
    case renderer(OpaquePointer?)
  }

  let storage: Storage
  var view: AnyView

  init<V: View>(_ view: V, _ ref: OpaquePointer) {
    storage = .renderer(ref)
    self.view = AnyView(view)
  }

  init(renderer ref: OpaquePointer) {
    storage = .renderer(ref)
    view = AnyView(EmptyView())
  }

  init(window ref: OpaquePointer) {
    storage = .application(ref)
    view = AnyView(EmptyView())
  }

  func destroy() {
    switch storage {
    case .application:
      fatalError("Attempt to destroy root Application.")
    case let .renderer(target):
      SDL_DestroyRenderer(target)
    }
  }
}
