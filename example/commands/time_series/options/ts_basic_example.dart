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

  print('--- 📈 Time Series Basic Example ---');

  const key = 'sensor:temp:room1';

  // 1. TS.CREATE
  print('1. Creating Time Series: $key');
  try {
    await client.tsCreate(
      key,
      options: [
        'RETENTION', 86400000, // 1 Day retention
        'LABELS', 'area', 'room1', 'type', 'temp'
      ],
      forceRun: true,
    );
  } catch (e) {
    print('   Error (might exist): $e');
  }

  // 2. TS.ADD
  print('2. Adding Samples...');
  // Timestamp '*' = Auto (System Time)
  final t1 = await client.tsAdd(key, '*', 20.5, forceRun: true);
  print('   Added sample at: $t1, value: 20.5');

  await Future<void>.delayed(const Duration(milliseconds: 100)); // Small delay
  final t2 = await client.tsAdd(key, '*', 21.0, forceRun: true);
  print('   Added sample at: $t2, value: 21.0');

  // 3. TS.GET
  print('3. Getting Last Sample...');
  final last = await client.tsGet(key, forceRun: true);
  print('   Last Sample: $last'); // [timestamp, value]

  // 4. TS.INCRBY / DECRBY
  print('4. Incrementing/Decrementing...');
  // Initialize counter series
  const counterKey = 'sensor:counter';
  await client.tsAdd(counterKey, '*', 100, forceRun: true);

  await client.tsIncrBy(counterKey, 50, forceRun: true); // 100 + 50 = 150
  print('   After INCRBY 50: '
      '${(await client.tsGet(counterKey, forceRun: true) as List)[1]}');

  await client.tsDecrBy(counterKey, 20, forceRun: true); // 150 - 20 = 130
  print('   After DECRBY 20: '
      '${(await client.tsGet(counterKey, forceRun: true) as List)[1]}');

  // 5. TS.DEL
  print('5. Deleting Range...');
  // Delete the first sample we added (t1)
  final deleted = await client.tsDel(key, t1 as int, t1, forceRun: true);
  print('   Deleted samples count: $deleted');

  await client.disconnect();
  print('--- Done ---');
}
