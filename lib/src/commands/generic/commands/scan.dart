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

import '../commands.dart' show GenericCommands;

extension ScanCommand on GenericCommands {
  /// SCAN cursor [MATCH pattern] [COUNT count] [TYPE type]
  ///
  /// Incrementally iterate the keys space.
  /// Returns: [next_cursor, [keys]]
  Future<List<dynamic>> scan(
    String cursor, {
    String? match,
    int? count,
    String? type,
  }) async {
    final cmd = <String>['SCAN', cursor];
    if (match != null) {
      cmd.add('MATCH');
      cmd.add(match);
    }
    if (count != null) {
      cmd.add('COUNT');
      cmd.add(count.toString());
    }
    if (type != null) {
      cmd.add('TYPE');
      cmd.add(type);
    }

    final result = await execute(cmd);
    if (result is! List) return ['0', <List>[]];

    // Ensure strict typing for return
    final nextCursor = result[0].toString();
    final keys = (result[1] as List).map((e) => e.toString()).toList();

    return [nextCursor, keys];
  }
}
