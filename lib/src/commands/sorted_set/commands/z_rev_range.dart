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

extension ZRevRangeCommand on SortedSetCommands {
  /// ZREVRANGE key start stop `[WITHSCORES]`
  ///
  /// **Redis**
  /// As of Redis version 6.2.0, this command is regarded as deprecated.
  /// Deprecated: Use ZRANGE with REV argument.
  ///
  /// **Valkey**: Available.
  Future<List<String>> zRevRange(
    String key,
    int start,
    int stop, {
    bool withScores = false,
  }) async {
    final cmd = <String>['ZREVRANGE', key, start.toString(), stop.toString()];
    if (withScores) cmd.add('WITHSCORES');
    final result = await execute(cmd);
    return (result as List).cast<String>();
  }
}
