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
  if (!await client.isRedis) {
    print('⚠️  Skipping: This example requires a Redis server.');
    print('   Current server appears to be Valkey or other compatible server.');
    if (client.isConnected) {
      await client.disconnect();
    }
    return;
  }

  await client.flushAll();

  print('--- 📊 Time Series Range & Batch Example ---');

  const key1 = 'metric:cpu:host1';
  const key2 = 'metric:cpu:host2';

  // Setup keys
  await client.tsCreate2(key1,
      labels: {'metric': 'cpu', 'host': '1'}, forceRun: true);
  await client.tsCreate2(key2,
      labels: {'metric': 'cpu', 'host': '2'}, forceRun: true);

  // 1. TS.MADD (Batch Add)
  print('1. Adding Batch Samples (MADD)...');
  final currentTs = DateTime.now().millisecondsSinceEpoch;

  await client.tsMAdd([
    [key1, currentTs, 45],
    [key2, currentTs, 60],
    [key1, currentTs + 1000, 50],
    [key2, currentTs + 1000, 65],
    [key1, currentTs + 2000, 55],
    [key2, currentTs + 2000, 70],
  ], forceRun: true);
  print('   Samples added.');

  // 2. TS.MGET (Multi-Get by Filter)
  print('2. Getting Last Samples (MGET)...');
  // Get latest value for all series with label 'metric=cpu'
  // Named parameter usage:
  final mgetRes = await client.tsMGet(['metric=cpu'], forceRun: true);
  print('   MGET Result: $mgetRes');

  // 3. TS.RANGE (Forward Range with Aggregation)
  print('3. Querying Range (RANGE)...');
  // Aggregate: Average value in 2000ms buckets
  final rangeRes = await client.tsRange2(key1, '-', '+', // Min to Max
      aggregator: 'avg',
      bucketDuration: 2000,
      forceRun: true);
  print('   Range (Avg/2s) for host1: $rangeRes');

  // 4. TS.REVRANGE (Reverse Range)
  print('4. Querying Reverse Range (REVRANGE)...');
  // Get last 2 samples in reverse order
  final revRes =
      await client.tsRevRange2(key2, '-', '+', count: 2, forceRun: true);
  print('   RevRange (Last 2) for host2: $revRes');

  // 5. TS.MRANGE (Multi-Range Query)
  print('5. Querying Multi-Range (MRANGE)...');

  // Changed fromTimestamp from '-' to 0 because 'ALIGN start' requires
  // explicit timestamp.
  final mrangeRes = await client.tsMRange2(
      fromTimestamp: 0, // Start Time (Explicit 0 instead of '-')
      toTimestamp: '+', // End Time
      filters: ['metric=cpu'], // Filters
      align: 'start',
      aggregator: 'avg',
      bucketDuration: 1000,
      forceRun: true);
  print('   MRange Result: $mrangeRes');

  await client.disconnect();
  print('--- Done ---');
}
