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

import '../commands.dart' show BitmapCommands;

extension BitOpCommand on BitmapCommands {
  /// BITOP operation destkey key [key ...]
  ///
  /// Perform a bitwise operation between multiple keys (containing string
  /// values)
  /// and store the result in the destination key.
  ///
  /// Operations: 'AND', 'OR', 'XOR', 'NOT'
  /// Note: 'NOT' requires exactly one source key.
  ///
  /// Complexity: O(N)
  ///
  /// Returns:
  /// - [int]: The size of the string stored in the destination key.
  Future<int> bitOp(String operation, String destKey, List<String> keys) async {
    final op = operation.toUpperCase();
    final cmd = <String>['BITOP', op, destKey, ...keys];
    return executeInt(cmd);
  }
}
