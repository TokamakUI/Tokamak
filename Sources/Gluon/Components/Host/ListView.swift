//
//  ListView.swift
//  Gluon
//
//  Created by Max Desiatov on 21/01/2019.
//

public struct CellPath {
  public let item: Int
  public let section: Int
}

public protocol CellProvider {
  associatedtype Item: Equatable
  associatedtype Props: Equatable
  static func cell(props: Props, item: Item, path: CellPath) -> AnyNode
}

public struct ListView<T: CellProvider>: HostComponent {
  public struct Props: Equatable {
    let model: [[T.Item]]
    let cellProps: T.Props
  }

  public typealias Children = Null
}
