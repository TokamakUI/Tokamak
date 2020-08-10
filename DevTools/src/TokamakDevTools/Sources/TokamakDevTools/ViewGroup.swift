import JavaScriptKit
import TokamakDOM

struct ViewButtonStyle: ButtonStyle {
  func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    configuration.label
  }
}

struct ViewGroup: View {
  @EnvironmentObject var inspector: NodeInspector

  let node: Node
  var color: Color {
    node.isPrimitive ? .primary : .blue
  }

  var weight: Font.Weight {
    node.isPrimitive ? .regular : .heavy
  }

  var label: some View {
    Button(node.typeName) { inspector.activeNode = node }
      .buttonStyle(ViewButtonStyle())
      .foregroundColor(color)
      .font(.system(size: 13, weight: weight, design: .monospaced))
      .onHover {
        if let target = node.target {
          if $0 {
            _ = JSObjectRef.global.window.object!.highlightElement!(target)
          } else {
            _ = JSObjectRef.global.window.object!.unhighlightElement!(target)
          }
        } else if let firstChild = node.firstChild(where: { $0.target != nil }) {
          // Highlight the first child host.
          if $0 {
            _ = JSObjectRef.global.window.object!.highlightElement!(firstChild.target!)
          } else {
            _ = JSObjectRef.global.window.object!.unhighlightElement!(firstChild.target!)
          }
        }
      }
  }

  var body: some View {
    Group {
      if let children = node.children {
        DisclosureGroup(content: {
          ForEach(children) { child in
            ViewGroup(node: child)
          }
        }) {
          label
        }
      } else {
        label
      }
    }
  }
}
