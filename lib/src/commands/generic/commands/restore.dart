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

extension RestoreCommand on GenericCommands {
  /// RESTORE key ttl serialized-value [REPLACE] [ABSTTL] [IDLETIME seconds]
  /// [FREQ frequency]
  ///
  /// Create a key associated with a value that is obtained by deserializing
  /// the provided serialized value.
  Future<String> restore(
    String key,
    int ttl,
    List<int> serializedValue, {
    bool replace = false,
    bool absttl = false,
    int? idleTime,
    int? freq,
  }) async {
    // Command list must be <dynamic> or <Object> to hold List<int>
    // (binary data)
    // Use List<dynamic> to support binary data (serializedValue)
    final cmd = <dynamic>['RESTORE', key, ttl, serializedValue];

    if (replace) cmd.add('REPLACE');
    if (absttl) cmd.add('ABSTTL');
    if (idleTime != null) {
      cmd.add('IDLETIME');
      cmd.add(idleTime);
    }
    if (freq != null) {
      cmd.add('FREQ');
      cmd.add(freq);
    }

    // NOTE: Do NOT use executeString() here. Need to handle binary payload.
    // executeString() typically expects List<String>, which fails for binary
    // data.
    // Use execute() directly, which should handle List<dynamic>, and convert
    // result to String.
    // Standard execute() casts everything to String, which corrupts binary
    // payloads.
    // The implementation of executeDynamic in the client must handle List<int>
    // as raw bytes.
    final result = await execute(cmd);

    return result.toString();
  }
}
