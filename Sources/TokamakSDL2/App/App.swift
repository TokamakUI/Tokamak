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
//  Created by Szymon on 2/10/23.
//

import OpenCombineShim
import SDL
import TokamakCore

public extension App {
  static func _launch(_ app: Self, with configuration: _AppConfiguration) {
    _ = Unmanaged.passRetained(SDLRenderer(app, configuration.rootEnvironment))
  }

  static func _setTitle(_ title: String) {
    guard let window = SDLRenderer.shared?.window else { return }
    SDL_SetWindowTitle(window, title)
  }

  var _phasePublisher: AnyPublisher<ScenePhase, Never> {
    CurrentValueSubject(.active).eraseToAnyPublisher()
  }

  var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> {
    CurrentValueSubject(.light).eraseToAnyPublisher()
  }
}
