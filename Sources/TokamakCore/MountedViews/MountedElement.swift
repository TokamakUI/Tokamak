// Copyright 2018-2020 Tokamak contributors
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
//
//  Created by Max Desiatov on 28/11/2018.
//

import Runtime

/// The container for any of the possible `MountedElement` types
enum MountedElementKind {
  case app(_AnyApp)
  case scene(_AnyScene)
  case view(AnyView)

  var type: Any.Type {
    switch self {
    case let .app(app): return app.type
    case let .scene(scene): return scene.type
    case let .view(view): return view.type
    }
  }
}

public class MountedElement<R: Renderer> {
  private var element: MountedElementKind

  public internal(set) var app: _AnyApp {
    get {
      if case let .app(app) = element {
        return app
      } else {
        fatalError("The `MountedElement` is of type `\(element)`, not `App`.")
      }
    } set {
      element = .app(newValue)
    }
  }

  public internal(set) var scene: _AnyScene {
    get {
      if case let .scene(scene) = element {
        return scene
      } else {
        fatalError("The `MountedElement` is of type `\(element)`, not `Scene`.")
      }
    }
    set {
      element = .scene(newValue)
    }
  }

  public internal(set) var view: AnyView {
    get {
      if case let .view(view) = element {
        return view
      } else {
        fatalError("The `MountedElement` is of type `\(element)`, not `View`.")
      }
    }
    set {
      element = .view(newValue)
    }
  }

  var typeConstructorName: String {
    switch element {
    case .app: fatalError("""
    `App` values aren't supposed to be reconciled, thus the type constructor name is not stored \
    for `App` elements. Please report this crash as a bug at \
    https://github.com/swiftwasm/Tokamak/issues/new
    """)
    case let .scene(scene): return scene.typeConstructorName
    case let .view(view): return view.typeConstructorName
    }
  }

  var mountedChildren = [MountedElement<R>]()
  var environmentValues: EnvironmentValues
  unowned var parent: MountedElement<R>?
  /// `didSet` on this field propagates the preference changes up the view tree.
  var preferenceStore: _PreferenceStore {
    didSet {
      parent?.preferenceStore.merge(with: preferenceStore)
    }
  }

  init(_ app: _AnyApp, _ environmentValues: EnvironmentValues, _ parent: MountedElement<R>?) {
    element = .app(app)
    preferenceStore = .init()
    self.parent = parent
    self.environmentValues = environmentValues
    updateEnvironment()
  }

  init(_ scene: _AnyScene, _ environmentValues: EnvironmentValues, _ parent: MountedElement<R>?) {
    element = .scene(scene)
    preferenceStore = .init()
    self.parent = parent
    self.environmentValues = environmentValues
    updateEnvironment()
  }

  init(_ view: AnyView, _ environmentValues: EnvironmentValues, _ parent: MountedElement<R>?) {
    element = .view(view)
    preferenceStore = .init()
    self.parent = parent
    self.environmentValues = environmentValues
    updateEnvironment()
  }

  @discardableResult
  func updateEnvironment() -> TypeInfo {
    // swiftlint:disable:next force_try
    let info = try! typeInfo(of: element.type)
    switch element {
    case .app:
      environmentValues = info.injectEnvironment(from: environmentValues, into: &app.app)
    case .scene:
      environmentValues = info.injectEnvironment(from: environmentValues, into: &scene.scene)
    case .view:
      environmentValues = info.injectEnvironment(from: environmentValues, into: &view.view)
    }

    return info
  }

  func mount(
    before sibling: R.TargetType? = nil,
    on parent: MountedElement<R>? = nil,
    with reconciler: StackReconciler<R>
  ) {
    fatalError("implement \(#function) in subclass")
  }

  func unmount(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  func update(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  /** Traverses the tree of elements from `self` to all first descendants looking for the nearest
   `target` in a `MountedHostView`, skipping `GroupView`. The result is then used as a "cursor"
   passed to the `mount` function of a `Renderer` implementation, allowing correct in-tree updates.
   */
  var firstDescendantTarget: R.TargetType? {
    guard let hostView = self as? MountedHostView<R>, !(hostView.view.type is GroupView.Type)
    else {
      return mountedChildren.first?.firstDescendantTarget
    }

    return hostView.target
  }
}

extension TypeInfo {
  fileprivate func injectEnvironment(
    from environmentValues: EnvironmentValues,
    into element: inout Any
  ) -> EnvironmentValues {
    var modifiedEnv = environmentValues
    // swiftlint:disable force_try
    // Extract the view from the AnyView for modification, apply Environment changes:
    if genericTypes.contains(where: { $0 is EnvironmentModifier.Type }),
      let modifier = try! property(named: "modifier").get(from: element) as? EnvironmentModifier
    {
      modifier.modifyEnvironment(&modifiedEnv)
    }

    // Inject @Environment values
    // swiftlint:disable force_cast
    // `DynamicProperty`s can have `@Environment` properties contained in them,
    // so we have to inject into them as well.
    for dynamicProp in properties.filter({ $0.type is DynamicProperty.Type }) {
      let propInfo = try! typeInfo(of: dynamicProp.type)
      var propWrapper = try! dynamicProp.get(from: element) as! DynamicProperty
      for prop in propInfo.properties.filter({ $0.type is EnvironmentReader.Type }) {
        var wrapper = try! prop.get(from: propWrapper) as! EnvironmentReader
        wrapper.setContent(from: modifiedEnv)
        try! prop.set(value: wrapper, on: &propWrapper)
      }
      try! dynamicProp.set(value: propWrapper, on: &element)
    }
    for prop in properties.filter({ $0.type is EnvironmentReader.Type }) {
      var wrapper = try! prop.get(from: element) as! EnvironmentReader
      wrapper.setContent(from: modifiedEnv)
      try! prop.set(value: wrapper, on: &element)
    }
    // swiftlint:enable force_try
    // swiftlint:enable force_cast

    return modifiedEnv
  }

  /// Extract all `DynamicProperty` from a type, recursively.
  /// This is necessary as a `DynamicProperty` can be nested.
  /// `EnvironmentValues` can also be injected at this point.
  func dynamicProperties(_ environment: EnvironmentValues, source: inout Any) -> [PropertyInfo] {
    var dynamicProps = [PropertyInfo]()
    for prop in properties where prop.type is DynamicProperty.Type {
      dynamicProps.append(prop)
      // swiftlint:disable force_try
      let propInfo = try! typeInfo(of: prop.type)
      _ = propInfo.injectEnvironment(from: environment, into: &source)
      var extracted = try! prop.get(from: source)
      dynamicProps.append(
        contentsOf: propInfo.dynamicProperties(
          environment,
          source: &extracted
        )
      )
      // swiftlint:disable:next force_cast
      var extractedDynamicProp = extracted as! DynamicProperty
      extractedDynamicProp.update()
      try! prop.set(value: extractedDynamicProp, on: &source)
      // swiftlint:enable force_try
    }
    return dynamicProps
  }
}

extension AnyView {
  func makeMountedView<R: Renderer>(
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues,
    _ parent: MountedElement<R>?
  ) -> MountedElement<R> {
    if type == EmptyView.self {
      return MountedEmptyView(self, environmentValues, parent)
    } else if bodyType == Never.self && !(type is ViewDeferredToRenderer.Type) {
      return MountedHostView(self, parentTarget, environmentValues, parent)
    } else {
      return MountedCompositeView(self, parentTarget, environmentValues, parent)
    }
  }
}
