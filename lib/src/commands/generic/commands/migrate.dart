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

extension MigrateCommand on GenericCommands {
  /// MIGRATE host port key|"" destination-db timeout `[COPY]` `[REPLACE]`
  /// [AUTH password] [AUTH2 username password] [KEYS key [key ...]]
  ///
  /// Atomically transfer a key from a source Redis instance to a destination
  /// Redis instance.
  Future<String> migrate(
    String host,
    int port,
    String key, // Use empty string "" if using [keys] parameter
    int destinationDb,
    int timeout, {
    bool copy = false,
    bool replace = false,
    String? authPassword,
    String? auth2Username, // Requires authPassword
    List<String>? keys,
  }) async {
    final targetKey = keys != null && keys.isNotEmpty ? '' : key;

    final cmd = <String>[
      'MIGRATE',
      host,
      port.toString(),
      targetKey,
      destinationDb.toString(),
      timeout.toString()
    ];

    if (copy) cmd.add('COPY');
    if (replace) cmd.add('REPLACE');

    if (auth2Username != null && authPassword != null) {
      cmd.add('AUTH2');
      cmd.add(auth2Username);
      cmd.add(authPassword);
    } else if (authPassword != null) {
      cmd.add('AUTH');
      cmd.add(authPassword);
    }

    if (keys != null && keys.isNotEmpty) {
      cmd.add('KEYS');
      cmd.addAll(keys);
    }

    return executeString(cmd);
  }
}
