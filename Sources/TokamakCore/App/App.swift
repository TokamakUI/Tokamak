// Copyright 2020-2021 Tokamak contributors
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
//  Created by Carson Katri on 7/16/20.
//

import OpenCombineShim

/// Provides the ability to set the title of the Scene.
public protocol _TitledApp {
  static func _setTitle(_ title: String)
}

/// The renderer is responsible for implementing certain functionality.
public protocol App: _TitledApp {
  associatedtype Body: Scene
  var body: Body { get }

  /// Implemented by the renderer to mount the `App`
  static func _launch(
    _ app: Self,
    with configuration: _AppConfiguration
  )

  /// Implemented by the renderer to update the `App` on `ScenePhase` changes
  var _phasePublisher: AnyPublisher<ScenePhase, Never> { get }

  /// Implemented by the renderer to update the `App` on `ColorScheme` changes
  var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> { get }

  static var _configuration: _AppConfiguration { get }

  static func main()

  init()
}

public struct _AppConfiguration {
  public let reconciler: Reconciler
  public let rootEnvironment: EnvironmentValues

  public init(
    reconciler: Reconciler = .stack,
    rootEnvironment: EnvironmentValues = .init()
  ) {
    self.reconciler = reconciler
    self.rootEnvironment = rootEnvironment
  }

  public enum Reconciler {
    /// Use the `StackReconciler`.
    case stack
    /// Use the `FiberReconciler` with layout steps optionally enabled.
    case fiber(useDynamicLayout: Bool = false)
  }
}

public extension App {
  static var _configuration: _AppConfiguration { .init() }

  static func main() {
    let app = Self()
    _launch(app, with: Self._configuration)
  }
}
