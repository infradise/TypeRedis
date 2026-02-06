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

import 'package:typeredis/typeredis.dart';

Future<void> main() async {
  final client = TRClient(host: 'localhost', port: 6379);
  await client.connect();
  await client.flushAll();

  print('--- 🛠 TypeRedis Stream Management Example ---\n');

  const key = 'logs:system';

  // 1. Populate Stream
  print('1. Adding 10 log entries...');
  for (var i = 1; i <= 10; i++) {
    await client.xAdd(key, {'id': '$i', 'msg': 'Log entry #$i'});
  }

  // XLEN: Check length
  final len = await client.xLen(key);
  print('   Current Stream Length: $len'); // 10

  // 2. XTRIM: Cap the stream size
  // Keep only the last 5 entries (Drop oldest 5)
  print('\n2. Trimming stream to keep last 5 entries (XTRIM)...');
  final trimmed = await client.xTrim(key, maxLen: 5);
  print('   Trimmed (Deleted): $trimmed entries');
  print('   New Length: ${await client.xLen(key)}'); // 5

  // 3. XDEL: Delete a specific entry
  // Let's remove the specific entry. We need an ID first.
  final entries = await client.xRevRange(key, count: 1); // Get latest
  final victimId = entries[0].id;

  print('\n3. Deleting specific entry $victimId (XDEL)...');
  final deleted = await client.xDel(key, [victimId]);
  print('   Deleted count: $deleted');

  // 4. XREVRANGE: Inspect in reverse order (Latest first)
  print('\n4. Inspecting logs (Latest First) (XREVRANGE)...');
  final reverseLogs = await client.xRevRange(key, start: '+', end: '-');
  for (var log in reverseLogs) {
    print('   [${log.id}] ${log.fields}');
  }

  // 5. XINFO: Introspection
  print('\n5. Stream Introspection (XINFO)...');

  // Setup a group for demonstration
  await client.xGroupCreate(key, 'monitor_group', '0', mkStream: true);
  await client.xGroupCreateConsumer(key, 'monitor_group', 'viewer_1');

  // A. XINFO STREAM
  final streamInfo = await client.xInfoStream(key) as List; // key-value list
  print('   Stream Info (Raw): $streamInfo');

  // B. XINFO GROUPS
  final groups = await client.xInfoGroups(key);
  print('   Consumer Groups found: ${groups.length}');

  // C. XINFO CONSUMERS
  final consumers = await client.xInfoConsumers(key, 'monitor_group');
  print('   Consumers in "monitor_group": $consumers');

  // 6. XGROUP Maintenance
  print('\n6. Group Maintenance...');

  // A. XGROUP SETID (Rewind group to beginning)
  await client.xGroupSetId(key, 'monitor_group', '0');
  print('   Rewound "monitor_group" to 0.');

  // B. XGROUP DELCONSUMER
  final pending =
      await client.xGroupDelConsumer(key, 'monitor_group', 'viewer_1');
  print('   Deleted consumer "viewer_1" (Pending msgs: $pending)');

  // C. XGROUP DESTROY
  final destroyed = await client.xGroupDestroy(key, 'monitor_group');
  print('   Destroyed group "monitor_group": $destroyed');

  // 7. XSETID (Advanced/Internal use)
  // Force the next ID to be extremely high
  print('\n7. Setting next ID manually (XSETID)...');
  // Usually used when restoring backups or migrating data
  await client.xSetId(key, '9999999999999-0');
  print('   Next ID will be > 9999999999999-0');

  await client.close();
  print('\n--- Done ---');
}
