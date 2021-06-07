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
//
//  Created by Max Desiatov on 07/12/2018.
//

import TokamakStaticHTML
import XCTest

private let expectedHTML =
  #"""
  <html>
  <head>
    <title></title>
    <style>
      ._tokamak-stack > * {
    flex-shrink: 0;
  }
  ._tokamak-scrollview-hideindicators {
    scrollbar-color: transparent;
    scrollbar-width: 0;
  }
  ._tokamak-scrollview-hideindicators::-webkit-scrollbar {
    width: 0;
    height: 0;
  }
  ._tokamak-list {
    list-style: none;
    overflow-y: auto;
    width: 100%;
    height: 100%;
    padding: 0;
  }
  ._tokamak-disclosuregroup-label {
    cursor: pointer;
  }
  ._tokamak-disclosuregroup-chevron-container {
    width: .25em;
    height: .25em;
    padding: 10px;
    display: inline-block;
  }
  ._tokamak-disclosuregroup-chevron {
    width: 100%;
    height: 100%;
    transform: rotate(45deg);
    border-right: solid 2px rgba(0, 0, 0, 0.25);
    border-top: solid 2px rgba(0, 0, 0, 0.25);
  }
  ._tokamak-disclosuregroup-content {
    display: flex;
    flex-direction: column;
    margin-left: 1em;
  }
  ._tokamak-buttonstyle-reset {
    -webkit-appearance: none;
    -moz-appearance: none;
    appearance: none;
    background: transparent;
    border: none;
    margin: 0;
    padding: 0;
    font-size: inherit;
  }

  ._tokamak-text-redacted {
    position: relative;
  }
  ._tokamak-text-redacted::after {
    content: " ";
    background-color: rgb(200, 200, 200);
    position: absolute;
    left: 0;
    width: calc(100% + .1em);
    height: 1.2em;
    border-radius: .1em;
  }
  ._tokamak-geometryreader {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  ._tokamak-navigationview {
    display: flex;
    flex-direction: row;
    align-items: stretch;
    width: 100%;
    height: 100%;
  }
  ._tokamak-navigationview-content {
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    flex-grow: 1;
    height: 100%;
  }

  ._tokamak-formcontrol {
    color-scheme: light dark;
  }

  ._tokamak-link {
    text-decoration: none;
  }

  ._tokamak-texteditor {
    width: 100%;
    height: 100%;
  }

  @media (prefers-color-scheme:dark) {
    ._tokamak-text-redacted::after {
      background-color: rgb(100, 100, 100);
    }

    ._tokamak-disclosuregroup-chevron {
      border-right-color: rgba(255, 255, 255, 0.25);
      border-top-color: rgba(255, 255, 255, 0.25);
    }
  }
    </style>
  </head>
  <body style="margin: 0;display: flex;
  width: 100%;
  height: 100%;
  justify-content: center;
  align-items: center;
  overflow: hidden;"><div class="_tokamak-stack" style="display: flex; flex-direction: column; align-items: center;
  height: 100%;
  "><span class="" style="
  font-family: system,
  -apple-system,
  '.SFNSText-Regular',
  'San Francisco',
  'Roboto',
  'Segoe UI',
  'Helvetica Neue',
  'Lucida Grande',
  sans-serif;
  color: rgba(0.0, 0.0, 0.0, 1.0);
  font-style: normal;
  font-weight: 400;
  letter-spacing: normal;
  vertical-align: baseline;
  text-decoration: none;
  text-decoration-color: inherit;
  text-align: left;">text</span>
  <div style="flex-grow: 1; "></div></div></body>
  </html>
  """#

final class ReconcilerTests: XCTestCase {
  struct Model {
    let text: Text
  }

  private struct OptionalBody: View {
    var model: Model?

    var body: some View {
      if let text = model?.text {
        VStack {
          text

          Spacer()
        }
      }
    }
  }

  func testOptional() {
    let resultingHTML = StaticHTMLRenderer(OptionalBody(model: Model(text: Text("text"))))
      .render(shouldSortAttributes: true)

    XCTAssertEqual(resultingHTML, expectedHTML)
  }
}
