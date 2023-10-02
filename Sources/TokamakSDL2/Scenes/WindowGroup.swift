import TokamakCore

extension WindowGroup: SceneDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(content)
  }
}
