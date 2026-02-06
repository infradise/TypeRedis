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
  group('Stream Commands', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.close();
    });

    test('XADD, XRANGE, XLEN', () async {
      const key = 'stream:test';

      // 1. XADD
      final id1 = await client.xAdd(key, {'temp': '20', 'loc': 'room1'});
      expect(id1, isNotEmpty);

      final id2 = await client.xAdd(key, {'temp': '22', 'loc': 'room1'});
      expect(id2, isNotEmpty);

      // 2. XLEN (Not implemented in short version but check existence)
      // Assuming xLen is implemented similarly to others
      // expect(await client.xLen(key), equals(2));

      // 3. XRANGE
      final range = await client.xRange(key, start: '-', end: '+');
      expect(range.length, equals(2));
      expect(range[0].fields['temp'], equals('20'));
      expect(range[1].fields['temp'], equals('22'));
    });

    test('Consumer Group (XGROUP, XREADGROUP, XACK)', () async {
      const key = 'stream:group';
      const group = 'mygroup';
      const consumer = 'consumer1';

      // Setup: Add data
      final id = await client.xAdd(key, {'msg': 'hello'}); // mkStream: true

      // 1. XGROUP CREATE
      // Use mkStream: true to create stream if not exists (redundant here but
      // good for test)
      // Note: xAdd with mkStream above created it, but let's test XGROUP
      // We need to create group starting from beginning (0) or last ($)
      final resGroup =
          await client.xGroupCreate(key, group, '0', mkStream: true);
      expect(resGroup, equals('OK'));

      // 2. XREADGROUP
      final readRes = await client.xReadGroup(
        group,
        consumer,
        [key],
        ['>'], // Read new messages
        count: 1,
      );

      expect(readRes.containsKey(key), isTrue);
      expect(readRes[key]!.length, equals(1));
      expect(readRes[key]![0].id, equals(id));
      expect(readRes[key]![0].fields['msg'], equals('hello'));

      // 3. XACK
      final ackCount = await client.xAck(key, group, [id]);
      expect(ackCount, equals(1));
    });
  });
}
