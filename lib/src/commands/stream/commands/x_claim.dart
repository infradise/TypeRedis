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

import '../commands.dart' show StreamCommands, StreamEntry, parseStreamEntry;

extension XClaimCommand on StreamCommands {
  /// XCLAIM key group consumer min-idle-time id [id ...] [IDLE ms]
  /// [TIME ms-unix-time] [RETRYCOUNT count] `[FORCE]` `[JUSTID]`
  ///
  /// Changes (or acquires) ownership of a message in a consumer group.
  Future<List<StreamEntry>> xClaim(
    String key,
    String group,
    String consumer,
    int minIdleTime,
    List<String> ids, {
    int? idle,
    int? time,
    int? retryCount,
    bool force = false,
    bool justId = false,
  }) async {
    final cmd = <String>[
      'XCLAIM',
      key,
      group,
      consumer,
      minIdleTime.toString()
    ];
    cmd.addAll(ids);

    if (idle != null) {
      cmd.add('IDLE');
      cmd.add(idle.toString());
    }
    if (time != null) {
      cmd.add('TIME');
      cmd.add(time.toString());
    }
    if (retryCount != null) {
      cmd.add('RETRYCOUNT');
      cmd.add(retryCount.toString());
    }
    if (force) cmd.add('FORCE');
    if (justId) cmd.add('JUSTID');

    final result = await execute(cmd);
    if (result == null) return [];

    // If JUSTID is used, it returns list of IDs (String).
    // Otherwise, returns list of entries.
    // For type safety in this specific method, we assume standard usage
    // (StreamEntry).
    // If JUSTID is vital, we might need a separate method or dynamic return.
    // Here we parse as StreamEntry, implying JUSTID=false usage or h
    // andle emptiness.

    return (result as List).map((e) {
      if (justId) {
        // Only IDs returned, cannot make full StreamEntry with fields
        return StreamEntry(id: e.toString(), fields: {});
      }
      return parseStreamEntry(e as List);
    }).toList();
  }
}
