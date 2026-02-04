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

extension ZRangeStoreCommand on SortedSetCommands {
  /// ZRANGESTORE dst src min max [BYSCORE | BYLEX] [REV] [LIMIT offset count]
  ///
  /// Stores a range of elements from a sorted set into another key.
  Future<int> zRangeStore(
    String dst,
    String src,
    Object min,
    Object max, {
    bool byScore = false,
    bool byLex = false,
    bool rev = false,
    int? offset,
    int? count,
  }) async {
    final cmd = <String>[
      'ZRANGESTORE',
      dst,
      src,
      min.toString(),
      max.toString()
    ];
    if (byScore) cmd.add('BYSCORE');
    if (byLex) cmd.add('BYLEX');
    if (rev) cmd.add('REV');
    if (offset != null && count != null) {
      cmd.add('LIMIT');
      cmd.add(offset.toString());
      cmd.add(count.toString());
    }
    return executeInt(cmd);
  }
}
