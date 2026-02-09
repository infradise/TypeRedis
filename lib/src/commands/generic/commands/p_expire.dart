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

extension PExpireCommand on GenericCommands {
  /// PEXPIRE key milliseconds [NX|XX|GT|LT]
  ///
  /// Set a timeout on key in milliseconds.
  Future<bool> pExpire(
    String key,
    int milliseconds, {
    bool nx = false,
    bool xx = false,
    bool gt = false,
    bool lt = false,
  }) async {
    final cmd = <String>['PEXPIRE', key, milliseconds.toString()];
    if (nx) cmd.add('NX');
    if (xx) cmd.add('XX');
    if (gt) cmd.add('GT');
    if (lt) cmd.add('LT');
    return (await executeInt(cmd)) == 1;
  }
}
