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

extension ZUnionCommand on SortedSetCommands {
  /// ZUNION numkeys key [key ...] [WEIGHTS weight [weight ...]]
  /// [AGGREGATE <SUM | MIN | MAX>] `[WITHSCORES]`
  Future<List<String>> zUnion(
    List<String> keys, {
    List<num>? weights,
    String? aggregate,
    bool withScores = false,
  }) async {
    final cmd = <String>['ZUNION', keys.length.toString(), ...keys];
    if (weights != null) {
      cmd.add('WEIGHTS');
      cmd.addAll(weights.map((w) => w.toString()));
    }
    if (aggregate != null) {
      cmd.add('AGGREGATE');
      cmd.add(aggregate);
    }
    if (withScores) cmd.add('WITHSCORES');

    final result = await execute(cmd);
    return (result as List).cast<String>();
  }
}
