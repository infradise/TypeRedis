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

extension ObjectFreqCommand on GenericCommands {
  /// OBJECT FREQ key
  ///
  /// Returns the logarithmic access frequency counter of a Redis object (LFU).
  /// Available when maxmemory-policy is set to an LFU policy.
  Future<int?> objectFreq(String key) async {
    final cmd = <String>['OBJECT', 'FREQ', key];
    return await execute(cmd) as int?;
  }
}
