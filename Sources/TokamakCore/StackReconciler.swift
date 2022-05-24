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

import OpenCombineShim

/** A class that reconciles a "raw" tree of element values (such as `App`, `Scene` and `View`,
 all coming from `body` or `renderedBody` properties) with a tree of mounted element instances
 ('MountedApp', `MountedScene`, `MountedCompositeView` and `MountedHostView` respectively). Any
 updates to the former tree are reflected in the latter tree, and then resulting changes are
 delegated to the renderer for it to reflect those in its viewport.

 Scheduled updates are stored in a simple stack-like structure and are processed sequentially as
 opposed to potentially more sophisticated implementations. [React's fiber
 reconciler](https://github.com/acdlite/react-fiber-architecture) is one of those and could be
 implemented in the future to improve UI responsiveness under heavy load and potentially even
 support multi-threading when it's supported in WebAssembly.
 */
public final class StackReconciler<R: Renderer> {
  /** A set of mounted elements that triggered a re-render. These are stored in a `Set` instead of
   an array to avoid duplicate re-renders. The actual performance benefits of such de-duplication
   haven't been proven in the absence of benchmarks, so this could be updated to a simple `Array` in
   the future if that's proven to be more effective.
   */
  private var queuedRerenders = Set<Rerender>()

  struct Rerender: Hashable {
    let element: MountedCompositeElement<R>
    let transaction: Transaction

    func hash(into hasher: inout Hasher) {
      hasher.combine(element)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.element == rhs.element
    }
  }

  /** A root renderer's target instance. We establish the "host-target" terminology where a "host"
   is a primitive `View` that doesn't have any children, and a "target" is an instance of a type
   declared by a rendererto which the "host" is rendered to. For example, in the DOM renderer a
   "target" is a DOM node, in a hypothetical iOS renderer it would be a `UIView`, and a macOS
   renderer would declare an `NSView` as its "target" type.
   */
  public let rootTarget: R.TargetType

  /** A root renderer's main preference store.
   */
  public var preferenceStore: _PreferenceStore {
    rootElement.preferenceStore
  }

  /** A root of the mounted elements tree to which all other mounted elements are attached to.
   */
  private let rootElement: MountedElement<R>

  /** A renderer instance to delegate to. Usually the renderer owns the reconciler instance, thus
   the reference has to be weak to avoid a reference cycle.
   **/
  private(set) unowned var renderer: R

  /** A platform-specific implementation of an event loop scheduler. Usually reconciler
   updates are scheduled in reponse to user input. To make updates non-blocking so that the app
   feels responsive, the actual reconcilliation needs to be scheduled on the next event loop cycle.
   Usually it's `DispatchQueue.main.async` on platforms where `Dispatch` is supported, or
   `setTimeout` in the DOM environment.
   */
  private let scheduler: (@escaping () -> ()) -> ()

  public init<V: View>(
    view: V,
    target: R.TargetType,
    environment: EnvironmentValues,
    renderer: R,
    scheduler: @escaping (@escaping () -> ()) -> ()
  ) {
    self.renderer = renderer
    self.scheduler = scheduler
    rootTarget = target

    rootElement = AnyView(view).makeMountedView(renderer, target, environment, .init(), nil)

    performInitialMount()
  }

  public init<A: App>(
    app: A,
    target: R.TargetType,
    environment: EnvironmentValues,
    renderer: R,
    scheduler: @escaping (@escaping () -> ()) -> ()
  ) {
    self.renderer = renderer
    self.scheduler = scheduler
    rootTarget = target

    rootElement = MountedApp(app, target, environment, nil)

    performInitialMount()
    if let mountedApp = rootElement as? MountedApp<R> {
      setupPersistentSubscription(for: app._phasePublisher, to: \.scenePhase, of: mountedApp)
      setupPersistentSubscription(for: app._colorSchemePublisher, to: \.colorScheme, of: mountedApp)
    }
  }

  private func performInitialMount() {
    rootElement.mount(in: self, with: .init(animation: nil))
    performPostrenderCallbacks()
  }

  private func queueStorageUpdate(
    for mountedElement: MountedCompositeElement<R>,
    id: Int,
    transaction: Transaction,
    updater: (inout Any) -> ()
  ) {
    updater(&mountedElement.storage[id])
    queueUpdate(for: mountedElement, transaction: transaction)
  }

  internal func queueUpdate(
    for mountedElement: MountedCompositeElement<R>,
    transaction: Transaction
  ) {
    let shouldSchedule = queuedRerenders.isEmpty
    queuedRerenders.insert(
      .init(
        element: mountedElement,
        transaction: transaction
      )
    )

    guard shouldSchedule else { return }

    scheduler { [weak self] in self?.updateStateAndReconcile() }
  }

  private func updateStateAndReconcile() {
    let queued = queuedRerenders
    queuedRerenders.removeAll()

    for mountedView in queued {
      mountedView.element.update(in: self, with: mountedView.transaction)
    }

    performPostrenderCallbacks()
  }

  private func setupStorage(
    id: Int,
    for property: PropertyInfo,
    of compositeElement: MountedCompositeElement<R>,
    body bodyKeypath: ReferenceWritableKeyPath<MountedCompositeElement<R>, Any>
  ) {
    // `ValueStorage` property already filtered out, so safe to assume the value's type
    // swiftlint:disable:next force_cast
    var storage = property.get(from: compositeElement[keyPath: bodyKeypath]) as! ValueStorage

    if compositeElement.storage.count == id {
      compositeElement.storage.append(storage.anyInitialValue)
    }

    if storage.getter == nil {
      storage.getter = { compositeElement.storage[id] }

      guard var writableStorage = storage as? WritableValueStorage else {
        return property.set(value: storage, on: &compositeElement[keyPath: bodyKeypath])
      }

      // Avoiding an indirect reference cycle here: this closure can be owned by callbacks
      // owned by view's target, which is strongly referenced by the reconciler.
      writableStorage.setter = { [weak self, weak compositeElement] newValue, transaction in
        guard let element = compositeElement else { return }
        self?.queueStorageUpdate(for: element, id: id, transaction: transaction) { $0 = newValue }
      }

      property.set(value: writableStorage, on: &compositeElement[keyPath: bodyKeypath])
    }
  }

  private func setupTransientSubscription(
    for property: PropertyInfo,
    of compositeElement: MountedCompositeElement<R>,
    body bodyKeypath: KeyPath<MountedCompositeElement<R>, Any>
  ) {
    // `ObservedProperty` property already filtered out, so safe to assume the value's type
    // swiftlint:disable force_cast
    let observed = property.get(
      from: compositeElement[keyPath: bodyKeypath]
    ) as! ObservedProperty
    // swiftlint:enable force_cast

    // break the reference cycle here as subscriptions are stored in the `compositeElement`
    // instance property
    observed.objectWillChange.sink { [weak self, weak compositeElement] _ in
      if let compositeElement = compositeElement {
        self?.queueUpdate(for: compositeElement, transaction: .init(animation: nil))
      }
    }.store(in: &compositeElement.transientSubscriptions)
  }

  private func setupPersistentSubscription<T: Equatable>(
    for publisher: AnyPublisher<T, Never>,
    to keyPath: WritableKeyPath<EnvironmentValues, T>,
    of mountedApp: MountedApp<R>
  ) {
    publisher.sink { [weak self, weak mountedApp] value in
      guard
        let mountedApp = mountedApp,
        mountedApp.environmentValues[keyPath: keyPath] != value
      else { return }

      mountedApp.environmentValues[keyPath: keyPath] = value
      self?.queueUpdate(for: mountedApp, transaction: .init(animation: nil))
    }.store(in: &mountedApp.persistentSubscriptions)
  }

  private func body(
    of compositeElement: MountedCompositeElement<R>,
    keyPath: ReferenceWritableKeyPath<MountedCompositeElement<R>, Any>
  ) -> Any {
    compositeElement.updateEnvironment()
    if let info = typeInfo(of: compositeElement.type) {
      var stateIdx = 0
      let dynamicProps = info.dynamicProperties(
        &compositeElement.environmentValues,
        source: &compositeElement[keyPath: keyPath]
      )

      compositeElement.transientSubscriptions = []
      for property in dynamicProps {
        // Setup state/subscriptions
        if property.type is ValueStorage.Type {
          setupStorage(id: stateIdx, for: property, of: compositeElement, body: keyPath)
          stateIdx += 1
        }
        if property.type is ObservedProperty.Type {
          setupTransientSubscription(for: property, of: compositeElement, body: keyPath)
        }
      }
    }

    return compositeElement[keyPath: keyPath]
  }

  func render(compositeView: MountedCompositeView<R>) -> AnyView {
    let view = body(of: compositeView, keyPath: \.view.view)

    guard let renderedBody = renderer.primitiveBody(for: view) else {
      return compositeView.view.bodyClosure(view)
    }

    return renderedBody
  }

  func render(mountedApp: MountedApp<R>) -> _AnyScene {
    mountedApp.app.bodyClosure(body(of: mountedApp, keyPath: \.app.app))
  }

  func render(mountedScene: MountedScene<R>) -> _AnyScene.BodyResult {
    mountedScene.scene.bodyClosure(body(of: mountedScene, keyPath: \.scene.scene))
  }

  // swiftlint:disable function_parameter_count
  func reconcile<Element>(
    _ mountedElement: MountedCompositeElement<R>,
    with element: Element,
    transaction: Transaction,
    getElementType: (Element) -> Any.Type,
    updateChild: (MountedElement<R>) -> (),
    mountChild: (Element) -> MountedElement<R>
  ) {
    // FIXME: for now without properly handling `Group` and `TupleView` mounted composite views
    // have only a single element in `mountedChildren`, but this will change when
    // fragments are implemented and this switch should be rewritten to compare
    // all elements in `mountedChildren`
    switch (mountedElement.mountedChildren.last, element) {
    // no mounted children previously, but children available now
    case let (nil, childBody):
      let child: MountedElement<R> = mountChild(childBody)
      mountedElement.mountedChildren = [child]
      child.mount(in: self, with: transaction)

    // some mounted children before and now
    case let (mountedChild?, childBody):
      let childBodyType = getElementType(childBody)

      // new child has the same type as existing child
      if mountedChild.typeConstructorName == typeConstructorName(childBodyType) {
        updateChild(mountedChild)
        mountedChild.update(in: self, with: transaction)
      } else {
        // new child is of a different type, complete rerender, i.e. unmount the old
        // wrapper, then mount a new one with the new `childBody`
        mountedChild.unmount(in: self, with: transaction, parentTask: nil)

        let newMountedChild: MountedElement<R> = mountChild(childBody)
        mountedElement.mountedChildren = [newMountedChild]
        newMountedChild.mount(in: self, with: transaction)
      }
    }
  }

  // swiftlint:enable function_parameter_count

  private var queuedPostrenderCallbacks = [() -> ()]()
  func afterCurrentRender(perform callback: @escaping () -> ()) {
    queuedPostrenderCallbacks.append(callback)
  }

  private func performPostrenderCallbacks() {
    queuedPostrenderCallbacks.forEach { $0() }
    queuedPostrenderCallbacks.removeAll()
  }
}
