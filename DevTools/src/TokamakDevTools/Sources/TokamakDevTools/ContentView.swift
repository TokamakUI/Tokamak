import TokamakDOM

struct ContentView: View {
  @EnvironmentObject var tree: Tree
  @State private var onlyComposite: Bool = true
  @State private var query: String = ""

  @ObservedObject var inspector = NodeInspector()

  var body: some View {
    ScrollView {
      HStack {
        Toggle("Only Composite Views", isOn: $onlyComposite)
        TextField("Search", text: $query)
      }
      HStack {
        // OutlineGroup(tree.root, children: onlyComposite ? \.compositeChildren : \.children) {
        //     Text(String($0.type.split(separator: "<").first!))
        //         .foregroundColor($0.isPrimitive ? .primary : ($0.isHost ? .green : .blue))
        //         .font(.system(size: 12, weight: $0.isPrimitive ? .regular : .bold, design: .monospaced))
        // }
        VStack {
          ViewGroup(node: tree.root)
        }
        Spacer()
        InspectorView()
      }
    }
    .environmentObject(inspector)
  }
}
