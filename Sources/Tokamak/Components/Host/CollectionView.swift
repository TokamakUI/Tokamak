//
//  CollectionView.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/6/19.
//

public struct CollectionView<T: CellProvider>: HostComponent {
  public struct Props: Equatable, StyleProps {
    public let cellProps: T.Props
    public let model: T.Model
    public let onSelect: Handler<CellPath>?
    public let style: Style?

    public init(
      _ style: Style? = nil,
      cellProps: T.Props,
      onSelect: Handler<CellPath>? = nil,
      singleSection: T.Model.Element
    ) {
      self.cellProps = cellProps
      model = T.Model.single(section: singleSection)
      self.onSelect = onSelect
      self.style = style
    }

    public init(
      _ style: Style? = nil,
      cellProps: T.Props,
      model: T.Model,
      onSelect: Handler<CellPath>? = nil
    ) {
      self.cellProps = cellProps
      self.model = model
      self.onSelect = onSelect
      self.style = style
    }
  }

  public typealias Children = Null
}

extension CollectionView.Props where T.Props == Null {
  public init(
    _ style: Style? = nil,
    model: T.Model,
    onSelect: Handler<CellPath>? = nil
  ) {
    cellProps = Null()
    self.model = model
    self.onSelect = onSelect
    self.style = style
  }

  public init(
    _ style: Style? = nil,
    onSelect: Handler<CellPath>? = nil,
    singleSection: T.Model.Element
  ) {
    cellProps = Null()
    model = T.Model.single(section: singleSection)
    self.onSelect = onSelect
    self.style = style
  }
}
