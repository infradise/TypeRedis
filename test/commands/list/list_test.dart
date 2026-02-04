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
  group('List Commands', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close(); // disconnect
    });

    test('LPUSH, RPUSH, LRANGE, LLEN', () async {
      const key = 'test:list:push';

      // 1. LPUSH
      final len1 = await client.lPush(key, ['world']);
      expect(len1, equals(1));

      // 2. LPUSH multiple
      final len2 = await client.lPush(key, ['hello']);
      expect(len2, equals(2));

      // 3. RPUSH
      final len3 = await client.rPush(key, ['!']);
      expect(len3, equals(3));

      // 4. LRANGE (Check order: hello, world, !)
      final items = await client.lRange(key, 0, -1);
      expect(items, equals(['hello', 'world', '!']));

      // 5. LLEN
      final len = await client.lLen(key);
      expect(len, equals(3));
    });

    test('LPOP, RPOP', () async {
      const key = 'test:list:pop';
      await client.rPush(key, ['1', '2', '3']);

      // 1. LPOP
      final head = await client.lPop(key);
      expect(head, equals('1'));

      // 2. RPOP
      final tail = await client.rPop(key);
      expect(tail, equals('3'));

      // 3. LPOP count (Redis 6.2+)
      // Remaining: ['2']
      // Depending on server version, count arg might return array.
      // Assuming basic LPOP for single item now.
      final last = await client.lPop(key);
      expect(last, equals('2'));

      // 4. Empty pop
      final empty = await client.lPop(key);
      expect(empty, isNull);
    });

    test('LINDEX, LSET, LINSERT', () async {
      const key = 'test:list:mod';
      await client.rPush(key, ['A', 'B', 'C']);

      // 1. LINDEX
      expect(await client.lIndex(key, 0), equals('A'));
      expect(await client.lIndex(key, -1), equals('C'));
      expect(await client.lIndex(key, 100), isNull);

      // 2. LSET
      await client.lSet(key, 1, 'updated');
      expect(await client.lIndex(key, 1), equals('updated'));

      // 3. LINSERT
      // List: [A, updated, C]
      final len = await client.lInsert(key, 'BEFORE', 'C', 'inserted');
      // List: [A, updated, inserted, C]
      expect(len, equals(4));

      final list = await client.lRange(key, 0, -1);
      expect(list[2], equals('inserted'));
    });

    test('LREM, LTRIM', () async {
      const key = 'test:list:trim';
      await client.rPush(key, ['A', 'A', 'B', 'A', 'C']);

      // 1. LREM (Remove 2 occurrences of 'A' from head)
      final removed = await client.lRem(key, 2, 'A');
      expect(removed, equals(2));

      // List: [B, A, C]
      expect(await client.lRange(key, 0, -1), equals(['B', 'A', 'C']));

      // 2. LTRIM (Keep indices 0 to 1)
      await client.lTrim(key, 0, 1);
      // List: [B, A]
      final result = await client.lRange(key, 0, -1);
      expect(result, equals(['B', 'A']));
    });

    test('LPOS', () async {
      const key = 'test:list:pos';
      await client.rPush(key, ['a', 'b', 'c', 'b']);

      // 1. Simple LPOS
      final idx = await client.lPos(key, 'b');
      expect(idx, equals(1)); // Index of first 'b'

      // 2. LPOS with Rank (2nd match)
      final idx2 = await client.lPos(key, 'b', rank: 2);
      expect(idx2, equals(3));
    });

    test('LMOVE', () async {
      const key = 'test:list:move';
      await client.rPush(key, ['1', '2']);

      // Move from RIGHT to LEFT (Rotation)
      // [1, 2] -> [2, 1]
      final val = await client.lMove(key, key, 'RIGHT', 'LEFT');
      expect(val, equals('2'));

      final list = await client.lRange(key, 0, -1);
      expect(list, equals(['2', '1']));
    });

    test('BLPOP (Blocking)', () async {
      const key = 'test:list:blocking';

      // Case 1: List has data (returns immediately)
      await client.rPush(key, ['val']);
      final result = await client.bLPop([key], 1.0);

      expect(result, isNotNull);
      expect(result![0], equals(key));
      expect(result[1], equals('val'));

      // Case 2: List is empty (timeout)
      // Since we can't easily spawn a separate client in this unit test to push
      // while blocking, we test the timeout behavior.
      final start = DateTime.now();
      final timeoutResult = await client.bLPop([key], 1.0); // 1 sec timeout
      final diff = DateTime.now().difference(start).inMilliseconds;

      expect(timeoutResult, isNull);
      expect(diff, greaterThanOrEqualTo(900)); // Allow some margin
    });
  });
}
