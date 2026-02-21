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
  group('Time Series - Basic Operations', () {
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

    testRedis('TS.CREATE, TS.ADD, TS.GET', () async {
      const key = 'ts:temp:room1';

      // 1. TS.CREATE
      // Create a time series with labels and retention policy (1 hour)
      await client.tsCreate(
        key,
        options: [
          'RETENTION',
          3600000,
          'LABELS',
          'sensor_id',
          '1',
          'area',
          'room1'
        ],
        forceRun: true,
      );

      // 2. TS.ADD
      // Add a sample. Timestamp '*' means auto-generated.
      final timestamp1 = await client.tsAdd(key, '*', 25.5, forceRun: true);
      expect(timestamp1, isA<int>());
      expect(timestamp1, greaterThan(0));

      // Add another sample with explicit timestamp
      final timestamp2 = (timestamp1 as int) + 1000;
      await client.tsAdd(key, timestamp2, 26.0, forceRun: true);

      // 3. TS.GET
      // Get the last sample
      final lastSample = await client.tsGet(key, forceRun: true) as List;

      // Result format: [timestamp, value]
      expect(lastSample, isA<List>());
      expect(lastSample[0], equals(timestamp2));
      // Value might be double or string depending on RESP version
      expect(double.parse(lastSample[1].toString()), equals(26.0));
    });

    testRedis('TS.INCRBY, TS.DECRBY', () async {
      const key = 'ts:counter';

      // Create implicitly via ADD
      await client.tsAdd(key, '*', 100, forceRun: true);

      // 1. TS.INCRBY
      // Increase value by 50
      final tsAfterIncr = await client.tsIncrBy(key, 50, forceRun: true);
      expect(tsAfterIncr, isA<int>());

      // Verify value
      final getIncr = await client.tsGet(key, forceRun: true) as List;
      expect(double.parse(getIncr[1].toString()), equals(150.0));

      // 2. TS.DECRBY
      // Decrease value by 20
      await client.tsDecrBy(key, 20, forceRun: true);

      final getDecr = await client.tsGet(key, forceRun: true) as List;
      expect(double.parse(getDecr[1].toString()), equals(130.0));
    });

    testRedis('TS.DEL', () async {
      const key = 'ts:del_test';
      await client.tsCreate(key, forceRun: true);

      // Add 3 samples
      final t1 = await client.tsAdd(key, '*', 10, forceRun: true) as int;
      final t2 = await client.tsAdd(key, t1 + 1000, 20, forceRun: true) as int;
      final t3 = await client.tsAdd(key, t2 + 1000, 30, forceRun: true) as int;

      // TS.DEL range [t1, t2]
      final deletedCount = await client.tsDel(key, t1, t2, forceRun: true);

      // Expect 2 samples deleted
      expect(deletedCount, equals(2));

      // Verify only t3 remains
      final remaining = await client.tsGet(key, forceRun: true) as List;
      expect(remaining[0], equals(t3));
    });
  });
}
