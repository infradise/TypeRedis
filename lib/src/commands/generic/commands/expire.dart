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

extension ExpireCommand on GenericCommands {
  /// EXPIRE key seconds [NX|XX|GT|LT]
  ///
  /// Set a timeout on key.
  /// Options (Redis 7.0+):
  /// - [nx]: Set expiry only when the key has no expiry.
  /// - [xx]: Set expiry only when the key has an existing expiry.
  /// - [gt]: Set expiry only when the new expiry is greater than current one.
  /// - [lt]: Set expiry only when the new expiry is less than current one.
  Future<bool> expire(
    String key,
    int seconds, {
    bool nx = false,
    bool xx = false,
    bool gt = false,
    bool lt = false,
  }) async {
    final cmd = <String>['EXPIRE', key, seconds.toString()];

    // TODO: Check isRedis70OrLater()

    if (nx) cmd.add('NX');
    if (xx) cmd.add('XX');
    if (gt) cmd.add('GT');
    if (lt) cmd.add('LT');
    return (await executeInt(cmd)) == 1;
  }
}
