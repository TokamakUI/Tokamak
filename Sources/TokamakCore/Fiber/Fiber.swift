// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 2/15/22.
//

import Foundation
import OpenCombineShim

// swiftlint:disable type_body_length
@_spi(TokamakCore)
public extension FiberReconciler {
  /// A manager for a single `View`.
  ///
  /// There are always 2 `Fiber`s for every `View` in the tree,
  /// a current `Fiber`, and a work in progress `Fiber`.
  /// They point to each other using the `alternate` property.
  ///
  /// The current `Fiber` represents the `View` as it is currently rendered on the screen.
  /// The work in progress `Fiber` (the `alternate` of current),
  /// is used in the reconciler to compute the new tree.
  ///
  /// When reconciling, the tree is recomputed from
  /// the root of the state change on the work in progress `Fiber`.
  /// Each node in the fiber tree is updated to apply any changes,
  /// and a list of mutations needed to get the rendered output to match is created.
  ///
  /// After the entire tree has been traversed, the current and work in progress trees are swapped,
  /// making the updated tree the current one,
  /// and leaving the previous current tree available to apply future changes on.
  final class Fiber {
    weak var reconciler: FiberReconciler<Renderer>?

    /// The underlying value behind this `Fiber`. Either a `Scene` or `View` instance.
    ///
    /// Stored as an IUO because it uses `bindProperties` to create the underlying instance,
    /// and captures a weak reference to `self` in the visitor function,
    /// which requires all stored properties be set before capturing.
    @_spi(TokamakCore)
    public var content: Content!

    /// Outputs from evaluating `View._makeView`
    ///
    /// Stored as an IUO because creating `ViewOutputs` depends on
    /// the `bindProperties` method, which requires
    /// all stored properties be set before using.
    /// `outputs` is guaranteed to be set in the initializer.
    var outputs: ViewOutputs!

    /// The erased `Layout` to use for this content.
    ///
    /// Stored as an IUO because it uses `bindProperties` to create the underlying instance.
    var layout: AnyLayout?

    /// The identity of this `View`
    var id: Identity?

    /// The mounted element, if this is a `Renderer` primitive.
    var element: Renderer.ElementType?

    /// The index of this element in its `elementParent`
    var elementIndex: Int?

    /// The first child node.
    @_spi(TokamakCore)
    public var child: Fiber?

    /// This node's right sibling.
    @_spi(TokamakCore)
    public var sibling: Fiber?

    /// An unowned reference to the parent node.
    ///
    /// Parent references are `unowned` (as opposed to `weak`)
    /// because the parent will always exist if a child does.
    /// If the parent is released, the child is released with it.
    @_spi(TokamakCore)
    public unowned var parent: Fiber?

    /// The nearest parent that can be mounted on.
    unowned var elementParent: Fiber?

    /// The nearest parent that receives preferences.
    unowned var preferenceParent: Fiber?

    /// The cached type information for the underlying `View`.
    var typeInfo: TypeInfo?

    /// Boxes that store `State` data.
    var state: [PropertyInfo: MutableStorage] = [:]

    /// Subscribed `Cancellable`s keyed with the property contained the observable.
    ///
    /// Each time properties are bound, a new subscription could be created.
    /// When the subscription is overridden, the old cancellable is released.
    var subscriptions: [PropertyInfo: AnyCancellable] = [:]

    /// Storage for `PreferenceKey` values as they are passed up the tree.
    var preferences: _PreferenceStore?

    /// The computed dimensions and origin.
    var geometry: ViewGeometry?

    /// The WIP node if this is current, or the current node if this is WIP.
    @_spi(TokamakCore)
    public weak var alternate: Fiber?

    var createAndBindAlternate: (() -> Fiber?)?

    /// A box holding a value for an `@State` property wrapper.
    /// Will call `onSet` (usually a `Reconciler.reconcile` call) when updated.
    final class MutableStorage {
      private(set) var value: Any
      let onSet: () -> ()

      func setValue(_ newValue: Any, with transaction: Transaction) {
        value = newValue
        onSet()
      }

      init(initialValue: Any, onSet: @escaping () -> ()) {
        value = initialValue
        self.onSet = onSet
      }
    }

    public enum Identity: Hashable {
      case explicit(AnyHashable)
      case structural(index: Int)
    }

    init<V: View>(
      _ view: inout V,
      element: Renderer.ElementType?,
      parent: Fiber?,
      elementParent: Fiber?,
      preferenceParent: Fiber?,
      elementIndex: Int?,
      traits: _ViewTraitStore?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.reconciler = reconciler
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      self.preferenceParent = preferenceParent
      typeInfo = TokamakCore.typeInfo(of: V.self)

      let environment = parent?.outputs.environment ?? .init(.init())
      bindProperties(to: &view, typeInfo, environment.environment)
      var updateView = view
      let viewInputs = ViewInputs(
        content: view,
        updateContent: { $0(&updateView) },
        environment: environment,
        traits: traits,
        preferenceStore: preferences
      )
      outputs = V._makeView(viewInputs)
      if let preferenceStore = outputs.preferenceStore {
        preferences = preferenceStore
      }
      view = updateView
      content = content(for: view)

      if let element = element {
        self.element = element
      } else if Renderer.isPrimitive(view) {
        self.element = .init(
          from: .init(from: view, useDynamicLayout: reconciler?.renderer.useDynamicLayout ?? false)
        )
      }

      if self.element != nil {
        layout = (view as? _AnyLayout)?._erased() ?? DefaultLayout.shared
      }

      // Only specify an `elementIndex` if we have an element.
      if self.element != nil {
        self.elementIndex = elementIndex
      }

      let alternateView = view
      createAndBindAlternate = { [weak self] in
        guard let self = self else { return nil }
        // Create the alternate lazily
        let alternate = Fiber(
          bound: alternateView,
          state: self.state,
          subscriptions: self.subscriptions,
          preferences: self.preferences,
          layout: self.layout,
          alternate: self,
          outputs: self.outputs,
          typeInfo: self.typeInfo,
          element: self.element,
          parent: self.parent?.alternate,
          elementParent: self.elementParent?.alternate,
          preferenceParent: self.preferenceParent?.alternate,
          reconciler: reconciler
        )
        self.alternate = alternate
        if self.parent?.child === self {
          self.parent?.alternate?.child = alternate // Link it with our parent's alternate.
        } else {
          // Find our left sibling.
          var node = self.parent?.child
          while node?.sibling !== self {
            guard node?.sibling != nil else { return alternate }
            node = node?.sibling
          }
          if node?.sibling === self {
            node?.alternate?.sibling = alternate // Link it with our left sibling's alternate.
          }
        }
        return alternate
      }
    }

    init<V: View>(
      bound view: V,
      state: [PropertyInfo: MutableStorage],
      subscriptions: [PropertyInfo: AnyCancellable],
      preferences: _PreferenceStore?,
      layout: AnyLayout!,
      alternate: Fiber,
      outputs: ViewOutputs,
      typeInfo: TypeInfo?,
      element: Renderer.ElementType?,
      parent: FiberReconciler<Renderer>.Fiber?,
      elementParent: Fiber?,
      preferenceParent: Fiber?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.alternate = alternate
      self.reconciler = reconciler
      self.element = element
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      self.preferenceParent = preferenceParent
      self.typeInfo = typeInfo
      self.outputs = outputs
      self.state = state
      self.subscriptions = subscriptions
      self.preferences = preferences
      if element != nil {
        self.layout = layout
      }
      content = content(for: view)
    }

    private func bindProperties<T>(
      to content: inout T,
      _ typeInfo: TypeInfo?,
      _ environment: EnvironmentValues
    ) {
      var erased: Any = content
      bindProperties(to: &erased, typeInfo, environment)
      // swiftlint:disable:next force_cast
      content = erased as! T
    }

    /// Collect `DynamicProperty`s and link their state changes to the reconciler.
    private func bindProperties(
      to content: inout Any,
      _ typeInfo: TypeInfo?,
      _ environment: EnvironmentValues
    ) {
      guard let typeInfo = typeInfo else { return }

      for property in typeInfo.properties where property.type is DynamicProperty.Type {
        var value = property.get(from: content)
        // Bind nested properties.
        bindProperties(to: &value, TokamakCore.typeInfo(of: property.type), environment)
        // Create boxes for `@State` and other mutable properties.
        if var storage = value as? WritableValueStorage {
          let box = self.state[property] ?? MutableStorage(
            initialValue: storage.anyInitialValue,
            onSet: { [weak self] in
              guard let self = self else { return }
              self.reconciler?.fiberChanged(self)
            }
          )
          state[property] = box
          storage.getter = { box.value }
          storage.setter = { box.setValue($0, with: $1) }
          value = storage
          // Create boxes for `@StateObject` and other immutable properties.
        } else if var storage = value as? ValueStorage {
          let box = self.state[property] ?? MutableStorage(
            initialValue: storage.anyInitialValue,
            onSet: {}
          )
          state[property] = box
          storage.getter = { box.value }
          value = storage
          // Read from the environment.
        } else if var environmentReader = value as? EnvironmentReader {
          environmentReader.setContent(from: environment)
          value = environmentReader
        }
        // Subscribe to observable properties.
        if let observed = value as? ObservedProperty {
          subscriptions[property] = observed.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            self.reconciler?.fiberChanged(self)
          }
        }
        property.set(value: value, on: &content)
      }
      if var environmentReader = content as? EnvironmentReader {
        environmentReader.setContent(from: environment)
        content = environmentReader
      }
    }

    /// Call `update()` on each `DynamicProperty` in the type.
    private func updateDynamicProperties(
      of content: inout Any,
      _ typeInfo: TypeInfo?
    ) {
      guard let typeInfo = typeInfo else { return }
      for property in typeInfo.properties where property.type is DynamicProperty.Type {
        var value = property.get(from: content)
        // Update nested properties.
        updateDynamicProperties(of: &value, TokamakCore.typeInfo(of: property.type))
        // swiftlint:disable:next force_cast
        var dynamicProperty = value as! DynamicProperty
        dynamicProperty.update()
        property.set(value: dynamicProperty, on: &content)
      }
    }

    /// Update each `DynamicProperty` in our content.
    func updateDynamicProperties() {
      guard let content = content else { return }
      switch content {
      case .app(var app, let visit):
        updateDynamicProperties(of: &app, typeInfo)
        self.content = .app(app, visit: visit)
      case .scene(var scene, let visit):
        updateDynamicProperties(of: &scene, typeInfo)
        self.content = .scene(scene, visit: visit)
      case .view(var view, let visit):
        updateDynamicProperties(of: &view, typeInfo)
        self.content = .view(view, visit: visit)
      }
    }

    func update<V: View>(
      with view: inout V,
      elementIndex: Int?,
      traits: _ViewTraitStore?
    ) -> Renderer.ElementType.Content? {
      typeInfo = TokamakCore.typeInfo(of: V.self)

      self.elementIndex = elementIndex

      let environment = parent?.outputs.environment ?? .init(.init())
      bindProperties(to: &view, typeInfo, environment.environment)
      var updateView = view
      let inputs = ViewInputs(
        content: view,
        updateContent: {
          $0(&updateView)
        },
        environment: environment,
        traits: traits,
        preferenceStore: preferences
      )
      outputs = V._makeView(inputs)
      view = updateView
      content = content(for: view)

      if element != nil {
        layout = (view as? _AnyLayout)?._erased() ?? DefaultLayout.shared
      }

      if Renderer.isPrimitive(view) {
        return .init(from: view, useDynamicLayout: reconciler?.renderer.useDynamicLayout ?? false)
      } else {
        return nil
      }
    }

    init<A: App>(
      _ app: inout A,
      rootElement: Renderer.ElementType,
      rootEnvironment: EnvironmentValues,
      reconciler: FiberReconciler<Renderer>
    ) {
      self.reconciler = reconciler
      child = nil
      sibling = nil
      // `App`s are always the root, so they can have no parent.
      parent = nil
      elementParent = nil
      preferenceParent = nil
      element = rootElement
      typeInfo = TokamakCore.typeInfo(of: A.self)
      bindProperties(to: &app, typeInfo, rootEnvironment)
      var updateApp = app
      outputs = .init(
        inputs: .init(
          content: app,
          updateContent: {
            $0(&updateApp)
          },
          environment: .init(rootEnvironment),
          traits: .init(),
          preferenceStore: preferences
        )
      )
      if let preferenceStore = outputs.preferenceStore {
        preferences = preferenceStore
      }
      app = updateApp
      content = content(for: app)

      layout = .init(RootLayout(renderer: reconciler.renderer))

      let alternateApp = app
      createAndBindAlternate = { [weak self] in
        guard let self = self else { return nil }
        // Create the alternate lazily
        let alternate = Fiber(
          bound: alternateApp,
          state: self.state,
          subscriptions: self.subscriptions,
          preferences: self.preferences,
          layout: self.layout,
          alternate: self,
          outputs: self.outputs,
          typeInfo: self.typeInfo,
          element: self.element,
          reconciler: reconciler
        )
        self.alternate = alternate
        return alternate
      }
    }

    init<A: App>(
      bound app: A,
      state: [PropertyInfo: MutableStorage],
      subscriptions: [PropertyInfo: AnyCancellable],
      preferences: _PreferenceStore?,
      layout: AnyLayout?,
      alternate: Fiber,
      outputs: SceneOutputs,
      typeInfo: TypeInfo?,
      element: Renderer.ElementType?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.alternate = alternate
      self.reconciler = reconciler
      self.element = element
      child = nil
      sibling = nil
      parent = nil
      elementParent = nil
      preferenceParent = nil
      self.typeInfo = typeInfo
      self.outputs = outputs
      self.state = state
      self.subscriptions = subscriptions
      self.preferences = preferences
      self.layout = layout
      content = content(for: app)
    }

    init<S: Scene>(
      _ scene: inout S,
      element: Renderer.ElementType?,
      parent: Fiber?,
      elementParent: Fiber?,
      preferenceParent: Fiber?,
      environment: EnvironmentBox?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.reconciler = reconciler
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      self.element = element
      self.preferenceParent = preferenceParent
      typeInfo = TokamakCore.typeInfo(of: S.self)

      let environment = environment ?? parent?.outputs.environment ?? .init(.init())
      bindProperties(to: &scene, typeInfo, environment.environment)
      var updateScene = scene
      outputs = S._makeScene(
        .init(
          content: scene,
          updateContent: {
            $0(&updateScene)
          },
          environment: environment,
          traits: .init(),
          preferenceStore: preferences
        )
      )
      if let preferenceStore = outputs.preferenceStore {
        preferences = preferenceStore
      }
      scene = updateScene
      content = content(for: scene)

      if element != nil {
        layout = (scene as? _AnyLayout)?._erased() ?? DefaultLayout.shared
      }

      let alternateScene = scene
      createAndBindAlternate = { [weak self] in
        guard let self = self else { return nil }
        // Create the alternate lazily
        let alternate = Fiber(
          bound: alternateScene,
          state: self.state,
          subscriptions: self.subscriptions,
          preferences: self.preferences,
          layout: self.layout,
          alternate: self,
          outputs: self.outputs,
          typeInfo: self.typeInfo,
          element: self.element,
          parent: self.parent?.alternate,
          elementParent: self.elementParent?.alternate,
          preferenceParent: self.preferenceParent?.alternate,
          reconciler: reconciler
        )
        self.alternate = alternate
        if self.parent?.child === self {
          self.parent?.alternate?.child = alternate // Link it with our parent's alternate.
        } else {
          // Find our left sibling.
          var node = self.parent?.child
          while node?.sibling !== self {
            guard node?.sibling != nil else { return alternate }
            node = node?.sibling
          }
          if node?.sibling === self {
            node?.alternate?.sibling = alternate // Link it with our left sibling's alternate.
          }
        }
        return alternate
      }
    }

    init<S: Scene>(
      bound scene: S,
      state: [PropertyInfo: MutableStorage],
      subscriptions: [PropertyInfo: AnyCancellable],
      preferences: _PreferenceStore?,
      layout: AnyLayout!,
      alternate: Fiber,
      outputs: SceneOutputs,
      typeInfo: TypeInfo?,
      element: Renderer.ElementType?,
      parent: FiberReconciler<Renderer>.Fiber?,
      elementParent: Fiber?,
      preferenceParent: Fiber?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.alternate = alternate
      self.reconciler = reconciler
      self.element = element
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      self.preferenceParent = preferenceParent
      self.typeInfo = typeInfo
      self.outputs = outputs
      self.state = state
      self.subscriptions = subscriptions
      self.preferences = preferences
      if element != nil {
        self.layout = layout
      }
      content = content(for: scene)
    }

    func update<S: Scene>(
      with scene: inout S
    ) -> Renderer.ElementType.Content? {
      typeInfo = TokamakCore.typeInfo(of: S.self)

      let environment = parent?.outputs.environment ?? .init(.init())
      bindProperties(to: &scene, typeInfo, environment.environment)
      var updateScene = scene
      outputs = S._makeScene(.init(
        content: scene,
        updateContent: {
          $0(&updateScene)
        },
        environment: environment,
        traits: .init(),
        preferenceStore: preferences
      ))
      scene = updateScene
      content = content(for: scene)

      if element != nil {
        layout = (scene as? _AnyLayout)?._erased() ?? DefaultLayout.shared
      }

      return nil
    }
  }
}
