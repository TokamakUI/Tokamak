// Copyright 2020 Tokamak contributors
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
//  Created by Szymon on 23/7/2023.
//

import Foundation

public enum _GesturePhase {
    /// The gesture phase when it begins.
    ///
    /// - Parameters:
    ///   - boundsOrigin: The origin point of the target element in global coordinates.
    ///   - location: The current location of the gesture in global coordinates.
    case began(boundsOrigin: CGPoint, location: CGPoint)
    
    /// The gesture phase when it changes.
    ///
    /// - Parameters:
    ///   - boundsOrigin: The optional origin point of the target element in global coordinates.
    ///   - location: The optional current location of the gesture in global coordinates.
    case changed(boundsOrigin: CGPoint?, location: CGPoint?)
    
    /// The gesture phase when it ends.
    ///
    /// - Parameters:
    ///   - boundsOrigin: The optional origin point of the target element in global coordinates.
    ///   - location: The current location of the gesture in global coordinates.
    case ended(boundsOrigin: CGPoint?, location: CGPoint)
    
    /// The gesture phase when it is cancelled.
    case cancelled
}
