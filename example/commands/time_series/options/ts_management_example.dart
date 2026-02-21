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

import 'package:keyscope_client/keyscope_client.dart';

Future<void> main() async {
  final client = KeyscopeClient(host: 'localhost', port: 6379);
  await client.connect();

  // Redis Only Feature
  if (!await client.isRedisServer()) {
    // or !await client.isRedis
    print('⚠️  Skipping: This example requires a Redis server.');
    print('   Current server appears to be Valkey or other compatible server.');
    await client.close(); // disconnect
    return;
  }

  await client.flushAll();

  print('--- ⚙️ Time Series Management Example ---');

  const rawKey = 'sensor:raw';
  const avgKey = 'sensor:avg_1m';

  // Setup: Create raw and compacted keys
  await client.tsCreate(rawKey,
      options: ['LABELS', 'type', 'raw'], forceRun: true);
  await client.tsCreate(avgKey,
      options: ['LABELS', 'type', 'avg'], forceRun: true);

  // 1. TS.CREATERULE (Downsampling)
  print('1. Creating Compaction Rule...');
  // Rule: Aggregate 'raw' data into 'avg_1m' using 'avg' function over 60000ms
  //       (1 min) buckets
  await client.tsCreateRule(rawKey, avgKey, 'avg', 60000, forceRun: true);
  print('   Rule created: raw -> avg_1m (1 min average)');

  // 2. TS.INFO
  print('2. Inspecting Series Info...');
  final info = await client.tsInfo(rawKey, forceRun: true);
  // Info should show the rule
  print('   Source Key Info (Partial): $info');

  // 3. TS.ALTER
  print('3. Altering Series Configuration...');
  // Change retention policy to 2 hours (7200000 ms) and update labels
  await client.tsAlter(rawKey,
      options: ['RETENTION', 7200000, 'LABELS', 'type', 'raw_v2'],
      forceRun: true);
  print('   Series configuration updated.');

  // 4. TS.QUERYINDEX
  print('4. Querying Index...');
  // Find keys with the new label
  final keys = await client.tsQueryIndex(['type=raw_v2'], forceRun: true);
  print('   Found keys: $keys');

  // 5. TS.DELETERULE
  print('5. Deleting Compaction Rule...');
  await client.tsDeleteRule(rawKey, avgKey, forceRun: true);
  print('   Rule deleted.');

  await client.disconnect();
  print('--- Done ---');
}
