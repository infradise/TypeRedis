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

extension ZRevRangeByLexCommand on SortedSetCommands {
  /// ZREVRANGEBYLEX key max min [LIMIT offset count]
  ///
  /// **Redis**
  /// As of Redis version 6.2.0, this command is regarded as deprecated.
  /// Deprecated: Use ZRANGE with BYLEX and REV arguments.
  ///
  /// **Valkey**: Available.
  Future<List<String>> zRevRangeByLex(
    String key,
    String max,
    String min, {
    int? offset,
    int? count,
  }) async {
    final cmd = <String>['ZREVRANGEBYLEX', key, max, min];
    if (offset != null && count != null) {
      cmd.add('LIMIT');
      cmd.add(offset.toString());
      cmd.add(count.toString());
    }
    final result = await execute(cmd);
    return (result as List).cast<String>();
  }
}
