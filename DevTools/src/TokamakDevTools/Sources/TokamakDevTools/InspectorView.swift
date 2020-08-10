import TokamakDOM

struct InspectorView: View {
  @EnvironmentObject var inspector: NodeInspector

  var body: some View {
    List {
      if let activeNode = inspector.activeNode {
        Group {
          Text(activeNode.type)
          Section(header: Text("Dynamic Properties")) {
            ForEach(activeNode.dynamicProperties, id: \.self) {
              Text($0)
            }
          }
        }
      } else {
        Text("Click on a node.")
      }
    }
    .listStyle(SidebarListStyle())
    .frame(idealWidth: 100, minHeight: 0, maxHeight: .infinity)
  }
}
