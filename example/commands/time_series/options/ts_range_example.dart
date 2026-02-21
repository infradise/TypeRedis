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

  print('--- 📊 Time Series Range & Batch Example ---');

  const key1 = 'metric:cpu:host1';
  const key2 = 'metric:cpu:host2';

  // Setup keys with labels for querying
  await client.tsCreate(key1,
      options: ['LABELS', 'metric', 'cpu', 'host', '1'], forceRun: false);
  await client.tsCreate(key2,
      options: ['LABELS', 'metric', 'cpu', 'host', '2'], forceRun: false);

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
  ], forceRun: false);
  print('   Samples added.');

  // 2. TS.MGET (Multi-Get by Filter)
  print('2. Getting Last Samples (MGET)...');
  // Get latest value for all series with label 'metric=cpu'
  final mgetRes = await client.tsMGet(['metric=cpu'], forceRun: false);
  print('   MGET Result: $mgetRes');

  // 3. TS.RANGE (Forward Range with Aggregation)
  print('3. Querying Range (RANGE)...');
  // Aggregate: Average value in 2000ms buckets
  final rangeRes = await client.tsRange(key1, '-', '+', // Min to Max
      options: ['AGGREGATION', 'avg', 2000],
      forceRun: false);
  print('   Range (Avg/2s) for host1: $rangeRes');

  // 4. TS.REVRANGE (Reverse Range)
  print('4. Querying Reverse Range (REVRANGE)...');
  // Get last 2 samples in reverse order
  // Argument order: '-' (min) then '+' (max)
  final revRes = await client.tsRevRange(
      key2, '-', '+', // Min to Max (Order is reversed by command)
      options: ['COUNT', 2],
      forceRun: false);
  print('   RevRange (Last 2) for host2: $revRes');

  // 5. TS.MRANGE (Multi-Range Query)
  print('5. Querying Multi-Range (MRANGE)...');
  // Get range for all CPUs, aligned to start time
  // ALIGN requires AGGREGATION. Added 'AGGREGATION avg 1000'.
  // We align 1000ms buckets to the start time.

  // Changed fromTimestamp from '-' to 0
  // > because 'ALIGN start' requires explicit timestamp.
  // > ERR TSDB: start alignment can only be used with explicit start timestamp
  final mrangeRes = await client.tsMRange(0, '+', ['metric=cpu'],
      options: ['ALIGN', 'start', 'AGGREGATION', 'avg', 1000], forceRun: false);
  print('   MRange Result: $mrangeRes');

  final mrangeRes2 = await client.tsMRange2(
      fromTimestamp: 0, // Start Time (Explicit 0 instead of '-')
      toTimestamp: '+',
      filters: ['metric=cpu'],
      align: 'start',
      aggregator: 'avg',
      bucketDuration: 1000,
      count: 10,
      withLabels: true);
  print('   MRange Result: $mrangeRes2');

  await client.disconnect();
  print('--- Done ---');
}
