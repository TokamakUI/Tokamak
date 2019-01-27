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

/** A collection of sections with random access to its elements and
 an ability to create a new `SectionModel` with a single section. The most
 basic `SectionedModel` is an array of arrays `[[T]]`, where every element
 in the top level array is a section `[T]` and every element `T` is a row/item
 in this section.
 */
public protocol SectionedModel: RandomAccessCollection
  where Element: RandomAccessCollection, Index == Int {
  static func single(section: Element) -> Self
}

extension Array: SectionedModel where Element: RandomAccessCollection {
  public static func single(section: Element) -> [Element] {
    return [section]
  }
}

public protocol CellProvider {
  associatedtype Props: Equatable
  associatedtype Identifier: RawRepresentable
    where Identifier.RawValue == String
  associatedtype Model: SectionedModel & Equatable

  static func cell(
    props: Props,
    item: Model.Element.Element,
    path: CellPath
  ) -> (Identifier, AnyNode)
}

enum SingleIdentifier: String {
  case single
}

public protocol SimpleCellProvider: CellProvider
  where Identifier == SingleIdentifier {
  static func cell(
    props: Props,
    item: Model.Element.Element,
    path: CellPath
  ) -> AnyNode
}

extension SimpleCellProvider {
  static func cell(
    props: Props,
    item: Model.Element.Element,
    path: CellPath
  ) -> (Identifier, AnyNode) {
    return (.single, cell(props: props, item: item, path: path))
  }
}

public struct ListView<T: CellProvider>: HostComponent {
  public struct Props: Equatable, StyleProps {
    public let cellProps: T.Props
    public let model: T.Model
    public let style: Style?

    public init(
      cellProps: T.Props,
      singleSection: T.Model.Element,
      _ style: Style? = nil
    ) {
      self.cellProps = cellProps
      model = T.Model.single(section: singleSection)
      self.style = style
    }

    public init(
      cellProps: T.Props,
      model: T.Model,
      _ style: Style? = nil
    ) {
      self.cellProps = cellProps
      self.model = model
      self.style = style
    }
  }

  public typealias Children = Null
}
