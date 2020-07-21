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

public final class StackReconciler<R: Renderer> {
  private var queuedRerenders = Set<MountedCompositeView<R>>()

  public let rootTarget: R.TargetType
  private let rootView: MountedView<R>
  private(set) weak var renderer: R?
  private let scheduler: (@escaping () -> ()) -> ()

  public init<V: View>(
    view: V,
    target: R.TargetType,
    renderer: R,
    environment: EnvironmentValues,
    scheduler: @escaping (@escaping () -> ()) -> ()
  ) {
    self.renderer = renderer
    self.scheduler = scheduler
    rootTarget = target

    rootView = view.makeMountedView(target, environment)

    rootView.mount(with: self)
  }

  private func queueStateUpdate(
    for mountedView: MountedCompositeView<R>,
    id: Int,
    updater: (inout Any) -> ()
  ) {
    updater(&mountedView.state[id])
    queueUpdate(for: mountedView)
  }

  private func queueUpdate(for mountedView: MountedCompositeView<R>) {
    let shouldSchedule = queuedRerenders.isEmpty
    queuedRerenders.insert(mountedView)

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
    of compositeView: MountedCompositeView<R>
  ) {
    // swiftlint:disable force_try
    // `ValueStorage` property already filtered out, so safe to assume the value's type
    // swiftlint:disable:next force_cast
    var state = try! property.get(from: compositeView.view.view) as! ValueStorage

    if compositeView.state.count == id {
      compositeView.state.append(state.anyInitialValue)
    }

    if state.getter == nil || state.setter == nil {
      state.getter = { compositeView.state[id] }

      // Avoiding an indirect reference cycle here: this closure can be
      // owned by callbacks owned by view's target, which is strongly referenced
      // by the reconciler.
      state.setter = { [weak self, weak compositeView] newValue in
        guard let view = compositeView else { return }
        self?.queueStateUpdate(for: view, id: id) { $0 = newValue }
      }
    }
    try! property.set(value: state, on: &compositeView.view.view)
  }

  private func setupSubscription(
    for property: PropertyInfo,
    of compositeView: MountedCompositeView<R>
  ) {
    // `ObservedProperty` property already filtered out, so safe to assume the value's type
    // swiftlint:disable:next force_cast
    let observed = try! property.get(from: compositeView.view.view) as! ObservedProperty

    observed.objectWillChange.sink { [weak self] _ in
      self?.queueUpdate(for: compositeView)
    }.store(in: &compositeView.subscriptions)
  }

  func render(compositeView: MountedCompositeView<R>) -> some View {
    let info = try! typeInfo(of: compositeView.view.type)

    let needsSubscriptions = compositeView.subscriptions.isEmpty

    var stateIdx = 0
    for property in info.properties {
      if property.type is ValueStorage.Type {
        setupState(id: stateIdx, for: property, of: compositeView)
        stateIdx += 1
      } else if needsSubscriptions && property.type is ObservedProperty.Type {
        setupSubscription(for: property, of: compositeView)
      }
    }

    print("querying body of \(compositeView.view.type)")
    let result = compositeView.view.bodyClosure(compositeView.view.view)

    return result
  }
}
