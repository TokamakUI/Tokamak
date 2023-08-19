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
//  Created by Szymon on 18/8/2023.
//

import Foundation

extension View {
    /// Defines the content shape for hit testing.
    /// - Parameters:
    ///   - shape: The hit testing shape for the view.
    ///   - eoFill: A Boolean that indicates whether the shape is interpreted with the even-odd winding number rule.
    /// - Returns: A view that uses the given shape for hit testing.
    @inlinable public func contentShape<S: Shape>(
        _ shape: S,
        eoFill: Bool = false
    ) -> some View {
        // TODO: Add content shape modifier. Verify gesture start against the shape fill area.
        self
    }
}
