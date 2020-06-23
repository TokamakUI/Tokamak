// Copyright 2020 Tokamak contributors
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

import TokamakDOM

struct SVGCircle: View {
  var body: some View {
    HTML("svg", ["width": "100", "height": "100"]) {
      HTML("circle", [
        "cx": "50", "cy": "50", "r": "40",
        "stroke": "green", "stroke-width": "4", "fill": "yellow",
      ])
    }
  }
}
