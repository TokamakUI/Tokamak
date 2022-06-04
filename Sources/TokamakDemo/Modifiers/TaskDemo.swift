// Copyright 2021 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if os(WASI) && compiler(>=5.5) && (canImport(Concurrency) || canImport(_Concurrency))
import JavaScriptKit
import TokamakDOM

private let jsFetch = JSObject.global.fetch.function!
private func fetch(_ url: String) -> JSPromise {
  JSPromise(jsFetch(url).object!)!
}

private struct Response: Decodable {
  let uuid: String
}

struct TaskDemo: View {
  @State
  private var response: Result<Response, Error>?

  var body: some View {
    VStack {
      switch response {
      case let .success(response):
        Text("Fetched UUID is \(response.uuid)")
      case let .failure(error):
        Text("Error is \(error)")
      default:
        Text("Response not available yet")
      }

      Button("Fetch new UUID asynchronously") {
        response = nil
        Task { await fetchResponse() }
      }
    }.task {
      await fetchResponse()
    }
  }

  func fetchResponse() async {
    do {
      let fetchResult = try await fetch("https://httpbin.org/uuid").value
      let json = try await JSPromise(fetchResult.json().object!)!.value
      response = Result { try JSValueDecoder().decode(Response.self, from: json) }
    } catch {
      response = .failure(error)
    }
  }
}
#endif
