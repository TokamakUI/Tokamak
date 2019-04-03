//
//  TestProps.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/2/19.
//

import Foundation

public protocol Default {
    var str: String { get }
}

struct Props: Default {
  var str: String
}
