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

extension ZRevRankCommand on SortedSetCommands {
  /// ZREVRANK key member `[WITHSCORE]`
  ///
  /// Returns the rank of member in the sorted set stored at key, with
  /// the scores ordered from high to low.
  Future<dynamic> zRevRank(String key, String member,
      {bool withScore = false}) async {
    final cmd = <String>['ZREVRANK', key, member];
    if (withScore) cmd.add('WITHSCORE');
    return execute(cmd);
  }
}
