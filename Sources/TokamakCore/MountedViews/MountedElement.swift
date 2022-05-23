// Copyright 2018-2021 Tokamak contributors
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

/// The container for any of the possible `MountedElement` types
private enum MountedElementKind {
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
  var type: Any.Type { element.type }

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

  public var transaction: Transaction = .init(animation: nil)
  /// Where this element is the process of mounting/unmounting.
  var transitionPhase = TransitionPhase.willMount
  /// The current `UnmountTask` of this element.
  var unmountTask: UnmountTask<R>?

  public internal(set) var environmentValues: EnvironmentValues

  private(set) weak var parent: MountedElement<R>?

  var preferenceStore: _PreferenceStore = .init()

  public internal(set) var viewTraits: _ViewTraitStore

  init(_ app: _AnyApp, _ environmentValues: EnvironmentValues, _ parent: MountedElement<R>?) {
    element = .app(app)
    self.parent = parent
    self.environmentValues = environmentValues
    viewTraits = .init()
    updateEnvironment()
    connectParentPreferenceStore()
  }

  init(_ scene: _AnyScene, _ environmentValues: EnvironmentValues, _ parent: MountedElement<R>?) {
    element = .scene(scene)
    self.parent = parent
    self.environmentValues = environmentValues
    viewTraits = .init()
    updateEnvironment()
    connectParentPreferenceStore()
  }

  init(
    _ view: AnyView,
    _ environmentValues: EnvironmentValues,
    _ viewTraits: _ViewTraitStore,
    _ parent: MountedElement<R>?
  ) {
    element = .view(view)
    self.parent = parent
    self.environmentValues = environmentValues
    self.viewTraits = viewTraits
    updateEnvironment()
    connectParentPreferenceStore()
  }

  func updateEnvironment() {
    let type = element.type
    switch element {
    case .app:
      environmentValues.inject(into: &app.app, type)
    case .scene:
      environmentValues.inject(into: &scene.scene, type)
    case .view:
      environmentValues.inject(into: &view.view, type)
    }
  }

  func connectParentPreferenceStore() {
    preferenceStore.parent = parent?.preferenceStore
  }

  /// You must call `super.prepareForMount` before all other mounting work.
  func prepareForMount(with transaction: Transaction) {
    // `GroupView`'s don't really mount, so let their children transition if the group can.
    if case let .view(view) = element,
       view.type is GroupView.Type
    {
      transitionPhase = parent?.transitionPhase ?? .normal
    }
    // Allow the root of a mount to transition
    // (if their parent isn't mounting, then they are the root of the mount).
    if parent?.transitionPhase == .normal {
      viewTraits.insert(
        transaction.animation != nil
          || _AnyTransitionProxy(viewTraits.transition)
          .resolve(in: environmentValues)
          .insertionAnimation != nil,
        forKey: CanTransitionTraitKey.self
      )
    }
  }

  /// You must call `super.mount` after all other mounting work.
  func mount(
    before sibling: R.TargetType? = nil,
    on parent: MountedElement<R>? = nil,
    in reconciler: StackReconciler<R>,
    with transaction: Transaction
  ) {
    // Set the phase to `normal` after finished mounting.
    transitionPhase = .normal
  }

  /// You must call `super.unmount` before all other unmounting work.
  func unmount(
    in reconciler: StackReconciler<R>,
    with transaction: Transaction,
    parentTask: UnmountTask<R>?
  ) {
    if !(self is MountedHostView<R>) {
      unmountTask = parentTask?.appendChild()
    }

    // `GroupView`'s don't really unmount, so let their children transition if the group can.
    if case let .view(view) = element,
       view.type is GroupView.Type
    {
      transitionPhase = parent?.transitionPhase ?? .normal
    } else {
      // Set the phase to `willUnmount` before unmounting.
      transitionPhase = .willUnmount
    }
    // Allow the root of an unmount to transition
    // (if their parent isn't unmounting, then they are the root of the unmount).
    if parent?.transitionPhase == .normal {
      viewTraits.insert(
        transaction.animation != nil
          || _AnyTransitionProxy(viewTraits.transition)
          .resolve(in: environmentValues)
          .removalAnimation != nil,
        forKey: CanTransitionTraitKey.self
      )
    }
  }

  func update(in reconciler: StackReconciler<R>, with transaction: Transaction) {
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

extension EnvironmentValues {
  mutating func inject(into element: inout Any, _ type: Any.Type) {
    guard let info = typeInfo(of: type) else { return }

    // Extract the view from the AnyView for modification, apply Environment changes:
    if let container = element as? ModifierContainer {
      container.environmentModifier?.modifyEnvironment(&self)
    }

    // Inject @Environment values
    // swiftlint:disable force_cast
    // `DynamicProperty`s can have `@Environment` properties contained in them,
    // so we have to inject into them as well.
    for dynamicProp in info.properties.filter({ $0.type is DynamicProperty.Type }) {
      guard let propInfo = typeInfo(of: dynamicProp.type) else { return }
      var propWrapper = dynamicProp.get(from: element) as! DynamicProperty
      for prop in propInfo.properties.filter({ $0.type is EnvironmentReader.Type }) {
        var wrapper = prop.get(from: propWrapper) as! EnvironmentReader
        wrapper.setContent(from: self)
        prop.set(value: wrapper, on: &propWrapper)
      }
      dynamicProp.set(value: propWrapper, on: &element)
    }
    for prop in info.properties.filter({ $0.type is EnvironmentReader.Type }) {
      var wrapper = prop.get(from: element) as! EnvironmentReader
      wrapper.setContent(from: self)
      prop.set(value: wrapper, on: &element)
    }
    // swiftlint:enable force_cast
  }
}

extension TypeInfo {
  /// Extract all `DynamicProperty` from a type, recursively.
  /// This is necessary as a `DynamicProperty` can be nested.
  /// `EnvironmentValues` can also be injected at this point.
  func dynamicProperties(
    _ environment: inout EnvironmentValues,
    source: inout Any
  ) -> [PropertyInfo] {
    var dynamicProps = [PropertyInfo]()
    for prop in properties where prop.type is DynamicProperty.Type {
      dynamicProps.append(prop)
      guard let propInfo = typeInfo(of: prop.type) else { continue }

      environment.inject(into: &source, prop.type)
      var extracted = prop.get(from: source)
      dynamicProps.append(
        contentsOf: propInfo.dynamicProperties(
          &environment,
          source: &extracted
        )
      )
      // swiftlint:disable:next force_cast
      var extractedDynamicProp = extracted as! DynamicProperty
      extractedDynamicProp.update()
      prop.set(value: extractedDynamicProp, on: &source)
    }
    return dynamicProps
  }
}

extension AnyView {
  func makeMountedView<R: Renderer>(
    _ renderer: R,
    _ parentTarget: R.TargetType,
    _ environmentValues: EnvironmentValues,
    _ viewTraits: _ViewTraitStore,
    _ parent: MountedElement<R>?
  ) -> MountedElement<R> {
    if type == EmptyView.self {
      return MountedEmptyView(self, environmentValues, viewTraits, parent)
    } else if bodyType == Never.self && !renderer.isPrimitiveView(type) {
      return MountedHostView(self, parentTarget, environmentValues, viewTraits, parent)
    } else {
      return MountedCompositeView(self, parentTarget, environmentValues, viewTraits, parent)
    }
  }
}
