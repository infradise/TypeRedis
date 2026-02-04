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

extension ZInterCommand on SortedSetCommands {
  /// ZINTER numkeys key [key ...] [WEIGHTS weight [weight ...]]
  /// [AGGREGATE <SUM | MIN | MAX>] `[WITHSCORES]`
  ///
  /// Computes the intersection of numkeys sorted sets given by
  /// the specified keys.
  Future<List<String>> zInter(
    List<String> keys, {
    List<num>? weights,
    String? aggregate, // SUM, MIN, MAX
    bool withScores = false,
  }) async {
    final cmd = <String>['ZINTER', keys.length.toString(), ...keys];
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
