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

public let tokamakStyles = """
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

@media (prefers-color-scheme:dark) {
  ._tokamak-buttonstyle-default {
    background-color: rgb(99, 95, 98);
  }

  ._tokamak-securefield {
    background-color: rgb(99, 95, 98);
    color: #FFFFFF;
  }
  ._tokamak-textfield-default {
    background-color: rgb(99, 95, 98);
    color: #FFFFFF;
  }
  ._tokamak-textfield-roundedborder {
    background-color: rgb(99, 95, 98);
    color: #FFFFFF;
  }

  ._tokamak-picker {
    background-color: rgb(99, 95, 98);
    color: #FFFFFF;
  }

  ._tokamak-text-redacted::after {
    background-color: rgb(100, 100, 100);
  }
}
"""

public let rootNodeStyles = """
display: flex;
width: 100%;
height: 100%;
justify-content: center;
align-items: center;
overflow: hidden;
"""
