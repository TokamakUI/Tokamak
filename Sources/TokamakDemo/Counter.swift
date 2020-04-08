//
//  Counter.swift
//  TokamakDemo
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

public struct Counter: View {
  @State public var count: Int

  let limit: Int

  public init(_ count: Int, limit: Int = Int.max) {
    _count = .init(wrappedValue: count)
    self.limit = limit
  }

  public var body: some View {
    count < limit ?
      AnyView(
        HStack(alignment: .center) {
          Button("Increment") { self.count += 1 }
          Text("\(count)")
        }
      ) : AnyView(HStack { EmptyView() })
  }
}
