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

public enum CoordinateSpace {
    case global
    case local
    case named(AnyHashable)
}

extension CoordinateSpace: Equatable, Hashable {
    // Equatable and Hashable conformance
}

extension CoordinateSpace {
    public var isGlobal: Bool {
        switch self {
        case .global:
            return true
        default:
            return false
        }
    }
    
    public var isLocal: Bool {
        switch self {
        case .local:
            return true
        default:
            return false
        }
    }
}

extension CoordinateSpace {
    static func convertGlobalSpaceCoordinates(rect: CGRect, toNamedOrigin namedOrigin: CGPoint) -> CGRect {
        let translatedOrigin = convert(rect.origin, toNamedOrigin: namedOrigin)
        return CGRect(origin: translatedOrigin, size: rect.size)
    }
    
    static func convert(_ point: CGPoint, toNamedOrigin namedOrigin: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - namedOrigin.x, y: point.y - namedOrigin.y)
    }
}


extension View {
    /// Assigns a name to the view’s coordinate space, so other code can operate on dimensions like points and sizes relative to the named space.
    /// - Parameter name: A name used to identify this coordinate space.
    public func coordinateSpace<T>(name: T) -> some View where T : Hashable {
        self.modifier(_CoordinateSpaceModifier(name: name))
    }
}

private struct CoordinateSpaceEnvironmentKey: EnvironmentKey {
    static let defaultValue: CoordinateSpaceEnvironmentValue = CoordinateSpaceEnvironmentValue()
}

extension EnvironmentValues {
    var _coordinateSpace: CoordinateSpaceEnvironmentValue {
        get { self[CoordinateSpaceEnvironmentKey.self] }
        set { self[CoordinateSpaceEnvironmentKey.self] = newValue }
    }
}

class CoordinateSpaceEnvironmentValue {
    var activeCoordinateSpace: [CoordinateSpace: CGRect] = [:]
}

struct _CoordinateSpaceModifier<T : Hashable>: ViewModifier {
    @Environment(\._coordinateSpace) var coordinateSpace
    let name: T
    
    public func body(content: Content) -> some View {
        content.background {
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.size, initial: true) {
                        coordinateSpace.activeCoordinateSpace[.named(name)] = proxy.frame(in: .global)
                    }
                    .onDisappear {
                        coordinateSpace.activeCoordinateSpace.removeValue(forKey: .named(name))
                    }
            }
        }
    }
}
