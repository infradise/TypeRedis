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

extension ZScanCommand on SortedSetCommands {
  /// ZSCAN key cursor [MATCH pattern] [COUNT count]
  ///
  /// Iterates elements of Sorted Set types.
  Future<List<dynamic>> zScan(
    String key,
    int cursor, {
    String? match,
    int? count,
  }) async {
    final cmd = <String>['ZSCAN', key, cursor.toString()];
    if (match != null) {
      cmd.add('MATCH');
      cmd.add(match);
    }
    if (count != null) {
      cmd.add('COUNT');
      cmd.add(count.toString());
    }

    final result = await execute(cmd);
    if (result is List && result.length == 2) {
      final nextCursor = result[0] as String;
      final elements = (result[1] as List).cast<String>();
      return [nextCursor, elements];
    }
    throw Exception('Unexpected ZSCAN response format');
  }
}
