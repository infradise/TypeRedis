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
  group('Hash Commands - Basic & Standard', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close(); // disconnect();
    });

    test('HSET & HGET - Set and retrieve fields', () async {
      final count =
          await client.hSet('user:100', {'name': 'Alice', 'age': '30'});
      expect(count, equals(2));

      final name = await client.hGet('user:100', 'name');
      final age = await client.hGet('user:100', 'age');
      final missing = await client.hGet('user:100', 'email');

      expect(name, equals('Alice'));
      expect(age, equals('30'));
      expect(missing, isNull);
    });

    test('HSETNX - Set field only if not exists', () async {
      // 1. Set initial value
      await client.hSet('config', {'mode': 'dark'});

      // 2. Try to set existing field (Should fail)
      final result1 = await client.hSetNx('config', 'mode', 'light');
      expect(result1, isFalse);
      expect(await client.hGet('config', 'mode'), equals('dark'));

      // 3. Set new field (Should succeed)
      final result2 = await client.hSetNx('config', 'volume', '50');
      expect(result2, isTrue);
      expect(await client.hGet('config', 'volume'), equals('50'));
    });

    test('HMSET & HMGET', () async {
      if (await client.isRedisServer()) {
        await client.hMSet('vehicle:1', {'type': 'car', 'brand': 'Tesla'});
        //
      }
      if (await client.isValkeyServer()) {
        await client.hMSet('vehicle:1', {'type': 'car', 'brand': 'Tesla'});
      }

      final values = await client.hMGet('vehicle:1', ['type', 'brand', 'year']);
      expect(values, equals(['car', 'Tesla', null]));
    });

    test('HDEL & HEXISTS', () async {
      await client.hSet('cart:1', {'item1': 'apple', 'item2': 'banana'});

      final existsBefore = await client.hExists('cart:1', 'item1');
      expect(existsBefore, isTrue);

      final deletedCount = await client.hDel('cart:1', ['item1', 'item99']);
      expect(deletedCount, equals(1)); // Only item1 existed

      final existsAfter = await client.hExists('cart:1', 'item1');
      expect(existsAfter, isFalse);
    });

    test('HLEN & HSTRLEN', () async {
      await client.hSet('msg:1', {'title': 'Hello', 'body': 'World'});

      final len = await client.hLen('msg:1');
      expect(len, equals(2));

      final strLen = await client.hStrLen('msg:1', 'title');
      expect(strLen, equals(5)); // 'Hello'.length

      final missingStrLen = await client.hStrLen('msg:1', 'missing');
      expect(missingStrLen, equals(0));
    });

    test('HINCRBY & HINCRBYFLOAT', () async {
      await client.hSet('stats', {'views': '10', 'temperature': '25.5'});

      final newViews = await client.hIncrBy('stats', 'views', 5);
      expect(newViews, equals(15));

      final newTemp = await client.hIncrByFloat('stats', 'temperature', 1.5);
      expect(newTemp, equals(27.0));
    });

    test('HKEYS, HVALS, HGETALL', () async {
      await client.hSet('dict', {'a': '1', 'b': '2'});

      final keys = await client.hKeys('dict');
      expect(keys, containsAll(['a', 'b']));

      final vals = await client.hVals('dict');
      expect(vals, containsAll(['1', '2']));

      final all = await client.hGetAll('dict');
      expect(all, equals({'a': '1', 'b': '2'}));
    });
  });
}
