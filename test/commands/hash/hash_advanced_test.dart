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
  group('Hash Commands - Advanced & Expiration', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close(); // disconnect();
    });

    test('HEXPIRE & HTTL - Field expiration (Seconds)', () async {
      await client.hSet('session', {'token': 'abc', 'data': 'xyz'});

      // Set expiration for 'token' field to 100 seconds
      final result = await client.hExpire('session', 100, fields: ['token']);
      expect(result, equals([1])); // 1 = set successfully

      final ttl = await client.hTtl('session', ['token', 'data']);
      // token should have TTL approx 100, data should be -1 (no expiry)
      expect(ttl[0], inInclusiveRange(90, 100));
      expect(ttl[1], equals(-1));
    });

    test('HPEXPIRE & HPTTL - Field expiration (Milliseconds)', () async {
      await client.hSet('cache', {'img': 'binary'});

      // Set expiration to 5000ms (5s)
      await client.hPExpire('cache', 5000, fields: ['img']);

      final pttl = await client.hPTtl('cache', ['img']);
      expect(pttl[0], inInclusiveRange(4000, 5000));
    });

    test('HEXPIREAT & HEXPIRETIME - Timestamp based', () async {
      await client.hSet('event', {'start': 'now'});

      // Expire at specific timestamp (future)
      final futureTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      await client.hExpireAt('event', futureTime, fields: ['start']);

      final expireTime = await client.hExpireTime('event', ['start']);
      expect(expireTime[0], equals(futureTime));
    });

    test('HPERSIST - Remove expiration', () async {
      await client.hSet('temp', {'key': 'val'});
      await client.hExpire('temp', 100, fields: ['key']);

      // Ensure TTL exists
      expect((await client.hTtl('temp', ['key']))[0], greaterThan(0));

      // Persist
      final result = await client.hPersist('temp', ['key']);
      expect(result, equals([1]));

      // Ensure TTL is gone (-1)
      expect((await client.hTtl('temp', ['key']))[0], equals(-1));
    });

    test('HGETEX - Get values and set field expiration', () async {
      const key = 'test:hgetex';

      // 1. Setup: Create hash data using Map
      await client.hSet(key, {
        'field1': 'value1',
        'field2': 'value2',
        'field3': 'value3', // This field will not be touched by HGETEX
      });

      // 2. Execute HGETEX
      // Retrieve 'field1' and 'field2', and set their TTL to 10 seconds.
      // 'missing_field' does not exist, so it should return null.
      final values = await client.hGetEx(
        key,
        ['field1', 'field2', 'missing_field'],
        ex: 10,
      );

      // 3. Verify Return Values (Should behave like HMGET)
      expect(values, isA<List>());
      expect(values.length, equals(3));
      expect(values[0], equals('value1'));
      expect(values[1], equals('value2'));
      expect(values[2], isNull);

      // 4. Verify TTL (Check if expiration was applied correctly)
      final ttls = await client.hTtl(key, ['field1', 'field2', 'field3']);

      // field1: Should have a TTL set (between 0 and 10 seconds)
      expect(ttls[0], greaterThan(0));
      expect(ttls[0], lessThanOrEqualTo(10));

      // field2: Should have a TTL set
      expect(ttls[1], greaterThan(0));

      // field3: Was not included in HGETEX, so it should not have a TTL (-1)
      expect(ttls[2], equals(-1));
    });

    test('HGETEX - Get and set expiry 1', () async {
      // 1. Setup: Set initial data
      await client.hSet('otp', {'code': '1234'});

      // 2. Execute HGETEX
      // Get 'code' field and set TTL to 60 seconds.
      // Even if we request a single field, the result is returned as a List.
      final val = await client.hGetEx('otp', ['code'], ex: 60);

      // 3. Verify Value
      expect(val, equals(['1234']));

      // 4. Verify TTL
      final ttl = await client.hTtl('otp', ['code']);

      // The TTL should be set (approx 60s)
      expect(ttl[0], greaterThan(0));
      expect(ttl[0], lessThanOrEqualTo(60));
    });

    test('HGETEX - Get and set expiry 2', () async {
      // await client.hSet('otp', {'code': '1234'});
      await client.hSet('otp', {'code': 1234});

      // final res = await client.hGet('otp', 'code');
      final res = await client.hGetEx('otp', ['code'], ex: 60);

      expect(res, equals(['1234']));

      // Get value and set TTL to 60s
      final val = await client.hGetEx('otp', ['code'], ex: 60);
      expect(val, equals(['1234']));

      final ttl = await client.hTtl('otp', ['code']);
      expect(ttl[0], inInclusiveRange(50, 60));
    });

    test('HSETEX - Set value and expiry (Helper)', () async {
      // HSETEX is a helper extension command
      final success = await client.hSetEx('auth', 10, 'token', 'secret');
      expect(success, isTrue);

      final val = await client.hGet('auth', 'token');
      expect(val, equals('secret'));

      final ttl = await client.hTtl('auth', ['token']);
      expect(ttl[0], inInclusiveRange(1, 10));
    });

    test('HRANDFIELD - Random fields', () async {
      await client.hSet('colors', {'r': 'red', 'g': 'green', 'b': 'blue'});

      // 1. Single random field
      final single = await client.hRandField('colors');
      expect(single, isA<String>());

      // 2. Multiple random fields (Keys only)
      final multiple = await client.hRandField('colors', count: 2);
      expect(multiple, isA<List>());
      expect((multiple as List).length, equals(2));

      // 3. Multiple random fields (With values)
      final withValues =
          await client.hRandField('colors', count: 2, withValues: true);
      expect(withValues, isA<Map<String, String>>());
      expect((withValues as Map).length, equals(2));
    });

    test('HSCAN - Iterate fields', () async {
      // Setup: Add multiple fields
      final data = <String, String>{};
      for (var i = 0; i < 10; i++) {
        data['key$i'] = 'val$i';
      }
      await client.hSet('big_hash', data);

      // Scan
      final result = await client.hScan('big_hash', '0', count: 5);

      expect(result.length, equals(2));
      final cursor = result[0] as String;
      final keys = result[1] as List;

      expect(cursor, isNotNull);
      expect(keys, isNotEmpty);
      // Scan returns flat list [key, val, key, val...]
      expect(keys.length % 2, equals(0));
    });
  });
}
