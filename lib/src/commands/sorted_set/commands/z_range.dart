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

extension ZRangeCommand on SortedSetCommands {
  /// ZRANGE key start stop [BYSCORE | BYLEX] [REV] [LIMIT offset count]
  /// `[WITHSCORES]`
  ///
  /// Returns the specified range of elements in the sorted set stored at key.
  Future<List<String>> zRange(
    String key,
    Object start,
    Object stop, {
    bool byScore = false,
    bool byLex = false,
    bool rev = false,
    int? offset,
    int? count,
    bool withScores = false,
  }) async {
    final cmd = <String>['ZRANGE', key, start.toString(), stop.toString()];
    if (byScore) cmd.add('BYSCORE');
    if (byLex) cmd.add('BYLEX');
    if (rev) cmd.add('REV');
    if (offset != null && count != null) {
      cmd.add('LIMIT');
      cmd.add(offset.toString());
      cmd.add(count.toString());
    }
    if (withScores) cmd.add('WITHSCORES');

    final result = await execute(cmd);
    return (result as List).cast<String>();
  }
}
