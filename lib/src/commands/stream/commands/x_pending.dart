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

import '../commands.dart' show StreamCommands;

extension XPendingCommand on StreamCommands {
  /// XPENDING key group [[IDLE min-idle-time] start end count [consumer]]
  ///
  /// Inspecting pending messages in a Consumer Group.
  ///
  /// Returns:
  /// - Summary form: [pending_count, min_id, max_id, consumer_list]
  /// - Extended form: List of pending messages details.
  Future<dynamic> xPending(
    String key,
    String group, {
    int? idle,
    String? start,
    String? end,
    int? count,
    String? consumer,
  }) async {
    final cmd = <String>['XPENDING', key, group];

    if (start != null && end != null && count != null) {
      if (idle != null) {
        cmd.add('IDLE');
        cmd.add(idle.toString());
      }
      cmd.add(start);
      cmd.add(end);
      cmd.add(count.toString());
      if (consumer != null) cmd.add(consumer);
    }

    return execute(cmd);
  }
}
