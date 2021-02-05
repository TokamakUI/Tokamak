import TokamakShim

struct TokamakApp: App {
  var body: some Scene {
    WindowGroup("Spooky Hanger") {
      NavigationView {
        List {
          ForEach(["Section"], id: \.self) { section in
            Section(header: Text(section).font(.headline)) {
              ForEach(["Item 1"], id: \.self) { childRow in
                NavigationLink(
                  destination: Text(childRow).padding([.leading, .trailing])
                ) {
                  Text(childRow)
                }
                .padding(.leading)
              }
            }
          }
        }
        .listStyle(SidebarListStyle())
      }
    }
  }
}

TokamakApp.main()
