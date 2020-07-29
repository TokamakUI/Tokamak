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

  var elementType: Any.Type {
    switch element {
    case let .app(app): return app.type
    case let .scene(scene): return scene.type
    case let .view(view): return view.type
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

  init(_ app: _AnyApp, _ environmentValues: EnvironmentValues) {
    element = .app(app)
    self.environmentValues = environmentValues
  }

  init(_ scene: _AnyScene, _ environmentValues: EnvironmentValues) {
    element = .scene(scene)
    self.environmentValues = environmentValues
  }

  init(_ view: AnyView, _ environmentValues: EnvironmentValues) {
    element = .view(view)
    self.environmentValues = environmentValues
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

extension TypeInfo {
  func injectEnvironment(from environmentValues: EnvironmentValues, into element: inout Any) {
    // Inject @Environment values
    // swiftlint:disable force_cast
    // swiftlint:disable force_try
    // `DynamicProperty`s can have `@Environment` properties contained in them,
    // so we have to inject into them as well.
    for dynamicProp in properties.filter({ $0.type is DynamicProperty.Type }) {
      let propInfo = try! typeInfo(of: dynamicProp.type)
      var propWrapper = try! dynamicProp.get(from: element) as! DynamicProperty
      for prop in propInfo.properties.filter({ $0.type is EnvironmentReader.Type }) {
        var wrapper = try! prop.get(from: propWrapper) as! EnvironmentReader
        wrapper.setContent(from: environmentValues)
        try! prop.set(value: wrapper, on: &propWrapper)
      }
      try! dynamicProp.set(value: propWrapper, on: &element)
    }
    for prop in properties.filter({ $0.type is EnvironmentReader.Type }) {
      var wrapper = try! prop.get(from: element) as! EnvironmentReader
      wrapper.setContent(from: environmentValues)
      try! prop.set(value: wrapper, on: &element)
    }
    // swiftlint:enable force_try
    // swiftlint:enable force_cast
  }
}

extension AnyView {
  func makeMountedView<R: Renderer>(
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues
  ) -> MountedElement<R> {
    // Find Environment changes
    var modifiedEnv = environmentValues
    // swiftlint:disable force_try
    // Extract the view from the AnyView for modification
    let viewInfo = try! typeInfo(of: type)
    if viewInfo.genericTypes.filter({ $0 is EnvironmentModifier.Type }).count > 0 {
      // Apply Environment changes:
      if let modifier = try! viewInfo
        .property(named: "modifier")
        .get(from: view) as? EnvironmentModifier {
        modifier.modifyEnvironment(&modifiedEnv)
      }
    }
    var modifiedView = view
    viewInfo.injectEnvironment(from: environmentValues, into: &modifiedView)

    var anyView = self
    anyView.view = modifiedView
    if anyView.type == EmptyView.self {
      return MountedNull(anyView, modifiedEnv)
    } else if anyView.bodyType == Never.self && !(anyView.type is ViewDeferredToRenderer.Type) {
      return MountedHostView(anyView, parentTarget, modifiedEnv)
    } else {
      return MountedCompositeView(anyView, parentTarget, modifiedEnv)
    }
  }
}
