//
//  Ref.swift
//  Gluon
//
//  Created by Max Desiatov on 09/02/2019.
//

public protocol AnyRef: class {
  var valueAsAny: Any? { get set }
}

public final class Ref<T>: AnyRef {
  public var value: T?

  public var valueAsAny: Any? {
    get {
      return value
    }
    set {
      guard let new = newValue as? T else { return }

      value = new
    }
  }

  init(_ value: T?) {
    self.value = value
  }
}

extension Hooks {
  public func ref<T>(_ initial: T? = nil) -> Ref<T> {
    // FIXME: return an existing ref if there is one available in reconciler
    return Ref(initial)
  }
}
