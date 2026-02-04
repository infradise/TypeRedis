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
  group('List Advanced Commands', () {
    late TRClient client;
    const key = 'test:list:adv';
    const dest = 'test:list:dest';

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close(); //disconnect
    });

    test('LPUSHX and RPUSHX', () async {
      // 1. Push to non-existent key (should fail)
      expect(await client.lPushX(key, ['A']), equals(0));
      expect(await client.rPushX(key, ['A']), equals(0));

      // 2. Push to existing key
      await client.lPush(key, ['Init']);
      expect(await client.lPushX(key, ['Left']), equals(2)); // [Left, Init]
      expect(await client.rPushX(key, ['Right']),
          equals(3)); // [Left, Init, Right]
    });

    test('RPOPLPUSH and BRPOPLPUSH', () async {
      await client.rPush(key, ['A', 'B', 'C']);

      // 1. RPOPLPUSH (Non-blocking)
      // [A, B, C] -> Pop C -> Push to dest
      final val = await client.rPopLPush(key, dest);
      expect(val, equals('C'));
      expect(await client.lRange(dest, 0, -1), equals(['C']));

      // 2. BRPOPLPUSH (Blocking - Immediate)
      // [A, B] -> Pop B -> Push to dest
      final bVal = await client.bRPopLPush(key, dest, 1.0);
      expect(bVal, equals('B'));
      expect(await client.lRange(dest, 0, -1), equals(['B', 'C']));

      // 3. BRPOPLPUSH (Blocking - Timeout)
      // key has ['A'] left. Pop A. Now key is empty.
      await client.rPop(key);
      final nullVal = await client.bRPopLPush(key, dest, 0.1); // Short timeout
      expect(nullVal, isNull);
    });

    test('LMPOP and BLMPOP', () async {
      await client.rPush(key, ['A', 'B', 'C', 'D']);

      // 1. LMPOP
      // Pop 2 elements from LEFT of 'key'
      // Result structure: [keyName, [val1, val2]]
      final result = await client.lMPop([key], 'LEFT', count: 2);
      expect(result, isA<List>());

      // Cast dynamic result to List
      final listResult = result as List;

      expect(listResult[0], equals(key));
      expect(listResult[1], equals(['A', 'B']));

      // 2. BLMPOP (Immediate)
      // Remaining: [C, D]. Pop 1 from RIGHT.
      final bResult = await client.bLMPop(1.0, [key], 'RIGHT', count: 1);
      expect(bResult, isA<List>());

      // Cast dynamic result to List
      final listBResult = bResult as List;

      expect(listBResult[1], equals(['D']));

      // 3. BLMPOP (Timeout)
      final timeoutRes =
          await client.bLMPop(0.1, ['missing'], 'LEFT', count: 1);
      expect(timeoutRes, isNull);
    });

    test('BLMOVE', () async {
      await client.rPush(key, ['SourceVal']);

      // 1. BLMOVE (Immediate)
      // Pop LEFT of key, Push LEFT of dest
      final moved = await client.bLMove(key, dest, 'LEFT', 'LEFT', 1.0);
      expect(moved, equals('SourceVal'));
      expect(await client.lIndex(dest, 0), equals('SourceVal'));

      // 2. BLMOVE (Timeout)
      final timeout = await client.bLMove(key, dest, 'LEFT', 'LEFT', 0.1);
      expect(timeout, isNull);
    });

    test('LPOS', () async {
      // Create list: [A, B, A, C, A, D]
      await client.rPush(key, ['A', 'B', 'A', 'C', 'A', 'D']);

      // 1. First occurrence
      expect(await client.lPos(key, 'A'), equals(0));

      // 2. Second occurrence (Rank 2)
      expect(await client.lPos(key, 'A', rank: 2), equals(2));

      // 3. From the end (Rank -1) -> last 'A' at index 4
      expect(await client.lPos(key, 'A', rank: -1), equals(4));

      // 4. Return multiple matches (Count 2)
      // Should return indices of first two 'A's -> [0, 2]
      final matches = await client.lPos(key, 'A', count: 2);
      expect(matches, equals([0, 2]));
    });

    test('BRPOP and BLPOP (Multiple Keys)', () async {
      const key1 = 'list:empty';
      const key2 = 'list:ready';
      await client.rPush(key2, ['Value']);

      // Should skip key1 (empty) and pop from key2
      // Returns [key2, Value]
      final result = await client.bRPop([key1, key2], 1.0);
      expect(result, isNotNull);
      expect(result![0], equals(key2));
      expect(result[1], equals('Value'));
    });
  });
}
