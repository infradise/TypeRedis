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

import '../../../server_metadata.dart' show RunningMode, ServerMetadata;
import '../commands.dart' show ServerCommands;

extension InfoServerMetadataCommand on ServerCommands {
  /// Executes 'INFO SERVER' and parses the result into [ServerMetadata].
  Future<ServerMetadata> infoServerMetadata() async {
    final info = await executeString(['INFO', 'SERVER']);

    var version = '0.0.0';
    var name = 'unknown';
    var mode = RunningMode.unknown;

    // (Parse here OS, TCP Port, etc. if needed)

    final lines = info.split('\r\n');
    for (final line in lines) {
      if (line.isEmpty || line.startsWith('#')) continue;

      final parts = line.split(':');
      if (parts.length < 2) continue;

      final key = parts[0];
      final value = parts[1];

      switch (key) {
        case 'redis_version':
          if (name != 'valkey') {
            version = value;
            name = 'redis';
          }
          break;
        case 'valkey_version':
          version = value;
          name = 'valkey';
          break;
        case 'redis_mode':
        case 'server_mode':
          if (value == 'cluster') {
            mode = RunningMode.cluster;
          } else if (value == 'sentinel') {
            mode = RunningMode.sentinel;
          } else {
            mode = RunningMode.standalone;
          }
          break;
      }
    }

    return ServerMetadata(
      version: version,
      serverName: name,
      mode: mode,
      maxDatabases: 16, // TODO: databases from 'INFO KEYSPACE'
    );
  }
}
