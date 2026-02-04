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

import '../../extensions/server_version_check.dart' show ServerVersionCheck;
import '../commands.dart' show BitmapCommands;

extension BitCountCommand on BitmapCommands {
  /// BITCOUNT key [start end [BYTE | BIT]]
  ///
  /// Count the number of set bits (population counting) in a string.
  ///
  /// Options:
  /// - [start] & [end]: Specify a range.
  /// - [useBit]: If true, interprets start and end as bit offsets
  ///                      (available since Redis 7.0).
  ///             If false (default), interprets them as byte offsets.
  ///
  /// Complexity: O(N)
  ///
  /// Returns:
  /// - [int]: The number of bits set to 1.
  Future<int> bitCount(String key,
      {int? start, int? end, bool useBit = false}) async {
    final cmd = <String>['BITCOUNT', key];

    if (start != null && end != null) {
      cmd.add(start.toString());
      cmd.add(end.toString());
      if (useBit) {
        cmd.add('BIT');
      } else {
        if (useBit == false) {
          if (await isRedis70OrLater() || await isValkey70OrLater()) {
            cmd.add('BYTE');
          }
        }
      }
    }

    return executeInt(cmd);
  }
}
