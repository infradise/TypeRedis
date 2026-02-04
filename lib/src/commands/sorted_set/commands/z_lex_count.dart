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

import '../commands.dart' show SortedSetCommands;

extension ZLexCountCommand on SortedSetCommands {
  /// ZLEXCOUNT key min max
  ///
  /// Returns the number of elements in the sorted set at key with a value
  /// between min and max.
  /// Min and max are lex ranges (e.g. "[a", "(b", "-", "+")
  Future<int> zLexCount(String key, String min, String max) async {
    final cmd = <String>['ZLEXCOUNT', key, min, max];
    return executeInt(cmd);
  }
}
