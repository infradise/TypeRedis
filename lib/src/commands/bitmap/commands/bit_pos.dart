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

extension BitPosCommand on BitmapCommands {
  /// BITPOS key bit [start [end [BYTE | BIT]]]
  ///
  /// Return the position of the first bit set to 1 or 0 in a string.
  ///
  /// Options:
  /// - [start]: Start byte (or bit) offset.
  /// - [end]: End byte (or bit) offset.
  /// - [useBit]: If true, interprets offsets as bit offsets (Redis 7.0+).
  ///
  /// Complexity: O(N)
  ///
  /// Returns:
  /// - [int]: The position of the first bit set to [bit]. -1 if not found.
  Future<int> bitPos(String key, int bit,
      {int? start, int? end, bool useBit = false}) async {
    final cmd = <String>['BITPOS', key, bit.toString()];

    if (start != null) {
      cmd.add(start.toString());

      final needModifier =
          useBit || (await isValkey70OrLater() || await isRedis70OrLater());

      if (end != null) {
        cmd.add(end.toString());
      } else if (needModifier) {
        cmd.add('-1');
      }

      if (useBit) {
        cmd.add('BIT');
      } else if (_isRedis7OrLater()) {
        if (useBit == false) {
          if (await isRedis70OrLater() || await isValkey70OrLater()) {
            cmd.add('BYTE');
          }
        }
      }
    }

    return executeInt(cmd);
  }

  bool _isRedis7OrLater() => true;
}
