// Copyright 2019-2020 Tokamak contributors
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
//
//  Created by Jed Fox on 07/01/2020.
//

#if canImport(SwiftUI)
import SwiftUI
#else
import TokamakDOM
#endif

struct TokamakDemoView: View {
  var body: some View {
    ScrollView(showsIndicators: false) {
      HStack {
        Spacer()
      }
      VStack {
        Counter(count: 5, limit: 15)
          .padding()
          .background(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
          .border(Color.red, width: 3)
        ZStack {
          Text("I'm on bottom")
          Text("I'm forced to the top")
            .zIndex(1)
          Text("I'm on top")
        }
        .padding(20)
        ForEachDemo()
        TextDemo()
        #if canImport(TokamakDOM)
        SVGCircle()
          .frame(width: 25, height: 25)
        #endif
        TextFieldDemo()
        SpacerDemo()
        Spacer()
        Text("Forced to bottom.")
        EnvironmentDemo()
          .font(.system(size: 21))
      }
    }
  }
}
