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
  group('Time Series - Management & Rules', () {
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

    testRedis('TS.CREATERULE, TS.DELETERULE', () async {
      const sourceKey = 'ts:source';
      const destKey = 'ts:compacted';

      await client.tsCreate(sourceKey, forceRun: false);
      await client.tsCreate(destKey, forceRun: false);

      // 1. TS.CREATERULE
      // Create rule: Aggregate 'avg' into 5000ms buckets
      await client.tsCreateRule(sourceKey, destKey, 'avg', 5000,
          forceRun: false);

      // Verify via TS.INFO
      final info = await client.tsInfo(sourceKey, forceRun: false);
      expect(info.toString(), contains(destKey));

      // 2. TS.DELETERULE
      await client.tsDeleteRule(sourceKey, destKey, forceRun: false);

      // Verify deletion
      final infoAfter = await client.tsInfo(sourceKey, forceRun: false);
      expect(infoAfter.toString(), isNot(contains(destKey)));
    });

    testRedis('TS.ALTER, TS.INFO, TS.QUERYINDEX', () async {
      const key = 'ts:manage';
      await client.tsCreate(key,
          options: ['LABELS', 'ver', '1'], forceRun: false);

      // 1. TS.ALTER
      // Change label
      await client.tsAlter(key,
          options: ['LABELS', 'ver', '2'], forceRun: false);

      // 2. TS.INFO
      final info = await client.tsInfo(key, forceRun: false);
      expect(info.toString(), contains('ver'));
      expect(info.toString(), contains('2'));

      // 3. TS.QUERYINDEX
      final keys = await client.tsQueryIndex(['ver=2'], forceRun: false);
      expect(keys, contains(key));
    });
  });
}
