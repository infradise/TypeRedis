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

extension ZMScoreCommand on SortedSetCommands {
  /// ZMSCORE key member [member ...]
  ///
  /// Returns the scores associated with the specified members in
  /// the sorted set stored at key.
  Future<List<double?>> zMScore(String key, List<String> members) async {
    final cmd = <String>['ZMSCORE', key, ...members];
    final result = await execute(cmd);
    if (result is List) {
      return result
          .map((e) => e == null ? null : double.parse(e.toString()))
          .toList();
    }
    return [];
  }
}
