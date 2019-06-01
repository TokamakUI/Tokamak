struct List: PureLeafComponent {
  struct Props: Equatable {
    let model: [AppRoute]
    let onSelect: Handler<CellPath>
  }

  static func render(props: Props) -> AnyNode {
    return ListView<Cells>.node(.init(
      Style([
        Edges.equal(to: .parent),
      ]),
      model: [props.model],
      onSelect: props.onSelect
    ))
  }
}
