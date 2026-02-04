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
import 'package:valkey_client/valkey_client.dart';

void main() {
  group('Sorted Set Extended Commands', () {
    late ValkeyClient client;

    setUp(() async {
      client = ValkeyClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close();
    });

    test('Store Operations (ZUNIONSTORE, ZDIFFSTORE)', () async {
      // Setup
      // s1: {a:1, b:2}
      // s2: {b:3, c:4}
      await client.zAdd('s1', {'a': 1, 'b': 2});
      await client.zAdd('s2', {'b': 3, 'c': 4});

      // 1. ZUNIONSTORE
      // Union keys: a, b, c.
      // Weights default to 1. Aggregate defaults to SUM.
      // b = 2 + 3 = 5
      final unionCount = await client.zUnionStore('dest:union', ['s1', 's2']);
      expect(unionCount, equals(3));
      expect(await client.zScore('dest:union', 'b'), equals(5.0));

      // 2. ZDIFFSTORE
      // Diff (s1 - s2): {a} (b is in s2, so removed)
      final diffCount = await client.zDiffStore('dest:diff', ['s1', 's2']);
      expect(diffCount, equals(1));
      expect(await client.zScore('dest:diff', 'a'), equals(1.0));
      expect(await client.zScore('dest:diff', 'b'), isNull);
    });

    test('Advanced Stats & Range Store (ZINTERCARD, ZRANGESTORE)', () async {
      await client.zAdd('z1', {'a': 1, 'b': 2, 'c': 3});
      await client.zAdd('z2', {'b': 2, 'c': 4, 'd': 5});

      // 1. ZINTERCARD
      // Intersection: b, c (Count: 2)
      final card = await client.zInterCard(['z1', 'z2']);
      expect(card, equals(2));

      // With Limit
      final cardLimit = await client.zInterCard(['z1', 'z2'], limit: 1);
      expect(cardLimit, equals(1)); // Limiting calculation

      // 2. ZRANGESTORE
      // Store rank 0 to 1 of z1 ({a, b}) into new key
      final storedCount = await client.zRangeStore('dest:range', 'z1', 0, 1);
      expect(storedCount, equals(2));
      final members = await client.zRange('dest:range', 0, -1);
      expect(members, orderedEquals(['a', 'b']));
    });

    test('Blocking Pops (BZPOPMAX, BZPOPMIN)', () async {
      // Note: In single-threaded test, we test the case where data EXISTS
      // immediately.
      // Testing actual blocking (waiting) requires parallel connections or
      // isolates.
      await client.zAdd('tasks', {'low': 1, 'high': 100});

      // 1. BZPOPMAX (Should return immediately with 'high')
      // Returns: [key, member, score]
      final maxRes = await client.bzPopMax(['tasks'], 1.0);
      expect(maxRes, isA<List>());

      // Cast dynamic result to List
      final maxResResult = maxRes as List;

      expect(maxResResult[0], equals('tasks'));
      expect(maxResResult[1], equals('high'));

      // 2. BZPOPMIN (Should return immediately with 'low')
      final minRes = await client.bzPopMin(['tasks'], 1.0);

      // Cast dynamic result to List
      final minResResult = minRes as List;

      expect(minResResult[1], equals('low'));

      // Empty check
      expect(await client.zCard('tasks'), equals(0));
    });

    test('Specific Removals (ZREMRANGEBYRANK, ZREMRANGEBYLEX)', () async {
      // 1. ZREMRANGEBYRANK
      // 0:a, 1:b, 2:c, 3:d
      await client.zAdd('rank_rem', {'a': 1, 'b': 2, 'c': 3, 'd': 4});

      // Remove rank 1 to 2 (b, c)
      final remRankCount = await client.zRemRangeByRank('rank_rem', 1, 2);
      expect(remRankCount, equals(2));

      final remainingRank = await client.zRange('rank_rem', 0, -1);
      expect(remainingRank, orderedEquals(['a', 'd']));

      // 2. ZREMRANGEBYLEX
      // Scores must be 0
      await client
          .zAdd('lex_rem', {'alpha': 0, 'bravo': 0, 'charlie': 0, 'delta': 0});

      // Remove [bravo, [charlie]
      final remLexCount =
          await client.zRemRangeByLex('lex_rem', '[bravo', '[charlie');
      expect(remLexCount, equals(2)); // bravo, charlie removed

      final remainingLex = await client.zRange('lex_rem', 0, -1);
      expect(remainingLex, orderedEquals(['alpha', 'delta']));
    });

    test('Legacy Range Commands (Score & Lex)', () async {
      const key = 'legacy_range';
      await client.zAdd(key, {'a': 10, 'b': 20, 'c': 30});

      // 1. ZRANGEBYSCORE
      final rangeScore = await client.zRangeByScore(key, 10, 20);
      expect(rangeScore, orderedEquals(['a', 'b']));

      // 2. ZREVRANGEBYSCORE (High to Low)
      final revRangeScore = await client.zRevRangeByScore(key, 30, 20);
      expect(revRangeScore, orderedEquals(['c', 'b']));

      // Setup for Lex
      await client.del([key]);
      await client.zAdd(key, {'a': 0, 'b': 0, 'c': 0});

      // 3. ZRANGEBYLEX
      final rangeLex = await client.zRangeByLex(key, '-', '[b');
      expect(rangeLex, orderedEquals(['a', 'b']));

      // 4. ZREVRANGEBYLEX
      final revRangeLex = await client.zRevRangeByLex(key, '[c', '[b');
      expect(revRangeLex, orderedEquals(['c', 'b']));
    });
  });
}
