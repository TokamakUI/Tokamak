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

enum MetadataState: UInt {
  case complete = 0x00
  case nonTransitiveComplete = 0x01
  case layoutComplete = 0x3F
  case abstract = 0xFF
}

private let isBlockingMask: UInt = 0x100

struct MetadataRequest {
  private let bits: UInt

  init(desiredState: MetadataState, isBlocking: Bool) {
    if isBlocking {
      bits = desiredState.rawValue | isBlockingMask
    } else {
      bits = desiredState.rawValue & ~isBlockingMask
    }
  }
}

struct MetadataResponse {
  let metadata: UnsafePointer<StructMetadata>
  let state: MetadataState
}

@_silgen_name("swift_checkMetadataState")
func _checkMetadataState(_ request: MetadataRequest, _ type: StructMetadata) -> MetadataResponse
