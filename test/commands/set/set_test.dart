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
  group('Set Commands', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close();
    });

    test('SADD, SCARD, SMEMBERS', () async {
      const key = 'set:basic';

      // 1. SADD
      final added = await client.sAdd(key, ['a', 'b', 'c']);
      expect(added, equals(3));

      // Add duplicate
      final dup = await client.sAdd(key, ['a']);
      expect(dup, equals(0));

      // 2. SCARD
      expect(await client.sCard(key), equals(3));

      // 3. SMEMBERS (Order is not guaranteed)
      final members = await client.sMembers(key);
      expect(members, unorderedEquals(['a', 'b', 'c']));
    });

    test('SREM, SISMEMBER, SMISMEMBER', () async {
      const key = 'set:check';
      await client.sAdd(key, ['a', 'b', 'c']);

      // 1. SISMEMBER
      expect(await client.sIsMember(key, 'a'), isTrue);
      expect(await client.sIsMember(key, 'z'), isFalse);

      // 2. SMISMEMBER
      final checks = await client.sMIsMember(key, ['a', 'z', 'c']);
      expect(checks, equals([1, 0, 1]));

      // 3. SREM
      final removed = await client.sRem(key, ['a', 'z']); // 'z' doesn't exist
      expect(removed, equals(1)); // Only 'a' removed
      expect(await client.sIsMember(key, 'a'), isFalse);
    });

    test('SDIFF, SDIFFSTORE', () async {
      // Set 1: {1, 2, 3, 4}
      // Set 2: {3, 4, 5}
      // Diff (1 - 2): {1, 2}
      await client.sAdd('s1', ['1', '2', '3', '4']);
      await client.sAdd('s2', ['3', '4', '5']);

      // 1. SDIFF
      final diff = await client.sDiff('s1', ['s2']);
      expect(diff, unorderedEquals(['1', '2']));

      // 2. SDIFFSTORE
      final count = await client.sDiffStore('dest', 's1', ['s2']);
      expect(count, equals(2));

      final stored = await client.sMembers('dest');
      expect(stored, unorderedEquals(['1', '2']));
    });

    test('SINTER, SINTERSTORE, SINTERCARD', () async {
      // Set 1: {1, 2, 3}
      // Set 2: {2, 3, 4}
      // Inter: {2, 3}
      await client.sAdd('s1', ['1', '2', '3']);
      await client.sAdd('s2', ['2', '3', '4']);

      // 1. SINTER
      final inter = await client.sInter(['s1', 's2']);
      expect(inter, unorderedEquals(['2', '3']));

      // 2. SINTERCARD
      final card = await client.sInterCard(['s1', 's2']);
      expect(card, equals(2));

      // 3. SINTERSTORE
      final count = await client.sInterStore('dest', ['s1', 's2']);
      expect(count, equals(2));
      expect(await client.sIsMember('dest', '2'), isTrue);
    });

    test('SUNION, SUNIONSTORE', () async {
      // Set 1: {a, b}
      // Set 2: {b, c}
      // Union: {a, b, c}
      await client.sAdd('s1', ['a', 'b']);
      await client.sAdd('s2', ['b', 'c']);

      // 1. SUNION
      final union = await client.sUnion(['s1', 's2']);
      expect(union, unorderedEquals(['a', 'b', 'c']));

      // 2. SUNIONSTORE
      final count = await client.sUnionStore('dest', ['s1', 's2']);
      expect(count, equals(3));
    });

    test('SMOVE', () async {
      await client.sAdd('src', ['a', 'b']);
      await client.sAdd('dest', ['x']);

      // 1. Move 'a' from src to dest
      final result = await client.sMove('src', 'dest', 'a');
      expect(result, isTrue);

      expect(await client.sIsMember('src', 'a'), isFalse);
      expect(await client.sIsMember('dest', 'a'), isTrue);

      // 2. Move non-existent member
      final fail = await client.sMove('src', 'dest', 'z');
      expect(fail, isFalse);
    });

    test('SPOP', () async {
      const key = 'set:pop';
      await client.sAdd(key, ['a', 'b', 'c']);

      // 1. Pop single
      final val = await client.sPop(key);
      expect(val, isA<String>());
      expect(await client.sCard(key), equals(2));

      // 2. Pop count
      final list = await client.sPop(key, 2);
      expect(list, isA<List>());
      expect((list as List).length, equals(2));
      expect(await client.sCard(key), equals(0));
    });

    test('SRANDMEMBER', () async {
      const key = 'set:rand';
      await client.sAdd(key, ['a', 'b', 'c']);

      // 1. Single random
      final val = await client.sRandMember(key);
      expect(['a', 'b', 'c'], contains(val));

      // Set should NOT change
      expect(await client.sCard(key), equals(3));

      // 2. Count random (distinct)
      final list = await client.sRandMember(key, 2);
      expect(list, isA<List>());
      expect((list as List).length, equals(2));

      // 3. Count random (allow duplicates - negative count)
      final dupList = await client.sRandMember(key, -5);
      expect((dupList as List).length, equals(5));
    });

    test('SSCAN', () async {
      const key = 'set:scan';
      // Add enough items to potentially trigger pagination
      // (though small scan works too)
      final items = List.generate(20, (i) => 'val-$i');
      await client.sAdd(key, items);

      // 1. Simple Scan
      final result = await client.sScan(key, 0);
      expect(result.length, equals(2)); // [cursor, elements]

      final cursor = result[0] as String;
      final elements = result[1] as List<String>;

      expect(int.parse(cursor), greaterThanOrEqualTo(0));
      expect(elements.isNotEmpty, isTrue);

      // 2. Scan with Match
      final matchRes = await client.sScan(key, 0, match: 'val-1*');
      final matchElements = matchRes[1] as List<String>;
      // Should contain val-1, val-10, val-11...
      for (var e in matchElements) {
        expect(e, startsWith('val-1'));
      }
    });
  });
}
