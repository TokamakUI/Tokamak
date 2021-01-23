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

/** Returns name of a given unapplied generic type. `Button<Text>` and
 `Button<Image>` types are different, but when reconciling the tree of mounted views
 they are treated the same, thus the `Button` part of the type (the type constructor)
 is returned.
 */
func typeConstructorName(_ type: Any.Type) -> String {
  // FIXME: no idea if this calculation is reliable, but seems to be the only way to get
  // a name of a type constructor in runtime. Should definitely check if these are different
  // across modules, otherwise can cause problems with views with same names in different
  // modules.
  String(String(describing: type).prefix { $0 != "<" })
}
