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

import OpenCombine
import Runtime

/** A class that reconciles a "raw" tree of element values (such as `App`, `Scene` and `View`,
 all coming from `body` or `deferredBody` properties) with a tree of mounted element instances
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
  private var queuedRerenders = Set<MountedCompositeElement<R>>()

  /** A root renderer's target instance. We establish the "host-target" terminology where a "host"
   is a primitive `View` that doesn't have any children, and a "target" is an instance of a type
   declared by a rendererto which the "host" is rendered to. For example, in the DOM renderer a
   "target" is a DOM node, in a hypothetical iOS renderer it would be a `UIView`, and a macOS
   renderer would declare an `NSView` as its "target" type.
   */
  public let rootTarget: R.TargetType

  /** A root of the mounted elements tree to which all other mounted elements are attached to.
   */
  private let rootElement: MountedElement<R>

  /** A renderer instance to delegate to. Usually the renderer owns the reconciler instance, thus
   the reference has to be weak to avoid a reference cycle.
   **/
  private(set) weak var renderer: R?

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

    rootElement = AnyView(view).makeMountedView(target, environment)

    rootElement.mount(with: self)
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

    rootElement = MountedApp(app, target, environment)

    rootElement.mount(with: self)
    if let mountedApp = rootElement as? MountedApp<R> {
      setupSubscription(for: app._phasePublisher, to: \.scenePhase, of: mountedApp)
      setupSubscription(for: app._colorSchemePublisher, to: \.colorScheme, of: mountedApp)
    }
  }

  private func queueStateUpdate(
    for mountedElement: MountedCompositeElement<R>,
    id: Int,
    updater: (inout Any) -> ()
  ) {
    updater(&mountedElement.state[id])
    queueUpdate(for: mountedElement)
  }

  private func queueUpdate(for mountedElement: MountedCompositeElement<R>) {
    let shouldSchedule = queuedRerenders.isEmpty
    queuedRerenders.insert(mountedElement)

    guard shouldSchedule else { return }

    scheduler { [weak self] in self?.updateStateAndReconcile() }
  }

  private func updateStateAndReconcile() {
    for mountedView in queuedRerenders {
      mountedView.update(with: self)
    }

    queuedRerenders.removeAll()
  }

  private func setupState(
    id: Int,
    for property: PropertyInfo,
    of compositeElement: MountedCompositeElement<R>,
    body bodyKeypath: ReferenceWritableKeyPath<MountedCompositeElement<R>, Any>
  ) {
    // swiftlint:disable force_try
    // `ValueStorage` property already filtered out, so safe to assume the value's type
    // swiftlint:disable:next force_cast
    var state = try! property.get(from: compositeElement[keyPath: bodyKeypath]) as! ValueStorage

    if compositeElement.state.count == id {
      compositeElement.state.append(state.anyInitialValue)
    }

    if state.getter == nil || state.setter == nil {
      state.getter = { compositeElement.state[id] }

      // Avoiding an indirect reference cycle here: this closure can be owned by callbacks
      // owned by view's target, which is strongly referenced by the reconciler.
      state.setter = { [weak self, weak compositeElement] newValue in
        guard let element = compositeElement else { return }
        self?.queueStateUpdate(for: element, id: id) { $0 = newValue }
      }
    }
    try! property.set(value: state, on: &compositeElement[keyPath: bodyKeypath])
  }

  private func setupSubscription(
    for property: PropertyInfo,
    of compositeElement: MountedCompositeElement<R>,
    body bodyKeypath: KeyPath<MountedCompositeElement<R>, Any>
  ) {
    // `ObservedProperty` property already filtered out, so safe to assume the value's type
    // swiftlint:disable force_cast
    let observed = try! property.get(
      from: compositeElement[keyPath: bodyKeypath]
    ) as! ObservedProperty
    // swiftlint:enable force_cast

    observed.objectWillChange.sink { [weak self] _ in
      self?.queueUpdate(for: compositeElement)
    }.store(in: &compositeElement.subscriptions)
  }

  private func setupSubscription<T: Equatable>(
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
      self?.queueUpdate(for: mountedApp)
    }.store(in: &mountedApp.subscriptions)
  }

  func render<T>(compositeElement: MountedCompositeElement<R>,
                 body bodyKeypath: ReferenceWritableKeyPath<MountedCompositeElement<R>, Any>,
                 result: KeyPath<MountedCompositeElement<R>, (Any) -> T>) -> T {
    let info = compositeElement.updateEnvironment()

    var stateIdx = 0
    let dynamicProps = info.dynamicProperties(
      compositeElement.environmentValues,
      source: &compositeElement[keyPath: bodyKeypath]
    )

    let needsSubscriptions = compositeElement.subscriptions.isEmpty
    for property in dynamicProps {
      // Setup state/subscriptions
      if property.type is ValueStorage.Type {
        setupState(id: stateIdx, for: property, of: compositeElement, body: bodyKeypath)
        stateIdx += 1
      } else if needsSubscriptions && property.type is ObservedProperty.Type {
        setupSubscription(for: property, of: compositeElement, body: bodyKeypath)
      }
    }

    return compositeElement[keyPath: result](compositeElement[keyPath: bodyKeypath])
  }

  func render(compositeView: MountedCompositeView<R>) -> AnyView {
    render(compositeElement: compositeView, body: \.view.view, result: \.view.bodyClosure)
  }

  func render(mountedApp: MountedApp<R>) -> _AnyScene {
    render(compositeElement: mountedApp, body: \.app.app, result: \.app.bodyClosure)
  }

  func render(mountedScene: MountedScene<R>) -> _AnyScene.BodyResult {
    render(compositeElement: mountedScene, body: \.scene.scene, result: \.scene.bodyClosure)
  }

  func reconcile<Element>(
    _ mountedElement: MountedCompositeElement<R>,
    with element: Element,
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
      child.mount(with: self)

    // some mounted children before and now
    case let (mountedChild?, childBody):
      let childBodyType = getElementType(childBody)

      // FIXME: no idea if using `mangledName` is reliable, but seems to be the only way to get
      // a name of a type constructor in runtime. Should definitely check if these are different
      // across modules, otherwise can cause problems with views with same names in different
      // modules.

      // new child has the same type as existing child
      // swiftlint:disable:next force_try
      if try! mountedChild.typeConstructorName == typeInfo(of: childBodyType).mangledName {
        updateChild(mountedChild)
        mountedChild.update(with: self)
      } else {
        // new child is of a different type, complete rerender, i.e. unmount the old
        // wrapper, then mount a new one with the new `childBody`
        mountedChild.unmount(with: self)

        let newMountedChild: MountedElement<R> = mountChild(childBody)
        mountedElement.mountedChildren = [newMountedChild]
        newMountedChild.mount(with: self)
      }
    }
  }
}
