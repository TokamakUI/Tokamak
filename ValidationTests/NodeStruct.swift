//
//  NodeStruct.swift
//  SwiftCLI
//
//  This file help to test Node
//
//  Created by Matvii Hodovaniuk on 5/12/19.
//

import Foundation

struct Img {
  let className = "Icon"
  let id = "uniq-id-0001"
  let height = 400
  let width = 300
}

struct Div {
  let className = "Avatar"
  let id = "uniq-id-0000"
  let disabled = false

  let content = Img()
}
