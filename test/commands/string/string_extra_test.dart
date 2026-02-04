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

import 'package:test/test.dart';
import 'package:typeredis/typeredis.dart';

void main() {
  group('String Commands (Redis Only Feature) - Extra (MSETEX, DIGEST, DELEX)',
      () {
    late TRClient client;
    var isRedis = false;
    const port = 6379;

    setUpAll(() async {
      final tempClient = TRClient(host: 'localhost', port: port);
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
      if (!isRedis) return;

      client = TRClient(host: 'localhost', port: port);
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

    testRedis('MSETEX - get and ttl', () async {
      const k1 = 'test:msetex:1';
      const k2 = 'test:msetex:2';

      final result = await client.mSetEx({k1: 'v1', k2: 'v2'}, ex: 10);
      expect(result, equals(1));

      // Verify values and TTL
      expect(await client.get(k1), equals('v1'));
      final ttl = await client.ttl(k1);
      expect(ttl, inInclusiveRange(1, 10));
    });

    testRedis('MSETEX - mGet and ttl', () async {
      const k3 = 'test:msetex:3';
      const k4 = 'test:msetex:4';

      // 1. MSETEX with EX option
      // MSETEX 2 k1 v1 k2 v2 EX 10
      final result = await client.mSetEx({
        k3: 'v3',
        k4: 'v4',
      }, ex: 10);

      expect(result, equals(1)); // Returns 1 on success

      // 2. Verify values
      final values = await client.mGet([k3, k4]);
      expect(values, equals(['v3', 'v4']));
    });

    testRedis('DELEX with IFEQ / IFNE', () async {
      const key = 'test:delex:cond';

      // 1. IFEQ - Success
      await client.set(key, 'target');
      final res1 = await client.delEx(key, ifEq: 'target');
      expect(res1, equals(1));
      expect(await client.exists(key), equals(0));

      // 2. IFEQ - Fail (Value mismatch)
      await client.set(key, 'target');
      final res2 = await client.delEx(key, ifEq: 'wrong');
      expect(res2, equals(0));
      expect(await client.exists(key), equals(1));

      // 3. IFNE - Success
      final res3 = await client.delEx(key, ifNe: 'wrong');
      expect(res3, equals(1)); // 'target' != 'wrong', so delete
    });

    testRedis('DIGEST and DELEX with IFDEQ', () async {
      const key = 'test:delex:digest';
      const value = 'some_long_value_to_hash';

      await client.set(key, value);

      // 1. Get Digest
      final digest = await client.digest(key);
      expect(digest, isNotNull);

      // 2. IFDEQ - Success (Digest Match)
      final res = await client.delEx(key, ifDeq: digest!);
      expect(res, equals(1));
      expect(await client.exists(key), equals(0));
    });
  });
}
