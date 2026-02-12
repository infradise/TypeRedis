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

import 'package:keyscope_client/keyscope_client.dart';
import 'package:test/test.dart';

void main() {
  group('Time Series - Management & Rules', () {
    late KeyscopeClient client;

    setUp(() async {
      client = KeyscopeClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();
    });

    tearDown(() async {
      await client.disconnect();
    });

    test('TS.CREATERULE, TS.DELETERULE', () async {
      const sourceKey = 'ts:source';
      const destKey = 'ts:compacted';

      await client.tsCreate(sourceKey, forceRun: true);
      await client.tsCreate(destKey, forceRun: true);

      // 1. TS.CREATERULE
      // Create rule: Aggregate 'avg' into 5000ms buckets
      await client.tsCreateRule(sourceKey, destKey, 'avg', 5000,
          forceRun: true);

      // Verify via TS.INFO
      final info = await client.tsInfo(sourceKey, forceRun: true);
      expect(info.toString(), contains(destKey));

      // 2. TS.DELETERULE
      await client.tsDeleteRule(sourceKey, destKey, forceRun: true);

      // Verify deletion
      final infoAfter = await client.tsInfo(sourceKey, forceRun: true);
      expect(infoAfter.toString(), isNot(contains(destKey)));
    });

    test('TS.ALTER, TS.INFO, TS.QUERYINDEX', () async {
      const key = 'ts:manage';
      await client.tsCreate(key,
          options: ['LABELS', 'ver', '1'], forceRun: true);

      // 1. TS.ALTER
      // Change label
      await client.tsAlter(key,
          options: ['LABELS', 'ver', '2'], forceRun: true);

      // 2. TS.INFO
      final info = await client.tsInfo(key, forceRun: true);
      expect(info.toString(), contains('ver'));
      expect(info.toString(), contains('2'));

      // 3. TS.QUERYINDEX
      final keys = await client.tsQueryIndex(['ver=2'], forceRun: true);
      expect(keys, contains(key));
    });
  });
}
