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

import '../commands.dart' show StreamCommands, parseStreamEntry;

extension XAutoClaimCommand on StreamCommands {
  /// XAUTOCLAIM key group consumer min-idle-time start [COUNT count]
  /// `[JUSTID]`
  ///
  /// Returns: [next_start_id, [entries]]
  Future<List<dynamic>> xAutoClaim(
    String key,
    String group,
    String consumer,
    int minIdleTime,
    String start, {
    int? count,
    bool justId = false,
  }) async {
    final cmd = <String>[
      'XAUTOCLAIM',
      key,
      group,
      consumer,
      minIdleTime.toString(),
      start
    ];

    if (count != null) {
      cmd.add('COUNT');
      cmd.add(count.toString());
    }
    if (justId) cmd.add('JUSTID');

    final result = await execute(cmd);
    if (result is! List) return ['0-0', <List>[]];

    final nextStartId = result[0].toString();
    final rawEntries = result[1] as List;

    final entries = rawEntries.map((e) {
      if (justId) return e.toString();
      return parseStreamEntry(e as List);
    }).toList();

    return [nextStartId, entries];
  }
}
