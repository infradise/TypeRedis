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
  group('String Commands - Advanced', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close(); // disconnect
    });

    test('SET with Options (NX, XX, GET, EX)', () async {
      const key = 'opt_key';

      // 1. NX (Set if Not Exists) - Success
      final res1 = await client.set(key, 'A', nx: true);
      expect(res1, equals('OK'));

      // 2. NX - Fail (Key exists)
      final res2 = await client.set(key, 'B', nx: true);
      expect(res2, isNull);

      // 3. XX (Set if Exists) - Success
      final res3 = await client.set(key, 'C', xx: true);
      expect(res3, equals('OK'));
      expect(await client.get(key), equals('C'));

      // 4. GET (Return old value)
      final old = await client.set(key, 'D', get: true);
      expect(old, equals('C'));
    });

    test('SETNX, MSETNX', () async {
      const k1 = 'k1';
      const k2 = 'k2';

      // 1. SETNX
      expect(await client.setNx(k1, 'v1'), equals(1)); // Success
      expect(await client.setNx(k1, 'new'), equals(0)); // Fail

      // 2. MSETNX (Atomic)
      // k1 exists, so MSETNX should fail for ALL keys
      final mRes = await client.mSetNx({k1: 'upd', k2: 'v2'});
      expect(mRes, equals(0));
      expect(await client.get(k2), isNull); // k2 was not set
    });

    test('SETEX, PSETEX, GETEX', () async {
      const key = 'ex_key';

      // 1. SETEX (Seconds)
      await client.setEx(key, 10, 'val');
      final ttl = await client.executeInt(['TTL', key]); // Helper check
      expect(ttl, inInclusiveRange(1, 10));

      // 2. PSETEX (Milliseconds)
      await client.pSetEx(key, 5000, 'val2');
      final pttl = await client.executeInt(['PTTL', key]);
      expect(pttl, inInclusiveRange(1000, 5000));

      // 3. GETEX (Get and Update TTL)
      // Remove TTL (PERSIST)
      await client.getEx(key, persist: true);
      final noTtl = await client.executeInt(['TTL', key]);
      expect(noTtl, equals(-1));
    });

    test('LCS (Longest Common Subsequence)', () async {
      await client.set('s1', 'ohmytext');
      await client.set('s2', 'mynewtext');

      // 1. Basic String
      final lcsStr = await client.lcs('s1', 's2');
      expect(lcsStr, equals('mytext'));

      // 2. Length only
      final lcsLen = await client.lcs('s1', 's2', len: true);
      expect(lcsLen, equals(6));
    });

    test('DELIFEQ', () async {
      const key = 'lock';
      await client.set(key, 'secret');

      // 1. Wrong value -> 0
      final res1 = await client.delIfEq(key, 'wrong');
      expect(res1, equals(0));
      expect(await client.get(key), equals('secret'));

      // 2. Correct value -> 1
      final res2 = await client.delIfEq(key, 'secret');
      expect(res2, equals(1));
      expect(await client.get(key), isNull);
    });
  });
}
