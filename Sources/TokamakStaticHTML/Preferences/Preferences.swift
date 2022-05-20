//
//  Preferences.swift
//  
//
//  Created by Andrew Barba on 5/20/22.
//

import TokamakCore

internal struct HTMLTitlePreferenceKey: PreferenceKey {
    static var defaultValue: String = ""

    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

internal struct HTMLMetaPreferenceKey: PreferenceKey {
    internal enum HTMLMeta: Equatable, Hashable {
        case charset(_ charset: String)
        case name(_ name: String, content: String)
        case property(_ property: String, content: String)
        case httpEquiv(_ httpEquiv: String, content: String)
    }

    static var defaultValue: [HTMLMeta] = []

    static func reduce(value: inout [HTMLMeta], nextValue: () -> [HTMLMeta]) {
        value.append(contentsOf: nextValue())
    }
}
