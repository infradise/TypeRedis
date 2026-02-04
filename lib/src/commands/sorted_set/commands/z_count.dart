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

extension ZCountCommand on SortedSetCommands {
  /// ZCOUNT key min max
  ///
  /// Returns the number of elements in the sorted set at key with a score
  /// between min and max.
  Future<int> zCount(String key, Object min, Object max) async {
    final cmd = <String>['ZCOUNT', key, min.toString(), max.toString()];
    return executeInt(cmd);
  }
}
