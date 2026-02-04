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
  group('String Commands - Basic', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close(); // disconnect
    });

    test('SET, GET, STRLEN, APPEND', () async {
      const key = 'test:string:basic';

      // 1. SET & GET
      expect(await client.set(key, 'Hello'), equals('OK'));
      expect(await client.get(key), equals('Hello'));

      // 2. STRLEN
      expect(await client.strLen(key), equals(5));

      // 3. APPEND
      final newLen = await client.append(key, ' World');
      expect(newLen, equals(11));
      expect(await client.get(key), equals('Hello World'));

      // 4. Missing Key
      expect(await client.get('missing'), isNull);
      expect(await client.strLen('missing'), equals(0));
    });

    test('MSET, MGET', () async {
      final data = {'k1': 'v1', 'k2': 'v2'};

      // 1. MSET
      expect(await client.mSet(data), equals('OK'));

      // 2. MGET
      final values = await client.mGet(['k1', 'missing', 'k2']);
      expect(values, equals(['v1', null, 'v2']));
    });

    test('GETRANGE, SETRANGE, SUBSTR', () async {
      const key = 'test:string:range';
      await client.set(key, 'Hello World');

      // 1. GETRANGE (indices are inclusive)
      expect(await client.getRange(key, 0, 4), equals('Hello'));
      expect(await client.getRange(key, -5, -1), equals('World'));

      // 2. SUBSTR (Deprecated alias)
      expect(await client.subStr(key, 0, 4), equals('Hello'));

      // 3. SETRANGE
      // "Hello World" -> "Hello Redis"
      final len = await client.setRange(key, 6, 'Redis');
      expect(len, equals(11));
      expect(await client.get(key), equals('Hello Redis'));
    });

    test('GETSET, GETDEL', () async {
      const key = 'test:string:getmod';
      await client.set(key, 'A');

      // 1. GETSET
      final old = await client.getSet(key, 'B');
      expect(old, equals('A'));
      expect(await client.get(key), equals('B'));

      // 2. GETDEL
      final deleted = await client.getDel(key);
      expect(deleted, equals('B'));
      expect(await client.get(key), isNull);
    });
  });
}
