/*
 * Copyright 2025-2026 Infradise Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import '../commands.dart' show GenericCommands;

extension TypeCommand on GenericCommands {
  /// TYPE key
  ///
  /// Returns the string representation of the type of the value stored at
  /// [key].
  /// The different types that can be returned are: string, list, set, zset,
  /// hash, stream and none.
  ///
  /// Complexity: O(1)
  ///
  /// Returns:
  /// - [String]: The type of the value (e.g., "string", "list", "set", "zset",
  /// "hash", "stream", "none").
  Future<String> type(String key) async {
    final cmd = <String>['TYPE', key];
    return executeString(cmd);
  }
}
