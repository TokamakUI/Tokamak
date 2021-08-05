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

import TokamakCore

public let tokamakStyles = """
._tokamak-stack {
  display: grid;
}
._tokamak-hstack {
  grid-auto-flow: column;
  column-gap: var(--tokamak-stack-gap, \(Int(defaultStackSpacing))px);
}
._tokamak-vstack {
  grid-auto-flow: row;
  row-gap: var(--tokamak-stack-gap, \(Int(defaultStackSpacing))px);
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
@supports (-webkit-appearance: default-button) {
  ._tokamak-button-prominence-increased {
    -webkit-appearance: default-button;
  }
}
@supports not (-webkit-appearance: default-button) {
  ._tokamak-button-prominence-increased {
    background-color: rgb(55, 120, 246);
    border: 1px solid rgb(88, 156, 248);
    border-radius: 4px;
  }
  ._tokamak-button-prominence-increased:active {
    background-color: rgb(38, 99, 226);
  }

  @media (prefers-color-scheme:dark) {
    ._tokamak-button-prominence-increased {
      background-color: rgb(56, 116, 225);
    }
    ._tokamak-button-prominence-increased:active {
      background-color: rgb(56, 134, 247);
    }
  }
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
._tokamak-navigationview-with-toolbar-content ._tokamak-scrollview {
  padding-top: 50px;
}
._tokamak-navigationview-destination {
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  flex-grow: 1;
  height: 100%;
}

._tokamak-toolbar {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 50px;
  display: flex;
  align-items: center;
  overflow: hidden;
  background: rgba(200, 200, 200, 0.2);
  -webkit-backdrop-filter: saturate(180%) blur(20px);
  backdrop-filter: saturate(180%) blur(20px);
}

._tokamak-toolbar-content {
  flex: 1 1 auto;
  display: flex;
  height: 100%;
}
._tokamak-toolbar-leading > *, ._tokamak-toolbar-center > * {
  margin-right: 8px;
}
._tokamak-toolbar-trailing > * {
  margin-left: 8px;
}
._tokamak-toolbar-leading {
  margin-right: auto;
  align-items: center;
  justify-content: flex-start;
  padding-left: 16px;
}
._tokamak-toolbar-center {
  align-items: center;
  justify-content: center;
}
._tokamak-toolbar-trailing {
  margin-left: auto;
  align-items: center;
  justify-content: flex-end;
  padding-right: 16px;
}

._tokamak-toolbar-button {
  padding: 2px 4px;
  border-radius: 3px;
  border: 1px solid rgba(0, 0, 0, 0.05);
  height: 25px;
  padding: 0 8px;
  display: flex;
  align-items: center;
}
._tokamak-toolbar-button:hover {
  border-color: transparent;
  background-color: rgba(0, 0, 0, 0.05);
}
._tokamak-toolbar-button:active {
  border-color: transparent;
  background-color: rgba(0, 0, 0, 0.1);
}
._tokamak-toolbar-textfield input {
  padding: 4px 4px 4px 8px;
  border-radius: 3px;
  background-color: rgba(0, 0, 0, 0.05);
  width: 100%;
  height: 100%;
}

._tokamak-formcontrol, ._tokamak-formcontrol-reset {
  color-scheme: light dark;
}
._tokamak-formcontrol-reset {
  background: none;
  border: none;
}

._tokamak-link {
  text-decoration: none;
}

._tokamak-texteditor {
  width: 100%;
  height: 100%;
}

._tokamak-aspect-ratio-fill > img {
  object-fit: fill;
}

._tokamak-aspect-ratio-fit > img {
  object-fit: contain;
}

@media (prefers-color-scheme:dark) {
  ._tokamak-text-redacted::after {
    background-color: rgb(100, 100, 100);
  }

  ._tokamak-disclosuregroup-chevron {
    border-right-color: rgba(255, 255, 255, 0.25);
    border-top-color: rgba(255, 255, 255, 0.25);
  }

  ._tokamak-toolbar {
    background: rgba(100, 100, 100, 0.2);
  }
  ._tokamak-toolbar-button {
    border: 1px solid rgba(255, 255, 255, 0.1);
  }
  ._tokamak-toolbar-button:hover {
    background-color: rgba(255, 255, 255, 0.05);
  }
  ._tokamak-toolbar-button:active {
    background-color: rgba(255, 255, 255, 0.1);
  }
  ._tokamak-toolbar-textfield input {
    background-color: rgba(255, 255, 255, 0.05);
    color: #FFFFFF;
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
