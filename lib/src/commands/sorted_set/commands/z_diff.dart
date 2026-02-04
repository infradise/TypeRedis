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

extension ZDiffCommand on SortedSetCommands {
  /// ZDIFF numkeys key [key ...] `[WITHSCORES]`
  ///
  /// Computes the difference between the first and all successive input
  /// sorted sets.
  Future<List<String>> zDiff(List<String> keys,
      {bool withScores = false}) async {
    final cmd = <String>['ZDIFF', keys.length.toString(), ...keys];
    if (withScores) cmd.add('WITHSCORES');
    final result = await execute(cmd);
    return (result as List).cast<String>();
  }
}
