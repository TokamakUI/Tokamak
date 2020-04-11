//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Button<Label>: View where Label: View {
  let label: Label
  let action: () -> ()

  public init(action: @escaping () -> (), @ViewBuilder label: () -> Label) {
    self.label = label()
    self.action = action
  }
}

extension Button where Label == Text {
  public init<S>(_ title: S, action: @escaping () -> ()) where S: StringProtocol {
    self.init(action: action) {
      Text(title)
    }
  }
}
