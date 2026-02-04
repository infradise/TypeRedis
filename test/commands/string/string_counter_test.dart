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
  group('String Commands - Counters', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close(); // disconnect
    });

    test('INCR, DECR', () async {
      const key = 'cnt';

      // 1. INCR (0 -> 1)
      expect(await client.incr(key), equals(1));

      // 2. DECR (1 -> 0)
      expect(await client.decr(key), equals(0));

      // 3. DECR (0 -> -1)
      expect(await client.decr(key), equals(-1));
    });

    test('INCRBY, DECRBY', () async {
      const key = 'cnt_by';

      // 1. INCRBY
      expect(await client.incrBy(key, 10), equals(10));

      // 2. DECRBY
      expect(await client.decrBy(key, 4), equals(6));
    });

    test('INCRBYFLOAT', () async {
      const key = 'cnt_float';

      // 1. Initial float
      final val1 = await client.incrByFloat(key, 10.5);
      expect(val1, equals(10.5));

      // 2. Add float
      final val2 = await client.incrByFloat(key, 0.1);
      // Floating point comparison
      expect(val2, closeTo(10.6, 0.0001));

      // 3. Verify string storage
      expect(await client.get(key), equals('10.6'));
    });
  });
}
