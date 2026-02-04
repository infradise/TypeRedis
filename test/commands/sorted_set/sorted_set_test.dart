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
  group('Sorted Set Commands', () {
    late ValkeyClient client;

    setUp(() async {
      client = ValkeyClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close(); // disconnect
    });

    // Group 1: Basic CRUD (Add, Score, Incr, Card)
    test('ZADD, ZSCORE, ZINCRBY, ZCARD, ZMSCORE', () async {
      const key = 'zset:basic';

      // 1. ZADD
      // Add multiple members
      final added = await client.zAdd(key, {'a': 10, 'b': 20});
      expect(added, equals(2));

      // 2. ZSCORE
      expect(await client.zScore(key, 'a'), equals(10.0));
      expect(await client.zScore(key, 'missing'), isNull);

      // 3. ZMSCORE
      final mScores = await client.zMScore(key, ['a', 'missing', 'b']);
      expect(mScores, equals([10.0, null, 20.0]));

      // 4. ZINCRBY
      final newScore = await client.zIncrBy(key, 5.5, 'a');
      expect(newScore, equals(15.5));

      // 5. ZCARD
      expect(await client.zCard(key), equals(2));

      // 6. ZCOUNT
      // Count between 15 and 30 (inclusive) -> 'a'(15.5), 'b'(20)
      expect(await client.zCount(key, 15, 30), equals(2));
    });

    // Group 2: Ranks and Ranges (Index based)
    test('ZRANK, ZREVRANK, ZRANGE (Index)', () async {
      const key = 'zset:rank';
      // a:1, b:2, c:3
      await client.zAdd(key, {'a': 1, 'b': 2, 'c': 3});

      // 1. ZRANK (Low to High)
      expect(await client.zRank(key, 'a'), equals(0));
      expect(await client.zRank(key, 'c'), equals(2));

      // 2. ZREVRANK (High to Low)
      expect(await client.zRevRank(key, 'c'), equals(0));

      // 3. ZRANGE (Forward)
      final range = await client.zRange(key, 0, 1);
      expect(range, orderedEquals(['a', 'b']));

      // 4. ZRANGE (Reverse with Scores)
      final revRange =
          await client.zRange(key, 0, 0, rev: true, withScores: true);
      expect(revRange, orderedEquals(['c', '3'])); // [Member, Score]

      // 5. Deprecated Alias Check (ZREVRANGE)
      final aliasRev = await client.zRevRange(key, 0, 1);
      expect(aliasRev, orderedEquals(['c', 'b']));
    });

    // Group 3: Advanced Ranges (By Score, By Lex)
    test('ZRANGE (ByScore, ByLex), ZLEXCOUNT', () async {
      const keyScore = 'zset:score';
      await client.zAdd(keyScore, {'a': 10, 'b': 20, 'c': 30});

      // 1. BYSCORE (10 <= score <= 20)
      final byScore = await client.zRange(keyScore, 10, 20, byScore: true);
      expect(byScore, orderedEquals(['a', 'b']));

      const keyLex = 'zset:lex';
      // Scores must be equal for Lex operations
      await client.zAdd(keyLex, {'apple': 0, 'banana': 0, 'cherry': 0});

      // 2. BYLEX ([a, [c)
      final byLex = await client.zRange(keyLex, '[a', '[c', byLex: true);
      expect(
          byLex,
          orderedEquals(
              ['apple', 'banana'])); // cherry is excluded or range stops at c

      // 3. ZLEXCOUNT
      final lexCount = await client.zLexCount(keyLex, '-', '+');
      expect(lexCount, equals(3));
    });

    // Group 4: Set Operations (Inter, Union, Diff)
    test('ZINTER, ZUNION, ZDIFF (and Stores)', () async {
      // s1: {a:1, b:2}
      // s2: {b:3, c:4}
      await client.zAdd('s1', {'a': 1, 'b': 2});
      await client.zAdd('s2', {'b': 3, 'c': 4});

      // 1. ZINTER (Default SUM) -> b: 2+3=5
      final inter = await client.zInter(['s1', 's2'], withScores: true);
      expect(
          inter,
          containsAll(
              ['b', '5'])); // implementation may return doubles as string

      // 2. ZUNION (MAX) -> b: max(2,3)=3
      final union =
          await client.zUnion(['s1', 's2'], aggregate: 'MAX', withScores: true);
      // a:1, b:3, c:4
      expect(union, containsAll(['b', '3']));

      // 3. ZDIFF (s1 - s2) -> a
      final diff = await client.zDiff(['s1', 's2']);
      expect(diff, orderedEquals(['a']));

      // 4. Stores (ZINTERSTORE)
      final stored = await client.zInterStore('dest', ['s1', 's2']);
      expect(stored, equals(1)); // Only 'b' intersects
    });

    // Group 5: Removal
    test('ZREM, ZREMRANGE...', () async {
      const key = 'zset:rem';
      await client.zAdd(key, {'a': 1, 'b': 2, 'c': 3, 'd': 4});

      // 1. ZREM
      expect(await client.zRem(key, ['a']), equals(1));

      // 2. ZREMRANGEBYSCORE (2 <= score <= 3) -> removes b, c
      expect(await client.zRemRangeByScore(key, 2, 3), equals(2));

      // Remaining: d
      expect(await client.zCard(key), equals(1));
    });

    // Group 6: Popping & Random (Blocking included non-blocking check)
    test('ZPOP, ZMPOP, BZMPOP, ZRANDMEMBER', () async {
      const key = 'zset:pop';
      await client.zAdd(key, {'a': 10, 'b': 20, 'c': 30});

      // 1. ZRANDMEMBER
      final rand = await client.zRandMember(key);
      expect(['a', 'b', 'c'], contains(rand));

      // 2. ZPOPMAX
      final popped = await client.zPopMax(key); // Pops 'c'
      expect(popped, contains('c'));

      // 3. ZMPOP (Min) -> Pops 'a'
      final mPop =
          await client.zMPop([key], 'MIN') as List; // List<List<dynamic>>;

      // Structure: [key, [[member, score]]]
      expect(mPop[0], equals(key));

      // (X) expect(mPop[1][0][0], equals('a'));
      final mPopElements = mPop[1] as List;
      expect((mPopElements[0] as List)[0], equals('a'));

      // 4. BZMPOP (Blocking with timeout)
      // Remaining: 'b'
      // Since 'b' exists, it should return immediately.
      final bzPop = await client.bzMPop(0.5, [key], 'MAX') as List;

      // (X) expect(bzPop[1][0][0], equals('b'));
      final bzPopElements = bzPop[1] as List;
      expect((bzPopElements[0] as List)[0], equals('b'));

      // Now empty
      expect(await client.zCard(key), equals(0));
    });

    // Group 7: Scan
    test('ZSCAN', () async {
      const key = 'zset:scan';
      await client.zAdd(key, {'a': 1, 'b': 2});

      final result = await client.zScan(key, 0);
      final members = result[1] as List<String>;

      expect(members, containsAll(['a', '1', 'b', '2']));
    });
  });
}
