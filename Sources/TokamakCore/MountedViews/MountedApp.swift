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
//  Created by Carson Katri on 7/19/20.
//

import OpenCombine
import Runtime

// This is very similar to `MountedCompositeView`. However, the `mountedBody`
// is the computed content of the specified `Scene`, instead of having child
// `View`s
final class MountedApp<R: Renderer>: MountedCompositeElement<R> {
  override func mount(with reconciler: StackReconciler<R>) {
    let childBody = reconciler.render(mountedApp: self)

    let child: MountedElement<R> = mountChild(childBody)
    mountedChildren = [child]
    child.mount(with: reconciler)
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }
  }

  func mountChild<S: Scene>(_ childBody: S) -> MountedElement<R> {
    let mountedScene = childBody.makeMountedView(R.self,
                                                 parentTarget,
                                                 environmentValues)
    if let title = mountedScene.title {
      // swiftlint:disable force_cast
      (app.appType as! TitledApp.Type)._setTitle(title)
    }
    return mountedScene.body
  }

  override func update(with reconciler: StackReconciler<R>) {
    // FIXME: for now without properly handling `Group` mounted composite views have only
    // a single element in `mountedChildren`, but this will change when
    // fragments are implemented and this switch should be rewritten to compare
    // all elements in `mountedChildren`

    // Inject @Environment values
    // `DynamicProperty`s can have `@Environment` properties contained in them,
    // so we have to inject into them as well.
    // swiftlint:disable force_try
    let appInfo = try! typeInfo(of: app.appType)
    for dynamicProp in appInfo.properties.filter({ $0.type is DynamicProperty.Type }) {
      let propInfo = try! typeInfo(of: dynamicProp.type)
      var propWrapper = try! dynamicProp.get(from: app.app) as! DynamicProperty
      for prop in propInfo.properties.filter({ $0.type is EnvironmentReader.Type }) {
        var wrapper = try! prop.get(from: propWrapper) as! EnvironmentReader
        wrapper.setContent(from: environmentValues)
        try! prop.set(value: wrapper, on: &propWrapper)
      }
      try! dynamicProp.set(value: propWrapper, on: &app.app)
    }
    for prop in appInfo.properties.filter({ $0.type is EnvironmentReader.Type }) {
      var wrapper = try! prop.get(from: app.app) as! EnvironmentReader
      wrapper.setContent(from: environmentValues)
      try! prop.set(value: wrapper, on: &app.app)
    }
    // swiftlint:enable force_cast
    // swiftlint:enable force_try

    switch (mountedChildren.last, reconciler.render(mountedApp: self)) {
    // no mounted children, but children available now
    case let (nil, childBody):
      let child: MountedElement<R> = mountChild(childBody)
      mountedChildren = [child]
      child.mount(with: reconciler)

    // some mounted children
    case let (wrapper?, childBody):
      let childBodyType = (childBody as? AnyView)?.type ?? type(of: childBody)

      // FIXME: no idea if using `mangledName` is reliable, but seems to be the only way to get
      // a name of a type constructor in runtime. Should definitely check if these are different
      // across modules, otherwise can cause problems with views with same names in different
      // modules.

      // new child has the same type as existing child
      // swiftlint:disable:next force_try
      if try! wrapper.view.typeConstructorName == typeInfo(of: childBodyType).mangledName {
        wrapper.scene = AnyScene(childBody)
        wrapper.update(with: reconciler)
      } else {
        // new child is of a different type, complete rerender, i.e. unmount the old
        // wrapper, then mount a new one with the new `childBody`
        wrapper.unmount(with: reconciler)

        let child: MountedElement<R> = mountChild(childBody)
        mountedChildren = [child]
        child.mount(with: reconciler)
      }
    }
  }
}

extension App {
  func makeMountedApp<R>(_ parentTarget: R.TargetType,
                         _ environmentValues: EnvironmentValues)
    -> MountedApp<R> where R: Renderer {
    // Find Environment changes
    var injectableApp = self
    let any = (injectableApp as? AnyApp) ?? AnyApp(injectableApp)
    // swiftlint:disable force_try

    let appInfo = try! typeInfo(of: any.appType)
    var extractedApp = any.app
    // Inject @Environment values
    // swiftlint:disable force_cast
    // `DynamicProperty`s can have `@Environment` properties contained in them,
    // so we have to inject into them as well.
    for dynamicProp in appInfo.properties.filter({ $0.type is DynamicProperty.Type }) {
      let propInfo = try! typeInfo(of: dynamicProp.type)
      var propWrapper = try! dynamicProp.get(from: extractedApp) as! DynamicProperty
      for prop in propInfo.properties.filter({ $0.type is EnvironmentReader.Type }) {
        var wrapper = try! prop.get(from: propWrapper) as! EnvironmentReader
        wrapper.setContent(from: environmentValues)
        try! prop.set(value: wrapper, on: &propWrapper)
      }
      try! dynamicProp.set(value: propWrapper, on: &extractedApp)
    }
    for prop in appInfo.properties.filter({ $0.type is EnvironmentReader.Type }) {
      var wrapper = try! prop.get(from: any.app) as! EnvironmentReader
      wrapper.setContent(from: environmentValues)
      try! prop.set(value: wrapper, on: &extractedApp)
    }
    // swiftlint:enable force_cast

    // Set the extractedApp back on the AnyApp after modification
    let anyAppInfo = try! typeInfo(of: AnyApp.self)
    try! anyAppInfo.property(named: "app").set(value: extractedApp, on: &injectableApp)
    // swiftlint:enable force_try

    // Make MountedView
    let anyApp = injectableApp as? AnyApp ?? AnyApp(injectableApp)
    return MountedApp(anyApp, parentTarget, environmentValues)
  }
}
