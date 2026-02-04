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

extension ZRandMemberCommand on SortedSetCommands {
  /// ZRANDMEMBER key [count [WITHSCORES]]
  ///
  /// When called with just the key argument, return a random element from
  /// the sorted set value stored at key.
  Future<dynamic> zRandMember(String key,
      {int? count, bool withScores = false}) async {
    final cmd = <String>['ZRANDMEMBER', key];
    if (count != null) {
      cmd.add(count.toString());
      if (withScores) cmd.add('WITHSCORES');
    }
    final result = await execute(cmd);
    if (count == null) {
      return result as String?; // Single element
    }
    return (result as List).cast<String>(); // List
  }
}
