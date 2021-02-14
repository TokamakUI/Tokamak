import TokamakShim

struct TokamakApp: App {
  var body: some Scene {
    WindowGroup("Spooky Hanger") {
      NavigationView {
        List {
          ForEach(["Item 1"], id: \.self) { childRow in
            NavigationLink(
              destination: Text(childRow)
            ) {
              Text(childRow)
            }
          }
        }
      }
    }
  }
}

TokamakApp.main()
