//
//  Created by Max Desiatov on 08/04/2020.
//

public struct Text: View {
  let content: String

  public init(verbatim content: String) {
    self.content = content
  }

  public init<S>(_ content: S) where S: StringProtocol {
    self.content = String(content)
  }
}

public func textContent(_ text: Text) -> String {
  text.content
}
