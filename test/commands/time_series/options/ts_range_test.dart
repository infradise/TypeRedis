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
import 'package:test/test.dart';

void main() {
  group('Time Series - Range & Batch', () {
    late KeyscopeClient client;
    var isRedis = false;
    const port = 6379;

    setUpAll(() async {
      final tempClient = KeyscopeClient(host: 'localhost', port: port);
      try {
        await tempClient.connect();
        isRedis = await tempClient.isRedisServer();
      } catch (e) {
        print('Warning: Failed to check server type in setUpAll: $e');
      } finally {
        await tempClient.close();
      }
    });

    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: port);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      if (isRedis) {
        try {
          if (client.isConnected) {
            await client.close();
          }
        } catch (_) {}
      }

      await client.disconnect();
    });

    void testRedis(String description, Future<void> Function() body) {
      test(description, () async {
        if (!isRedis) {
          markTestSkipped('Skipping: This feature is supported on Redis only.');
          return;
        }
        await body();
      });
    }

    testRedis('TS.MADD, TS.MGET', () async {
      const key1 = 'ts:batch:1';
      const key2 = 'ts:batch:2';

      await client.tsCreate(key1,
          options: ['LABELS', 'type', 'A'], forceRun: false);
      await client.tsCreate(key2,
          options: ['LABELS', 'type', 'B'], forceRun: false);

      // 1. TS.MADD
      final maddRes = await client.tsMAdd([
        [key1, '*', 10],
        [key2, '*', 20]
      ], forceRun: false);

      expect(maddRes, isA<List>());
      expect(maddRes.length, equals(2));

      // 2. TS.MGET (Filter by label)
      final mgetRes = await client.tsMGet(['type=A'], forceRun: false);

      // Should contain key1 data but not key2
      final resStr = mgetRes.toString();
      expect(resStr, contains(key1));
      expect(resStr, isNot(contains(key2)));
    });

    testRedis('TS.RANGE, TS.REVRANGE', () async {
      const key = 'ts:range_test';
      await client.tsCreate(key, forceRun: false);

      // Seed data: 10 samples
      const startTs = 10000;
      for (var i = 0; i < 10; i++) {
        await client.tsAdd(key, startTs + (i * 1000), i + 1, forceRun: false);
      }

      // 1. TS.RANGE (All)
      final rangeAll = await client.tsRange(key, '-', '+', forceRun: false);
      expect((rangeAll as List).length, equals(10));

      // 2. TS.RANGE (With Aggregation)
      // Sum in 5000ms buckets
      final rangeAgg = await client.tsRange(key, '-', '+',
          options: ['AGGREGATION', 'sum', 5000], forceRun: false) as List;
      // Expect 2 buckets
      expect(rangeAgg.length, equals(2));

      // 3. TS.REVRANGE (Limit Count)
      final revRange = await client.tsRevRange(key, '-', '+',
          options: ['COUNT', 2], forceRun: false) as List;
      expect(revRange.length, equals(2));
      // First item should be the last inserted (val 10)
      expect(double.parse((revRange[0] as List)[1].toString()), equals(10.0));
    });

    testRedis('TS.MRANGE', () async {
      await client.tsCreate('ts:m:1',
          options: ['LABELS', 'team', 'blue'], forceRun: false);
      await client.tsCreate('ts:m:2',
          options: ['LABELS', 'team', 'blue'], forceRun: false);

      await client.tsAdd('ts:m:1', 1000, 10, forceRun: false);
      await client.tsAdd('ts:m:2', 1000, 20, forceRun: false);

      // TS.MRANGE (Filter by team=blue)
      final mrangeRes =
          await client.tsMRange('-', '+', ['team=blue'], forceRun: false);

      final resStr = mrangeRes.toString();
      expect(resStr, contains('ts:m:1'));
      expect(resStr, contains('ts:m:2'));
    });
  });
}
