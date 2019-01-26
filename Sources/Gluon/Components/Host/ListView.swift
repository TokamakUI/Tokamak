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
  associatedtype Identifier: RawRepresentable
    where Identifier.RawValue == String

  static func cell(
    props: Props,
    item: Item,
    path: CellPath
  ) -> (Identifier, AnyNode)
}

enum SingleIdentifier: String {
  case single
}

public protocol SingleCellProvider: CellProvider
  where Identifier == SingleIdentifier {
  static func cell(
    props: Props,
    item: Item,
    path: CellPath
  ) -> AnyNode
}

extension SingleCellProvider {
  static func cell(
    props: Props,
    item: Item,
    path: CellPath
  ) -> (Identifier, AnyNode) {
    return (.single, cell(props: props, item: item, path: path))
  }
}

public struct ListView<T: CellProvider>: HostComponent {
  public struct Props: Equatable, StyleProps {
    public let cellProps: T.Props
    public let model: [[T.Item]]
    public let style: Style?

    public init(
      cellProps: T.Props,
      model: [T.Item],
      _ style: Style? = nil
    ) {
      self.cellProps = cellProps
      self.model = [model]
      self.style = style
    }

    public init(
      cellProps: T.Props,
      model: [[T.Item]],
      _ style: Style? = nil
    ) {
      self.cellProps = cellProps
      self.model = model
      self.style = style
    }
  }

  public typealias Children = Null
}
