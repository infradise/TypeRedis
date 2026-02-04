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
  group('JSON.DEBUG Commands', () {
    late TRClient client;

    setUp(() async {
      client = TRClient(host: 'localhost', port: 6379);
      await client.connect();
      await client.flushAll();

      // Setup: Complex JSON data for testing
      const key = 'test:debug:data';
      const data = '{'
          '"name": "Product A", '
          '"tags": ["new", "sale", "featured"], '
          '"details": {"weight": 100, "dims": [10, 20, 30]}, '
          '"history": [{"date": "2023-01-01", "action": "created"}] '
          '}';
      await client.jsonSet(key: key, path: r'$', data: data);
    });

    tearDown(() async {
      await client.close(); // disconnect
    });

    test('JSON.DEBUG MEMORY - handles int and List return types', () async {
      const key = 'test:debug:data';

      // 1. Without path -> Returns int (Total size)
      final totalMemory = await client.jsonDebugMemory(key: key);
      expect(totalMemory, isA<int>());
      expect(totalMemory, greaterThan(0));

      // 2. With path (Recursive) -> Returns List (Size of matching elements)
      final elementMemory =
          await client.jsonDebugMemory(key: key, path: r'$..*');
      expect(elementMemory, isA<List>());
      expect((elementMemory as List).isNotEmpty, isTrue);
    });

    test('JSON.DEBUG MEMORY - handles Restricted and Enhanced syntax',
        () async {
      const key = 'test:debug:memory';
      // Data from the spec example:
      // {"firstName":"John", ... "phoneNumbers": [...]}
      const data =
          '{"firstName":"John","lastName":"Smith","age":27,"weight":135.25, '
          '"isAlive":true,"address":{"street":"21 2nd Street", '
          '"city":"New York","state":"NY","zipcode":"10021-3100"}, '
          '"phoneNumbers":[{"type":"home","number":"212 555-1234"}, '
          '{"type":"office","number":"646 555-4567"}], '
          '"children":[],"spouse":null}';

      await client.jsonSet(key: key, path: '.', data: data);

      // 1. Restricted Syntax (No path) -> Returns int
      // Expect: (integer) 632 (approximate, depends on implementation)
      final totalMem = await client.jsonDebugMemory(key: key);
      expect(totalMem, isA<int>());
      expect(totalMem, greaterThan(0));

      // 2. Restricted Syntax (Path starts with '.') -> Returns int
      // Expect: (integer) 166 (approximate)
      final phoneMem =
          await client.jsonDebugMemory(key: key, path: '.phoneNumbers');
      expect(phoneMem, isA<int>());
      expect(phoneMem, greaterThan(0));

      // 3. Enhanced Syntax (Path starts with '$') -> Returns List<int>
      // Expect: Array of integers
      final enhancedMem =
          await client.jsonDebugMemory(key: key, path: r'$..phoneNumbers');
      expect(enhancedMem, isA<List>());
      expect((enhancedMem as List).isNotEmpty, isTrue);
      expect(enhancedMem.first, isA<int>());

      // 4. Non-existent Key Behavior
      // Restricted -> null
      final missingRestricted =
          await client.jsonDebugMemory(key: 'missing_key');

      if (await client.isValkeyServer()) {
        expect(missingRestricted, isNull); // Valkey
      }
      if (await client.isRedisServer()) {
        expect(missingRestricted, 0); // Redis
      }

      // Enhanced -> Empty List
      final missingEnhanced =
          await client.jsonDebugMemory(key: 'missing_key', path: r'$');

      if (await client.isRedisServer()) {
        expect(missingEnhanced, isA<List>()); // []
        expect((missingEnhanced as List).isEmpty, isTrue);
      }
      if (await client.isValkeyServer()) {
        expect(missingEnhanced, isNull); // null
        expect((missingEnhanced as List?)?.isEmpty ?? true, isTrue);
      }
    });

    test('JSON.DEBUG FIELDS - handles int and List return types', () async {
      // Skip test if running on Redis
      if (await client.isRedisServer()) {
        markTestSkipped('Skipping: This feature is only supported on Valkey.');
        return;
      }

      const key = 'test:debug:data';

      // 1. Without path -> Returns int (Total recursive fields count)
      final rootFields = await client.jsonDebugFields(key: key);

      // {
      //   "name": "Product A",
      //   "tags": ["new", "sale", "featured"],
      //   "details": {
      //     "weight": 100,
      //     "dims": [10, 20, 30]
      //   },
      //   "history": [{"date": "2026-02-01", "action": "created"}]
      // }

      expect(rootFields, isA<int>());

      // Breakdown of the count (Total 15) based on Spec:
      // "Each container value, except the root container, counts as one
      //  additional field."
      //
      // 1. name: 1 (Primitive)
      // 2. tags: 4 (Array itself=1 + 3 elements)
      // 3. details: 6 (Object itself=1 + weight=1 + dims(Array=1 + 3 elements))
      // 4. history: 4 (Array itself=1 + Object(Self=1 + date=1 + action=1))
      // Total: 1 + 4 + 6 + 4 = 15
      //
      expect(rootFields, equals(15));
      //
      // - Root keys: 4 (name, tags, details, history)
      // - tags elements: 3
      // - details keys: 2 (weight, dims)
      // - dims elements: 3
      // - history elements: 1
      // - history[0] keys: 2 (date, action)

      // 2. With path -> Returns List (Fields count for matches)
      final detailsFields =
          await client.jsonDebugFields(key: key, path: r'$.details');
      expect(detailsFields, isA<List>());

      // Details breakdown (Total 6):
      // - The Object itself doesn't count as it's the root of this query?
      // - Wait, checking Valkey logic: returns count of fields *at* the path.
      // - Unlike root, counting a specific path includes its subtree.
      // - details: 1 (weight) + 4 (dims: self=1 + 3 elements) = 5?
      // - Let's re-verify with spec: "Objects and arrays recursively count..."
      // - If path points to 'details', it sums children.
      // - weight(1) + dims(4) = 5.
      expect((detailsFields as List).first, equals(5)); // 2 or 5

      // details object has:
      // - keys: 2 (weight, dims)
      // - dims elements: 3
      // Total: 5
    });

    test('JSON.DEBUG DEPTH', () async {
      // Skip test if running on Redis
      if (await client.isRedisServer()) {
        markTestSkipped('Skipping: This feature is only supported on Valkey.');
        return;
      }

      const key = 'test:debug:data';
      final depth = await client.jsonDebugDepth(key: key);
      expect(depth, isA<int>());
      // Root -> details -> dims -> value (Depth: 3 or 4 depending on counting)
      expect(depth, greaterThan(1));
    });

    test('JSON.DEBUG HELP', () async {
      final help = await client.jsonDebugHelp();
      // 1) "MEMORY <key> [path] - reports memory usage"
      // 2) "HELP                - this message"

      expect(help, isNotEmpty);
      expect(help, contains(contains('MEMORY')));
      expect(help, contains(contains('HELP')));
    });

    test('JSON.DEBUG Dangerous Commands (Smoke Test)', () async {
      // Skip test if running on Redis
      if (await client.isRedisServer()) {
        markTestSkipped('Skipping: This feature is only supported on Valkey.');
        return;
      }

      // These print "DANGER..." to console.
      // We just check if the command is sent successfully without client-side
      // error.

      // Note: Some of these might return 'nil' or specific internal structures
      // depending on the server state, so we just check the call completes.

      await expectLater(client.jsonDebugMaxDepthKey(), completes);
      await expectLater(client.jsonDebugMaxSizeKey(), completes);

      // For now, we don't test KEYTABLE-CORRUPT to avoid breaking the test
      // server state intentionally.
    });
  });
}
