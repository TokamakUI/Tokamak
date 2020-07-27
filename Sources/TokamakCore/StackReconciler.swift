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

public final class StackReconciler<R: Renderer> {
  private var queuedRerenders = Set<MountedCompositeElement<R>>()

  public let rootTarget: R.TargetType
  private let rootElement: MountedElement<R>
  private(set) weak var renderer: R?
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

    rootElement = view.makeMountedView(target, environment)

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

    rootElement = app.makeMountedApp(target, environment)

    rootElement.mount(with: self)
    if let mountedApp = rootElement as? MountedApp<R> {
      app._phasePublisher.sink { [weak self] phase in
        if mountedApp.environmentValues[keyPath: \.scenePhase] != phase {
          mountedApp.environmentValues[keyPath: \.scenePhase] = phase
          self?.queueUpdate(for: mountedApp)
        }
      }.store(in: &mountedApp.subscriptions)
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

      // Avoiding an indirect reference cycle here: this closure can be
      // owned by callbacks owned by view's target, which is strongly referenced
      // by the reconciler.
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

  func render<T>(compositeElement: MountedCompositeElement<R>,
                 body bodyKeypath: ReferenceWritableKeyPath<MountedCompositeElement<R>, Any>,
                 result: KeyPath<MountedCompositeElement<R>, (Any) -> T>) -> T {
    let info = try! typeInfo(of: compositeElement.elementType)
    info.injectEnvironment(from: compositeElement.environmentValues,
                           into: &compositeElement[keyPath: bodyKeypath])

    let needsSubscriptions = compositeElement.subscriptions.isEmpty

    var stateIdx = 0
    let dynamicProps = info.dynamicProperties(compositeElement.environmentValues,
                                              source: &compositeElement[keyPath: bodyKeypath],
                                              shouldUpdate: true)
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

  func render(compositeView: MountedCompositeView<R>) -> some View {
    render(compositeElement: compositeView, body: \.view.view, result: \.view.bodyClosure)
  }

  func render(mountedApp: MountedApp<R>) -> some Scene {
    render(compositeElement: mountedApp, body: \.app.app, result: \.app.bodyClosure)
  }

  func render(mountedScene: MountedScene<R>) -> some Scene {
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
      if try! mountedChild.view.typeConstructorName == typeInfo(of: childBodyType).mangledName {
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
